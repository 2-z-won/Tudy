import 'package:flutter/material.dart';
import 'package:frontend/api/Friend/controller/AddFriendController.dart';
import 'package:frontend/api/Friend/controller/AddListController.dart';
import 'package:frontend/api/Friend/controller/FriendListController.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:frontend/components/GroupFriend/FriendList.dart';
import 'package:frontend/components/GroupFriend/GroupFriendItem.dart';
import 'package:frontend/components/GroupFriend/JoinAddFindfield.dart';
import 'package:frontend/components/GroupFriend/GroupList.dart';
import 'package:frontend/constants/colors.dart';

class Friendpage extends StatefulWidget {
  const Friendpage({super.key});

  @override
  State<Friendpage> createState() => _GroupPageState();
}

class _GroupPageState extends State<Friendpage> {
  final TextEditingController _friendAddController = TextEditingController();
  final FriendAddListController _requestController = Get.put(
    FriendAddListController(),
  );
  final FriendListController _friendListcontroller = Get.put(
    FriendListController(),
  );

  String? userId; // 🔹 로그인된 유저 아이디

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final uid = await getUserIdFromStorage(); // utils/auth_util.dart 함수
    print('🔍 FriendPage - 로드된 userId: $uid');
    
    setState(() {
      userId = uid;
    });
    
    print('🔍 FriendPage - 친구 신청 목록 조회 시작');
    await _requestController.fetchRequests(uid!);
    print('🔍 FriendPage - 친구 목록 조회 시작');
    await _friendListcontroller.fetchFriendsAndGoals(uid);
  }

  @override
  void dispose() {
    _friendAddController.dispose();
    super.dispose();
  }

  String messageType = '';
  String message = '';
  void onJoin() async {
    final toUserId = _friendAddController.text.trim();
    if (toUserId.isEmpty) return;

    await FriendAddRequestController.sendFriendRequest(
      userId: userId!,
      toUserId: toUserId,
    );

    setState(() {
      if (FriendAddRequestController.successMessage.value.isNotEmpty) {
        messageType = 'success';
        message = FriendAddRequestController.successMessage.value;
        _friendAddController.clear();
      } else {
        messageType = 'error';
        message = FriendAddRequestController.errorMessage.value;
      }
    });

    // 2초 후 메시지 초기화
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          messageType = '';
          message = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🟨 메인 콘텐츠
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 45,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "친구",
                    style: TextStyle(fontSize: 14, color: SubTextColor),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Divider(height: 1, color: Color(0xFFF4EBEB)),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    JoinAddField(
                      hinttext: "친구명을 입력하세요",
                      button: "SEND",
                      controller: _friendAddController,
                      onJoin: onJoin,
                      messageType: messageType,
                      message: message,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: const Divider(height: 1, color: Color(0xFFF4EBEB)),
                    ),
                    CardContainer(
                      title: "✉️ 친구 신청 목록 ✉️",
                      child: Obx(() {
                        final requests = _requestController.requests;
                        if (requests.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "친구 신청 목록이 없습니다!",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA9A9A9),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: requests.map((request) {
                            final fromUser = request.fromUser;
                            return JoinRequestRow(
                              name: fromUser['name'] ?? '이름 없음',
                              imageAsset: 'assets/profile.jpg', // 이미지 경로 수정 가능
                              onApprove: () async {
                                await _requestController.approveRequest(
                                  request.id,
                                  userId!,
                                );
                              },
                              onReject: () async {
                                await _requestController.rejectRequest(
                                  request.id,
                                  userId!,
                                );
                              },
                            );
                          }).toList(),
                        );
                      }),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: const Divider(height: 1, color: Color(0xFFF4EBEB)),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "👥 나의 친구",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Obx(() {
                      if (_friendListcontroller.friendList.isEmpty) {
                        return Text("친구 목록이 비어있습니다");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _friendListcontroller.friendList.length,
                        itemBuilder: (context, index) {
                          final friend =
                              _friendListcontroller.friendList[index];
                          return FriendDropdownCard(
                            name: friend.name,
                            imageUrl: friend.profileImage,
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          // 🟩 상단 앱바 스타일 커스텀
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 45,
              child: Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 15,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
