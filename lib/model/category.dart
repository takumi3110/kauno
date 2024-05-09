import 'package:flutter/foundation.dart';

class Category {
  String name;

  Category({required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(name: map['name']);
  }
}