import 'package:flutter/material.dart';
import '../../screens/settings_screen.dart';
import '../../screens/user_profile_screen.dart';

class NavBar extends StatelessWidget {
  final int activeIndex;
  final Function setPage;
  final VoidCallback loadPreferences;

  const NavBar({
    required this.loadPreferences,
    required this.activeIndex,
    required this.setPage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(
              color:
                  isDarkTheme
                      ? const Color(0xff4B4B4B)
                      : const Color.fromRGBO(0, 0, 0, 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Settings
            Expanded(
              child: Tooltip(
                message: "Settings",
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () async {
                    final bool result =
                        await Navigator.pushNamed(
                              context,
                              SettingsScreen.routeName,
                            )
                            as bool;
                    if (result) {
                      loadPreferences();
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 21,
                          color:
                              activeIndex == 3
                                  ? isDarkTheme
                                      ? Colors.white
                                      : Colors.black87
                                  : isDarkTheme
                                  ? Colors.white38
                                  : const Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        Text(
                          "Settings",
                          style: TextStyle(
                            color:
                                activeIndex == 3
                                    ? isDarkTheme
                                        ? Colors.white
                                        : Colors.black87
                                    : isDarkTheme
                                    ? Colors.white38
                                    : const Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // User Profile
            Expanded(
              child: Tooltip(
                message: "Profile",
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, UserProfileScreen.routeName);
                  },

                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 21,
                          color:
                              activeIndex == 2
                                  ? isDarkTheme
                                      ? Colors.white
                                      : Colors.black87
                                  : isDarkTheme
                                  ? Colors.white38
                                  : const Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        Text(
                          "Profile",
                          style: TextStyle(
                            color:
                                activeIndex == 2
                                    ? isDarkTheme
                                        ? Colors.white
                                        : Colors.black87
                                    : isDarkTheme
                                    ? Colors.white38
                                    : const Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Home
            Expanded(
              child: Tooltip(
                message: "Home",
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    setPage(0);
                  },

                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apps,
                          size: 21,
                          color:
                              activeIndex == 0
                                  ? isDarkTheme
                                      ? Colors.white
                                      : Colors.black87
                                  : isDarkTheme
                                  ? Colors.white38
                                  : const Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        Text(
                          "Home",
                          style: TextStyle(
                            color:
                                activeIndex == 0
                                    ? isDarkTheme
                                        ? Colors.white
                                        : Colors.black87
                                    : isDarkTheme
                                    ? Colors.white38
                                    : const Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Statistics
            Expanded(
              child: Tooltip(
                message: "Statistics",
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    setPage(1);
                  },

                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 21,
                          color:
                              activeIndex == 1
                                  ? isDarkTheme
                                      ? Colors.white
                                      : Colors.black87
                                  : isDarkTheme
                                  ? Colors.white38
                                  : const Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                        Text(
                          "Statistics",
                          style: TextStyle(
                            color:
                                activeIndex == 1
                                    ? isDarkTheme
                                        ? Colors.white
                                        : Colors.black87
                                    : isDarkTheme
                                    ? Colors.white38
                                    : const Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
