import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/Item.dart';
import 'package:kauno/util/sqlite/item_sqlite.dart';
import 'package:kauno/util/widget_utils.dart';
import 'package:kauno/view/screen.dart';

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  List<Map<String, dynamic>> itemControllers = [];

  final dateFormatter = DateFormat('yyyy年M月d日');
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    dateController.text = dateFormatter.format(_selectedDate);
    itemControllers.add({
      'title': TextEditingController()
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.sizeOf(context).height;
    final minDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final maxDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

    return Scaffold(
      appBar: WidgetUtils.createAppBar('リスト作成'),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                              label: Text('カテゴリー')
                          ),
                        ),
                        TextField(
                          controller: dateController,
                          decoration: const InputDecoration(
                              label: Text('日付')
                          ),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            DatePicker.showDatePicker(
                                locale: LocaleType.jp,
                                context,
                                showTitleActions: true,
                                minTime: minDate,
                                maxTime: maxDate,
                                onConfirm: (DateTime date) {
                                  dateController.text = dateFormatter.format(date);
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                }
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: ListView.builder(
                        itemCount: itemControllers.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            onDismissed: (direction) {
                              setState(() {
                                itemControllers.removeAt(index);
                              });
                            },
                            key: UniqueKey(),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextField(
                                controller: itemControllers[index]['title'],
                                decoration: InputDecoration(
                                    label: const Text('タイトル'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    )
                                ),
                                onSubmitted: (_) {
                                  if (itemControllers.last['title'].text.isNotEmpty) {
                                    setState(() {
                                      itemControllers.add({
                                        'title': TextEditingController()
                                      }
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (categoryController.text.isNotEmpty && itemControllers[0]['title'].text.isNotEmpty) {
              List<Item> newTodos = [];
              for (var item in itemControllers) {
                Item newTodo = Item(
                    category: categoryController.text,
                    title: item['title'].text,
                    date: _selectedDate,
                    isFinished: false
                );
                newTodos.add(newTodo);
              }
              if (newTodos.isNotEmpty) {
                var result = await ItemSqlite.insertTodo(newTodos);
                if (result == true) {
                  if (!context.mounted) return;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Screen()));
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登録に失敗しました。')));
                }
              }
            }
          },
          child: const Text('登録')
      ),
    );
  }
}
