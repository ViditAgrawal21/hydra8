import 'package:flutter/material.dart';
import 'package:my_app/helpers/calculate_intake.dart';

class DrinktypeSelector extends StatelessWidget {
  final DrinkType selectedDrink;
  final Function setSelectedDrink;

  const DrinktypeSelector(
      {required this.selectedDrink, required this.setSelectedDrink, super.key});

  final Map<String, DrinkType> drinks = const {
    "water": DrinkType.water,
    "coffee": DrinkType.coffee,
    "tea": DrinkType.tea,
    "juice": DrinkType.juice,
    "soft drink": DrinkType.softDrink,
    "milk": DrinkType.milk,
  };

  static ColorFilter greyscale = const ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 125,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: drinks.entries.map((entry) {
          return Container(
            margin:
                const EdgeInsets.only(top: 10, bottom: 14, right: 5, left: 5),
            decoration: BoxDecoration(
              border: selectedDrink == entry.value
                  ? Border.all(
                      color: selectedDrink == entry.value
                          ? Theme.of(context).primaryColor
                          : const Color.fromRGBO(0, 0, 0, 0.2),
                      width: selectedDrink == entry.value ? 3 : 3)
                  : Border.all(width: 3, color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: isDarkTheme
                  ? const Color.fromRGBO(255, 255, 255, 0.03)
                  : const Color.fromRGBO(0, 0, 0, 0.03),
              elevation: 0,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                splashColor: Theme.of(context).primaryColor.withAlpha(50),
                borderRadius: BorderRadius.circular(7),
                onTap: () => setSelectedDrink(entry.value),
                child: Container(
                  padding: const EdgeInsets.only(right: 8, left: 8, top: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          height: 60,
                          alignment: Alignment.center,
                          width: 60,
                          child: selectedDrink == entry.value
                              ? entry.value == DrinkType.softDrink
                                  ? const Image(
                                      image: AssetImage(
                                          "assets/images/beverages/soft_drink.png"))
                                  : Image(
                                      image: AssetImage(
                                          "assets/images/beverages/${entry.key}.png"))
                              : ColorFiltered(
                                  colorFilter: greyscale,
                                  child: entry.value == DrinkType.softDrink
                                      ? const Image(
                                          image: AssetImage(
                                              "assets/images/beverages/soft_drink.png"))
                                      : Image(
                                          image: AssetImage(
                                              "assets/images/beverages/${entry.key}.png")),
                                )),
                      Text(
                        entry.key,
                        style: TextStyle(
                            color: selectedDrink == entry.value
                                ? Theme.of(context).primaryColor
                                : isDarkTheme
                                    ? Colors.white70
                                    : const Color.fromRGBO(0, 0, 0, 0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
