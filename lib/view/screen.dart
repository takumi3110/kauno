import 'package:flutter/material.dart';
import 'package:kauno/view/calendar/calendar_page.dart';
import 'package:kauno/view/list/list_page.dart';
import 'package:kauno/view/trash/trashed_page.dart';


class Screen extends StatefulWidget {
  final int? index;
  const Screen({super.key, this.index});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  late int selectedIndex = 0;
  List<Widget> pageList = [const ListPage(), const CalendarPage(), const TrashedPage()];

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      selectedIndex = widget.index!;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'リスト'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: '削除済み')
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),

    );
  }
}
