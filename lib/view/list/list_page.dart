import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/Item.dart';
import 'package:kauno/util/sqlite/item_sqlite.dart';
import 'package:kauno/util/widget_utils.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  final dateFormatter = DateFormat('yyyy年M月d日');
  DateTime _selectedData = DateTime.now();

  Stream getTodoStream(String date) async* {
    yield await ItemSqlite.databaseHelper.getData(date);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: WidgetUtils.createAppBar('リスト'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          DateTime newDate = _selectedData.subtract(const Duration(days: 1));
                          _selectedData = newDate;
                          // getTodoList(dateFormatter.format(newDate));
                        });
                      },
                      child: const Icon(Icons.chevron_left)),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedData = DateTime.now();
                        });
                        // getTodoList(dateFormatter.format(DateTime.now()));
                      },
                      child: Text(
                        dateFormatter.format(_selectedData),
                        style: const TextStyle(fontSize: 18),
                      )),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          DateTime newDate = _selectedData.add(const Duration(days: 1));
                          _selectedData = newDate;
                          // getTodoList(dateFormatter.format(newDate));
                        });
                      },
                      child: const Icon(Icons.chevron_right)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: '検索',
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                debugPrint('tap');
                              })),
                    RichText(
                        text: TextSpan(
                            text: '今日',
                            style: const TextStyle(fontSize: 14, color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _selectedData = DateTime.now();
                                });
                              })),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                    stream: getTodoStream(dateFormatter.format(_selectedData)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.length > 0) {
                        return ListView.builder(
                            // shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Item item = snapshot.data![index];
                              return Dismissible(
                                onDismissed: (DismissDirection direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('削除しました。')));
                                    item.isDeleted = true;
                                    var result = await ItemSqlite.updateItem(item);
                                    if (result == true) {
                                      setState(() {
                                        item.isDeleted = true;
                                      });
                                    }
                                  }
                                  debugPrint('dismissed');
                                },
                                direction: item.isFinished ? DismissDirection.startToEnd : DismissDirection.none,
                                key: UniqueKey(),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  color: Colors.white,
                                  child: CheckboxListTile(
                                    activeColor: Colors.blue,
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                              color: item.isFinished ? Colors.grey: Colors.black,
                                              decoration:
                                                  item.isFinished ? TextDecoration.lineThrough : TextDecoration.none),
                                        ),
                                        Text(
                                          '${item.quantity} 個',
                                          style: TextStyle(
                                            color: item.isFinished ? Colors.grey: Colors.black
                                          ),
                                        )
                                      ],
                                    ),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: item.isFinished,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))),
                                    onChanged: (bool? value) async {
                                      if (item.isFinished != value) {
                                        item.isFinished = value!;
                                        var result = await ItemSqlite.updateItem(item);
                                        if (result == true) {
                                          setState(() {
                                            item.isFinished = value;
                                          });
                                        }
                                      }
                                      // await ItemSqlite.updateTodo(newTodo)
                                    },
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Align(
                          alignment: Alignment.topCenter,
                          child: Text('登録がありません。'),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                // return DraggableScrollableSheet(
                //   initialChildSize:1,
                //   expand: false,
                //   builder: (context, scrollController) {
                //     return Padding(
                //       padding: const EdgeInsets.all(20.0),
                //       child: ListView(
                //         shrinkWrap: true,
                //         controller: scrollController,
                //           children: [
                //             Text('シンプル作成'),
                //             Padding(
                //               padding: const EdgeInsets.all(10.0),
                //               child: TextField(
                //                 decoration: InputDecoration(labelText: '商品名'),
                //               ),
                //             ),
                //             ElevatedButton(
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //                 child: const Text('登録')
                //             )
                //           ]
                //       ),
                //     );
                //   },
                // );
                return Container(
                  height: 500,
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
                  child: Column(
                    children: [
                      const Text('シンプル作成'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: itemNameController,
                                decoration: const InputDecoration(
                                  labelText: '商品名'
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: DropdownButtonFormField(
                                  items: quantityList.map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(value: value, child: Text(value.toString()));
                                  }).toList(),
                                  onChanged: (int? value) {
                                    itemQuantityController.text = value.toString();
                                  }
                              ),
                            )
                          ],
                        ),
                      ),
                      if (bottomSpace == 0)
                      ElevatedButton(
                          onPressed: () async{
                            if (itemNameController.text.isNotEmpty && itemQuantityController.text.isNotEmpty) {
                              Item newItem = Item(
                                category: 'なし',
                                name: itemNameController.text,
                                quantity: int.parse(itemQuantityController.text),
                                date: _selectedData,
                                shop: '',
                                isFinished: false,
                                isDeleted: false
                              );
                              var result = await ItemSqlite.insertItem([newItem]);
                              if (result == true) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('リストを登録しました。')));
                                setState(() {
                                  itemNameController.text = '';
                                });
                              } else {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('リストの登録に失敗しました。')));
                              }
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          child: const Text('登録')
                      )
                    ],
                  ),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
