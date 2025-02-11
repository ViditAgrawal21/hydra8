import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/generate_routes.dart';
import 'package:my_app/helpers/theme_provider.dart';
import 'package:my_app/models/DrinkAmount.dart';
import 'package:my_app/screens/navigation_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/screens/startup_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:my_app/screens/phone_verification_screen.dart';
import 'package:my_app/helpers/bluetooth_helper.dart'; // Import BluetoothHelper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCqdy7iLGr28aHDRIrWyREs52yUZbc30dU",
        authDomain: "hydra8-b53ab.firebaseapp.com",
        projectId: "hydra8-b53ab",
        storageBucket: "hydra8-b53ab.firebasestorage.app",
        messagingSenderId: "958237253833",
        appId: "1:958237253833:web:212464f2a39077cbd1ed18",
        measurementId: "G-F4VVC5HYYJ",
      ),
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  } // Initialize Firebase
  //* Initialize Hive Database
  await Hive.initFlutter();
  Hive.registerAdapter(DrinkAmountAdapter());
  await Hive.openBox<DrinkAmount>('drink_amounts');

  //* Lock screen in portrait-mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String themeMode = prefs.getString("theme_mode") ?? "system";

  if (themeMode.isNotEmpty) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkTheme =
        themeMode != "system"
            ? themeMode == "dark"
            : brightness == Brightness.dark;
    if (isDarkTheme) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: const Color(0xff252525),
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _intakeAmount = 0;

  void loadIntakeAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _intakeAmount = (prefs.getInt('intake_amount') ?? -1);
    });
  }

  @override
  void initState() {
    super.initState();
    loadIntakeAmount();
  }

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light)); */

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => BluetoothHelper(),
        ), // ✅ Add BluetoothHelper here
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MaterialApp(
            color: Colors.white,
            debugShowCheckedModeBanner: false,

            title: 'Hydra8',
            themeMode: themeProvider.theme,
            darkTheme: MyThemes.darkTheme,
            theme: MyThemes.lightTheme,
            home:
                _intakeAmount == -1
                    ? const StartupNavigation()
                    : const NavigationController(initIndex: 0),
            onGenerateRoute: generateRoutes,
          );
        },
      ),
    );
  }
}
