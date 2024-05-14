
import 'package:flutter/material.dart';
import 'package:kauno/util/localstore/category_localstore.dart';
import 'package:localstore/localstore.dart';

class ItemCategory {
  String id;
  String name;

  ItemCategory({this.id = '', required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name
    };
  }

  factory ItemCategory.fromMap(Map<String, dynamic> map) {
    return ItemCategory(id: map['id'], name: map['name']);
  }
}

extension ExtItemCategory on ItemCategory {
  Future save() async {
    try {
      await CategoryLocalStore.categoryCollection.doc(id).set(toMap());
      return true;
    } catch (e) {
      debugPrint('category登録エラー: $e');
      return false;
    }
  }

  Future delete() async {
    try {
      await CategoryLocalStore.categoryCollection.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('category削除エラー: $e');
      return false;
    }
  }
}