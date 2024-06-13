import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:kauno/components/primary_button.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/model/item_category.dart';
import 'package:kauno/util/localstore/category_localstore.dart';

class WidgetUtils {
   static final numberFormatter = NumberFormat('#,###');

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

  static Row modalHeader(String title, GestureTapCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        InkWell(
          onTap: onTap,
          child: const Icon(
            Icons.close,
            color: Colors.grey,
            size: 40,
          ),
        ),
      ],
    );
  }

  static Future<DateTime?> showDatePicker(
      BuildContext context, DateChangedCallback? onConfirm, DateTime today) {
    return DatePicker.showDatePicker(
        locale: LocaleType.jp,
        context,
        showTitleActions: true,
        minTime: DateTime(today.year, today.month - 3, 1),
        maxTime: DateTime(today.year, today.month + 3, 0),
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
      BuildContext context, GestureTapCallback onTapClose, Widget child) {
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
      padding: const EdgeInsets.all(10),
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
                          // TODO: delete
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

}
