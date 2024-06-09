import 'dart:async';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/util/localstore/item_localstore.dart';
import 'package:kauno/view/calendar/detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  TextEditingController dateController = TextEditingController();

  final _today = DateTime.now();
  final dateFormatter = DateFormat('M月d日');

  List<CalendarEvent> events = [];
  List<Item> items = [];
  StreamSubscription<Map<String, dynamic>>? _itemSubscription;
  final _items = <String, Item>{};

  List<CalendarEvent> createEvents() {
    List<CalendarEvent> events = [];
    _items.forEach((key, value) {
      events.add(CalendarEvent(
          eventName: value.name,
          eventDate: value.date,
          eventTextStyle: const TextStyle(
              fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          eventBackgroundColor: value.isFinished ? Colors.grey : Colors.cyan));
    });
    return events;
  }

  @override
  void initState() {
    _itemSubscription = ItemLocalStore.itemCollection.stream
        .where((event) => !Item.fromMap(event).isDeleted)
        .listen((event) {
      if (mounted) {
        final item = Item.fromMap(event);
        setState(() {
          events.add(CalendarEvent(
              eventName: item.name,
              eventDate: item.date,
              eventTextStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              eventBackgroundColor:
                  item.isFinished ? Colors.grey : Colors.cyan));
          items.add(item);
          _items.putIfAbsent(item.id!, () => item);
        });
      }
    });
    dateController.text = dateFormatter.format(_today);
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
              return itemDate.year == date.year &&
                  itemDate.month == date.month &&
                  itemDate.day == date.day;
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${date.month}月 ${date.day}日',
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailPage(
                                                              date: date,
                                                            )));
                                              },
                                              child: const Icon(
                                                Icons.edit_calendar,
                                                color: Colors.blue,
                                              ))
                                        ],
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          onTap: () {
                                            setState(() {
                                              item.isFinished =
                                                  !item.isFinished;
                                            });
                                            item.save();
                                          },
                                          child: Card(
                                            color: Colors.white,
                                            child: ListTile(
                                              title: Text(
                                                item.name,
                                                style: TextStyle(
                                                    color: item.isFinished
                                                        ? Colors.grey
                                                        : Colors.black,
                                                    decoration: item.isFinished
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none),
                                              ),
                                              leading: Checkbox(
                                                activeColor:
                                                    Colors.lightBlueAccent,
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
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailPage(date: date)));
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
                style = const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold);
                break;
              case 6:
                style = const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold);
                break;
              default:
                style = const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold);
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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.indigoAccent,
      //   foregroundColor: Colors.white,
      //   onPressed: () async {
      //     await _showAddModal();
      //     // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Screen(index: 0,)));
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  // Future _showAddModal() async {
  //   await showModalBottomSheet(
  //     backgroundColor: Colors.white,
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Container(
  //           height: MediaQuery.sizeOf(context).height * 0.9,
  //           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text(
  //                     '商品登録',
  //                     style:
  //                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),
  //                   InkWell(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Icon(
  //                       Icons.close,
  //                       color: Colors.grey,
  //                       size: 40,
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(20),
  //                 child: ListView(
  //                   shrinkWrap: true,
  //                   children: [
  //                     // Text(dateFormatter.format(_today), style: TextStyle(fontSize: 20),)
  //                     TextField(
  //                       controller: dateController,
  //                       decoration: const InputDecoration(label: Text('日付')),
  //                       onTap: () {
  //                         FocusScope.of(context).requestFocus(FocusNode());
  //                         DatePicker.showDatePicker(
  //                             locale: LocaleType.jp,
  //                             context,
  //                             showTitleActions: true,
  //                             minTime: DateTime(_today.year, _today.month, 1),
  //                             maxTime:
  //                                 DateTime(_today.year, _today.month + 1, 0),
  //                             onConfirm: (DateTime date) {
  //                           setState(() {
  //                             dateController.text = dateFormatter.format(date);
  //                           });
  //                         });
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    super.dispose();
  }
}
