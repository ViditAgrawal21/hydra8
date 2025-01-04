import 'package:flutter/material.dart';

import '../helpers/helpers.dart';
import '../models/DrinkAmount.dart';
import '../widgets/statisticsscreen-widgets/history_list.dart';
import '../widgets/statisticsscreen-widgets/statistics_chart.dart';
import '../widgets/statisticsscreen-widgets/statistics_chart_month.dart';
import '../widgets/statisticsscreen-widgets/statistics_chart_year.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = "/statistics";
  final List<DrinkAmount> drinksAmounts;
  final String activeUnit;
  final int intakeAmount;

  const StatisticsScreen(
      {required this.intakeAmount,
      required this.activeUnit,
      required this.drinksAmounts,
      super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = "Week";

  @override
  Widget build(BuildContext context) {
    List<int> data = [];
    if (selectedPeriod == "Week") {
      data = [0, 0, 0, 0, 0, 0, 0];
      for (var element in widget.drinksAmounts.reversed) {
        for (var i = 0; i <= 6; i++) {
          DateTime date = DateTime.now().subtract(Duration(days: i));
          if (element.createdDate.year == date.year &&
              element.createdDate.month == date.month &&
              element.createdDate.day == date.day) {
            data[6 - i] +=
                (element.amount * getDrinkFactor(element.drinkType)).round();
          }
        }
      }
    } else if (selectedPeriod == "Month") {
      data = [0, 0, 0, 0];
      for (var element in widget.drinksAmounts) {
        for (var i = 0; i <= 3; i++) {
          for (var j = 0; j <= 6; j++) {
            DateTime date = DateTime.now()
                .subtract(Duration(days: DateTime.now().weekday + (7 * i)))
                .add(Duration(days: j));
            if (element.createdDate.year == date.year &&
                element.createdDate.month == date.month &&
                element.createdDate.day == date.day) {
              data[3 - i] +=
                  (element.amount * getDrinkFactor(element.drinkType)).round();
            }
          }
        }
      }
      data = data.map((e) => (e / 7).round()).toList();
    } else if (selectedPeriod == "Year") {
      data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      for (var element in widget.drinksAmounts) {
        for (var i = 0; i <= 11; i++) {
          if (i == 11 &&
              element.createdDate.month ==
                  DateTime.now().subtract(const Duration(days: 365)).month &&
              element.createdDate.year ==
                  DateTime.now().subtract(const Duration(days: 365)).year) {
            data[11 - i] +=
                (element.amount * getDrinkFactor(element.drinkType)).round();
            break;
          }
          if (i != 11 &&
              element.createdDate.month ==
                  DateTime.now()
                      .subtract(Duration(days: DateTime.now().day - 1 + 31 * i))
                      .month &&
              element.createdDate.year ==
                  DateTime.now()
                      .subtract(Duration(days: DateTime.now().day - 1 + 31 * i))
                      .year) {
            data[11 - i] +=
                (element.amount * getDrinkFactor(element.drinkType)).round();
          }
        }
      }
      print(data);
      data = data.map((e) => (e / 30).round()).toList();
    }

    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkTheme
          ? const Color(0xff2D2D2D)
          : const Color.fromRGBO(0, 0, 0, 0.03),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("History"),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 20),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                "Chart Period",
                style: TextStyle(
                    fontSize: 15,
                    color: isDarkTheme ? Colors.white : Colors.black87),
              ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: 100,
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: Color(0xffD9D9D9),
                  ),
                  dropdownColor: isDarkTheme
                      ? const Color.fromARGB(255, 50, 50, 50)
                      : Colors.white,
                  style: TextStyle(
                      fontSize: 19, color: Theme.of(context).primaryColor),
                  underline: Container(),
                  borderRadius: BorderRadius.circular(5),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPeriod = newValue!;
                    });
                  },
                  isExpanded: true,
                  elevation: 1,
                  hint: const Text("Choose Unit"),
                  items: <String>["Week", "Month", "Year"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: 70,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          Divider(
            color: isDarkTheme
                ? const Color(0xff4B4B4B)
                : const Color.fromRGBO(0, 0, 0, 0.1),
            height: 1,
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const BorderDirectional(
                    bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)))),
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 230,
                  child: selectedPeriod == "Week"
                      ? StatisticsChart(
                          data: data,
                          intakeAmount: widget.intakeAmount,
                          activeUnit: widget.activeUnit,
                        )
                      : selectedPeriod == "Month"
                          ? StatisticsChartMonth(
                              activeUnit: widget.activeUnit,
                              data: data,
                              intakeAmount: widget.intakeAmount)
                          : StatisticsChartYear(
                              activeUnit: widget.activeUnit,
                              data: data,
                              intakeAmount: widget.intakeAmount),
                ),
              ],
            ),
          ),
          Expanded(child: HistoryList(drinkAmounts: widget.drinksAmounts))
        ]),
      ),
    );
  }
}
