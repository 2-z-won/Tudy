import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants/colors.dart';

class JoinAddField extends StatefulWidget {
  final String hinttext;
  final String button;
  final TextEditingController controller;
  final VoidCallback onJoin;
  final VoidCallback? onEnter;
  final String messageType;
  final String message;

  const JoinAddField({
    super.key,
    required this.hinttext,
    required this.button,
    required this.controller,
    required this.onJoin,
    this.onEnter,
    required this.messageType,
    required this.message,
  });

  @override
  State<JoinAddField> createState() => _JoinAddFieldState();
}

class _JoinAddFieldState extends State<JoinAddField> {
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool get isAllDigitsFilled =>
      _digitControllers.every((controller) => controller.text.isNotEmpty);

  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // 눌렸을 때 작아짐
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // 다시 원래 크기로 복귀
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: widget.messageType == "error" || widget.messageType == "success"
      //     ? 30
      //     : widget.messageType == "password"
      //     ? 130
      //     : 75,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFE1DDD4)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFEDEDED),
                    border: Border.all(color: Color(0xFFE1DDD4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: widget.controller,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        color: Color(0xFFA6A6A6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsetsDirectional.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onJoin,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: AnimatedScale(
                  scale: _scale,
                  duration: Duration(milliseconds: 100),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF6E5),
                      border: Border.all(color: Color(0xFFE1DDD4)),
                    ),
                    child: Text(
                      widget.button,
                      style: TextStyle(
                        color: Color(0xFF565656),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.messageType == "error" || widget.messageType == "success")
            Text(
              widget.message,
              style: TextStyle(color: Color(0xFFE94F4F), fontSize: 12),
            )
          else if (widget.messageType == "password")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  List.generate(6, (index) {
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
                        style: const TextStyle(fontSize: 16, color: TextColor),
                        decoration: const InputDecoration(
                          counterText: "", // 글자 수 제거
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {}); // 숫자 입력 상태 반영

                          if (value.isNotEmpty) {
                            if (index < 5) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[index + 1]);
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                          } else if (index > 0) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index - 1]);
                          }
                        },
                      ),
                    );
                  })..add(
                    isAllDigitsFilled
                        ? GestureDetector(
                            onTap: widget.onEnter!,
                            child: Image.asset(
                              'assets/images/util_enter.png',
                              width: 24,
                              height: 24,
                            ),
                          )
                        : SizedBox(width: 20), // 자리 유지용
                  ),
            )
          else
            SizedBox.shrink(),
        ],
      ),
    );
  }
}
