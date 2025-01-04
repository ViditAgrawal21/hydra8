import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/helpers.dart';
import 'package:workmanager/workmanager.dart';

import '../../notifications/notifications.dart';

class ReminderTimesScreen extends StatefulWidget {
  static const routeName = "/reminder-times";
  const ReminderTimesScreen({super.key});

  @override
  _ReminderTimesScreenState createState() => _ReminderTimesScreenState();
}

class _ReminderTimesScreenState extends State<ReminderTimesScreen> {
  TimeOfDay selectedStartReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay selectedFinishReminderTime = const TimeOfDay(hour: 21, minute: 0);

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedStartReminderTime =
          stringToTimeOfDay(prefs.getString("reminder_start_time") ?? "9:00");
      selectedFinishReminderTime =
          stringToTimeOfDay(prefs.getString("reminder_finish_time") ?? "21:00");
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    void setReminders() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool notificationsActive = prefs.getBool("reminders_active") ?? false;
      int selectedReminderInterval = prefs.getInt("reminder_interval") ?? 1;
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

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 40,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                statusBarIconBrightness:
                    isDarkTheme ? Brightness.light : Brightness.dark),
            title: const Text("Reminder Times"),
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            )),
        body: SizedBox(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            Expanded(
                child: SizedBox(
              height: 70,
              child: InkWell(
                onTap: () {
                  showTimePicker(
                          context: context,
                          initialTime: selectedStartReminderTime)
                      .then((value) async {
                    if (value != null) {
                      setState(() {
                        selectedStartReminderTime = value;
                      });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("reminder_start_time",
                          formatTimeOfDay(selectedStartReminderTime));
                      setReminders();
                    }
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatTimeOfDay(selectedStartReminderTime),
                      style: TextStyle(
                          fontSize: 17, color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      "Start Time",
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white60 : Colors.black54),
                    )
                  ],
                ),
              ),
            )),
            const SizedBox(
              width: 10,
            ),
            const Text(
              "-",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: SizedBox(
              height: 70,
              child: InkWell(
                onTap: () {
                  showTimePicker(
                          context: context,
                          initialTime: selectedFinishReminderTime)
                      .then((value) async {
                    if (value != null) {
                      setState(() {
                        selectedFinishReminderTime = value;
                      });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("reminder_finish_time",
                          formatTimeOfDay(selectedFinishReminderTime));
                      setReminders();
                    }
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatTimeOfDay(selectedFinishReminderTime),
                      style: TextStyle(
                          fontSize: 17, color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      "End Time",
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white60 : Colors.black54),
                    )
                  ],
                ),
              ),
            ))
          ]),
        ));
  }
}
