import 'package:intl/intl.dart';

final dateFormatter = DateFormat('yyyy年M月d日');

class Item {
  int? id;
  String category;
  String name;
  DateTime date;
  String shop;
  int quantity;
  bool isFinished;
  bool isDeleted;

  Item({
    this.id,
    required this.category,
    required this.name,
    required this.date,
    this.shop = '',
    this.quantity = 1,
    required this.isFinished,
    this.isDeleted = false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'date': dateFormatter.format(date),
      'shop': shop,
      'quantity': quantity,
      'is_finished': isFinished ? 1: 0,
      'is_deleted': isDeleted ? 1: 0
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      category: map['category'],
      name: map['title'],
      date: dateFormatter.parse(map['date']),
      shop: map['shop'],
      quantity: map['quantity'],
      isFinished: map['is_finished'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }
}