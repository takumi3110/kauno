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

    final path = join(dbFilePath, 'kauno.db');
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
          CREATE TABLE items(
            id INTEGER PRIMARY KEY,
            category TEXT,
            name TEXT,
            date TEXT,
            shop TEXT,
            quantity INTEGER,
            is_finished INTEGER,
            is_deleted INTEGER
          );
          ''');
          await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY,
            name TEXT
          );
          ''');
        }
    );
  }

  // 全部取得
  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database? db = await database;
    return await db!.query('items');
  }

  // 一部取得　日付
  Future<dynamic> getData(String date) async {
    final Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query('items', where: 'date = ?', whereArgs: [date]);
    List<Item> results = [];
    for (var map in maps) {
      Item newItem = Item.fromMap(map);
      if (!newItem.isDeleted) {
        results.add(newItem);
      }
    }
    results.sort((a, b) => b.id! - a.id!);
    return results;
  }

  Future<dynamic> getDeletedData() async {
    final Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query('items', where: 'is_deleted = ?', whereArgs: [1]);
    List<DeletedItem> results = [];
    for (var map in maps) {
      Item getItem = Item.fromMap(map);
      if (results.isEmpty) {
        results.add(DeletedItem(date: getItem.date, items: [getItem]));
      } else {
        if (results.any((result) => result.date.isAtSameMomentAs(getItem.date))) {
          final index = results.indexWhere((result) => result.date == getItem.date);
          results[index].items.add(getItem);
        } else {
          results.add(DeletedItem(date: getItem.date, items: [getItem]));
        }
      }
    }
    results.sort((a, b) => 1);
    return results;
  }

  // 新規作成
  Future<void> insertData(Map<String, dynamic> data) async {
    final Database? db = await database;
    await db!.insert('items', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 更新してidを返す
  Future<int> updateData(int id, Map<String, dynamic> data) async {
    final Database? db = await database;
    return await db!.update('items', data, where: 'id = ?', whereArgs: [id]);
  }

//   削除してidを返す
  Future<int> deleteData(int id) async {
    final Database? db = await database;
    return await db!.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}