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
  TextEditingController shopController = TextEditingController();
  List<Map<String, dynamic>> itemControllers = [];

  final dateFormatter = DateFormat('yyyy年M月d日');
  DateTime _selectedDate = DateTime.now();

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  @override
  void initState() {
    dateController.text = dateFormatter.format(_selectedDate);
    itemControllers.add({'name': TextEditingController(), 'quantity': TextEditingController()});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                          controller: dateController,
                          decoration: const InputDecoration(label: Text('日付')),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            DatePicker.showDatePicker(
                                locale: LocaleType.jp,
                                context,
                                showTitleActions: true,
                                minTime: minDate,
                                maxTime: maxDate, onConfirm: (DateTime date) {
                              dateController.text = dateFormatter.format(date);
                              setState(() {
                                _selectedDate = date;
                              });
                            });
                          },
                        ),
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(label: Text('カテゴリー')),
                        ),
                        TextField(
                          controller: shopController,
                          decoration: const InputDecoration(label: Text('購入店舗')),
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
                          final isLast = index != itemControllers.length - 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: itemControllers[index]['name'],
                                    decoration: const InputDecoration(
                                      label: Text('商品名'),
                                      // border: OutlineInputBorder(
                                      //     borderRadius: BorderRadius.circular(10)
                                      // )
                                    ),
                                    onSubmitted: (_) {
                                      if (itemControllers.last['name'].text.isNotEmpty &&
                                          itemControllers.last['quantity'].text.isNotEmpty) {
                                        setState(() {
                                          itemControllers.add(
                                              {'name': TextEditingController(), 'quantity': TextEditingController()});
                                        });
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: DropdownButtonFormField(
                                      decoration: const InputDecoration(
                                        label: Text('個数'),
                                        // border: OutlineInputBorder(
                                        //   borderRadius: BorderRadius.circular(10)
                                        // )
                                      ),
                                      items: quantityList.map<DropdownMenuItem<int>>((int value) {
                                        return DropdownMenuItem<int>(value: value, child: Text(value.toString()));
                                      }).toList(),
                                      onChanged: (int? value) {
                                        itemControllers[index]['quantity'].text = value.toString();
                                        setState(() {
                                          if (itemControllers.last['name'].text.isNotEmpty &&
                                              itemControllers.last['quantity'].text.isNotEmpty) {
                                            itemControllers.add(
                                                {'name': TextEditingController(), 'quantity': TextEditingController()});
                                          }
                                        });
                                      }),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isLast) {
                                        itemControllers.removeAt(index);
                                      } else {
                                        itemControllers.add({
                                          'name': TextEditingController(),
                                          'quantity': TextEditingController(),
                                        });
                                      }
                                    });
                                  },
                                    child: Icon(isLast ? Icons.highlight_off: Icons.add, size: 20, color: Colors.blueGrey,)
                                )
                              ],
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
            if (categoryController.text.isNotEmpty) {
              List<Item> newTodos = [];
              for (var item in itemControllers) {
                if (item['name'].text.isNotEmpty && item['quantity'].text.isNotEmpty) {
                  Item newTodo = Item(
                      category: categoryController.text,
                      shop: shopController.text,
                      name: item['name'].text,
                      quantity: int.parse(item['quantity'].text),
                      date: _selectedDate,
                      isFinished: false,
                      isDeleted: false);
                  newTodos.add(newTodo);
                }
              }
              if (newTodos.isNotEmpty) {
                var result = await ItemSqlite.insertItem(newTodos);
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
          child: const Text('登録')),
    );
  }
}
