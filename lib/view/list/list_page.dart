import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/todo.dart';
import 'package:kauno/util/database/todo_database.dart';
import 'package:kauno/util/widget_utils.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final dateFormatter = DateFormat('yyyy年M月d日');

  DateTime _selectedData = DateTime.now();

  Stream getTodoStream(String date) async* {
    yield await TodoDatabase.databaseHelper.getData(date);
  }

  @override
  void initState() {
    // getTodoList(dateFormatter.format(DateTime.now()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                              Todo todo = snapshot.data![index];
                              return Dismissible(
                                onDismissed: (DismissDirection direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text('削除しました。')));
                                    todo.isDeleted = true;
                                    var result = await TodoDatabase.updateTodo(todo);
                                    if (result == true) {
                                      setState(() {
                                        todo.isDeleted = true;
                                      });
                                    }
                                  }
                                  debugPrint('dismissed');
                                },
                                direction: todo.isFinished ? DismissDirection.startToEnd : DismissDirection.none,
                                key: UniqueKey(),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  color: Colors.white,
                                  child: CheckboxListTile(
                                    activeColor: Colors.blue,
                                    title: Text(
                                      todo.title,
                                      style: TextStyle(
                                          decoration:
                                          todo.isFinished ? TextDecoration.lineThrough : TextDecoration.none),
                                    ),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: todo.isFinished,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10))),
                                    onChanged: (bool? value) async {
                                      if (todo.isFinished != value) {
                                        todo.isFinished = value!;
                                        var result = await TodoDatabase.updateTodo(todo);
                                        if (result == true) {
                                          setState(() {
                                            todo.isFinished = value;
                                          });
                                        }
                                      }
                                      // await TodoDatabase.updateTodo(newTodo)
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
        onPressed: () async{
          await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('簡単作成', style: TextStyle(fontSize: 20),),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: 'タイトル'
                            ),
                          ),
                        ),
                        ElevatedButton(onPressed: () {}, child: const Text('登録'))
                      ],
                    )
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
