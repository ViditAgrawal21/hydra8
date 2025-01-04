import 'package:flutter/material.dart';
import 'package:my_app/boxes.dart';
import 'package:my_app/helpers/calculate_intake.dart';
import 'package:my_app/models/DrinkAmount.dart';

class RecentDrinks extends StatelessWidget {
  final Function onAdd;
  final List<DrinkAmount> recentDrinks;

  const RecentDrinks(
      {required this.onAdd, required this.recentDrinks, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: recentDrinks.map((DrinkAmount drink) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    width: 70,
                    height: 110,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(0, 0, 0, 0.05),
                            width: 0),
                        borderRadius: BorderRadius.circular(10)),
                    child: Material(
                      elevation: 6,
                      shadowColor: Colors.black12,
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      child: Tooltip(
                        message: drink.drinkType,
                        child: InkWell(
                          splashColor:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          highlightColor:
                              Theme.of(context).primaryColor.withOpacity(.2),
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            final drinkAmount = DrinkAmount()
                              ..amount = drink.amount
                              ..unit = drink.unit
                              ..createdDate = DateTime.now()
                              ..drinkType = drink.drinkType;
                            final box = Boxes.getDrinkAmounts();
                            box.add(drinkAmount);
                            onAdd();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 4),
                            margin: const EdgeInsets.only(right: 6, left: 6),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  padding: const EdgeInsets.all(14),
                                  child: drink.drinkType ==
                                          DrinkType.softDrink.name
                                      ? const Image(
                                          image: AssetImage(
                                              "assets/images/beverages/soft_drink.png"))
                                      : Image(
                                          image: AssetImage(
                                              "assets/images/beverages/${drink.drinkType}.png")),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${drink.amount}${drink.unit}',
                                        style: TextStyle(
                                            color: isDarkTheme
                                                ? const Color(0xffDDDDDD)
                                                : const Color.fromRGBO(
                                                    0, 0, 0, 0.5)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
