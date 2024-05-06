import 'package:flutter/material.dart';
import 'package:kauno/model/Item.dart';
import 'package:kauno/util/sqlite/database_helper.dart';

class ItemSqlite {
  static final DatabaseHelper databaseHelper = DatabaseHelper();

  static Stream getItemStream(String date) async* {
    yield await databaseHelper.getData(date);
  }

  static Stream getDeletedItemStream() async* {
    yield await databaseHelper.getDeletedData();
  }

  static Future<bool> insertItem(List<Item> newItems) async {
    try {
      for (var newItem in newItems) {
        await databaseHelper.insertData(newItem.toMap());
      }
      debugPrint('Item作成完了');
      return true;
    } catch (e) {
      debugPrint('Item作成エラー: $e');
      return false;
    }
  }

  static Future<bool> updateItem(Item newItem) async {
    try {
      await databaseHelper.updateData(newItem.id!, newItem.toMap());
      debugPrint('Item更新完了');
      return true;
    } catch (e) {
      debugPrint('Item更新エラー: $e');
      return false;
    }
  }

  static Future<bool> deleteItems(List<int> itemIds) async {
    try {
      for (var itemId in itemIds) {
        await databaseHelper.deleteData(itemId);
      }
      debugPrint('Item削除完了');
      return true;
    } catch (e) {
      debugPrint('Item削除エラー: $e');
      return false;
    }
  }
}