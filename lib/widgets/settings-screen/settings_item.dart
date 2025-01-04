import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  IconData icon;
  String title;
  String subtitle;
  VoidCallback onTap;
  SettingsItem(
      {required this.onTap,
      required this.subtitle,
      required this.title,
      required this.icon,
      super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
        width: double.infinity,
        height: 65,
        child: InkWell(
          onTap: onTap,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    icon,
                    color: isDarkTheme ? Colors.white : const Color(0xff353535),
                    size: 26,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          color: isDarkTheme
                              ? Colors.white
                              : const Color(0xff353535)),
                    ),
                    subtitle.isEmpty
                        ? const SizedBox()
                        : Text(
                            subtitle,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xff9C9C9C)),
                          )
                  ],
                )
              ]),
        ));
  }
}
