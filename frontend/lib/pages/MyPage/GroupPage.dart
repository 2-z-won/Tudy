import 'package:flutter/material.dart';
import 'package:frontend/api/Group/controller/AddGroupController.dart';
import 'package:frontend/api/Group/controller/GroupController.dart';
import 'package:frontend/api/Group/controller/JoinGroupController.dart';
import 'package:frontend/api/Group/model/AddGroupModel.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/JoinAddFindfield.dart';
import 'package:frontend/components/bottomNavigation/GroupFriend/GroupList.dart';
import 'package:frontend/constants/colors.dart';
import 'package:flutter/services.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController _groupJoinController = TextEditingController();
  final GroupController _groupAddController = Get.put(GroupController());
  final JoinGroupController _joinGroupController = Get.put(
    JoinGroupController(),
  );
  final MyGroupController _myGroupController = Get.put(MyGroupController());

  String? userId; // 🔹 로그인된 유저 아이디

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final uid = await getUserIdFromStorage(); // utils/auth_util.dart 함수
    setState(() {
      userId = uid;
    });

    if (uid != null) {
      _myGroupController.fetchMyGroups(uid);
    }
  }

  void _onCreateGroup(String name, String password, String ownerId) {
    final newGroup = AddGroup(name: name, password: password, ownerId: ownerId);
    _groupAddController.createGroup(newGroup);
  }

  @override
  void dispose() {
    _groupAddController.dispose();
    super.dispose();
  }

  int? selectedGroupId;

  void onJoin() async {
    final groupName = _groupJoinController.text.trim();
    if (groupName.isEmpty || userId == null) return;

    final groupId = await _joinGroupController.searchGroupIdByName(groupName);
    if (groupId == null) {
      showMessage("error", "존재하지 않는 그룹입니다.");
      return;
    }

    // 그룹 존재 → 비밀번호 입력창 열기
    setState(() {
      selectedGroupId = groupId;
      message = "password";
    });
  }

  void onEnter() async {
    if (selectedGroupId == null) {
      showMessage("error", "그룹을 먼저 선택하세요.");
      return;
    }
    if (userId == null) {
      showMessage("error", "로그인을 다시 해주세요");
      return;
    }

    final password = _digitControllers.map((c) => c.text).join();

    await _joinGroupController.joinGroup(
      groupId: selectedGroupId!,
      userId: userId!,
      password: password,
    );

    showMessage(
      _joinGroupController.messageType.value,
      _joinGroupController.message.value,
    );

    if (_joinGroupController.messageType.value == "success" ||
        _joinGroupController.messageType.value == "error") {
      setState(() {
        messageType = "";
        message = "";
        selectedGroupId = null;
        _groupJoinController.clear();
        for (var c in _digitControllers) {
          c.clear();
        }
      });
    }
  }

  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String messageType = ""; // "success", "error"
  String message = "";

  void showMessage(String type, String msg) {
    setState(() {
      messageType = type;
      message = msg;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          messageType = "";
          message = "";
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
                    "그룹",
                    style: TextStyle(fontSize: 14, color: SubTextColor),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Divider(height: 1, color: Color(0xFFF4EBEB)),
              ),

              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    JoinAddField(
                      hinttext: "그룹명을 입력하세요",
                      button: "JOIN",
                      controller: _groupJoinController,
                      onJoin: onJoin,
                      onEnter: onEnter,
                      messageType: messageType,
                      message: message,
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: const Divider(height: 1, color: Color(0xFFF4EBEB)),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          "👥 나의 그룹",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Obx(() {
                      if (_myGroupController.myGroups.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "가입된 그룹이 없습니다",
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      }

                      return Column(
                        children: _myGroupController.myGroups.map((group) {
                          return GroupDropdownCard(
                            title: group.name,
                            groupId: group.id,
                          );
                        }).toList(),
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
                  Positioned(
                    right: 15,
                    top: 15,
                    child: GestureDetector(
                      onTap: _showCreateGroupDialog, // 👈 이 함수 연결
                      child: Icon(
                        Icons.add_rounded,
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

  void _showCreateGroupDialog() {
    TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(110, 110, 110, 0.2),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 340,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 12.9,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "그룹 생성",
                      style: TextStyle(
                        fontSize: 13,
                        color: SubTextColor,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFE1DDD4)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: TextField(
                        controller: groupNameController,
                        onChanged: (_) => setState(() {}),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "그룹명을 입력하세요",
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA6A6A6),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "PASSWORD",
                      style: TextStyle(
                        fontSize: 13,
                        color: SubTextColor,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 35,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E5),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Color(0xFFE1DDD4)),
                          ),
                          child: TextField(
                            controller: _digitControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: TextColor,
                            ),
                            decoration: const InputDecoration(
                              counterText: "", // 글자 수 제거
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {});
                              if (value.isNotEmpty) {
                                if (index < 5) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_focusNodes[index + 1]);
                                } else {
                                  FocusScope.of(
                                    context,
                                  ).unfocus(); // 마지막 입력 후 키보드 닫기
                                }
                              } else if (index > 0) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_focusNodes[index - 1]);
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 18),

                    (groupNameController.text.trim().isNotEmpty &&
                            _digitControllers.every(
                              (c) => c.text.trim().isNotEmpty,
                            ))
                        ? GestureDetector(
                            onTap: () {
                              final groupName = groupNameController.text.trim();
                              final password = _digitControllers
                                  .map((c) => c.text)
                                  .join();
                              _onCreateGroup(groupName, password, userId!);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "완료",
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    (groupNameController.text
                                            .trim()
                                            .isNotEmpty &&
                                        _digitControllers.every(
                                          (c) => c.text.trim().isNotEmpty,
                                        ))
                                    ? SubTextColor
                                    : Colors.grey,
                                letterSpacing: 2.0,
                              ),
                            ),
                          )
                        : const SizedBox(height: 0),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
