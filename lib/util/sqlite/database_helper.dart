import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kauno/model/Item.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  Future<String> getDbPath() async {
    var dbFilePath = '';
    if (Platform.isAndroid) {
      //   AndroidはgetDatabasePathを使用
      dbFilePath = await getDatabasesPath();
    } else if (Platform.isIOS) {
      // iosはgetLibraryDirectoryを使用
      final dbDirectory = await getLibraryDirectory();
      dbFilePath = dbDirectory.path;
    } else {
      // プラットフォームが判別できない場合はExceptionをthrow
      throw Exception('プラットフォームが判別できませんでした。');
    }

    final path = join(dbFilePath, 'todo.db');
    return path;
  }

  // databaseの初期化
  Future<Database> initDatabase() async {
    final path = await getDbPath();
    return await openDatabase(
        path,
        version:1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY,
            category TEXT,
            title TEXT,
            date TEXT,
            is_finished INTEGER,
            is_deleted INTEGER
          );
          ''');
        }
    );
  }

  // 全部取得
  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database? db = await database;
    return await db!.query('todos');
  }

  // 一部取得　日付
  Future<dynamic> getData(String date) async {
    final Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query('todos', where: 'date = ?', whereArgs: [date]);
    List<Item> results = [];
    for (var map in maps) {
      Item newTodo = Item.fromMap(map);
      if (!newTodo.isDeleted) {
        results.add(newTodo);
      }
    }
    return results;
  }

  // 新規作成
  Future<void> insertData(Map<String, dynamic> data) async {
    final Database? db = await database;
    await db!.insert('todos', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 更新してidを返す
  Future<int> updateData(int id, Map<String, dynamic> data) async {
    final Database? db = await database;
    return await db!.update('todos', data, where: 'id = ?', whereArgs: [id]);
  }

//   削除してidを返す
  Future<int> deleteData(int id) async {
    final Database? db = await database;
    return await db!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}