import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/components/add_category.dart';
import 'package:kauno/components/category_tab.dart';
import 'package:kauno/components/delete_category.dart';
import 'package:kauno/components/primary_button.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/model/item_category.dart';
import 'package:kauno/util/disable_focus_node.dart';
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
  TextEditingController itemQuantityController =
      TextEditingController(text: '1');
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController(text: '0');
  TextEditingController dateController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController searchShopController = TextEditingController();
  TextEditingController searchDateController = TextEditingController();
  DateTime? searchDate;

  StreamSubscription<Map<String, dynamic>>? _itemSubscription;
  StreamSubscription<Map<String, dynamic>>? _categorySubscription;
  final Map<String, Item> _defaultItems = {};
  final _items = <String, Item>{};

  final List<int> quantityList = List.generate(10, (index) => index + 1);

  final dateFormatter = DateFormat('M月d日');
  final DateTime _today = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<ItemCategory> categoryList = [
    ItemCategory(name: 'すべて'),
  ];

  int _selectCategoryIndex = 0;

  Future<bool> deleteCategory() async {
    try {
      // itemにあるカテゴリーをnullにする
      final items = _items.values.where(
          (item) => item.category == categoryList[_selectCategoryIndex].name);
      for (var item in items) {
        item.category = null;
        await item.save();
      }
      // 登録してあるカテゴリーを削除
      await categoryList[_selectCategoryIndex].delete();
      // カテゴリーリストから該当のカテゴリーを削除
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

  void onConfirm(DateTime date) {
    setState(() {
      dateController.text = dateFormatter.format(date);
      _selectedDate = date;
    });
  }

  Future<bool> createItem(Item? item) async {
    if (item != null) {
      setState(() {
        item.category = categoryController.text;
        item.name = itemNameController.text;
        item.price = int.parse(priceController.text);
        item.quantity = int.parse(itemQuantityController.text);
        item.date = _selectedDate;
        item.shop = shopController.text;
      });
      return await item.save();
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
          quantity: int.parse(itemQuantityController.text),
          date: _selectedDate,
          shop: shopController.text,
          isFinished: false,
          isDeleted: false);
      return await newItem.save();
    }
  }

  void clearController() {
    itemNameController.clear();
    itemQuantityController.text = '1';
    priceController.clear();
    categoryController.clear();
    shopController.clear();
}

  @override
  void initState() {
    _itemSubscription = ItemLocalStore.itemCollection.stream
        .where((event) => !Item.fromMap(event).isDeleted)
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
    dateController.text = dateFormatter.format(_today);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onTapSearchDate() {
      searchDateController.clear();
      setState(() {
        searchDate = null;
        _items.addAll(_defaultItems);
        if (searchShopController.text.isNotEmpty) {
          _items.removeWhere(
              (key, value) => value.shop != searchShopController.text);
        }
      });
      // searchDate = null;
    }

    onTapSearchShop() {
      searchShopController.clear();
      setState(() {
        _items.addAll(_defaultItems);
        if (searchDate != null) {
          _items.removeWhere((key, value) =>
              dateFormatter.format(value.date) !=
              dateFormatter.format(searchDate!));
        }
      });
    }

    void onTapSearchClose() {
      setState(() {
        searchDate = null;
      });
      searchDateController.clear();
      Navigator.pop(context);
    }

    void onTapAddModalClose() {
      clearController();
      _selectedDate = DateTime.now();
      Navigator.pop(context);
    }

    Future<void> onTapItemCard(Item item) async {
    if (item.category != null) {
      categoryController.text = item.category!;
    }
    _selectedDate = item.date;
    dateController.text = dateFormatter.format(item.date);
    itemNameController.text = item.name;
    priceController.text = item.price.toString();
    itemQuantityController.text = item.quantity.toString();
    shopController.text = item.shop;
    WidgetUtils.showAddItemModal(
        context,
        onTapAddModalClose,
        onConfirm,
        dateController,
        categoryController,
        shopController,
        itemNameController,
        priceController,
        itemQuantityController,
        categoryList,
        quantityList,
        createItem,
        item
    );
  }

    return Scaffold(
      appBar: WidgetUtils.createAppBar('リスト'),
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
                                  name: categoryList[index].name),
                            );
                          }),
                    ),
                    AddCategory(categoryController: categoryController),
                    DeleteCategory(
                        index: _selectCategoryIndex,
                        name: categoryList[_selectCategoryIndex].name,
                        deleteCategory: deleteCategory)
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: [
                    WidgetUtils.searchIconAndModal(
                        context,
                        onTapSearchClose,
                        Container(
                          height: 300,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextField(
                                  focusNode: AlwaysDisabledFocusNode(),
                                  controller: searchDateController,
                                  decoration:
                                      const InputDecoration(labelText: '月日'),
                                  onTap: () {
                                    onConfirm(DateTime date) {
                                      searchDateController.text =
                                          dateFormatter.format(date);
                                      setState(() {
                                        searchDate = date;
                                      });
                                    }

                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    WidgetUtils.showDatePicker(
                                        context, onConfirm);
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: TextField(
                                    controller: searchShopController,
                                    decoration: const InputDecoration(
                                        labelText: '購入店舗'),
                                  ),
                                ),
                                PrimaryButton(
                                    onPressed: () {
                                      setState(() {
                                        if (searchDate != null) {
                                          _items.removeWhere((key, value) =>
                                              dateFormatter
                                                  .format(value.date) !=
                                              dateFormatter
                                                  .format(searchDate!));
                                        }
                                        if (searchShopController
                                            .text.isNotEmpty) {
                                          _items.removeWhere((key, value) =>
                                              value.shop !=
                                              searchShopController.text);
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    children: '検索'),
                              ],
                            ),
                          ),
                        )),
                    if (searchDateController.text.isNotEmpty)
                      WidgetUtils.searchTextBadge(
                        searchDateController.text,
                        onTapSearchDate,
                      ),
                    if (searchShopController.text.isNotEmpty)
                      WidgetUtils.searchTextBadge(
                          searchShopController.text, onTapSearchShop),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                    index: _selectCategoryIndex,
                    children: List.generate(categoryList.length, (index) {
                      String? categoryName =
                          index > 0 ? categoryList[index].name : null;
                      return WidgetUtils.itemListView(_items, categoryName,
                          itemRemove, onTapItemCard, onChangeCheck);
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
          clearController();
          dateController.text = dateFormatter.format(_today);
          WidgetUtils.showAddItemModal(
              context,
              onTapAddModalClose,
              onConfirm,
              dateController,
              categoryController,
              shopController,
              itemNameController,
              priceController,
              itemQuantityController,
              categoryList,
              quantityList,
              createItem,
            null
          );
          // await _showModal(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Future _showModal(Item? item) async {
  //   onTapClose() {
  //     Navigator.pop(context);
  //     categoryController.clear();
  //     itemNameController.clear();
  //     priceController.text = '0';
  //     itemQuantityController.text = '1';
  //     _selectedDate = DateTime.now();
  //     shopController.clear();
  //   }
  //
  //   await showModalBottomSheet(
  //       backgroundColor: Colors.white,
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (BuildContext context) {
  //         final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
  //         return Container(
  //           // color: Colors.white,
  //           height: MediaQuery.sizeOf(context).height * 0.8 + bottomSpace,
  //           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               WidgetUtils.modalHeader('商品登録', onTapClose),
  //               Padding(
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //                 child: ListView(
  //                   shrinkWrap: true,
  //                   children: [
  //                     TextField(
  //                       controller: dateController,
  //                       decoration: const InputDecoration(label: Text('日付')),
  //                       onTap: () {
  //                         FocusScope.of(context).requestFocus(FocusNode());
  //                         WidgetUtils.showDatePicker(
  //                             context, onConfirm, _today);
  //                       },
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 10),
  //                       child: categoryController.text.isNotEmpty
  //                           ? DropdownButtonFormField(
  //                               disabledHint: const Text(
  //                                 '選べるカテゴリーがありません',
  //                                 style: TextStyle(fontSize: 14),
  //                               ),
  //                               decoration:
  //                                   const InputDecoration(labelText: 'カテゴリー'),
  //                               items: categoryList
  //                                   .where((category) => category.name != 'すべて')
  //                                   .map<DropdownMenuItem<String>>(
  //                                       (ItemCategory value) {
  //                                 return DropdownMenuItem(
  //                                     value: value.name,
  //                                     child: Text(value.name));
  //                               }).toList(),
  //                               value: categoryController.text,
  //                               // value: categoryList[0],
  //                               // value: categoryList.firstWhere((category) => category.name == categoryController.text, orElse: () => null),
  //                               onChanged: (String? value) {
  //                                 if (value != null) {
  //                                   categoryController.text = value;
  //                                 }
  //                               })
  //                           : DropdownButtonFormField(
  //                               disabledHint: const Text(
  //                                 '選べるカテゴリーがありません',
  //                                 style: TextStyle(fontSize: 14),
  //                               ),
  //                               decoration:
  //                                   const InputDecoration(labelText: 'カテゴリー'),
  //                               items: categoryList
  //                                   .where((category) => category.name != 'すべて')
  //                                   .map<DropdownMenuItem<String>>(
  //                                       (ItemCategory value) {
  //                                 return DropdownMenuItem(
  //                                     value: value.name,
  //                                     child: Text(value.name));
  //                               }).toList(),
  //                               onChanged: (String? value) {
  //                                 if (value != null) {
  //                                   categoryController.text = value;
  //                                 }
  //                               }),
  //                     ),
  //                     TextField(
  //                       keyboardType: TextInputType.text,
  //                       controller: shopController,
  //                       decoration: const InputDecoration(labelText: '店舗'),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 10),
  //                       child: TextField(
  //                         keyboardType: TextInputType.text,
  //                         controller: itemNameController,
  //                         decoration: const InputDecoration(labelText: '商品名'),
  //                       ),
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         Expanded(
  //                           child: Padding(
  //                             padding: const EdgeInsets.only(right: 10),
  //                             child: TextField(
  //                               controller: priceController,
  //                               keyboardType: TextInputType.number,
  //                               decoration: const InputDecoration(
  //                                   labelText: '価格', suffix: Text('円')),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 100,
  //                           child: DropdownButtonFormField(
  //                               decoration: const InputDecoration(
  //                                 labelText: '個数',
  //                                 suffix: Text('個'),
  //                               ),
  //                               items: quantityList
  //                                   .map<DropdownMenuItem<int>>((int value) {
  //                                 return DropdownMenuItem<int>(
  //                                     value: value,
  //                                     child: Text(value.toString()));
  //                               }).toList(),
  //                               value: int.parse(itemQuantityController.text),
  //                               onChanged: (int? value) {
  //                                 itemQuantityController.text =
  //                                     value.toString();
  //                               }),
  //                         )
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               // if (bottomSpace == 0)
  //               Container(
  //                   alignment: Alignment.bottomRight,
  //                   padding: const EdgeInsets.all(20),
  //                   child: PrimaryButton(
  //                     onPressed: () async {
  //                       if (itemNameController.text.isNotEmpty &&
  //                           itemQuantityController.text.isNotEmpty) {
  //                         var result = false;
  //                         if (item != null) {
  //                           setState(() {
  //                             item.category = categoryController.text;
  //                             item.name = itemNameController.text;
  //                             item.price = int.parse(priceController.text);
  //                             item.quantity =
  //                                 int.parse(itemQuantityController.text);
  //                             item.date = _selectedDate;
  //                             item.shop = shopController.text;
  //                           });
  //                           result = await item.save();
  //                         } else {
  //                           final id = ItemLocalStore.itemCollection.doc().id;
  //                           Item newItem = Item(
  //                               id: id,
  //                               category: categoryController.text.isNotEmpty
  //                                   ? categoryController.text
  //                                   : null,
  //                               name: itemNameController.text,
  //                               price: priceController.text.isNotEmpty
  //                                   ? int.parse(priceController.text)
  //                                   : 0,
  //                               quantity:
  //                                   int.parse(itemQuantityController.text),
  //                               date: _selectedDate,
  //                               shop: shopController.text,
  //                               isFinished: false,
  //                               isDeleted: false);
  //                           result = await newItem.save();
  //                         }
  //
  //                         if (result == true) {
  //                           if (!context.mounted) return;
  //                           // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('リストを登録しました。')));
  //                           setState(() {
  //                             // _items.putIfAbsent(newItem.id!, () => newItem);
  //                             itemNameController.clear();
  //                             priceController.clear();
  //                             shopController.clear();
  //                           });
  //                         } else {
  //                           if (!context.mounted) return;
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                               const SnackBar(
  //                                   content: Text('リストの登録に失敗しました。')));
  //                         }
  //                       }
  //                       if (!context.mounted) return;
  //                       Navigator.pop(context);
  //                     },
  //                     children: '登録',
  //                   ))
  //             ],
  //           ),
  //         );
  //       });
  // }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    if (_categorySubscription != null) _categorySubscription?.cancel();
    super.dispose();
  }
}
