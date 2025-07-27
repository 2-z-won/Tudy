import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  String get _formattedTime {
    final hours = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _seconds++;
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEC),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '🏆 1st: 정보의생명공학대학', //일단 텍스트 처리해놨어
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: _toggleTimer,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2E9DA).withOpacity(0.5),
                      spreadRadius: 10,
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF8BBD0), width: 4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('알고리즘 공부하기', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRunning ? 'STOP' : 'START',
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
