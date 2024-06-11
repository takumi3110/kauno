import 'package:flutter/material.dart';

class CategoryTab extends StatelessWidget {
  final bool isSelected;
  final String name;
  const CategoryTab({
    super.key,
    required this.isSelected,
    required this.name
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            // border: Border(bottom: BorderSide(color: _selectCategoryIndex == index ? Colors.blue: Colors.grey))
            border: Border(
                bottom: isSelected
                    ? const BorderSide(color: Colors.blue)
                    : BorderSide.none)),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ));
  }
}
