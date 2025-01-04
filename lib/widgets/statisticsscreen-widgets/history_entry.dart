import 'package:flutter/material.dart';
import 'package:my_app/models/DrinkAmount.dart';

class HistoryEntry extends StatelessWidget {
  final Function showDeleteDialog;
  final DrinkAmount amount;

  const HistoryEntry(
      {required this.showDeleteDialog, required this.amount, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDarkTheme
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Press longer on an entry to delete it"),
            behavior: SnackBarBehavior.floating,
          ));
        },
        onLongPress: () => showDeleteDialog(context, amount),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: isDarkTheme
                      ? Colors.white12
                      : const Color.fromRGBO(0, 0, 0, 0.2),
                  width: 1),
            ),
          ),
          padding: const EdgeInsets.all(15),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${amount.createdDate.hour.toString().length > 1 ? amount.createdDate.hour.toString() : "0${amount.createdDate.hour}"}:${amount.createdDate.minute.toString().length > 1 ? amount.createdDate.minute.toString() : "0${amount.createdDate.minute}"}',
              style: TextStyle(
                  color: isDarkTheme
                      ? Colors.white
                      : const Color.fromRGBO(0, 0, 0, 0.8),
                  fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  amount.drinkType == "softDrink"
                      ? "Soft Drink"
                      : amount.drinkType[0].toUpperCase() +
                          amount.drinkType.substring(1),
                  style: TextStyle(
                      color: isDarkTheme
                          ? Colors.white
                          : const Color.fromRGBO(0, 0, 0, 0.8),
                      fontSize: 15),
                ),
                const SizedBox(
                  width: 10,
                ),
                amount.drinkType == "softDrink"
                    ? const Image(
                        image: AssetImage(
                            "assets/images/beverages/soft_drink.png"),
                        height: 25,
                      )
                    : Image(
                        image: AssetImage(
                            "assets/images/beverages/${amount.drinkType}.png"),
                        height: 25,
                      ),
                const SizedBox(width: 15),
                Text(
                  '${amount.amount}${amount.unit}',
                  style: TextStyle(
                      color: isDarkTheme
                          ? Colors.white
                          : const Color.fromRGBO(0, 0, 0, 0.8),
                      fontSize: 16),
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
