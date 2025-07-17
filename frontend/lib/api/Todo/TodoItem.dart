import 'package:flutter/material.dart';

//TODO 모델
class SubTodo {
  final String goalTitle;
  final bool isGroup;
  final bool isDone;
  final bool isPhotoRequired;
  final bool isTimerRequired;

  SubTodo({
    required this.goalTitle,
    required this.isGroup,
    required this.isDone,
    required this.isPhotoRequired,
    required this.isTimerRequired,
  });
}

class TodoItem {
  final String category; // 카테고리명
  final List<SubTodo> subTodos; // 목표 리스트
  final Color mainColor;

  TodoItem({
    required this.category,
    required this.subTodos,
    required this.mainColor,
  });
}
