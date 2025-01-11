import 'package:flutter/material.dart';
import 'package:my_app/helpers/helpers.dart';
import 'package:my_app/models/DrinkAmount.dart';
import 'package:my_app/widgets/homescreen-widgets/recent_drinks.dart';

import 'progress.dart';

class HomescreenMain extends StatelessWidget {
  final int todaysDrinkAmount;
  final List<DrinkAmount> drinkAmounts;
  final int prevAmount;
  final int prevIntake;
  final int intakeAmount;
  final bool isActive;
  final bool isSunny;
  final Function sunnyIntakeChange;
  final Function activeIntakeChange;
  final Function onAdd;
  final VoidCallback loadPreferences;
  final String activeUnit;

  const HomescreenMain({
    required this.prevAmount,
    required this.activeUnit,
    required this.prevIntake,
    required this.intakeAmount,
    required this.isActive,
    required this.isSunny,
    required this.onAdd,
    required this.activeIntakeChange,
    required this.sunnyIntakeChange,
    required this.todaysDrinkAmount,
    required this.drinkAmounts,
    required this.loadPreferences,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopActions(
          activeUnit: activeUnit,
          loadPreferences: loadPreferences,
          isSunny: isSunny,
          sunnyIntakeChange: sunnyIntakeChange,
          intakeAmount: intakeAmount,
          isActive: isActive,
          activeIntakeChange: activeIntakeChange,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  kBottomNavigationBarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width < 450
                            ? MediaQuery.of(context).size.width
                            : 450,
                    height:
                        MediaQuery.of(context).size.width < 450
                            ? MediaQuery.of(context).size.width
                            : 450,
                    child: Progress(
                      activeUnit: activeUnit,
                      prevAmount: prevAmount,
                      prevIntake: prevIntake,
                      intakeAmount:
                          int.parse(intakeAmount.toString()) +
                          (isSunny
                              ? getIntakeChangeDifference(activeUnit)
                              : 0) +
                          (isActive
                              ? getIntakeChangeDifference(activeUnit)
                              : 0),
                      todaysAmount: todaysDrinkAmount,
                    ),
                  ),
                  drinkAmounts.isEmpty
                      ? const SizedBox(height: 110)
                      : RecentDrinks(
                        onAdd: onAdd,
                        recentDrinks:
                            drinkAmounts.length < 2
                                ? drinkAmounts.reversed.toList()
                                : drinkAmounts.length >= 5
                                ? drinkAmounts
                                    .sublist(
                                      drinkAmounts.length - 4,
                                      drinkAmounts.length,
                                    )
                                    .reversed
                                    .toList()
                                : drinkAmounts
                                    .sublist(0, drinkAmounts.length)
                                    .reversed
                                    .toList(),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TopActions extends StatelessWidget {
  final bool isSunny;
  final bool isActive;
  final int intakeAmount;
  final Function sunnyIntakeChange;
  final Function activeIntakeChange;
  final VoidCallback loadPreferences;
  final String activeUnit;

  const TopActions({
    super.key,
    required this.isSunny,
    required this.activeUnit,
    required this.sunnyIntakeChange,
    required this.intakeAmount,
    required this.isActive,
    required this.activeIntakeChange,
    required this.loadPreferences,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const BorderDirectional(
          bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1)),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Today's Progress",
                style: TextStyle(
                  color:
                      isDarkTheme
                          ? Colors.white
                          : const Color.fromRGBO(0, 0, 0, 0.75),
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color:
                          isSunny
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                    ),
                    child: IconButton(
                      splashColor: Colors.transparent,
                      tooltip: "Sunny Day",
                      iconSize: 20,
                      onPressed: () {
                        if (!isSunny) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Water Intake: ${isSunny ? "-${getIntakeChangeDifference(activeUnit)}" : "+${getIntakeChangeDifference(activeUnit)}"}$activeUnit (hot day)',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        sunnyIntakeChange(intakeAmount, isActive, isSunny);
                      },
                      icon: Icon(
                        Icons.sunny,
                        color:
                            isSunny
                                ? Colors.white
                                : isDarkTheme
                                ? Colors.white70
                                : const Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    right: 10,
                    left: 10,
                  ),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color:
                          isActive
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                    ),
                    child: IconButton(
                      iconSize: 20,
                      splashColor: Colors.transparent,
                      tooltip: "Active Day",
                      onPressed: () {
                        if (!isActive) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Water Intake: ${isActive ? "-${getIntakeChangeDifference(activeUnit)}" : "+${getIntakeChangeDifference(activeUnit)}"}$activeUnit (active day)',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        activeIntakeChange(intakeAmount, isSunny, isActive);
                      },
                      icon: Icon(
                        Icons.directions_bike_outlined,
                        color:
                            isActive
                                ? Colors.white
                                : isDarkTheme
                                ? Colors.white70
                                : const Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
