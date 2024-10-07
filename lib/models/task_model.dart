import 'package:flutter/foundation.dart';

class Task {
  final int id;
  final String title;
  final String details;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    int? id,
    required this.title,
    required this.details,
    required this.dueDate,
    this.isCompleted = false,
  }) : id = id ?? _generateSafeId();

  static int _generateSafeId() {
    // Generate a random number within a safe range
    return DateTime.now().millisecondsSinceEpoch % 1000000;
  }

  Task copyWith({
    int? id,
    String? title,
    String? details,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      details: map['details'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, details: $details, dueDate: $dueDate, isCompleted: $isCompleted}';
  }
}