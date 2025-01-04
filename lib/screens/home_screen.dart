import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/helpers.dart';
import 'package:my_app/models/DrinkAmount.dart';

import '../widgets/homescreen-widgets/homescreen_main.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  final List<DrinkAmount> drinksAmounts;
  final Function onAdd;
  final dynamic prevIsSunny;
  final dynamic prevIsActive;
  final Function setPrevIsSunny;
  final Function setPrevIsActive;
  final int intakeAmount;
  final String activeUnit;
  final bool isSunny;
  final Function changeSunny;
  final Function changeActive;
  final VoidCallback loadPreferences;
  final bool isActive;

  const HomeScreen(
      {required this.prevIsActive,
      required this.loadPreferences,
      required this.changeActive,
      required this.changeSunny,
      required this.isActive,
      required this.isSunny,
      required this.prevIsSunny,
      required this.activeUnit,
      required this.intakeAmount,
      required this.setPrevIsActive,
      required this.setPrevIsSunny,
      required this.onAdd,
      required this.drinksAmounts,
      super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int prevIntake = 0;

  void setActive(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(
        '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}_isActive',
        value);
    widget.setPrevIsActive(!value);
    widget.changeActive(value);
  }

  void setSunny(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(
        '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}_isSunny',
        value);
    widget.setPrevIsSunny(!value);
    widget.changeSunny(value);
  }

  void activeIntakeChange(intakeAmount, isSunny, isActive) {
    int intakeChangeDifference = getIntakeChangeDifference(widget.activeUnit);
    setState(() {
      if (isSunny) {
        if (isActive) {
          prevIntake = (intakeAmount) + intakeChangeDifference * 2;
        } else {
          prevIntake = (intakeAmount) + intakeChangeDifference;
        }
      } else {
        if (isActive) {
          prevIntake = (intakeAmount) + intakeChangeDifference;
        } else {
          prevIntake = (intakeAmount);
        }
      }
      setActive(!isActive);
    });
  }

  void sunnyIntakeChange(intakeAmount, isActive, isSunny) {
    int intakeChangeDifference = getIntakeChangeDifference(widget.activeUnit);
    setState(() {
      if (isActive) {
        if (isSunny) {
          prevIntake = (intakeAmount) + intakeChangeDifference * 2;
        } else {
          prevIntake = (intakeAmount) + intakeChangeDifference;
        }
      } else {
        if (isSunny) {
          prevIntake = (intakeAmount) + intakeChangeDifference;
        } else {
          prevIntake = (intakeAmount);
        }
      }
      setSunny(!(isSunny));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final amountsList = widget.drinksAmounts.map((DrinkAmount element) {
      if (element.createdDate.year == DateTime.now().year &&
          element.createdDate.month == DateTime.now().month &&
          element.createdDate.day == DateTime.now().day) {
        return (element.amount * getDrinkFactor(element.drinkType)).round();
      } else {
        return 0;
      }
    }).toList();

    final int todaysDrinkAmount = amountsList.isNotEmpty
        ? amountsList.reduce((value, e) => value + e)
        : 0;

    int intakeChangeDifference = getIntakeChangeDifference(widget.activeUnit);

    bool usePrevIsActive = widget.prevIsActive ?? widget.isActive;
    bool usePrevIsSunny = widget.prevIsSunny ?? widget.isSunny;
    int prevAmount = todaysDrinkAmount;
    int usePrevIntake = prevIntake;
    if (usePrevIsActive == widget.isActive &&
        usePrevIsSunny == widget.isSunny) {
      prevAmount =
          todaysDrinkAmount - (amountsList.isNotEmpty ? amountsList.last : 0);
      usePrevIntake = (widget.intakeAmount) +
          (widget.isActive ? intakeChangeDifference : 0) +
          (widget.isSunny ? intakeChangeDifference : 0);
    }

    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.transparent,

            // Status bar brightness (optional)
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
        ),
        backgroundColor: isDarkTheme
            ? const Color(0xff2D2D2D)
            : const Color.fromRGBO(0, 0, 0, 0.03),
        body: Center(
          child: HomescreenMain(
            activeUnit: widget.activeUnit,
            loadPreferences: widget.loadPreferences,
            onAdd: widget.onAdd,
            drinkAmounts: widget.drinksAmounts,
            prevAmount: prevAmount,
            prevIntake: usePrevIntake,
            intakeAmount: widget.intakeAmount,
            isActive: widget.isActive,
            isSunny: widget.isSunny,
            activeIntakeChange: activeIntakeChange,
            sunnyIntakeChange: sunnyIntakeChange,
            todaysDrinkAmount: todaysDrinkAmount,
          ),
        ));
  }
}
