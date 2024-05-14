import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kauno/model/item.dart';
import 'package:kauno/util/widget_utils.dart';

class TrashedPage extends StatefulWidget {
  const TrashedPage({super.key});

  @override
  State<TrashedPage> createState() => _TrashedPageState();
}

class _TrashedPageState extends State<TrashedPage> {
  final dateFormatter = DateFormat('yyyy年M月d日');

  List<int> checkedList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: WidgetUtils.createAppBar('削除済みリスト'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            // child: StreamBuilder(
            //     stream: ItemSqlite.getDeletedItemStream(),
            //     builder: (context, snapshot) {
            //       return Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           if (checkedList.isNotEmpty)
            //             GestureDetector(
            //                 onTap: () {
            //                   showDialog(
            //                       context: context,
            //                       builder: (BuildContext context) {
            //                         return CupertinoAlertDialog(
            //                           title: const Text(
            //                             '選択したアイテムを削除します。',
            //                             style: TextStyle(fontSize: 16),
            //                           ),
            //                           content: const Text('この操作は元に戻すことができません。'),
            //                           actions: [
            //                             CupertinoDialogAction(
            //                               isDestructiveAction: true,
            //                               onPressed: () {
            //                                 Navigator.pop(context);
            //                               },
            //                               child: const Text('キャンセル'),
            //                             ),
            //                             CupertinoDialogAction(
            //                                 child: const Text('OK'),
            //                                 onPressed: () async {
            //                                   var result = await ItemSqlite.deleteItems(checkedList);
            //                                   if (result == true) {
            //                                     setState(() {
            //                                       checkedList = [];
            //                                     });
            //                                     if (!context.mounted) return;
            //                                     ScaffoldMessenger.of(context)
            //                                         .showSnackBar(const SnackBar(content: Text('選択したアイテムを削除しました。')));
            //                                     Navigator.pop(context);
            //                                   }
            //                                 })
            //                           ],
            //                         );
            //                       });
            //                 },
            //                 child: const Text(
            //                   '選択した項目を削除する',
            //                   style: TextStyle(color: Colors.blue),
            //                 )),
            //           if (checkedList.isEmpty)
            //             GestureDetector(
            //                 onTap: () {
            //                   showDialog(
            //                       context: context,
            //                       builder: (BuildContext context) {
            //                         return CupertinoAlertDialog(
            //                           title: const Text('ゴミ箱を空にします。'),
            //                           content: const Text('ゴミ箱のアイテムを完全に削除します。この操作は元に戻すことができません。'),
            //                           actions: [
            //                             CupertinoDialogAction(
            //                               isDestructiveAction: true,
            //                               onPressed: () {
            //                                 Navigator.pop(context);
            //                               },
            //                               child: const Text('キャンセル'),
            //                             ),
            //                             CupertinoDialogAction(
            //                                 child: const Text('OK'),
            //                                 onPressed: () async {
            //                                   List<int> itemIds = [for (var data in snapshot.data) for (var item in data.items) item.id];
            //                                   var result = await ItemSqlite.deleteItems(itemIds);
            //                                   if (result == true) {
            //                                     setState(() {
            //                                       checkedList = [];
            //                                     });
            //                                     if (!context.mounted) return;
            //                                     ScaffoldMessenger.of(context)
            //                                         .showSnackBar(const SnackBar(content: Text('アイテムを削除しました。')));
            //                                     Navigator.pop(context);
            //                                   }
            //                                 })
            //                           ],
            //                         );
            //                       });
            //                 },
            //                 child: const Text(
            //                   'ゴミ箱を空にする',
            //                   style: TextStyle(color: Colors.blue),
            //                 )),
            //           const SizedBox(
            //             height: 10,
            //           ),
            //           snapshot.hasData && snapshot.data.length > 0
            //               ? Expanded(
            //                   child: ListView.builder(
            //                       itemCount: snapshot.data!.length,
            //                       itemBuilder: (BuildContext context, int index) {
            //                         DeletedItem deletedItem = snapshot.data![index];
            //                         return Padding(
            //                           padding: const EdgeInsets.only(bottom: 15),
            //                           child: Column(
            //                             mainAxisSize: MainAxisSize.min,
            //                             crossAxisAlignment: CrossAxisAlignment.start,
            //                             children: [
            //                               Text(dateFormatter.format(deletedItem.date)),
            //                               const Divider(),
            //                               for (var item in deletedItem.items)
            //                                 Dismissible(
            //                                   key: Key(item.id!.toString()),
            //                                   direction: DismissDirection.startToEnd,
            //                                   background: Container(
            //                                     alignment: Alignment.centerRight,
            //                                     child: const Row(
            //                                       children: [
            //                                         Icon(Icons.refresh),
            //                                         Text('元に戻す')
            //                                       ],
            //                                     ),
            //                                   ),
            //                                   onDismissed: (_) async{
            //                                     item.isDeleted = false;
            //                                     var result = await ItemSqlite.updateItem(item);
            //                                     if (result == true) {
            //                                       if (!context.mounted) return;
            //                                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name}を元に戻しました。')));
            //                                     }
            //                                   },
            //                                   child: Card(
            //                                     margin: const EdgeInsets.symmetric(vertical: 5),
            //                                     color: Colors.white,
            //                                     child: CheckboxListTile(
            //                                       activeColor: Colors.blue,
            //                                       title: Text(item.name),
            //                                       value: checkedList.contains(item.id),
            //                                       onChanged: (bool? value) {
            //                                         if (value == true) {
            //                                           setState(() {
            //                                             checkedList.add(item.id!);
            //                                           });
            //                                         } else {
            //                                           setState(() {
            //                                             final checkedIndex = checkedList.indexOf(item.id!);
            //                                             checkedList.removeAt(checkedIndex);
            //                                           });
            //                                         }
            //                                         debugPrint(checkedList.contains(item.id).toString());
            //                                       },
            //                                       controlAffinity: ListTileControlAffinity.leading,
            //                                     ),
            //                                   ),
            //                                 )
            //                               // Flexible(
            //                               //   fit: FlexFit.loose,
            //                               //   child: Padding(
            //                               //     padding: const EdgeInsets.only(bottom: 20.0),
            //                               //     child: ListView.builder(
            //                               //         shrinkWrap: true,
            //                               //         itemCount: deletedItem.items.length,
            //                               //         itemBuilder: (BuildContext context, int itemIndex) {
            //                               //           if (deletedItem.items.isNotEmpty) {
            //                               //             Item item = deletedItem.items[itemIndex];
            //                               //             return Card(
            //                               //               margin: const EdgeInsets.symmetric(vertical: 5),
            //                               //               color: Colors.white,
            //                               //               child: CheckboxListTile(
            //                               //                 activeColor: Colors.blue,
            //                               //                 title: Text(item.name),
            //                               //                 value: checkedList.contains(item.id),
            //                               //                 onChanged: (bool? value) {
            //                               //                   if (value == true) {
            //                               //                     setState(() {
            //                               //                       checkedList.add(item.id!);
            //                               //                     });
            //                               //                   } else {
            //                               //                     setState(() {
            //                               //                       final checkedIndex = checkedList.indexOf(item.id!);
            //                               //                       checkedList.removeAt(checkedIndex);
            //                               //                     });
            //                               //                   }
            //                               //                   debugPrint(checkedList.contains(item.id).toString());
            //                               //                 },
            //                               //                 controlAffinity: ListTileControlAffinity.leading,
            //                               //               ),
            //                               //             );
            //                               //           }
            //                               //           return Container();
            //                               //         }),
            //                               //   ),
            //                               // )
            //                             ],
            //                           ),
            //                         );
            //                       }),
            //                 )
            //               : const Align(
            //                   alignment: Alignment.topCenter,
            //                   child: Text('削除されたアイテムはありません。'),
            //                 )
            //         ],
            //       );
            //     }),
            child: Container(),
          ),
        ));
  }
}
