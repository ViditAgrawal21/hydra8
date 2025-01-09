import 'package:flutter/material.dart';

import '../../screens/settings_screen.dart';

class NavBar extends StatelessWidget {
  final int activeIndex;
  final Function setPage;
  final VoidCallback loadPreferences;

  const NavBar(
      {required this.loadPreferences,
      required this.activeIndex,
      required this.setPage,
      super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      /* shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(0),
          ),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      notchMargin: 7, */
      child: Container(
        height: 75,
        decoration: BoxDecoration(
            border: BorderDirectional(
                top: BorderSide(
                    color: isDarkTheme
                        ? const Color(0xff4B4B4B)
                        : const Color.fromRGBO(0, 0, 0, 0.1)))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Tooltip(
                              message: "History",
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey, splashFactory: NoSplash.splashFactory),
                                onPressed: () {
                                  setPage(1);
                                },
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bar_chart,
                                        size: 28,
                                        color: activeIndex == 1
                                            ? isDarkTheme
                                                ? Colors.white
                                                : Colors.black87
                                            : isDarkTheme
                                                ? Colors.white38
                                                : const Color.fromRGBO(
                                                    0, 0, 0, 0.3),
                                      ),
                                      Text(
                                        "History",
                                        style: TextStyle(
                                          color: activeIndex == 1
                                              ? isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black87
                                              : isDarkTheme
                                                  ? Colors.white38
                                                  : const Color.fromRGBO(
                                                      0, 0, 0, 0.3),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Tooltip(
                              message: "Home",
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey, splashFactory: NoSplash.splashFactory),
                                onPressed: () {
                                  setPage(0);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apps,
                                      size: 28,
                                      color: activeIndex == 0
                                          ? isDarkTheme
                                              ? Colors.white
                                              : Colors.black87
                                          : isDarkTheme
                                              ? Colors.white38
                                              : const Color.fromRGBO(
                                                  0, 0, 0, 0.3),
                                    ),
                                    Text(
                                      "Home",
                                      style: TextStyle(
                                        color: activeIndex == 0
                                            ? isDarkTheme
                                                ? Colors.white
                                                : Colors.black87
                                            : isDarkTheme
                                                ? Colors.white38
                                                : const Color.fromRGBO(
                                                    0, 0, 0, 0.3),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.1,
                            child: Tooltip(
                              message: "Settings",
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey, splashFactory: NoSplash.splashFactory),
                                onPressed: () async {
                                  final bool result = await Navigator.pushNamed(
                                      context, SettingsScreen.routeName) as bool;
                                  if (result) {
                                    loadPreferences();
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      size: 28,
                                      color: isDarkTheme
                                          ? Colors.white38
                                          : const Color.fromRGBO(0, 0, 0, 0.3),
                                    ),
                                    Text(
                                      "Settings",
                                      style: TextStyle(
                                        color: isDarkTheme
                                            ? Colors.white38
                                            : const Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /* Expanded(
                      child: Opacity(
                        opacity: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Tooltip(
                                message: "Settings",
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      splashFactory: NoSplash.splashFactory,
                                      primary: Colors.grey),
                                  onPressed: () {
                                    setPage(1);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.settings,
                                        size: 28,
                                        color: activeIndex == 1
                                            ? Colors.black87
                                            : const Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                      Text(
                                        "Settings",
                                        style: TextStyle(
                                            color: activeIndex == 1
                                                ? Colors.black87
                                                : const Color.fromRGBO(
                                                    0, 0, 0, 0.3)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) */
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
