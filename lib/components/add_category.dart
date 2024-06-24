import 'package:flutter/material.dart';
import 'package:kauno/components/primary_button.dart';
import 'package:kauno/model/item_category.dart';
import 'package:kauno/util/localstore/category_localstore.dart';

class AddCategory extends StatelessWidget {
  final TextEditingController categoryController;
  const AddCategory({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
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
                          categoryController.clear();
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
                              try {
                                await newCategory.save();
                                if (!context.mounted) return;
                            Navigator.pop(context);
                            categoryController.clear();
                              } on Exception catch (e) {
                                debugPrint('カテゴリー登録エラー: $e');
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('エラーがあり登録できませんでした。')));
                              }
                            }

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
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }
}
