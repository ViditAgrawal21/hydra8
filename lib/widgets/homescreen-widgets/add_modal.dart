import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/boxes.dart';
import 'package:my_app/helpers/calculate_intake.dart';
import 'package:my_app/models/DrinkAmount.dart';
import 'package:my_app/widgets/homescreen-widgets/drinktype_selector.dart';

class AddModal extends StatefulWidget {
  final Function onAdd;
  const AddModal({required this.onAdd, super.key});

  @override
  AddModalState createState() => AddModalState();
}

class AddModalState extends State<AddModal> {
  int _currentAmount = 100;
  String activeUnit = "";

  DateTime activeDate = DateTime.now();
  TimeOfDay activeTime = TimeOfDay.now();

  DrinkType selectedDrink = DrinkType.water;

  void loadActiveUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      activeUnit = prefs.getString("unit") ?? "";
      _currentAmount = (activeUnit == "ml" ? 200 : 10);
    });
  }

  @override
  void initState() {
    loadActiveUnit();
    super.initState();
  }

  void setSelectedDrink(newDrink) {
    setState(() {
      selectedDrink = newDrink;
    });
  }

  void addHandler(
      int amount, String unit, DateTime createdDate, DrinkType drinkType) {
    final drinkAmount = DrinkAmount()
      ..amount = amount
      ..unit = unit
      ..createdDate = createdDate
      ..drinkType = drinkType.name;
    final box = Boxes.getDrinkAmounts();
    box.add(drinkAmount);
    widget.onAdd();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Wrap(children: [
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color.fromRGBO(0, 0, 0, 0.2)),
              ),
              Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  color: Theme.of(context).colorScheme.surface,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.14),
                                        blurRadius: 2,
                                        offset: Offset(1, 1))
                                  ]),
                              child: Row(children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10)),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      height: 50,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                            foregroundColor: const Color.fromRGBO(
                                                0, 0, 0, 0.7), padding: const EdgeInsets.all(0),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)))),
                                        onPressed: () {
                                          showDatePicker(
                                                  context: context,
                                                  initialDate: activeDate,
                                                  firstDate:
                                                      DateTime(2000, 1, 1),
                                                  lastDate:
                                                      DateTime(2100, 1, 1))
                                              .then((value) {
                                            if (value != null) {
                                              setState(() {
                                                activeDate = value;
                                              });
                                            }
                                          });
                                        },
                                        child: Text(
                                            (activeDate.day ==
                                                        DateTime.now().day &&
                                                    activeDate.month ==
                                                        DateTime.now().month &&
                                                    activeDate.year ==
                                                        DateTime.now().year)
                                                ? "Today"
                                                : '${activeDate.day.toString()}/${activeDate.month.toString()}/${activeDate.year.toString()}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: isDarkTheme
                                                    ? Colors.white
                                                    : const Color.fromRGBO(
                                                        0, 0, 0, 0.7))),
                                      ),
                                    ))
                              ]),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    color: Theme.of(context).colorScheme.surface,
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.14),
                                          blurRadius: 2,
                                          offset: Offset(1, 1))
                                    ]),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: const Color.fromRGBO(0, 0, 0, 0.7), padding: const EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  onPressed: () {
                                    showTimePicker(
                                            context: context,
                                            initialTime: activeTime)
                                        .then((value) {
                                      if (value != null) {
                                        setState(() {
                                          activeTime = value;
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                      '${activeTime.hour}:${activeTime.minute.toString().length < 2 ? "0${activeTime.minute}" : activeTime.minute}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: isDarkTheme
                                              ? Colors.white
                                              : const Color.fromRGBO(
                                                  0, 0, 0, 0.7))),
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      DrinktypeSelector(
                        selectedDrink: selectedDrink,
                        setSelectedDrink: setSelectedDrink,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NumberPicker(
                                  minValue: activeUnit == "ml" ? 10 : 5,
                                  maxValue: 10000,
                                  itemHeight: 50,
                                  textStyle: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.white38
                                          : const Color.fromRGBO(0, 0, 0, 0.3),
                                      fontSize: 18),
                                  selectedTextStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 18),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1.5,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          top: BorderSide(
                                              width: 1.5,
                                              color: Theme.of(context)
                                                  .primaryColor))),
                                  value: _currentAmount,
                                  step: activeUnit == "ml" ? 10 : 5,
                                  haptics: true,
                                  onChanged: (value) {
                                    setState(() {
                                      _currentAmount = value;
                                    });
                                  }),
                              Text(
                                activeUnit,
                                style: TextStyle(
                                    fontSize: 19,
                                    color: Theme.of(context).primaryColor),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: SizedBox(
                                    height: 50,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).primaryColor, backgroundColor: isDarkTheme
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1)
                                              : Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.15),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(8))),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                  )),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation:
                                                _currentAmount > 0 ? 0 : 0, backgroundColor: Theme.of(context).primaryColor,
                                            shadowColor: const Color.fromARGB(
                                                    255, 4, 217, 255)
                                                .withOpacity(.5),
                                            splashFactory:
                                                InkRipple.splashFactory,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        onPressed: () => addHandler(
                                            _currentAmount,
                                            activeUnit,
                                            DateTime(
                                                activeDate.year,
                                                activeDate.month,
                                                activeDate.day,
                                                activeTime.hour,
                                                activeTime.minute),
                                            selectedDrink),
                                        child: const Text(
                                          "Add",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ]),
    );
  }
}
