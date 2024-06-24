import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteCategory extends StatelessWidget {
  final int index;
  final String name;
  final Future<bool> Function() deleteCategory;

  const DeleteCategory(
      {super.key,
      required this.index,
      required this.name,
      required this.deleteCategory});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          if (index > 0) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: const Text(
                      'このカテゴリーを削除しますか？',
                      style: TextStyle(fontSize: 14),
                    ),
                    content: Text(
                      '【$name】が削除されますが、登録されているアイテムは削除されません。',
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
                          var result = await deleteCategory();
                          if (result == true) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('エラーがあり削除できませんでした。')));
                          }
                        },
                      ),
                    ],
                  );
                });
          }
        },
        child: Icon(
          Icons.delete_forever,
          color: index == 0 ? Colors.grey[400] : Colors.grey[700],
          size: 30,
        ));
  }
}
