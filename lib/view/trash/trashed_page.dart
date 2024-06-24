import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/util/localstore/item_localstore.dart';
import 'package:kauno/util/widget_utils.dart';

class TrashedPage extends StatefulWidget {
  const TrashedPage({super.key});

  @override
  State<TrashedPage> createState() => _TrashedPageState();
}

class _TrashedPageState extends State<TrashedPage> {
  StreamSubscription<Map<String, dynamic>>? _itemSubscription;
  final dateFormatter = DateFormat('yyyy年M月d日');
  List<DeletedItem> deleteItems = [];

  List<String> checkedIds = [];

  void selectedItemDelete(String id) {
    var baseIndex = deleteItems
        .indexWhere((element) => element.items.any((value) => value.id == id));
    var itemIndex = deleteItems[baseIndex].items.indexWhere((element) => element.id == id);
    setState(() {
      // deleteItemsに入ってるitemsのindexを指定して削除
      deleteItems[baseIndex].items.removeAt(itemIndex);
      // 指定したindexのitemsが空になった場合、deleteItemsも削除
      if (deleteItems[baseIndex].items.isEmpty) {
        deleteItems.removeAt(baseIndex);
      }
    });
  }

  @override
  void initState() {
    _itemSubscription =
        ItemLocalStore.itemCollection.stream.where((event) => Item.fromMap(event).isDeleted).listen((event) {
      final item = Item.fromMap(event);
      setState(() {
        if (deleteItems.isEmpty) {
          deleteItems.add(DeletedItem(date: item.date, items: [item]));
        } else {
          if (deleteItems.any((result) => result.date.isAtSameMomentAs(item.date))) {
            final index = deleteItems.indexWhere((result) => result.date.isAtSameMomentAs(item.date));
            deleteItems[index].items.add(item);
          } else {
            deleteItems.add(DeletedItem(date: item.date, items: [item]));
          }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: WidgetUtils.createAppBar('削除済みリスト'),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (checkedIds.isNotEmpty)
                GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text(
                                '選択したアイテムを削除します。',
                                style: TextStyle(fontSize: 16),
                              ),
                              content: const Text('この操作は元に戻すことができません。'),
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
                                      try {
                                        for (var id in checkedIds) {
                                          await ItemLocalStore.itemCollection.doc(id).delete();
                                          selectedItemDelete(id);
                                        }
                                        setState(() {
                                          checkedIds = [];
                                        });
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(content: Text('選択したアイテムを削除しました。')));
                                        Navigator.pop(context);
                                      } catch (e) {
                                        debugPrint('item削除エラー: $e');
                                      }
                                    })
                              ],
                            );
                          });
                    },
                    child: const Text(
                      '選択した項目を削除する',
                      style: TextStyle(color: Colors.blue),
                    )),
              if (checkedIds.isEmpty)
                GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('ゴミ箱を空にします。'),
                              content: const Text('ゴミ箱のアイテムを完全に削除します。この操作は元に戻すことができません。'),
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
                                      List<Item> items = [
                                        for (var data in deleteItems)
                                          for (var item in data.items) item
                                      ];
                                      try {
                                        for (Item item in items) {
                                          item.delete();
                                        }
                                        setState(() {
                                          checkedIds = [];
                                          deleteItems = [];
                                        });
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(content: Text('アイテムを削除しました。')));
                                        Navigator.pop(context);
                                      } catch (e) {
                                        debugPrint('item削除エラー');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(content: Text('削除に失敗しました。')));
                                      }
                                    })
                              ],
                            );
                          });
                    },
                    child: const Text(
                      'ゴミ箱を空にする',
                      style: TextStyle(color: Colors.blue),
                    )),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: deleteItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      DeletedItem deletedItem = deleteItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateFormatter.format(deletedItem.date)),
                            const Divider(),
                            for (var item in deletedItem.items)
                              Dismissible(
                                key: Key(item.id!.toString()),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Row(
                                    children: [Icon(Icons.refresh), Text('元に戻す')],
                                  ),
                                ),
                                onDismissed: (_) async {
                                  item.isDeleted = false;
                                  var result = await item.save();
                                  if (result == true) {
                                    selectedItemDelete(item.id!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text('${item.name}を元に戻しました。')));
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  color: Colors.white,
                                  child: CheckboxListTile(
                                    activeColor: Colors.blue,
                                    title: Text(item.name),
                                    value: checkedIds.contains(item.id),
                                    onChanged: (bool? value) {
                                      if (value == true) {
                                        setState(() {
                                          checkedIds.add(item.id!);
                                        });
                                      } else {
                                        setState(() {
                                          final checkedIndex = checkedIds.indexOf(item.id!);
                                          checkedIds.removeAt(checkedIndex);
                                        });
                                      }
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        )));
  }

  @override
  void dispose() {
    if (_itemSubscription != null) _itemSubscription?.cancel();
    super.dispose();
  }
}
