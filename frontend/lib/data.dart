import 'package:flutter/material.dart';

//TODO 모델
class SubTodo {
  final String text;
  final bool isGroup;
  final bool isDone;
  final bool isPhotoRequired;
  final bool isTimerRequired;

  SubTodo({
    required this.text,
    required this.isGroup,
    required this.isDone,
    required this.isPhotoRequired,
    required this.isTimerRequired,
  });
}

class TodoItem {
  final String title; // 카테고리명
  final List<SubTodo> subTodos; // 목표 리스트
  final Color mainColor;

  TodoItem({
    required this.title,
    required this.subTodos,
    required this.mainColor,
  });
}

final List<TodoItem> todoList = [
  TodoItem(
    title: '알고리즘 공부하기',
    mainColor: Color(0xFF4D4AFF),
    subTodos: [
      SubTodo(
        text: '1차시: 그리디 알고리즘',
        isGroup: false,
        isDone: false,
        isPhotoRequired: false,
        isTimerRequired: true,
      ),
      SubTodo(
        text: '2차시: DP 기초',
        isGroup: false,
        isDone: true,
        isPhotoRequired: true,
        isTimerRequired: true,
      ),
    ],
  ),
  TodoItem(
    title: '팀 스터디',
    mainColor: Color(0xFFFF4A4A),
    subTodos: [
      SubTodo(
        text: 'CS 면접 준비',
        isGroup: true,
        isDone: false,
        isPhotoRequired: false,
        isTimerRequired: true,
      ),
      SubTodo(
        text: '기출 문제 리뷰',
        isGroup: true,
        isDone: true,
        isPhotoRequired: false,
        isTimerRequired: true,
      ),
    ],
  ),
  TodoItem(
    title: '토익 공부',
    mainColor: Color(0xFF00B894),
    subTodos: [
      SubTodo(
        text: 'LC 실전모의고사 1회',
        isGroup: false,
        isDone: true,
        isPhotoRequired: false,
        isTimerRequired: true,
      ),
      SubTodo(
        text: 'RC 문법 정리',
        isGroup: false,
        isDone: false,
        isPhotoRequired: true,
        isTimerRequired: false,
      ),
    ],
  ),
];
