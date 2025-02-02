import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/screens/start_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/helpers.dart';
import 'package:my_app/helpers/theme_provider.dart';
import 'package:my_app/notifications/notifications.dart';
import 'package:my_app/screens/about_screen.dart';
import 'package:my_app/screens/settings-screens/drink_reminder_screen.dart';
import 'package:my_app/screens/settings-screens/intake_goal_screen.dart';
import 'package:my_app/screens/settings-screens/reminder_times_screen.dart';
import 'package:my_app/screens/startup_navigation.dart';
import 'package:my_app/widgets/settings-screen/settings_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import '../boxes.dart';
import '../widgets/setup-widgets/calculate_dialog.dart';
import '../widgets/setup-widgets/reminder_time_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/screens/bluetooth_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "/settings";

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String activeUnit = "";
  int _currentGoal = 2000;

  bool notificationsActive = false;
  TimeOfDay selectedStartReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay selectedFinishReminderTime = const TimeOfDay(hour: 21, minute: 0);
  int selectedReminderInterval = 1;

  bool unitIsExpanded = false;
  bool intakeIsExpanded = false;
  bool remindersIsExpanded = false;

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      activeUnit = prefs.getString("unit") ?? "";
      notificationsActive = prefs.getBool("reminders_active") ?? false;
      selectedStartReminderTime = stringToTimeOfDay(
        prefs.getString("reminder_start_time") ?? "9:00",
      );
      selectedFinishReminderTime = stringToTimeOfDay(
        prefs.getString("reminder_finish_time") ?? "21:00",
      );
      selectedReminderInterval = prefs.getInt("reminder_interval") ?? 1;
      _currentGoal = prefs.getInt("intake_amount") ?? 2000;
    });
  }

  void openReminderDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
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
            ),
          ),
        );
      },
    ).then((value) async {
      if (value) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt("reminder_interval", selectedReminderInterval);
        prefs.setString(
          "reminder_start_time",
          formatTimeOfDay(selectedStartReminderTime),
        );
        prefs.setString(
          "reminder_finish_time",
          formatTimeOfDay(selectedFinishReminderTime),
        );
        setReminders();
      }
    });
  }

  void setReminders() async {
    await Workmanager().cancelAll();
    await Workmanager().initialize(
      remindersCallbackDispatcher,
      isInDebugMode: false,
    );
    await Workmanager().registerPeriodicTask(
      "reminder",
      "Reminder",
      inputData: {
        "start_hour": selectedStartReminderTime.hour,
        "start_minute": selectedStartReminderTime.minute,
        "finish_hour": selectedFinishReminderTime.hour,
        "finish_minute": selectedFinishReminderTime.minute,
        "init_time": TimeOfDay.now().toString(),
      },
      frequency: getDurationFromIntervalInt(selectedReminderInterval),
    );
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void setUnit(String newUnit) async {
    if (newUnit != activeUnit) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      onChangeUnit(activeUnit, newUnit, prefs);
      prefs.setString("unit", newUnit);
      setState(() {
        _currentGoal = prefs.getInt("intake_amount") ?? 0;
        activeUnit = newUnit;
      });
    }
  }

  void setGoal(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("intake_amount", value);
  }

  void showCalculateDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              children: [
                CalculateDialog(
                  setIntake: (int value) {
                    setState(() {
                      _currentGoal = value;
                    });
                  },
                  activeUnit: activeUnit,
                ),
              ],
            ),
          ),
    );
  }

  void showUnitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // const Row(
                    //   children: [
                    //     Text(
                    //       "Unit System",
                    //       style: TextStyle(fontSize: 16),
                    //       textAlign: TextAlign.start,
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        setUnit("ml");
                        Navigator.pop(context);
                      },
                      title: const Text("Metric System (L/ml)"),
                      leading: Radio<String>(
                        activeColor: Theme.of(context).primaryColor,
                        value: "ml",
                        groupValue: activeUnit,
                        onChanged: (String? value) {
                          setUnit(value as String);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    // ListTile(
                    //   contentPadding: const EdgeInsets.all(0),
                    //   onTap: () {
                    //     setUnit("oz UK");
                    //     Navigator.pop(context);
                    //   },
                    //   title: const Text("UK System (fl. oz)"),
                    //   leading: Radio<String>(
                    //     activeColor: Theme.of(context).primaryColor,
                    //     value: "oz UK",
                    //     groupValue: activeUnit,
                    //     onChanged: (String? value) {
                    //       setUnit(value as String);
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   contentPadding: const EdgeInsets.all(0),
                    //   onTap: () {
                    //     setUnit("oz US");
                    //     Navigator.pop(context);
                    //   },
                    //   title: const Text("US System (fl. oz)"),
                    //   leading: Radio<String>(
                    //     activeColor: Theme.of(context).primaryColor,
                    //     value: "oz US",
                    //     groupValue: activeUnit,
                    //     onChanged: (String? value) {
                    //       setUnit(value as String);
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    // ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearData(context) async {
    final box = Boxes.getDrinkAmounts();
    await box.deleteFromDisk();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await Workmanager().cancelAll();
    Navigator.pushNamedAndRemoveUntil(
      context,
      StartupNavigation.routeName,
      (route) => false,
    );
  }

  void showThemeModal(context) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // const Row(
                    //   children: [
                    //     Text(
                    //       "Theme",
                    //       style: TextStyle(fontSize: 16),
                    //       textAlign: TextAlign.start,
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        final themeProvider = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        );
                        themeProvider.setTheme(ThemeMode.dark);
                        Navigator.pop(context);
                      },
                      title: const Text("Dark"),
                      leading: Radio<String>(
                        activeColor: Theme.of(context).primaryColor,
                        value: ThemeMode.dark.toString(),
                        groupValue: themeProvider.theme.toString(),
                        onChanged: (String? value) {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        final themeProvider = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        );
                        themeProvider.setTheme(ThemeMode.light);
                        Navigator.pop(context);
                      },
                      title: const Text("Light"),
                      leading: Radio<String>(
                        activeColor: Theme.of(context).primaryColor,
                        value: ThemeMode.light.toString(),
                        groupValue: themeProvider.theme.toString(),
                        onChanged: (String? value) {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        final themeProvider = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        );
                        themeProvider.setTheme(ThemeMode.system);
                        Navigator.pop(context);
                      },
                      title: const Text("System"),
                      leading: Radio<String>(
                        activeColor: Theme.of(context).primaryColor,
                        value: ThemeMode.system.toString(),
                        groupValue: themeProvider.theme.toString(),
                        onChanged: (String? value) {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteDialog(context) async {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (BuildContext ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            title: const Text('Delete All Data'),
            content: const Text('Are you sure you want to delete all data?'),
            contentPadding: const EdgeInsets.only(
              left: 20,
              bottom: 5,
              right: 20,
            ),
            titlePadding: const EdgeInsets.only(
              top: 20,
              left: 20,
              bottom: 5,
              right: 15,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isDarkTheme ? Colors.white60 : Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  clearData(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Map<String, String> unitTexts = {
      "ml": "Metric System (L/ml)",
      "oz UK": "UK System (fl. oz)",
      "oz US": "US System (fl. oz)",
    };

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).scaffoldBackgroundColor,
            statusBarIconBrightness:
                isDarkTheme ? Brightness.light : Brightness.dark,
          ),
          title: const Text("Settings"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 56, bottom: 10),
                child: Text(
                  "General",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              Divider(
                color: isDarkTheme ? Colors.white12 : const Color(0xffE4E4E4),
                thickness: 1,
              ),
              SettingsItem(
                onTap: () {
                  // Navigate to the Bluetooth settings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BluetoothSettingsScreen(),
                    ),
                  );
                },
                title: "Add a Device",
                subtitle: "Connect a new Bluetooth device",
                icon: Icons.bluetooth,
              ),
              SettingsItem(
                onTap: showUnitDialog,
                title: "Unit System",
                subtitle:
                    unitTexts.containsKey(activeUnit)
                        ? unitTexts[activeUnit] as String
                        : "asdf",
                icon: Icons.calculate_outlined,
              ),
              SettingsItem(
                onTap: () {
                  Navigator.pushNamed(context, IntakeGoalScreen.routeName).then(
                    (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        _currentGoal = prefs.getInt("intake_amount") ?? 0;
                      });
                    },
                  );
                },
                title: "Intake Goal",
                subtitle: '$_currentGoal$activeUnit',
                icon: Icons.flag_outlined,
              ),
              Divider(
                color: isDarkTheme ? Colors.white12 : const Color(0xffE4E4E4),
                thickness: 1,
              ),
              Container(
                margin: const EdgeInsets.only(left: 56, bottom: 10, top: 10),
                child: Text(
                  "Reminders",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SettingsItem(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    DrinkReminderScreen.routeName,
                  ).then((value) => loadData());
                },
                title: "Drink Reminders",
                subtitle:
                    notificationsActive
                        ? 'Intervall - ${getReminderIntervalText(selectedReminderInterval)}'
                        : 'Disabled',
                icon: Icons.local_drink_outlined,
              ),
              SettingsItem(
                onTap: () {
                  Navigator.pushNamed(context, ReminderTimesScreen.routeName);
                },
                title: "Reminder Times",
                subtitle: "Start and end times",
                icon: Icons.access_time,
              ),
              Divider(
                color: isDarkTheme ? Colors.white12 : const Color(0xffE4E4E4),
                thickness: 1,
              ),
              Container(
                margin: const EdgeInsets.only(left: 56, bottom: 10, top: 10),
                child: Text(
                  "More",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SettingsItem(
                onTap: () {
                  showThemeModal(context);
                },
                title: "Appearance",
                subtitle:
                    themeProvider.theme.name[0].toUpperCase() +
                    themeProvider.theme.name.substring(1),
                icon: Icons.brightness_6_outlined,
              ),
              SettingsItem(
                onTap: () {
                  showDeleteDialog(context);
                },
                title: "Delete All Data",
                subtitle: "Full Reset",
                icon: Icons.delete_outline,
              ),
              SettingsItem(
                onTap: () async {
                  await launchUrl(
                    Uri.parse("mailto:agrawalvidit656@gmail.com"),
                  );
                },
                title: "Contact",
                subtitle: "agrawalvidit656@gmail.com",
                icon: Icons.email_outlined,
              ),
              SettingsItem(
                onTap: () {
                  Navigator.pushNamed(context, AboutScreen.routeName);
                },
                title: "About",
                subtitle: "v1.0.4",
                icon: Icons.info_outline,
              ),
              SettingsItem(
                onTap: () async {
                  // Show a confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Logout'),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // If the user cancels, close the dialog and return false
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // If the user confirms, close the dialog and return true
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                  // If the user confirmed, proceed with logout
                  if (shouldLogout == true) {
                    await FirebaseAuth.instance.signOut();

                    // Navigate to the start screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => StartScreen(() {
                              print("Logout Successfully!");
                            }),
                      ),
                    );
                  }
                },
                title: "Logout",
                subtitle: "Sign out from your account",
                icon: Icons.logout, // Use an appropriate logout icon
              ),
            ],
          ),
        ),
      ),
    );
  }
}
