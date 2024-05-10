import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/Item.dart';
import 'package:kauno/model/category.dart';
import 'package:kauno/util/function_utils.dart';
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
  TextEditingController categoryController = TextEditingController();

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  final dateFormatter = DateFormat('yyyy年M月d日');
  final _today = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<Category> categoryList = [
    Category(name: 'すべて'),
  ];

  int _selectCategoryIndex = 0;

  @override
  void initState() {
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
                                          onPressed: () {
                                            if(categoryController.text.isNotEmpty) {
                                              setState(() {
                                                categoryList.add(Category(name: categoryController.text));
                                              });
                                            }
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
                            onPressed: () {
                              setState(() {
                                categoryList.removeAt(_selectCategoryIndex);
                              });
                                Navigator.pop(context);
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
                child: StreamBuilder(
                    stream: ItemSqlite.getItemStream(dateFormatter.format(_selectedDate)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return IndexedStack(
                          index: _selectCategoryIndex,
                          children: List.generate(categoryList.length, (index) {
                            switch(_selectCategoryIndex) {
                              case 0:
                                return itemListView(snapshot.data);
                              default:
                                List<Item> filteredItems = snapshot.data.where((Item data) => data.category == categoryList[index].name).toList();
                                return itemListView(filteredItems);
                            }
                          })
                        );
                      } else {
                        return const Center(
                          child: Text('登録がありません。'),
                        );
                      }
                    })
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
                      const Text('簡単作成'),
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
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: '価格',
                                      suffix: Text('円')
                                    ),
                                  )
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
                                Item newItem = Item(
                                  // TODO: _selectedCategoryIndexでcategoryを指定
                                  category: 'なし',
                                  name: itemNameController.text,
                                  quantity: int.parse(itemQuantityController.text),
                                  date: _selectedDate,
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

  Widget itemListView(List<Item> items) {
    if (items.isNotEmpty) {
      return ListView.builder(
        // shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            Item item = items[index];
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

  }
}
