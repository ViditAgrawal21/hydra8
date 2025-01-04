import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../helpers/helpers.dart';
import '../../notifications/notifications.dart';

class DrinkReminderScreen extends StatefulWidget {
  static const routeName = "/drink-reminder";
  const DrinkReminderScreen({super.key});

  @override
  _DrinkReminderScreenState createState() => _DrinkReminderScreenState();
}

class _DrinkReminderScreenState extends State<DrinkReminderScreen> {
  int selectedReminderInterval = 1;
  bool notificationsActive = false;

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsActive = prefs.getBool("reminders_active") ?? false;
      selectedReminderInterval = prefs.getInt("reminder_interval") ?? 1;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void setReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TimeOfDay selectedStartReminderTime =
        stringToTimeOfDay(prefs.getString("reminder_start_time") ?? "9:00");
    TimeOfDay selectedFinishReminderTime =
        stringToTimeOfDay(prefs.getString("reminder_finish_time") ?? "21:00");
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

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 40,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                statusBarIconBrightness:
                    isDarkTheme ? Brightness.light : Brightness.dark),
            title: const Text("Drink Reminders"),
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            )),
        body: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () async {
                    if (notificationsActive) {
                      return;
                    }

                    // Request notification permission
                    if (await Permission.notification.request().isGranted) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("reminders_active", true);

                      setState(() {
                        notificationsActive = true;
                      });

                      setReminders(); // Your method to set reminders
                    } else {
                      // Show snackbar and direct user to app settings
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            "Notifications are disabled for this app"),
                        action: SnackBarAction(
                          label: "Settings",
                          onPressed: () async {
                            // Open app settings where user can enable notifications
                            await openAppSettings();
                          },
                        ),
                      ));
                    }
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: notificationsActive
                                ? Theme.of(context).primaryColor
                                : isDarkTheme
                                    ? Colors.white38
                                    : Colors.black38,
                            size: 26,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Intervall",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkTheme
                                        ? Colors.white
                                        : const Color(0xff353535)),
                              ),
                              const Text(
                                "Get reminded every x minutes to drink",
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xff9C9C9C)),
                              ),
                              notificationsActive
                                  ? DropdownButton<int>(
                                      borderRadius: BorderRadius.circular(5),
                                      elevation: 1,
                                      dropdownColor: isDarkTheme
                                          ? const Color.fromARGB(
                                              255, 50, 50, 50)
                                          : Colors.white,
                                      value: selectedReminderInterval,
                                      items: <int>[
                                        0,
                                        1,
                                        2,
                                        3
                                      ].map<DropdownMenuItem<int>>((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(
                                              getReminderIntervalText(value)),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setInt("reminder_interval",
                                            newValue as int);
                                        setState(() {
                                          selectedReminderInterval = newValue;
                                        });
                                        setReminders();
                                      },
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                color: isDarkTheme
                                    ? Colors.white12
                                    : const Color(0xffE4E4E4),
                                thickness: 1,
                                height: 1,
                              ),
                            ],
                          ),
                        )
                      ]),
                )),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () async {
                    await Workmanager().cancelAll();
                    if (!notificationsActive) {
                      return;
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("reminders_active", false);
                    setState(() {
                      notificationsActive = false;
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: !notificationsActive
                                ? Theme.of(context).primaryColor
                                : isDarkTheme
                                    ? Colors.white38
                                    : Colors.black38,
                            size: 26,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Reminders",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkTheme
                                        ? Colors.white
                                        : const Color(0xff353535)),
                              ),
                              const Text(
                                "Don't get reminded to drink",
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xff9C9C9C)),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                color: isDarkTheme
                                    ? Colors.white12
                                    : const Color(0xffE4E4E4),
                                thickness: 1,
                                height: 1,
                              ),
                            ],
                          ),
                        )
                      ]),
                ))
          ],
        ));
  }
}
