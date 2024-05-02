import 'package:intl/intl.dart';

final dateFormatter = DateFormat('yyyy年M月d日');

class Item {
  int? id;
  String category;
  String title;
  DateTime date;
  bool isFinished;
  bool isDeleted;

  Item({
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

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      date: dateFormatter.parse(map['date']),
      isFinished: map['is_finished'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }
}