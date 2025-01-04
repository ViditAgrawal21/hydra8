import 'package:flutter/material.dart';
import 'package:my_app/helpers/helpers.dart';

class ReminderTimeDialog extends StatefulWidget {
  final Function setStartTime;
  final Function setEndTime;
  final Function setInterval;
  final TimeOfDay selectedStartReminderTime;
  final TimeOfDay selectedFinishReminderTime;
  final int selectedReminderInterval;
  const ReminderTimeDialog(
      {required this.setEndTime,
      required this.selectedReminderInterval,
      required this.setStartTime,
      required this.setInterval,
      required this.selectedFinishReminderTime,
      required this.selectedStartReminderTime,
      super.key});

  @override
  ReminderTimeDialogState createState() => ReminderTimeDialogState();
}

class ReminderTimeDialogState extends State<ReminderTimeDialog> {
  late TimeOfDay selectedStartReminderTime;
  late TimeOfDay selectedFinishReminderTime;
  late int selectedReminderInterval;

  @override
  void initState() {
    selectedStartReminderTime = widget.selectedStartReminderTime;
    selectedFinishReminderTime = widget.selectedFinishReminderTime;
    selectedReminderInterval = widget.selectedReminderInterval;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Reminder Time",
            style: TextStyle(
                fontSize: 18,
                color: isDarkTheme ? Colors.white : Colors.black87),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Start time"),
              SizedBox(
                width: 130,
                child: OutlinedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                      backgroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                      side: WidgetStateProperty.all(BorderSide(
                          color: isDarkTheme
                              ? Colors.white30
                              : const Color(0xffE9E9E9)))),
                  onPressed: () async {
                    showTimePicker(
                            context: context,
                            initialTime: selectedStartReminderTime)
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          selectedStartReminderTime = value;
                        });
                      }
                    });
                  },
                  child: Text(
                    formatTimeOfDay(selectedStartReminderTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDarkTheme
                            ? Colors.white
                            : const Color(0xff383838)),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Finish time"),
              SizedBox(
                width: 130,
                child: OutlinedButton(
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                      backgroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                      side: WidgetStateProperty.all(BorderSide(
                          color: isDarkTheme
                              ? Colors.white30
                              : const Color(0xffE9E9E9)))),
                  onPressed: () async {
                    showTimePicker(
                            context: context,
                            initialTime: selectedFinishReminderTime)
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          selectedFinishReminderTime = value;
                        });
                      }
                    });
                  },
                  child: Text(
                    formatTimeOfDay(selectedFinishReminderTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDarkTheme
                            ? Colors.white
                            : const Color(0xff383838)),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Interval"),
              SizedBox(
                width: 130,
                child: DropdownButton<int>(
                  borderRadius: BorderRadius.circular(5),
                  elevation: 1,
                  dropdownColor: isDarkTheme
                      ? const Color.fromARGB(255, 50, 50, 50)
                      : Colors.white,
                  value: selectedReminderInterval,
                  items:
                      <int>[0, 1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(getReminderIntervalText(value)),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedReminderInterval = newValue as int;
                    });
                  },
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  false,
                ),
                style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Cancel'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  widget.setEndTime(selectedFinishReminderTime);
                  widget.setStartTime(selectedStartReminderTime);
                  widget.setInterval(selectedReminderInterval);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 25), backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Save',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          )
        ]),
      ],
    );
  }
}
