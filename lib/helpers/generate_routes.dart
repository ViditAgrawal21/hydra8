import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:my_app/screens/about_screen.dart';
import 'package:my_app/screens/settings-screens/drink_reminder_screen.dart';
import 'package:my_app/screens/settings-screens/intake_goal_screen.dart';
import 'package:my_app/screens/settings-screens/reminder_times_screen.dart';
import 'package:my_app/screens/settings_screen.dart';
import 'package:my_app/screens/setup_screen.dart';
import 'package:my_app/screens/startup_navigation.dart';
import 'package:my_app/screens/user_profile_screen.dart'; // Import the UserProfileScreen
import '../screens/home_screen.dart';
import '../screens/navigation_controller.dart';
import '../screens/statistics_screen.dart';

Route<dynamic> generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case ReminderTimesScreen.routeName:
      return PageTransition(
        child: const ReminderTimesScreen(),
        type: PageTransitionType.rightToLeft,
        isIos: true,
        alignment: Alignment.center,
        settings: settings,
      );
    case DrinkReminderScreen.routeName:
      return PageTransition(
        child: const DrinkReminderScreen(),
        type: PageTransitionType.rightToLeft,
        isIos: true,
        alignment: Alignment.center,
        settings: settings,
      );
    case IntakeGoalScreen.routeName:
      return PageTransition(
        child: const IntakeGoalScreen(),
        type: PageTransitionType.rightToLeft,
        isIos: true,
        alignment: Alignment.center,
        settings: settings,
      );
    case AboutScreen.routeName:
      return PageTransition(
        isIos: true,
        child: const AboutScreen(),
        type: PageTransitionType.rightToLeftWithFade,
        settings: settings,
      );
    case SettingsScreen.routeName:
      return PageTransition(
        isIos: true,
        child: const SettingsScreen(),
        type: PageTransitionType.rightToLeftWithFade,
        settings: settings,
      );
    case UserProfileScreen.routeName: // Add UserProfileScreen route
      final args = settings.arguments as Map<String, dynamic>?;
      final phoneNumber = args?['phoneNumber'] ?? 'default-phone-number';
      return PageTransition(
        isIos: true,
        child: UserProfileScreen(phoneNumber: phoneNumber),
        type: PageTransitionType.rightToLeftWithFade,
        settings: settings,
      );
    case StartupNavigation.routeName:
      return PageTransition(
        isIos: true,
        child: const StartupNavigation(),
        type: PageTransitionType.rightToLeftWithFade,
        settings: settings,
      );
    case HomeScreen.routeName:
      return PageTransition(
        isIos: true,
        child: const NavigationController(initIndex: 0),
        type: PageTransitionType.rightToLeftWithFade,
        settings: settings,
      );
    case StatisticsScreen.routeName:
      return PageTransition(
        isIos: true,
        child: const NavigationController(initIndex: 1),
        type: PageTransitionType.rightToLeftWithFade,
        settings: settings,
      );
    default:
      return PageTransition(
        isIos: true,
        child: const SetupScreen(),
        type: PageTransitionType.leftToRightWithFade,
        settings: settings,
      );
  }
}
