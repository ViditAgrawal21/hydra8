import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetGoalDialog extends StatefulWidget {
  final int currentGoal;
  final String activeUnit;
  final Function setIntake;
  const SetGoalDialog(
      {required this.setIntake,
      required this.currentGoal,
      required this.activeUnit,
      super.key});

  @override
  _SetGoalDialogState createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends State<SetGoalDialog> {
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    amountController.text = widget.currentGoal.toString();
    super.initState();
  }

  void onSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    bool inputIsValid = int.parse(amountController.text) > 0;
    if (inputIsValid) {
      int newIntake = int.parse(amountController.text);
      prefs.setInt("intake_amount", newIntake).then((value) {
        widget.setIntake(newIntake);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetAnimationDuration: const Duration(seconds: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
        child: Wrap(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Individual Amount",
                style: TextStyle(fontSize: 17),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      autofocus: true,
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          hintText: "Amount",
                          focusColor: Theme.of(context).primaryColor,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: amountController.text.isEmpty ||
                                          int.parse(amountController.text) < 1
                                      ? Colors.red
                                      : Theme.of(context).primaryColor))),
                      controller: amountController,
                      cursorColor: Theme.of(context).primaryColor,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                    ),
                  ),
                  Text(widget.activeUnit)
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                )
              ]),
            ],
          )
        ]),
      ),
    );
  }
}
