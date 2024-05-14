import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/model/item_category.dart';
import 'package:kauno/util/function_utils.dart';
import 'package:kauno/util/localstore/category_localstore.dart';
import 'package:kauno/util/localstore/item_localstore.dart';
import 'package:kauno/util/widget_utils.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  StreamSubscription<Map<String, dynamic>>? _itemSubscription;
  StreamSubscription<Map<String, dynamic>>? _categorySubscription;
  final _items = <String, Item>{};

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  final numberFormatter = NumberFormat('#,###');
  final dateFormatter = DateFormat('yyyy年M月d日');
  final _today = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<ItemCategory> categoryList = [
    ItemCategory(name: 'すべて'),
  ];

  int _selectCategoryIndex = 0;

  @override
  void initState() {
    _itemSubscription = ItemLocalStore.itemCollection.stream.listen((event) {
      if (mounted) {
        setState(() {
          final item = Item.fromMap(event);
          if (!item.isDeleted) {
            _items.putIfAbsent(item.id!, () => item);
          }
        });
      }
      if (kIsWeb) ItemLocalStore.itemCollection.stream.asBroadcastStream();
    });
    _categorySubscription = CategoryLocalStore.categoryCollection.stream.listen((event) {
      if (mounted) {
        setState(() {
          final category = ItemCategory.fromMap(event);
          categoryList.add(category);
        });
      }
      if (kIsWeb) CategoryLocalStore.categoryCollection.stream.asBroadcastStream();
    });
    super.initState();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      splashColor: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          DateTime newDate = _selectedDate.subtract(const Duration(days: 1));
                          _selectedDate = newDate;
                          // getTodoList(dateFormatter.format(newDate));
                        });
                      },
                      child: const Icon(Icons.chevron_left)),
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(
                      '${dateFormatter.format(_selectedDate)}(${FunctionUtils.formatWeekday(_selectedDate.weekday)})',
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (!_selectedDate.isAtSameMomentAs(_today))
                      RichText(
                          text: TextSpan(
                              text: '今日の日付に戻る',
                              style: const TextStyle(fontSize: 14, color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    _selectedDate = _today;
                                  });
                                })),
                  ]),
                  InkWell(
                      splashColor: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          DateTime newDate = _selectedDate.add(const Duration(days: 1));
                          _selectedDate = newDate;
                          // getTodoList(dateFormatter.format(newDate));
                        });
                      },
                      child: const Icon(Icons.chevron_right)),
                ],
              ),
              Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(categoryList.length, (index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            setState(() {
                              _selectCategoryIndex = index;
                            });
                          },
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                // border: Border(bottom: BorderSide(color: _selectCategoryIndex == index ? Colors.blue: Colors.grey))
                                  border: Border(
                                      bottom: _selectCategoryIndex == index ? const BorderSide(color: Colors.blue): BorderSide.none
                                  )
                              ),
                              child: Text(
                                categoryList[index].name,
                                style: TextStyle(
                                    color: _selectCategoryIndex == index ? Colors.blue: Colors.black
                                ),
                              )
                          ),
                        );
                      }),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () async{
                        await showModalBottomSheet(
                          backgroundColor: Colors.white,
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 500,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('カテゴリー追加', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(50),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Icon(Icons.close, color: Colors.grey, size: 40,),
                                          ),
                                        ),
                                      ],
                                    ),

                                    TextField(
                                      controller: categoryController,
                                      decoration: const InputDecoration(
                                        labelText: 'カテゴリー入力',
                                        // hintText: 'カテゴリーを追加'
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                          onPressed: () async{
                                            if(categoryController.text.isNotEmpty) {
                                                // save category
                                                final id = CategoryLocalStore.categoryCollection.doc().id;
                                                ItemCategory newCategory = ItemCategory(
                                                  id: id,
                                                    name: categoryController.text
                                                );
                                                var result = await newCategory.save();
                                                if (result == true) {
                                                  setState(() {
                                                    categoryList.add(ItemCategory(name: categoryController.text));
                                                  });
                                                }
                                            }
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            categoryController.text.isNotEmpty ? '登録': '閉じる'
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.add, size: 20,),
                      ),
                    )
                  ],
                ),
              ),
              if(_selectCategoryIndex != 0)
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('このカテゴリーを削除しますか？', style: TextStyle(fontSize: 14),),
                        content: Text(
                            '【${categoryList[_selectCategoryIndex].name}】が削除されますが、登録されているアイテムは削除されません。',
                          style: const TextStyle(fontSize: 14),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('キャンセル'),
                          ),
                          CupertinoDialogAction(
                              child: const Text('OK'),
                            onPressed: () async {
                                var result = await categoryList[_selectCategoryIndex].delete();
                                if (result == true) {
                                  setState(() {
                                    categoryList.removeAt(_selectCategoryIndex);
                                  });
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('エラーがあり削除できませんでした。')));
                                }
                            },
                          ),

                        ],
                      );
                    });
                  },
                    child: const Icon(Icons.delete_forever, color: Colors.blueGrey, size: 26,)),
              ),
              const SizedBox(height: 20,),
              Expanded(
                child: IndexedStack(
                    index: _selectCategoryIndex,
                    children: List.generate(categoryList.length, (index) {
                      switch(index) {
                        case 0:
                          var filterItems = <String, Item>{};
                          _items.forEach((key, value) {
                            DateTime date = value.date;
                            DateTime formatSelectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                            if (date.isAtSameMomentAs(formatSelectedDate)) {
                              filterItems.putIfAbsent(key, () => value);
                            }
                          });
                          return itemListView(filterItems);
                        default:
                          var filterItems = <String, Item>{};
                          _items.forEach((key, value) {
                            DateTime date = value.date;
                            DateTime formatSelectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                            if (date.isAtSameMomentAs(formatSelectedDate) && value.category == categoryList[index].name) {
                              filterItems.putIfAbsent(key, () => value);
                            }
                          });
                          return itemListView(filterItems);
                      // List<Item> filteredItems = snapshot.data.where((Item data) => data.category == categoryList[index].name).toList();
                      // return itemListView(filteredItems);
                      }
                    })
                ),
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
                return Container(
                  height: 500,
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
                  child: Column(
                    children: [
                      // const Text('簡単作成'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              keyboardType: TextInputType.text,
                              controller: itemNameController,
                              decoration: const InputDecoration(
                                  labelText: '商品名'
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: TextField(
                                      controller: priceController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: '価格',
                                        suffix: Text('円')
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: '個数',
                                      suffix: Text('個'),
                                    ),
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
                          ],
                        ),
                      ),
                      if (bottomSpace == 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            onPressed: () async{
                              if (itemNameController.text.isNotEmpty && itemQuantityController.text.isNotEmpty) {
                                final id = ItemLocalStore.itemCollection.doc().id;
                                Item newItem = Item(
                                  id: id,
                                  // TODO: _selectedCategoryIndexでcategoryを指定
                                  category: 'なし',
                                  name: itemNameController.text,
                                  price: int.parse(priceController.text),
                                  quantity: int.parse(itemQuantityController.text),
                                  date: _selectedDate,
                                  shop: '',
                                  isFinished: false,
                                  isDeleted: false
                                );
                                var result = await newItem.save();
                                if (result == true) {
                                  _items.putIfAbsent(newItem.id!, () => newItem);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('リストを登録しました。')));
                                  setState(() {
                                    itemNameController.text = '';
                                    priceController.text = '';
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
                        ),
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

  Widget itemListView(Map<String, Item> items) {
    if (items.isNotEmpty) {
      return ListView.builder(
        // shrinkWrap: true,
          itemCount: items.keys.length,
          itemBuilder: (context, index) {
            final key = items.keys.elementAt(index);
            final item = items[key]!;
            return Dismissible(
              onDismissed: (DismissDirection direction) async {
                if (direction == DismissDirection.startToEnd) {
                  item.isDeleted = true;
                  // TODO: delete
                  var result = await item.save();
                  if (result == true) {
                    setState(() {
                      _items.remove(item.id);
                    });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('削除しました。')));
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
                            color: item.isFinished ? Colors.grey : Colors.black,
                            decoration:
                            item.isFinished ? TextDecoration.lineThrough : TextDecoration.none),
                      ),
                      Text(
                        '${item.quantity} 個',
                        style: TextStyle(color: item.isFinished ? Colors.grey : Colors.black),
                      )
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(item.shop),
                      Text('${numberFormatter.format(item.price)} 円')
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: item.isFinished,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  onChanged: (bool? value) async {
                    if (item.isFinished != value) {
                      var result = await item.save();
                      if (result == true) {
                        setState(() {
                          item.isFinished = value!;
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

  }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    if (_categorySubscription != null) _categorySubscription?.cancel();
    super.dispose();
  }
}
