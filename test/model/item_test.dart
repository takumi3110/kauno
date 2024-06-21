import 'package:flutter_test/flutter_test.dart';
import 'package:kauno/model/item.dart';

void main() {
  group('Testing App Provider', () {
    Item newItem = Item(
        id: 'test',
        category: 'test_category',
        name: 'test',
        price: 100,
        quantity: 1,
        date: DateTime.now(),
        shop: 'test shop',
        isFinished: false,
        isDeleted: false
      );
    test('A new item should be added.', () async{
      var result = await newItem.save();
      expect(result, true);
    });

    test('An item should be check isFinished.', () async{
      newItem.isFinished = true;
      var result = await newItem.save();
      expect(result, true);
    });

    test('An Item should be check isDeleted.', () async{
      newItem.isDeleted = true;
      var result = await newItem.save();
      expect(result, true);
    });

    test('An item should be check deleted.', () async{
      var result = await newItem.delete();
      expect(result, true);
    });
  });
}