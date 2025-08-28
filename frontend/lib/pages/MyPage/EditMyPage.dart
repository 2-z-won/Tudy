import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/utils/auth_util.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/api/Mypage/editMypageController.dart';

class EditMypageView extends StatefulWidget {
  const EditMypageView({super.key});

  @override
  State<EditMypageView> createState() => _EditMypageViewState();
}

class _EditMypageViewState extends State<EditMypageView> {
  String? editingField;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController deptController = TextEditingController();

  late String selectedCollege;
  late final EditMypageController c;
  late String oldName, oldMajor, oldCollege, initPw;
  late String oldBirth;

  final List<String> colleges = [
    '치의학전문대학원',
    '한의학전문대학원',
    '인문대학',
    '사회과학대학',
    '자연과학대학',
    '공과대학',
    '법과대학',
    '사범대학',
    '상과대학',
    '약학대학',
    '의과대학',
    '치과대학',
    '예술대학',
    '학부대학',
    '스포츠과학부',
    '관광컨벤션학부',
    '나노과학기술대학',
    '생명자원과학대학',
    '간호대학',
    '경영대학',
    '생활과학대학',
    '경제통상대학',
    '이공대학',
    '사회문화대학',
    '정보의생명공학대학',
    '부속기관',
    '부속연구소',
  ];

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  DateTime? _parseDotDate(String s) {
    final m = RegExp(r'^(\d{4})\.(\d{2})\.(\d{2})$').firstMatch(s.trim());
    if (m == null) return null;
    final y = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final d = int.parse(m.group(3)!);
    final dt = DateTime(y, mo, d);
    //비유효 날짜 방지
    final ok = dt.year == y && dt.month == mo && dt.day == d;
    return ok ? dt : null;
  }

  String _formatDot(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}.${two(dt.month)}.${two(dt.day)}';
  }

  bool _isValidBirthDot(String s) {
    final dt = _parseDotDate(s);
    if (dt == null) return false;

    final today = DateTime.now();
    if (dt.isAfter(DateTime(today.year, today.month, today.day))) return false;
    if (dt.year < 1900) return false;
    return true;
  }

  Future<void> _pickBirthByCalendar() async {
    final now = DateTime.now();
    final first = DateTime(1900, 1, 1);
    final last = DateTime(now.year, now.month, now.day);

    final current = _parseDotDate(birthController.text) ?? last;
    final init = (current.isBefore(first) || current.isAfter(last))
        ? last
        : current;

    final selected = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
      helpText: '생일 선택',
      cancelText: '취소',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (selected != null) {
      setState(() {
        birthController.text = _formatDot(selected); // YYYY.MM.DD로 표기
      });
    }
  }

  @override
  void initState() {
    super.initState();

    c = Get.put(EditMypageController());

    final args = (Get.arguments ?? {}) as Map<String, dynamic>;
    nameController.text = (args['name']?.toString() ?? '');
    emailController.text = (args['email']?.toString() ?? '');
    // userId를 idController에 설정
    final userIdValue = args['userId']?.toString() ?? args['id']?.toString() ?? '';
    idController.text = userIdValue;
    print('🔍 EditMyPage - 설정된 userId: $userIdValue');
    print('🔍 EditMyPage - 전체 args: $args');
    pwController.text = (args['password']?.toString() ?? '');
    birthController.text = (args['birth']?.toString() ?? '');
    deptController.text = (args['department']?.toString() ?? '');
    final argCollege = args['college']?.toString();
    selectedCollege = (argCollege != null && colleges.contains(argCollege))
        ? argCollege
        : colleges.first;

    oldName = nameController.text.trim();
    oldMajor = deptController.text.trim();
    oldCollege = selectedCollege;
    initPw = pwController.text.trim();
    oldBirth = birthController.text.trim();

    final parsed =
        _parseDotDate(oldBirth) ?? _parseDotDate(oldBirth.replaceAll('-', '.'));
    if (parsed != null) {
      final dot = _formatDot(parsed);
      birthController.text = dot;
      oldBirth = dot;
    }

    loadUserId();
  }

  String? userId;
  Future<void> loadUserId() async {
    final uid = await getUserIdFromStorage();
    if (uid == null) {
      print('❌ 저장된 사용자 ID가 없습니다.');
      return;
    }
    setState(() => userId = uid);
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    pwController.dispose();
    emailController.dispose();
    birthController.dispose();
    deptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 40),
                color: const Color(0xFF2353A6),
                height: 110,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "학  생  증",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() => editingField = null);
                  },
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Spacer(),
                        buildInputField("NAME", nameController),
                        buildInputField("ID", idController, editable: false),
                        buildInputField(
                          "Password",
                          pwController,
                          obscureText: true,
                        ),
                        buildInputField(
                          "E-mail",
                          emailController,
                          editable: false,
                        ),
                        buildBirthField(),
                        buildDropdown("단과대", colleges, selectedCollege, (val) {
                          setState(() => selectedCollege = val!);
                        }),
                        buildInputField("학과/학부", deptController),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 25,
                                ),
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(() => editingField = null);
                                Get.back();
                              },
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                  color: SubTextColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (userId == null) {
                                  Get.snackbar('오류', '로그인이 필요합니다.');
                                  return;
                                }

                                final futures = <Future<bool>>[];

                                String onlyDigits(String s) =>
                                    s.replaceAll(RegExp(r'[^0-9]'), '');
                                String normalizeDot(String s) {
                                  final dt =
                                      _parseDotDate(s) ??
                                      _parseDotDate(s.replaceAll('-', '.'));
                                  return dt == null ? s.trim() : _formatDot(dt);
                                }

                                final inputRaw = birthController.text.trim();
                                final newBirth = normalizeDot(inputRaw);
                                final oldBirthNorm = normalizeDot(oldBirth);
                                /*print(
                                  '[BIRTH] input="$inputRaw" -> normalized="$newBirth", old="$oldBirthNorm"',
                                );*/

                                if (onlyDigits(newBirth) !=
                                    onlyDigits(oldBirthNorm)) {
                                  if (!_isValidBirthDot(newBirth)) {
                                    Get.snackbar(
                                      '형식 오류',
                                      '생일은 YYYY.MM.DD 형식으로 선택/입력해 주세요.',
                                    );
                                    return;
                                  }

                                  futures.add(
                                    c.updateBirth(
                                      userId: userId!,
                                      birthDate: newBirth,
                                      bodyKey: 'birth',
                                    ),
                                  );
                                }

                                if (nameController.text.trim() != oldName) {
                                  futures.add(
                                    c.updateName(
                                      userId: userId!,
                                      name: nameController.text.trim(),
                                    ),
                                  );
                                }
                                if (deptController.text.trim() != oldMajor) {
                                  futures.add(
                                    c.updateMajor(
                                      userId: userId!,
                                      major: deptController.text.trim(),
                                    ),
                                  );
                                }
                                if (selectedCollege != oldCollege) {
                                  futures.add(
                                    c.updateCollege(
                                      userId: userId!,
                                      college: selectedCollege,
                                    ),
                                  );
                                }

                                if (futures.isEmpty) {
                                  Get.snackbar('알림', '변경된 내용이 없습니다.');
                                  return;
                                }

                                final results = await Future.wait(futures);
                                if (results.every((e) => e)) {
                                  // 스냅샷 갱신
                                  oldName = nameController.text.trim();
                                  oldMajor = deptController.text.trim();
                                  oldCollege = selectedCollege;
                                  oldBirth = newBirth;
                                  initPw = pwController.text.trim();

                                  Get.snackbar(
                                    '완료',
                                    '프로필이 업데이트됐어요',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                  await Future.delayed(
                                    const Duration(milliseconds: 600),
                                  );
                                  if (mounted) Get.back();
                                } else {
                                  Get.snackbar('실패', c.errorMessage.value);
                                }
                              },
                              child: const Text(
                                '저장',
                                style: TextStyle(
                                  color: SubTextColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 55,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pnu_logo.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '부  산  대  학  교',
                      style: TextStyle(
                        color: Color(0xFF2353A6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 125,
                    height: 125,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Color(0xFFF1F1F1), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _profileImage != null
                          ? Image.file(_profileImage!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/images/profile.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    bool editable = true,
    bool obscureText = false,
  }) {
    final bool isEditing = editingField == label;

    return GestureDetector(
      onTap: editable
          ? () async {
              if (label == "Password") {
                final ok = await showPasswordCheckDialog();
                if (!mounted) return;
                if (ok == true) {
                  setState(() {
                    editingField = label;
                  });
                }
              } else {
                setState(() => editingField = label);
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 0, 15, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDCDAE2), width: 2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
            ),
            const Spacer(),
            isEditing
                ? Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      obscureText: obscureText,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration.collapsed(hintText: ''),
                      onEditingComplete: () {
                        setState(() => editingField = null);
                      },
                    ),
                  )
                : Text(
                    obscureText
                        ? '*' * controller.text.length
                        : controller.text,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                    ),
                  ),
            if (!isEditing && editable && label != "ID") ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: SubTextColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: double.infinity,
      height: 45,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCDAE2), width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              alignment: Alignment.centerRight,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> showPasswordCheckDialog() async {
    final TextEditingController pwCheckController = TextEditingController();
    bool isError = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      // ignore: deprecated_member_use
      barrierColor: const Color(0xFF6E6E6E).withOpacity(0.2),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              child: Container(
                width: 310,
                padding: const EdgeInsets.fromLTRB(23, 21, 23, 21),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE1DDD4)),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF000000).withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 12.9,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "현재 비밀번호를 입력해주세요",
                      style: TextStyle(fontSize: 14, color: SubTextColor),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFDCDAE2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: pwCheckController,
                        obscureText: true,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(fontSize: 16, color: TextColor),
                      ),
                    ),
                    if (isError) ...[
                      const SizedBox(height: 5),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "비밀번호가 일치하지 않습니다",
                          style: TextStyle(
                            color: Color(0xFFFF2C2C),
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFF2C2C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else
                      const SizedBox(height: 29),
                    GestureDetector(
                      onTap: () {
                        if (pwCheckController.text.trim() ==
                            pwController.text) {
                          Navigator.pop(context, true);
                        } else {
                          setState(() => isError = true);
                        }
                      },
                      child: const Text(
                        "완료",
                        style: TextStyle(fontSize: 14, color: SubTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return result ?? false;
  }

  Widget buildBirthField() {
    return GestureDetector(
      onTap: _pickBirthByCalendar,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 0, 15, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDCDAE2), width: 2),
        ),
        child: Row(
          children: [
            const Text(
              'Birth',
              style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
            ),
            const Spacer(),
            Text(
              (birthController.text.trim().isEmpty)
                  ? '선택'
                  : birthController.text,
              style: const TextStyle(color: Color(0xFF000000), fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFF6E6E6E),
            ),
          ],
        ),
      ),
    );
  }
}
