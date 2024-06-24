import 'dart:async';

import 'package:flutter/material.dart';
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
    });
  }

  Future<bool> createItem(Item? item) async {
    if (item != null) {
      setState(() {
        item.category = categoryController.text;
        item.name = itemNameController.text;
        item.price = int.parse(priceController.text);
        item.quantity = int.parse(itemQuantityController.text);
        item.date = _date;
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
          date: _date,
          shop: shopController.text,
          isFinished: false,
          isDeleted: false);
      return await newItem.save();
    }
  }

  void clearController() {
    itemNameController.clear();
    itemQuantityController.clear();
    priceController.clear();
    categoryController.clear();
    shopController.clear();
  }

  void onTapSearchShop() {
    searchShopController.clear();
    setState(() {
      _items.addAll(_defaultItems);
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
    void onTapAddModalClose() {
      clearController();
      Navigator.pop(context);
    }

    void onTapSearchClose() {
      searchShopController.clear();
      Navigator.pop(context);
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
          item);
    }

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
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                  controller: searchShopController,
                                  decoration:
                                      const InputDecoration(labelText: '購入店舗'),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: PrimaryButton(
                                    onPressed: () {
                                      setState(() {
                                        if (searchShopController
                                            .text.isNotEmpty) {
                                          _items.removeWhere((key, value) =>
                                              value.shop !=
                                              searchShopController.text);
                                        }
                                        Navigator.pop(context);
                                      });
                                    },
                                    children: '検索',
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                    if (searchShopController.text.isNotEmpty)
                      WidgetUtils.searchTextBadge(
                          searchShopController.text, onTapSearchShop)
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
          itemNameController.text = '';
          priceController.text = '';
          itemQuantityController.text = '1';
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
              null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    if (_categorySubscription != null) _categorySubscription?.cancel();
    super.dispose();
  }
}
