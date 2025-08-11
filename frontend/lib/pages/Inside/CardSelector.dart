// 파일명: study_room_selector.dart
import 'package:flutter/material.dart';

class StudyRoomSelector extends StatelessWidget {
  final String? selectedCardName;
  final void Function(String?) onCardTap;

  StudyRoomSelector({
    required this.onCardTap,
    required this.selectedCardName,
    super.key,
  });

  final List<Map<String, dynamic>> rooms = [
    {'name': '1', 'image': 'images/profile.jpg', 'locked': false},
    {'name': '2', 'image': 'images/profile.jpg', 'locked': false},
    {'name': '3', 'image': 'images/profile.jpg', 'locked': false},
    {'name': '4', 'image': 'images/profile.jpg', 'locked': false},
    {'name': '5', 'image': 'images/profile.jpg', 'locked': false},
  ];

  // final List<Map<String, dynamic>> rooms = [
  //   {'name': '학과사무실', 'image': 'images/profile.jpg', 'locked': false},
  //   {
  //     'name': '과방',
  //     'image': 'images/profile.jpg',
  //     'locked': true,
  //     'price': 1000,
  //   },
  //   {'name': '강의실', 'image': 'images/profile.jpg', 'locked': false},
  //   {'name': '학과사무실', 'image': 'images/profile.jpg', 'locked': false},
  //   {
  //     'name': '과방',
  //     'image': 'images/profile.jpg',
  //     'locked': true,
  //     'price': 1000,
  //   },
  //   {'name': '강의실', 'image': 'images/profile.jpg', 'locked': false},
  // ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rooms.map((room) {
        return Transform.translate(
          offset: room['name'] == selectedCardName
              ? Offset(0, -6)
              : Offset.zero,
          child: GestureDetector(
            onTap: () {
              if (room['name'] == selectedCardName) {
                onCardTap(null); // 🔸 같은 카드 다시 누르면 선택 해제
              } else {
                onCardTap(room['name']); // 🔸 다른 카드 선택
              }
            },
            child: _buildRoomCard(room),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 85,
                height: 90,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 156, 131, 111),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: RoomCard(room['image']),
              ),
              if (room['locked']) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 81,
                      height: 86,
                      padding: EdgeInsets.only(top: 22),
                      decoration: BoxDecoration(
                        color: Color(0xFF433123).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 28),
                          Text(
                            '${room['price']}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            room['name'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ), //폰트 바꾸고는 14로 조정해야함
          ),
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String imagePath;

  const RoomCard(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 81,
      height: 86,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF1F1E1B), width: 1.5),
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}

class ShadowContainer extends StatelessWidget {
  final double width;

  const ShadowContainer({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 125,
      decoration: const BoxDecoration(
        color: Color(0xFF312316),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final double width;
  final Widget child;

  const CardContainer({super.key, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 128,
      padding: const EdgeInsets.only(top: 12, left: 12, bottom: 7),
      decoration: const BoxDecoration(
        color: Color(0xFF85664A),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: child,
      ),
    );
  }
}
