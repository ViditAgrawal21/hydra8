import 'package:flutter/material.dart';
import 'package:my_app/boxes.dart';
import 'package:my_app/helpers/helpers.dart';
import 'package:my_app/models/DrinkAmount.dart';
import 'package:my_app/widgets/statisticsscreen-widgets/history_entry.dart';

class HistoryList extends StatelessWidget {
  final List<DrinkAmount> drinkAmounts;
  const HistoryList({required this.drinkAmounts, super.key});

  String formatDate(DateTime date) {
    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      return "Today";
    }
    return '${date.day} ${parseMonth(date.month)} ${date.year != DateTime.now().year ? date.year : ""} (${parseDay(date.weekday)}.)';
  }

  void showDeleteFromDayDialog(
      context, MapEntry<String, List<DrinkAmount>> entry) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: const Text('Delete all Entries from date'),
        content: const Text(
            'Are you sure you want to delete all entries from this date?'),
        contentPadding: const EdgeInsets.only(left: 20, bottom: 5, right: 20),
        titlePadding:
            const EdgeInsets.only(top: 20, left: 20, bottom: 5, right: 15),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final List<DrinkAmount> backupList = [];
              for (var amount in entry.value) {
                final DrinkAmount backupAmount = DrinkAmount()
                  ..amount = amount.amount
                  ..unit = amount.unit
                  ..createdDate = amount.createdDate
                  ..drinkType = amount.drinkType;
                backupList.add(backupAmount);
                amount.delete();
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Deleted entries"),
                action: SnackBarAction(
                  label: "Undo",
                  onPressed: () {
                    final box = Boxes.getDrinkAmounts();
                    for (var backupAmount in backupList) {
                      box.add(backupAmount);
                    }
                  },
                  textColor: Theme.of(context).primaryColor,
                ),
                behavior: SnackBarBehavior.floating,
              ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25), backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete',
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(context, amount) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        contentPadding: const EdgeInsets.only(left: 20, bottom: 5, right: 20),
        titlePadding:
            const EdgeInsets.only(top: 20, left: 20, bottom: 5, right: 15),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final DrinkAmount backupAmount = DrinkAmount()
                ..amount = amount.amount
                ..unit = amount.unit
                ..createdDate = amount.createdDate
                ..drinkType = amount.drinkType;
              amount.delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Deleted entry"),
                action: SnackBarAction(
                  label: "Undo",
                  onPressed: () {
                    final box = Boxes.getDrinkAmounts();
                    box.add(backupAmount);
                  },
                  textColor: Theme.of(context).primaryColor,
                ),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25), backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete',
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    drinkAmounts.sort(((a, b) => a.createdDate.compareTo(b.createdDate)));

    Map<String, List<DrinkAmount>> datesMap = {};
    for (var element in drinkAmounts.reversed) {
      String dateString = DateTime(element.createdDate.year,
              element.createdDate.month, element.createdDate.day)
          .toString();
      if (datesMap.containsKey(dateString)) {
        (datesMap[dateString] as List).add(element);
      } else {
        datesMap[dateString] = [element];
      }
    }

    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return drinkAmounts.isEmpty
        ? Center(
            child: Text("No Data",
                style: TextStyle(
                    color: isDarkTheme
                        ? Colors.white
                        : const Color.fromRGBO(0, 0, 0, 0.7))),
          )
        : ListView(
            children: datesMap.entries.map((e) {
              return Column(
                children: [
                  Material(
                    color: isDarkTheme
                        ? const Color.fromRGBO(0, 0, 0, 0.03)
                        : const Color(0xffF9F9F9),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "Press longer on a date to delete all of it's entries"),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      onLongPress: () {
                        showDeleteFromDayDialog(context, e);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          formatDate(DateTime.parse(e.key)),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  ...e.value
                      .map((DrinkAmount amount) => HistoryEntry(
                          showDeleteDialog: showDeleteDialog, amount: amount))
                      ,
                ],
              );
            }).toList(),
          );
  }
}
