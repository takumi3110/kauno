import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:kauno/components/primary_button.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/model/item_category.dart';
import 'package:kauno/util/localstore/category_localstore.dart';

class WidgetUtils {
   static final numberFormatter = NumberFormat('#,###');
   static final _today = DateTime.now();

  static AppBar createAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20),
      ),
      backgroundColor: Colors.white,
      shadowColor: Colors.black,
      elevation: 1,
      // automaticallyImplyLeading: false,
    );
  }

  static InkWell closeIcon(Function onTap, double size) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () => onTap(),
      child: Icon(Icons.close, color: Colors.grey, size: size,),
    );
  }

  static Row modalHeader(String title, Function onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        closeIcon(onTap, 40)
      ],
    );
  }

  static Future<DateTime?> showDatePicker(
      BuildContext context, DateChangedCallback? onConfirm) {
    return DatePicker.showDatePicker(
        locale: LocaleType.jp,
        context,
        showTitleActions: true,
        minTime: DateTime(_today.year, _today.month - 3, 1),
        maxTime: DateTime(_today.year, _today.month + 3, 0),
        onConfirm: onConfirm);
  }

  static Container searchTextBadge(String text, GestureTapCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.grey[400], borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(text),
          const SizedBox(
            width: 5,
          ),
          InkWell(
              onTap: onTap,
              child: const Icon(
                Icons.highlight_remove_outlined,
                size: 16,
              ))
        ],
      ),
    );
  }

  static InkWell searchIconAndModal(
      BuildContext context, Function onTapClose, Widget child) {
    return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          showModalBottomSheet(
              backgroundColor: Colors.white,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
                return Container(
                  width: double.infinity,
                  height: 400 + bottomSpace,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: SizedBox(
                    height: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WidgetUtils.modalHeader('絞り込み', onTapClose),
                        child
                      ],
                    ),
                  ),
                );
              });
        },
        child: const Icon(Icons.search));
  }

  static addCategory(BuildContext context, TextEditingController categoryController) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('カテゴリー追加',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: Column(
                    children: [
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'カテゴリー名入力',
                          // hintText: 'カテゴリーを追加'
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        alignment: Alignment.centerRight,
                        child: PrimaryButton(
                          onPressed: () async {
                            if (categoryController.text.isNotEmpty) {
                              // save category
                              final id = CategoryLocalStore.categoryCollection
                                  .doc()
                                  .id;
                              ItemCategory newCategory = ItemCategory(
                                  id: id, name: categoryController.text);
                              await newCategory.save();
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          children: '登録',
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
        },
      ),
    );
  }

  static Widget itemListView(
      Map<String, Item> items,
      String? categoryName,
      void Function(String itemId) itemRemove,
      Future<void>Function(Item item) onTapItemCard,
      void Function(Item item, bool? value) onChangeCheck,
      ) {
    final dateFormatter = DateFormat('M月d日');
    List<Item> itemList = [];
    if (categoryName != null) {
      final filter =
          items.values.where((item) => item.category == categoryName).toList();
      itemList = filter;
    } else {
      final filter = items.values.toList();
      itemList = filter;
    }
    itemList.sort((a, b) => a.date.isBefore(b.date) ? 1 : -1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          if (itemList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                  // shrinkWrap: true,
                  itemCount: itemList.length,
                  itemBuilder: (context, index) {
                    final item = itemList[index];
                    return Dismissible(
                      onDismissed: (DismissDirection direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          item.isDeleted = true;
                          // delete
                          var result = await item.save();
                          if (result == true) {
                            // setState(() {
                            //   _items.remove(item.id);
                            // });
                            itemRemove(item.id!);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('削除しました。')));
                          }
                        }
                        debugPrint('dismissed');
                      },
                      direction: item.isFinished
                          ? DismissDirection.startToEnd
                          : DismissDirection.none,
                      key: UniqueKey(),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete),
                      ),
                      child: InkWell(
                        onTap: () async {
                          await onTapItemCard(item);
                          // if (item.category != null) {
                          //   categoryController.text = item.category!;
                          // }
                          // _selectedDate = item.date;
                          // dateController.text = dateFormatter.format(item.date);
                          // itemNameController.text = item.name;
                          // priceController.text = item.price.toString();
                          // itemQuantityController.text =
                          //     item.quantity.toString();
                          // shopController.text = item.shop;
                          // await _showModal(item);
                        },
                        child: Card(
                          // margin: const EdgeInsets.symmetric(vertical: 5),
                          color: Colors.white,
                          child: ListTile(
                            // activeColor: Colors.blue,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                      color: item.isFinished
                                          ? Colors.grey
                                          : Colors.black,
                                      decoration: item.isFinished
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                                Text(
                                  '${item.quantity} 個',
                                  style: TextStyle(
                                      color: item.isFinished
                                          ? Colors.grey
                                          : Colors.black),
                                )
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child:
                                          Text(dateFormatter.format(item.date)),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Text(
                                          item.category != null
                                              ? item.category!
                                              : 'カテゴリーなし',
                                          style: const TextStyle(fontSize: 12),
                                        )),
                                    if (item.shop.isNotEmpty)
                                      Text(
                                        item.shop,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                                Text(
                                  '${numberFormatter.format(item.price)} 円',
                                  style: const TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            leading: Checkbox(
                              activeColor: Colors.lightBlueAccent,
                              value: item.isFinished,
                              shape: const CircleBorder(),
                              onChanged: (bool? value) {
                                // setState(() {
                                //   item.isFinished = value!;
                                //   item.save();
                                // });
                                onChangeCheck(item, value);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          if (itemList.isEmpty)
            const Align(
              alignment: Alignment.topCenter,
              child: Text('登録がありません。'),
            )
        ],
      ),
    );
  }
  
  static Future showAddItemModal(
      BuildContext context,
      Function onTapClose,
      void Function(DateTime date) onConfirm,
      TextEditingController dateController,
      TextEditingController categoryController,
      TextEditingController shopController,
      TextEditingController itemNameController,
      TextEditingController priceController,
      TextEditingController itemQuantityController,
      List<ItemCategory> categoryList,
      List<int> quantityList,
      Future<bool>Function(Item?) createItem,
      Item? item
      ) async {
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
                WidgetUtils.modalHeader('商品登録', onTapClose),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(label: Text('日付')),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          WidgetUtils.showDatePicker(
                              context, onConfirm,);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                // if (bottomSpace == 0)
                Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(20),
                    child: PrimaryButton(
                      onPressed: () async {
                        if (itemNameController.text.isNotEmpty &&
                            itemQuantityController.text.isNotEmpty) {
                          var result = await createItem(item);
                          if (result == true) {
                            if (!context.mounted) return;
                            itemNameController.clear();
                              priceController.clear();
                              shopController.clear();
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
                    ))
              ],
            ),
          );
        });
  }

}
