import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  ThemeProvider() {
    SharedPreferences.getInstance().then((prefs) {
      String? savedThemeMode = prefs.getString("theme_mode") ?? "system";
      if (savedThemeMode == "dark") {
        return themeMode = ThemeMode.dark;
      }
      if (savedThemeMode == "light") {
        return themeMode = ThemeMode.light;
      } else {
        return themeMode = ThemeMode.system;
      }
    });
  }

  ThemeMode get theme => themeMode;

  void setTheme(ThemeMode newTheme) async {
    themeMode = newTheme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("theme_mode", newTheme.name);
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkTheme = themeMode != ThemeMode.system
        ? themeMode == ThemeMode.dark
        : brightness == Brightness.dark;
    if (isDarkTheme) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: const Color(0xff252525),
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light));
    }
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff252525),
      textTheme: GoogleFonts.openSansTextTheme(const TextTheme()),
      splashFactory: InkRipple.splashFactory,
      primaryColor: const Color(0xff41C4FD),
      useMaterial3: true, colorScheme: const ColorScheme.dark(
          primary: Color(0xff41C4FD), brightness: Brightness.dark).copyWith(surface: const Color(0xff252525)), dialogTheme: const DialogThemeData(backgroundColor: Color(0xff252525)));
  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.openSansTextTheme(),
      splashFactory: InkRipple.splashFactory,
      primaryColor: const Color(0xff41C4FD),
      useMaterial3: true, colorScheme: const ColorScheme.light(
          primary: Color(0xff41C4FD), brightness: Brightness.light).copyWith(surface: Colors.white));
}
