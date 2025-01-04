import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_app/helpers/calculate_intake.dart';
import '../models/DrinkAmount.dart';

String parseDay(weekday) {
  if (weekday == DateTime.monday) {
    return "Mo";
  }
  if (weekday == DateTime.tuesday) {
    return "Tue";
  }
  if (weekday == DateTime.wednesday) {
    return "Wed";
  }
  if (weekday == DateTime.thursday) {
    return "Thu";
  }
  if (weekday == DateTime.friday) {
    return "Fri";
  }
  if (weekday == DateTime.saturday) {
    return "Sat";
  }
  if (weekday == DateTime.sunday) {
    return "Sun";
  }
  return "";
}

Duration getDurationFromIntervalInt(int interval) {
  switch (interval) {
    case 0:
      return const Duration(minutes: 30);
    case 1:
      return const Duration(hours: 1);
    case 2:
      return const Duration(hours: 2);
    case 3:
      return const Duration(hours: 3);
    default:
      return const Duration(hours: 1);
  }
}

TimeOfDay stringToTimeOfDay(String tod) {
  return TimeOfDay(
      hour: int.parse(tod.split(":")[0]), minute: int.parse(tod.split(":")[1]));
}

String formatTimeOfDay(TimeOfDay time) {
  String output = "";
  if (time.hour.toString().length == 1) {
    output += "0${time.hour}";
  } else {
    output += time.hour.toString();
  }
  output += ":";
  if (time.minute.toString().length == 1) {
    output += "0${time.minute}";
  } else {
    output += time.minute.toString();
  }
  return output;
}

String getReminderIntervalText(int selected) {
  switch (selected) {
    case 0:
      return "each 30mins";
    case 1:
      return "each 1h";
    case 2:
      return "each 2h";
    case 3:
      return "each 3h";
    default:
      return "";
  }
}

String parseMonth(int month) {
  if (month == 1) {
    return "January";
  }
  if (month == 2) {
    return "February";
  }
  if (month == 3) {
    return "March";
  }
  if (month == 4) {
    return "April";
  }
  if (month == 5) {
    return "May";
  }
  if (month == 6) {
    return "June";
  }
  if (month == 7) {
    return "Juli";
  }
  if (month == 8) {
    return "August";
  }
  if (month == 9) {
    return "September";
  }
  if (month == 10) {
    return "Oktober";
  }
  if (month == 11) {
    return "November";
  }
  if (month == 12) {
    return "Dezember";
  }
  return "";
}

void onChangeUnit(prevUnit, newUnit, prefs) {
  int currentIntakeAmount = prefs.getInt("intake_amount") ?? 0;
  if (prevUnit == "ml" && newUnit == "oz UK") {
    prefs.setInt(
        "intake_amount", max((currentIntakeAmount / 28.413).round(), 5));
  }
  if (prevUnit == "ml" && newUnit == "oz US") {
    prefs.setInt(
        "intake_amount", max(5, (currentIntakeAmount / 29.574).round()));
  }
  if (prevUnit == "oz US" && newUnit == "oz UK") {
    prefs.setInt(
        "intake_amount", max(5, (currentIntakeAmount * 1.041).round()));
  }
  if (prevUnit == "oz US" && newUnit == "ml") {
    prefs.setInt(
        "intake_amount", max(100, (currentIntakeAmount * 29.574).round()));
  }
  if (prevUnit == "oz UK" && newUnit == "oz US") {
    prefs.setInt(
        "intake_amount", max(5, (currentIntakeAmount / 1.041).round()));
  }
  if (prevUnit == "oz UK" && newUnit == "ml") {
    prefs.setInt(
        "intake_amount", max(100, (currentIntakeAmount * 28.413).round()));
  }

  var box = Hive.box<DrinkAmount>("drink_amounts");
  for (var key in box.keys) {
    DrinkAmount drinkAmount = box.get(key) as DrinkAmount;
    drinkAmount.unit = newUnit;
    int newAmount = 0;
    if (prevUnit == "ml" && newUnit == "oz UK") {
      newAmount = max(5, (drinkAmount.amount / 28.413).round());
    }
    if (prevUnit == "ml" && newUnit == "oz US") {
      newAmount = max(5, (drinkAmount.amount / 29.574).round());
    }
    if (prevUnit == "oz US" && newUnit == "oz UK") {
      newAmount = max(5, (drinkAmount.amount * 1.041).round());
    }
    if (prevUnit == "oz US" && newUnit == "ml") {
      newAmount = max(100, (drinkAmount.amount * 29.574).round());
      newAmount = (newAmount / 50).round() * 50;
    }
    if (prevUnit == "oz UK" && newUnit == "oz US") {
      newAmount = max(5, (drinkAmount.amount / 1.041).round());
    }
    if (prevUnit == "oz UK" && newUnit == "ml") {
      newAmount = max(100, (drinkAmount.amount * 28.413).round());
      newAmount = (newAmount / 50).round() * 50;
    }
    drinkAmount.amount = newAmount;
    drinkAmount.save();
  }
}

int getIntakeChangeDifference(activeUnit) {
  if (activeUnit == "ml") {
    return 500;
  } else if (activeUnit == "oz UK") {
    return 18;
  } else {
    return 17;
  }
}

double getDrinkFactor(String drinkType) {
  if (drinkType == DrinkType.water.name) {
    return 1;
  }
  if (drinkType == DrinkType.coffee.name || drinkType == DrinkType.tea.name) {
    return 0.99;
  }
  if (drinkType == DrinkType.milk.name) {
    return 0.89;
  }
  if (drinkType == DrinkType.juice.name ||
      drinkType == DrinkType.softDrink.name) {
    return 0.92;
  }
  return 1;
}

int getDaysInMonth(int month) {
  if (month == 2) {
    return 28;
  }
  if (month % 2 == 0) {
    return 30;
  }
  return 31;
}
