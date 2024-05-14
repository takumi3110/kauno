import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/util/localstore/item_localstore.dart';
import 'package:localstore/localstore.dart';

final dateFormatter = DateFormat('yyyy年M月d日');

class Item {
  String? id;
  String category;
  String name;
  int price;
  int quantity;
  DateTime date;
  String shop;
  bool isFinished;
  bool isDeleted;

  Item({
    this.id = '',
    required this.category,
    required this.name,
    this.price = 0,
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
      'price': price,
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
      name: map['name'],
      price: map['price'],
      date: dateFormatter.parse(map['date']),
      shop: map['shop'],
      quantity: map['quantity'],
      isFinished: map['is_finished'] == 1,
      isDeleted: map['is_deleted'] == 1,
    );
  }
}

extension ExtItem on Item {
  Future save() async {
    try {
      await ItemLocalStore.itemCollection.doc(id).set(toMap());
      return true;
    } catch (e) {
      debugPrint('item登録エラー: $e' );
      return false;
    }
  }

  Future delete() async {
    try {
      await ItemLocalStore.itemCollection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('item削除エラー: $e');
      return false;
    }
  }
}

class DeletedItem {
  DateTime date;
  List<Item> items;

  DeletedItem({
    required this.date,
    required this.items,
});

}