import 'package:intl/intl.dart';

final dateFormatter = DateFormat('yyyy年M月d日');

class Todo {
  int? id;
  String category;
  String title;
  DateTime date;
  bool isFinished;
  bool isDeleted;

  Todo({
    this.id,
    required this.category,
    required this.title,
    required this.date,
    required this.isFinished,
    this.isDeleted = false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'date': dateFormatter.format(date),
      'is_finished': isFinished ? 1: 0,
      'is_deleted': isDeleted ? 1: 0
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      date: dateFormatter.parse(map['date']),
      isFinished: map['is_finished'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }
}