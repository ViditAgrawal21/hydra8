import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/calculate_intake.dart';

class CalculateDialog extends StatefulWidget {
  final String activeUnit;
  final Function setIntake;
  const CalculateDialog(
      {required this.activeUnit, required this.setIntake, super.key});

  @override
  CalculateDialogState createState() => CalculateDialogState();
}

class CalculateDialogState extends State<CalculateDialog> {
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool weightIsValid = true;
  bool ageIsValid = true;

  String activeWeightUnit = "kg";

  bool validateWeight() {
    if (weightController.text.isEmpty ||
        int.parse(weightController.text) < 10) {
      setState(() {
        weightIsValid = false;
      });
      return false;
    }
    setState(() {
      weightIsValid = true;
    });
    return true;
  }

  bool validateAge() {
    if (ageController.text.isEmpty || int.parse(ageController.text) < 1) {
      setState(() {
        ageIsValid = false;
      });
      return false;
    }
    setState(() {
      ageIsValid = true;
    });
    return true;
  }

  void onSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final bool calculateiInputDataIsValid = validateWeight() && validateAge();
    if (calculateiInputDataIsValid) {
      int newIntake = calculateIntake(num.parse(weightController.text),
          int.parse(ageController.text), activeWeightUnit, widget.activeUnit);
      prefs.setInt("intake_amount", newIntake).then((value) {
        widget.setIntake(newIntake);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your Weight",
              style: TextStyle(
                  fontSize: 18,
                  color:
                      isDarkTheme ? Colors.white70 : const Color(0xFF3B3B3B)),
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
                  color:
                      isDarkTheme ? Colors.white70 : const Color(0xFF3B3B3B)),
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
                    style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.normal),
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
                      color: isDarkTheme
                          ? Colors.white70
                          : const Color(0xFF3B3B3B)),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: isDarkTheme
                            ? Colors.white54
                            : const Color.fromRGBO(0, 0, 0, 0.4)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
