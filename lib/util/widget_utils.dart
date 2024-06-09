import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class WidgetUtils {
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
}
