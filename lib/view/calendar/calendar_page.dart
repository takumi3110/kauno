import 'dart:async';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/util/localstore/item_localstore.dart';
import 'package:kauno/view/screen.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<CalendarEvent> events = [];
  List<Item> items = [];
  StreamSubscription<Map<String, dynamic>>? _itemSubscription;
  final _items = <String, Item> {};

  List<CalendarEvent> createEvents() {
    List<CalendarEvent> events = [];
    _items.forEach((key, value) {
      events.add(CalendarEvent(
          eventName: value.name,
          eventDate: value.date,
          eventTextStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          eventBackgroundColor: value.isFinished ? Colors.grey : Colors.cyan));
    });
    return events;
  }

  @override
  void initState() {
    _itemSubscription =
        ItemLocalStore.itemCollection.stream.where((event) => !Item.fromMap(event).isDeleted).listen((event) {
      if (mounted) {
        final item = Item.fromMap(event);
        setState(() {
          events.add(CalendarEvent(
              eventName: item.name,
              eventDate: item.date,
              eventTextStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              eventBackgroundColor: item.isFinished ? Colors.grey : Colors.cyan));
          items.add(item);
          _items.putIfAbsent(item.id!, () => item);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: WidgetUtils.createAppBar(''),
      body: SafeArea(
        child: CellCalendar(
          events: createEvents(),
          onCellTapped: (DateTime date) {
            final itemsOnTheDate = _items.values.where((item) {
              final itemDate = item.date;
              return itemDate.year == date.year && itemDate.month == date.month && itemDate.day == date.day;
            }).toList();
            if (itemsOnTheDate.isNotEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      backgroundColor: Colors.white,
                      content: StatefulBuilder(
                        builder: (context, setState) {
                          return SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.7,
                            width: double.maxFinite,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${date.month}月 ${date.day}日',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: InkWell(
                                              borderRadius: BorderRadius.circular(50),
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.grey,
                                                size: 28,
                                              ))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: itemsOnTheDate.length,
                                      itemBuilder: (context, index) {
                                        final item = itemsOnTheDate[index];
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            // TODO:チェックすると増えちゃう
                                            setState(() {
                                              item.isFinished = !item.isFinished;
                                            });
                                            item.save();
                                          },
                                          child: Card(
                                            color: Colors.white,
                                            child: ListTile(
                                              title: Text(
                                                item.name,
                                                style: TextStyle(
                                                    color: item.isFinished ? Colors.grey : Colors.black,
                                                    decoration:
                                                    item.isFinished ? TextDecoration.lineThrough : TextDecoration.none),
                                              ),
                                              leading: Checkbox(
                                                value: item.isFinished,
                                                shape: const CircleBorder(),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    item.isFinished = value!;
                                                    item.save();
                                                  });

                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  });
            }
          },
          monthYearLabelBuilder: (DateTime? datetime) {
            if (datetime != null) {
              final year = datetime.year.toString();
              final month = datetime.month.toString();
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '$year年 $month月',
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }
            return Container();
          },
          daysOfTheWeekBuilder: (dayIndex) {
            final labels = ['日', '月', '火', '水', '木', '金', '土'];
            TextStyle style;
            switch (dayIndex) {
              case 0:
                style = const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
                break;
              case 6:
                style = const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
                break;
              default:
                style = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
                break;
            }
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                labels[dayIndex],
                style: style,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Screen(index: 0,)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    super.dispose();
  }
}
