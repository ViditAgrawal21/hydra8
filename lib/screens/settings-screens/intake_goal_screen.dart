import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/widgets/settings-screen/set_goal_dialog.dart';

import '../../widgets/setup-widgets/calculate_dialog.dart';

class IntakeGoalScreen extends StatefulWidget {
  static const routeName = "/intake-goal";
  const IntakeGoalScreen({super.key});

  @override
  State<IntakeGoalScreen> createState() => _IntakeGoalScreenState();
}

class _IntakeGoalScreenState extends State<IntakeGoalScreen> {
  int currentGoal = 0;
  String activeUnit = "";

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      activeUnit = prefs.getString("unit") ?? "";
      currentGoal = prefs.getInt("intake_amount") ?? 2000;
    });
  }

  void setGoal(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("intake_amount", value);
  }

  void showSetGoalDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SetGoalDialog(
            currentGoal: currentGoal,
            activeUnit: activeUnit,
            setIntake: (int newGoal) {
              setState(() {
                currentGoal = newGoal;
              });
            },
          );
        });
  }

  void showCalculateDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              insetAnimationDuration: const Duration(seconds: 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Wrap(
                children: [
                  CalculateDialog(
                    setIntake: (int value) {
                      setState(() {
                        currentGoal = value;
                      });
                    },
                    activeUnit: activeUnit,
                  ),
                ],
              ),
            ));
  }

  @override
  void initState() {
    loadData();
    super.initState();
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
            title: const Text("Intake Goal"),
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            )),
        body: SizedBox(
          height: 65,
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: InkWell(
                  onTap: () {
                    showCalculateDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: const Icon(Icons.flag_outlined),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Individual Amount",
                            style: TextStyle(
                                fontSize: 17,
                                color: isDarkTheme
                                    ? Colors.white
                                    : const Color(0xff353535)),
                          ),
                          const Text(
                            "Tap to calculate",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xff9C9C9C)),
                          )
                        ],
                      )
                    ]),
                  ),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 65,
                    child: InkWell(
                      onTap: showSetGoalDialog,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text("$currentGoal $activeUnit")
                          ]),
                    ),
                  ))
            ],
          ),
        ));
  }
}
