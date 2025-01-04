import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/calculate_intake.dart';
import 'package:my_app/helpers/helpers.dart';
import 'package:my_app/notifications/notifications.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/widgets/setup-widgets/reminder_time_dialog.dart';
import 'package:workmanager/workmanager.dart';

import '../models/DrinkAmount.dart';

class SetupScreen extends StatefulWidget {
  static const routeName = "/setup";

  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String activeUnit = "ml";
  String activeWeightUnit = "kg";

  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool weightIsValid = true;
  bool ageIsValid = true;

  int _currentGoal = 100;
  int activeTabIndex = 0;
  bool unitIsValid = true;

  bool notificationsActive = false;
  TimeOfDay selectedStartReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay selectedFinishReminderTime = const TimeOfDay(hour: 21, minute: 0);
  int selectedReminderInterval = 1;

  @override
  void initState() {
    Hive.openBox<DrinkAmount>('drink_amounts');
    super.initState();
  }

  bool validateWeight({bool setError = true}) {
    if (weightController.text.isEmpty || int.parse(weightController.text) < 1) {
      if (setError) {
        setState(() {
          weightIsValid = false;
        });
      }
      return false;
    }
    if (setError) {
      setState(() {
        weightIsValid = true;
      });
    }
    return true;
  }

  bool validateAge({bool setError = true}) {
    if (ageController.text.isEmpty || int.parse(ageController.text) < 1) {
      if (setError) {
        setState(() {
          ageIsValid = false;
        });
      }

      return false;
    }
    if (setError) {
      setState(() {
        ageIsValid = true;
      });
    }
    return true;
  }

  void openReminderDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
                padding: const EdgeInsets.all(20),
                child: ReminderTimeDialog(
                  selectedReminderInterval: selectedReminderInterval,
                  selectedFinishReminderTime: selectedFinishReminderTime,
                  selectedStartReminderTime: selectedStartReminderTime,
                  setEndTime: (TimeOfDay newTime) {
                    setState(() {
                      selectedFinishReminderTime = newTime;
                    });
                  },
                  setStartTime: (TimeOfDay newTime) {
                    setState(() {
                      selectedStartReminderTime = newTime;
                    });
                  },
                  setInterval: (int newInterval) {
                    setState(() {
                      selectedReminderInterval = newInterval;
                    });
                  },
                )),
          );
        });
  }

  void setReminders(SharedPreferences prefs) async {
    prefs.setBool("reminders_active", notificationsActive);
    prefs.setInt("reminder_interval", selectedReminderInterval);
    prefs.setString(
        "reminder_start_time", formatTimeOfDay(selectedStartReminderTime));
    prefs.setString(
        "reminder_finish_time", formatTimeOfDay(selectedFinishReminderTime));
    if (notificationsActive) {
      await Workmanager().cancelAll();
      await Workmanager()
          .initialize(remindersCallbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask("reminder", "Reminder",
          inputData: {
            "start_hour": selectedStartReminderTime.hour,
            "start_minute": selectedStartReminderTime.minute,
            "finish_hour": selectedFinishReminderTime.hour,
            "finish_minute": selectedFinishReminderTime.minute,
            "init_time": TimeOfDay.now().toString(),
          },
          frequency: getDurationFromIntervalInt(selectedReminderInterval));
    }
  }

  void onSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final bool calculateiInputDataIsValid = validateWeight() && validateAge();

    if (activeTabIndex == 0 && calculateiInputDataIsValid) {
      prefs.setString("unit", activeUnit);
      setReminders(prefs);

      // Perform async operation and check if the widget is mounted
      prefs
          .setInt(
        "intake_amount",
        calculateIntake(
          num.parse(weightController.text),
          int.parse(ageController.text),
          activeWeightUnit,
          activeUnit,
        ),
      )
          .then((value) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeScreen.routeName,
            (_) => false,
          );
        }
      });
    } else if (activeTabIndex == 1) {
      setReminders(prefs);
      prefs.setString("unit", activeUnit);

      // Perform async operation and check if the widget is mounted
      prefs.setInt("intake_amount", _currentGoal).then((value) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeScreen.routeName,
            (_) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final unitSelection = Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 10, top: 25, right: 25, left: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ["ml", "oz UK", "oz US"]
            .map(
              (String unit) => OutlinedButton(
                  onPressed: () {
                    setState(() {
                      activeUnit = unit;
                    });
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                      backgroundColor: WidgetStateProperty.all(
                          activeUnit == unit
                              ? Theme.of(context).primaryColor
                              : Colors.transparent),
                      side: WidgetStateProperty.all(BorderSide(
                          color: activeUnit == unit
                              ? Theme.of(context).primaryColor
                              : isDarkTheme
                                  ? const Color(0xff515151)
                                  : const Color(0xffE9E9E9)))),
                  child: Text(
                    unit,
                    style: TextStyle(
                        color: activeUnit == unit
                            ? Colors.white
                            : isDarkTheme
                                ? const Color(0xffCACACA)
                                : const Color(0xff383838)),
                  )),
            )
            .toList(),
      ),
    );

    final calculateSide = Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your Weight",
              style: TextStyle(
                  fontSize: 18,
                  color: isDarkTheme ? Colors.white : const Color(0xFF3B3B3B)),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 150,
                  child: TextField(
                    onChanged: (_) {
                      validateWeight();
                    },
                    decoration: InputDecoration(
                      label: const Text("Weight"),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: weightIsValid
                                ? Theme.of(context).primaryColor
                                : Colors.red,
                            width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: weightIsValid
                                ? const Color(0xffD9D9D9)
                                : Colors.red,
                            width: 1.5),
                      ),
                    ),
                    style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.normal),
                    controller: weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                DropdownButton<String>(
                  value: activeWeightUnit,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: Color(0xffD9D9D9),
                  ),
                  elevation: 1,
                  dropdownColor: isDarkTheme
                      ? const Color.fromARGB(255, 50, 50, 50)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  underline: Container(
                    height: 1,
                    color: isDarkTheme ? Colors.white12 : Colors.black12,
                  ),
                  style: TextStyle(
                      color: isDarkTheme
                          ? Colors.white54
                          : const Color.fromRGBO(0, 0, 0, 0.4)),
                  onChanged: (String? newValue) {
                    setState(() {
                      activeWeightUnit = newValue!;
                    });
                  },
                  items: <String>['kg', 'lbs']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Select your Age",
              style: TextStyle(
                  fontSize: 20,
                  color: isDarkTheme ? Colors.white : const Color(0xFF3B3B3B)),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 120,
                  child: TextField(
                    onChanged: (_) => validateAge(),
                    decoration: InputDecoration(
                      label: const Text("Age"),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ageIsValid
                                ? Theme.of(context).primaryColor
                                : Colors.red,
                            width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ageIsValid
                                ? const Color(0xffD9D9D9)
                                : Colors.red,
                            width: 1.5),
                      ),
                    ),
                    controller: ageController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  "Years",
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          isDarkTheme ? Colors.white : const Color(0xFF3B3B3B)),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Your weight and age are only used for the calculation and will not be saved.",
              style: TextStyle(
                  fontSize: 13,
                  color: isDarkTheme
                      ? const Color.fromRGBO(255, 255, 255, .5)
                      : const Color.fromRGBO(0, 0, 0, 0.5)),
            )
          ],
        ));

    final manualSide = Padding(
      padding: const EdgeInsets.all(20),
      child: activeUnit == ""
          ? const Center(child: Text("Please select a unit"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select your Goal manually",
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          isDarkTheme ? Colors.white : const Color(0xFF3B3B3B)),
                ),
                Row(
                  children: [
                    NumberPicker(
                        minValue: activeUnit == "ml" ? 100 : 5,
                        maxValue: 10000,
                        itemHeight: 50,
                        textStyle: TextStyle(
                            color: isDarkTheme
                                ? Colors.white30
                                : const Color.fromRGBO(0, 0, 0, 0.3),
                            fontSize: 18),
                        selectedTextStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.5,
                                    color: Theme.of(context).primaryColor),
                                top: BorderSide(
                                    width: 1.5,
                                    color: Theme.of(context).primaryColor))),
                        value: _currentGoal,
                        step: activeUnit == "ml" ? 100 : 5,
                        haptics: true,
                        onChanged: (value) {
                          setState(() {
                            _currentGoal = value;
                          });
                        }),
                    Text(
                      activeUnit,
                      style: TextStyle(
                          fontSize: 19, color: Theme.of(context).primaryColor),
                    )
                  ],
                )
              ],
            ),
    );

    final tabBar = Column(
      children: [
        TabBar(
          onTap: (value) {
            setState(() {
              activeTabIndex = value;
            });
          },
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
          unselectedLabelColor:
              isDarkTheme ? const Color(0xffE9E9E9) : const Color(0xff8C8C8C),
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
          labelPadding: const EdgeInsets.only(bottom: 0),
          tabs: const [
            Tab(
              text: "Calculate Goal",
            ),
            Tab(
              text: "Choose Goal",
            )
          ],
        ),
        SizedBox(
          height: 340,
          child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [calculateSide, manualSide]),
        )
      ],
    );

    return Scaffold(
        floatingActionButton: AnimatedOpacity(
          opacity: (activeTabIndex == 0 &&
                      validateAge(setError: false) &&
                      validateWeight(setError: false)) ||
                  activeTabIndex == 1
              ? 1
              : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            scale: (activeTabIndex == 0 &&
                        validateAge(setError: false) &&
                        validateWeight(setError: false)) ||
                    activeTabIndex == 1
                ? 1
                : 0.5,
            child: FloatingActionButton.extended(
              onPressed: onSubmit,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              icon: Text(
                activeTabIndex == 0 ? "Finish" : "Finish",
                style: const TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              extendedIconLabelSpacing: 15,
              label: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          ),
        ),
        body: DefaultTabController(
          length: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Setup",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                              color: isDarkTheme
                                  ? Colors.white
                                  : const Color(0xff383838)),
                        ),
                      ],
                    ),
                  ),
                  unitSelection,
                  tabBar,
                  Divider(
                    height: 1,
                    color: isDarkTheme ? Colors.white30 : Colors.black26,
                  ),
                  SwitchListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 20, right: 20),
                    activeColor: Theme.of(context).primaryColor,
                    value: notificationsActive,
                    title: const Text("Activate Reminders"),
                    onChanged: (bool newValue) async {
                      if (newValue) {
                        // Request notification permission
                        if (await Permission.notification.request().isGranted) {
                          setState(() {
                            notificationsActive = newValue;
                          });
                        } else {
                          // Show a snackbar and prompt the user to open settings
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                                "Notifications are disabled for this app"),
                            action: SnackBarAction(
                              label: "Settings",
                              onPressed: () async {
                                // Open app settings
                                await openAppSettings();
                              },
                            ),
                          ));
                        }
                      } else {
                        // Directly update state when turning off notifications
                        setState(() {
                          notificationsActive = newValue;
                        });
                      }
                    },
                  ),
                  !notificationsActive
                      ? Container()
                      : SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () {
                              openReminderDialog(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(children: [
                                Text(
                                  "${formatTimeOfDay(selectedStartReminderTime)} - ${formatTimeOfDay(selectedFinishReminderTime)}",
                                  style: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 23),
                                ),
                                Text(
                                  getReminderIntervalText(
                                      selectedReminderInterval),
                                  style: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 12),
                                )
                              ]),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 100,
                  ),
                ]),
              ],
            ),
          ),
        ));
  }
}
