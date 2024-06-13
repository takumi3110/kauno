import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:kauno/components/add_category.dart';
import 'package:kauno/components/category_tab.dart';
import 'package:kauno/components/delete_category.dart';
import 'package:kauno/components/primary_button.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/model/item_category.dart';
import 'package:kauno/util/function_utils.dart';
import 'package:kauno/util/localstore/category_localstore.dart';
import 'package:kauno/util/localstore/item_localstore.dart';
import 'package:kauno/util/widget_utils.dart';

class DetailPage extends StatefulWidget {
  final DateTime date;

  const DetailPage({super.key, required this.date});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemQuantityController =
      TextEditingController(text: '1');
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController(text: '0');
  TextEditingController dateController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController searchShopController = TextEditingController();

  StreamSubscription<Map<String, dynamic>>? _itemSubscription;
  StreamSubscription<Map<String, dynamic>>? _categorySubscription;
  final Map<String, Item> _items = <String, Item>{};
  final Map<String, Item> _defaultItems = {};

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  final List<DropdownMenuItem> shopList = [];

  final numberFormatter = NumberFormat('#,###');
  final dateFormatter = DateFormat('yyyy年M月d日');
  late DateTime _date;

  final List<ItemCategory> categoryList = [
    ItemCategory(name: 'すべて'),
  ];

  int _selectCategoryIndex = 0;

  Future<bool> deleteCategory() async {
    try {
      final items = _items.values.where(
          (item) => item.category == categoryList[_selectCategoryIndex].name);
      for (var item in items) {
        item.category = null;
        await item.save();
      }
      await categoryList[_selectCategoryIndex].delete();
      setState(() {
        categoryList.removeAt(_selectCategoryIndex);
        _selectCategoryIndex = 0;
      });
      return true;
    } catch (e) {
      debugPrint('カテゴリー削除エラー: $e');
      return false;
    }
  }

  Future<void> onTapItemCard(Item item) async {
    if (item.category != null) {
      categoryController.text = item.category!;
    }
    dateController.text = dateFormatter.format(item.date);
    itemNameController.text = item.name;
    priceController.text = item.price.toString();
    itemQuantityController.text = item.quantity.toString();
    shopController.text = item.shop;
    await _showModal(item);
  }

  void itemRemove(String itemId) {
    setState(() {
      _items.remove(itemId);
    });
  }

  void onChangeCheck(Item item, bool? value) {
    setState(() {
      item.isFinished = value!;
      item.save();
    });
  }

  @override
  void initState() {
    _itemSubscription = ItemLocalStore.itemCollection.stream
        .where((event) =>
            !Item.fromMap(event).isDeleted &&
            Item.fromMap(event).date.isAtSameMomentAs(widget.date))
        .listen((event) {
      if (mounted) {
        final item = Item.fromMap(event);
        setState(() {
          _items.putIfAbsent(item.id!, () => item);
          _defaultItems.putIfAbsent(item.id!, () => item);
        });
      }
      // if (kIsWeb) ItemLocalStore.itemCollection.stream.asBroadcastStream();
    });
    _categorySubscription =
        CategoryLocalStore.categoryCollection.stream.listen((event) {
      if (mounted) {
        setState(() {
          final category = ItemCategory.fromMap(event);
          categoryList.add(category);
        });
      }
      // if (kIsWeb) CategoryLocalStore.categoryCollection.stream.asBroadcastStream();
    });
    setState(() {
      dateController.text = dateFormatter.format(widget.date);
      _date = widget.date;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: WidgetUtils.createAppBar(
          '${dateFormatter.format(_date)}(${FunctionUtils.formatWeekday(_date.weekday)})'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                          // shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                setState(() {
                                  _selectCategoryIndex = index;
                                });
                              },
                              child: CategoryTab(
                                  isSelected: _selectCategoryIndex == index,
                                  name: categoryList[index].name
                              ),
                            );
                          }),
                    ),
                    AddCategory(categoryController: categoryController),
                    DeleteCategory(
                        index: _selectCategoryIndex,
                        name: categoryList[_selectCategoryIndex].name,
                        deleteCategory: deleteCategory
                    )
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                    index: _selectCategoryIndex,
                    children: List.generate(categoryList.length, (index) {
                      String? categoryName =
                          index > 0 ? categoryList[index].name : null;
                      return WidgetUtils.itemListView(_items, categoryName, itemRemove, onTapItemCard, onChangeCheck);
                    })),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        onPressed: () async {
          itemNameController.text = '';
          priceController.text = '';
          itemQuantityController.text = '1';
          await _showModal(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future _showModal(Item? item) async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            // color: Colors.white,
            height: MediaQuery.sizeOf(context).height * 0.8 + bottomSpace,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('商品登録',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        categoryController.text = '';
                        itemNameController.text = '';
                        priceController.text = '0';
                        itemQuantityController.text = '1';
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
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
                              minTime: DateTime(_date.year, _date.month, 1),
                              maxTime: DateTime(_date.year, _date.month + 1, 0),
                              onConfirm: (DateTime date) {
                            setState(() {
                              dateController.text = dateFormatter.format(date);
                            });
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: categoryController.text.isNotEmpty
                            ? DropdownButtonFormField(
                                disabledHint: const Text(
                                  '選べるカテゴリーがありません',
                                  style: TextStyle(fontSize: 14),
                                ),
                                decoration:
                                    const InputDecoration(labelText: 'カテゴリー'),
                                items: categoryList
                                    .where((category) => category.name != 'すべて')
                                    .map<DropdownMenuItem<String>>(
                                        (ItemCategory value) {
                                  return DropdownMenuItem(
                                      value: value.name,
                                      child: Text(value.name));
                                }).toList(),
                                value: categoryController.text,
                                // value: categoryList[0],
                                // value: categoryList.firstWhere((category) => category.name == categoryController.text, orElse: () => null),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    categoryController.text = value;
                                  }
                                })
                            : DropdownButtonFormField(
                                disabledHint: const Text(
                                  '選べるカテゴリーがありません',
                                  style: TextStyle(fontSize: 14),
                                ),
                                decoration:
                                    const InputDecoration(labelText: 'カテゴリー'),
                                items: categoryList
                                    .where((category) => category.name != 'すべて')
                                    .map<DropdownMenuItem<String>>(
                                        (ItemCategory value) {
                                  return DropdownMenuItem(
                                      value: value.name,
                                      child: Text(value.name));
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    categoryController.text = value;
                                  }
                                }),
                      ),
                      TextField(
                        keyboardType: TextInputType.text,
                        controller: shopController,
                        decoration: const InputDecoration(labelText: '店舗'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: itemNameController,
                          decoration: const InputDecoration(labelText: '商品名'),
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
                                    labelText: '価格', suffix: Text('円')),
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
                                items: quantityList
                                    .map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()));
                                }).toList(),
                                value: int.parse(itemQuantityController.text),
                                onChanged: (int? value) {
                                  itemQuantityController.text =
                                      value.toString();
                                }),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(20),
                    child: PrimaryButton(
                      onPressed: () async {
                        if (itemNameController.text.isNotEmpty &&
                            itemQuantityController.text.isNotEmpty) {
                          var result = false;
                          if (item != null) {
                            setState(() {
                              item.category = categoryController.text;
                              item.name = itemNameController.text;
                              item.price = int.parse(priceController.text);
                              item.quantity =
                                  int.parse(itemQuantityController.text);
                              item.date = _date;
                              item.shop = shopController.text;
                            });
                            result = await item.save();
                          } else {
                            final id = ItemLocalStore.itemCollection.doc().id;
                            Item newItem = Item(
                                id: id,
                                category: categoryController.text.isNotEmpty
                                    ? categoryController.text
                                    : null,
                                name: itemNameController.text,
                                price: priceController.text.isNotEmpty
                                    ? int.parse(priceController.text)
                                    : 0,
                                quantity:
                                    int.parse(itemQuantityController.text),
                                date: _date,
                                shop: shopController.text,
                                isFinished: false,
                                isDeleted: false);
                            result = await newItem.save();
                          }

                          if (result == true) {
                            if (!context.mounted) return;
                            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('リストを登録しました。')));
                            setState(() {
                              // _items.putIfAbsent(newItem.id!, () => newItem);
                              itemNameController.text = '';
                              priceController.text = '';
                              shopController.text = '';
                            });
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('リストの登録に失敗しました。')));
                          }
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      children: '登録',
                    )),
                // if (bottomSpace == 0)
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    if (_categorySubscription != null) _categorySubscription?.cancel();
    super.dispose();
  }
}
