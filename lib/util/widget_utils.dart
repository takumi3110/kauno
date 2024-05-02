import 'package:flutter/material.dart';

class WidgetUtils {
  static AppBar createAppBar(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontSize: 20),),
      backgroundColor: Colors.white,
      shadowColor: Colors.black,
      elevation: 1,
    );
  }
}