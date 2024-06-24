import 'package:localstore/localstore.dart';

class CategoryLocalStore {
  static final db = Localstore.instance;
  static final categoryCollection = db.collection('categories');
}