import 'package:flutter/material.dart';
import 'package:kauno/model/Item.dart';
import 'package:kauno/util/sqlite/database_helper.dart';

class ItemSqlite {
  static final DatabaseHelper databaseHelper = DatabaseHelper();

  static Future<bool> insertTodo(List<Item> newTodos) async {
    try {
      for (var newTodo in newTodos) {
        await databaseHelper.insertData(newTodo.toMap());
      }
      return true;
    } catch (e) {
      debugPrint('Todo作成エラー: $e');
      return false;
    }
  }

  static Future<bool> updateTodo(Item newTodo) async {
    try {
      await databaseHelper.updateData(newTodo.id!, newTodo.toMap());
      debugPrint('Todo更新完了');
      return true;
    } catch (e) {
      debugPrint('Todo更新エラー: $e');
      return false;
    }
  }

  static Future<bool> deleteTodo(int todoId) async {
    try {
      await databaseHelper.deleteData(todoId);
      debugPrint('Todo削除完了');
      return true;
    } catch (e) {
      debugPrint('Todo削除エラー: $e');
      return false;
    }
  }
}