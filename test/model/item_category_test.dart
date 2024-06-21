import 'package:flutter_test/flutter_test.dart';
import 'package:kauno/model/item_category.dart';

void main() {
  group('Testing App Provider.', () {
    ItemCategory newCategory = ItemCategory(
      id: 'test',
        name: 'test_category'
    );

    test('A new category should be added.', () async{
      var result = await newCategory.save();
      expect(result, true);
    });

    test('A category should be deleted.', () async{
      var result = await newCategory.delete();
      expect(result, true);
    });

  });
}