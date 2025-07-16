import 'package:flutter/material.dart';
import 'package:frontend/pages/DiaryPage/BallonBubble.dart';
import 'package:intl/intl.dart';
import 'package:frontend/components/Calendar/CustomWeekCalendar.dart';
import 'package:frontend/constants/colors.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  static const int totalPages = 10000;
  static const int centerPage = totalPages ~/ 2;

  final PageController _pageController = PageController(
    initialPage: centerPage,
    viewportFraction: 0.85,
  );

  int _currentPage = centerPage;
  String? editingDateKey;
  String? balloonDateKey;

  final Map<String, TextEditingController> contentControllers = {};
  final Map<String, TextEditingController> emojiControllers = {};

  final List<String> emojis = [
    '☺️',
    '🙂',
    '😑',
    '🥰',
    '😨',
    '🥵',
    '😢',
    '😭',
    '😵‍💫',
    '🫥',
    '🤑',
    '😤',
    '🤒',
    '😇',
    '🤫',
    '😡',
    '🤬',
    '🤢',
    '🥹',
    '🫨',
    '🥸',
    '💗',
    '💩',
    '💢',
    '🍀',
  ];

  final Map<String, Map<String, dynamic>> diaryMap = {
    '2025.07.11': {'emoji': '😄', 'content': '주말 시작!'},
    '2025.07.13': {'emoji': '🙂', 'content': '어제는 날씨가 좋았어요.'},
    '2025.07.14': {'emoji': '😐', 'content': '조금 지쳤지만 잘 버텼어요.'},
  };

  late final DateTime baseDate;

  @override
  void initState() {
    super.initState();
    baseDate = DateTime.now();
  }

  String formatDate(DateTime date) => DateFormat('yyyy.MM.dd').format(date);
  String getWeekday(DateTime date) => DateFormat('EEEE').format(date);

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final int maxIndex = centerPage + today.difference(baseDate).inDays;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: CustomWeekCalendar(
              onDateSelected: (selectedDate) {
                final int selectedIndex =
                    centerPage + selectedDate.difference(baseDate).inDays;
                if (selectedIndex <= maxIndex) {
                  _pageController.animateToPage(
                    selectedIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentPage = selectedIndex);
                }
              },
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 360,
            child: PageView.builder(
              controller: _pageController,
              itemCount: maxIndex + 1,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final date = baseDate.add(Duration(days: index - centerPage));
                final dateKey = formatDate(date);
                final weekday = getWeekday(date);
                final diary = diaryMap[dateKey];
                final originalContent = diary?['content'] ?? '';
                final originalEmoji = diary?['emoji'] ?? '';

                contentControllers.putIfAbsent(
                  dateKey,
                  () => TextEditingController(text: originalContent),
                );
                emojiControllers.putIfAbsent(
                  dateKey,
                  () => TextEditingController(text: originalEmoji),
                );

                final contentController = contentControllers[dateKey]!;
                final emojiController = emojiControllers[dateKey]!;

                final isCurrent = index == _currentPage;
                final isEditing = editingDateKey == dateKey;
                final isSubmitEnabled =
                    contentController.text.trim().isNotEmpty &&
                    emojiController.text.trim().isNotEmpty;

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isCurrent ? 1.0 : 0.4,
                  child: Transform.scale(
                    scale: isCurrent ? 1.0 : 0.95,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => editingDateKey = dateKey),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13.5),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFF2E9DA),
                                  offset: Offset(0, 4),
                                  blurRadius: 12.9,
                                ),
                              ],
                            ),
                            width: 312,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateKey,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: SubTextColor,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Text(
                                          weekday,
                                          style: const TextStyle(
                                            color: Color(0xFF989898),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (isEditing) {
                                          setState(() {
                                            balloonDateKey =
                                                balloonDateKey == dateKey
                                                ? null
                                                : dateKey;
                                          });
                                        }
                                      },
                                      child: emojiController.text.isEmpty
                                          ? Container(
                                              width: 50,
                                              height: 50,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFE1DDD4),
                                              ),
                                              child: const Icon(
                                                Icons.add_rounded,
                                                size: 25,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              emojiController.text,
                                              style: const TextStyle(
                                                fontSize: 50,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: isEditing
                                      ? Column(
                                          children: [
                                            Transform.translate(
                                              offset: const Offset(0, -10),
                                              child: TextField(
                                                controller: contentController,
                                                maxLines: null,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          '일기 내용을 입력하세요...',
                                                      hintStyle: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(
                                                          0xFFA6A6A6,
                                                        ),
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF1F1F1F),
                                                  height: 1.8,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      contentController.text =
                                                          originalContent;
                                                      emojiController.text =
                                                          originalEmoji;
                                                      editingDateKey = null;
                                                      balloonDateKey = null;
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Color(0xFFE1DDD4),
                                                    size: 25,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: isSubmitEnabled
                                                      ? () {
                                                          setState(() {
                                                            diaryMap[dateKey] = {
                                                              'emoji':
                                                                  emojiController
                                                                      .text,
                                                              'content':
                                                                  contentController
                                                                      .text,
                                                            };
                                                            editingDateKey =
                                                                null;
                                                            balloonDateKey =
                                                                null;
                                                          });
                                                        }
                                                      : null,
                                                  child: Icon(
                                                    Icons.check,
                                                    color: isSubmitEnabled
                                                        ? const Color(
                                                            0xFFE1DDD4,
                                                          )
                                                        : const Color.fromARGB(
                                                            255,
                                                            243,
                                                            240,
                                                            240,
                                                          ),
                                                    size: 25,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : (originalContent.isEmpty
                                            ? const Center(
                                                child: Text(
                                                  '화면을 탭하여\n오늘의 일기를 작성해주세요 ✍️',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFFBBBBBB),
                                                  ),
                                                ),
                                              )
                                            : SingleChildScrollView(
                                                child: Text(
                                                  originalContent,
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF1F1F1F),
                                                    height: 1.8,
                                                  ),
                                                ),
                                              )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isEditing && balloonDateKey == dateKey)
                          Positioned(
                            top: 60,
                            right: 0,
                            left: 0,
                            child: Center(
                              child: BalloonBubble(
                                child: Wrap(
                                  spacing: 20,
                                  runSpacing: 10,
                                  children: emojis.map((e) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          emojiController.text = e;
                                          balloonDateKey = null;
                                        });
                                      },
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: emojiController.text == e
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          decoration: emojiController.text == e
                                              ? TextDecoration.underline
                                              : null,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
