import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/helpers/calculate_intake.dart';
import 'package:my_app/screens/home_screen.dart';
import '../models/DrinkAmount.dart';

class SetupScreen extends StatefulWidget {
  static const routeName = "/setup";

  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // User input fields
  String activeUnit = "ml";
  String activeWeightUnit = "kg";
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool weightIsValid = true;
  bool ageIsValid = true;

  // Lifestyle & Health Questions
  String activityLevel = "Moderate";
  bool physicallyDemandingJob = false;
  bool exercisesRegularly = false;
  bool hasMedicalCondition = false;
  bool isPregnantOrBreastfeeding = false;
  bool takesMedications = false;
  bool experiencesDehydration = false;
  bool followsDiet = false;
  String estimatedWaterIntake = "1-2 Liters";
  bool drinksDehydratingBeverages = false;
  bool wantsReminders = true;
  bool wantsToTrackOtherFluids = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySetUp();
  }

  void _checkIfAlreadySetUp() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('unit') && prefs.containsKey('intake_amount')) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (_) => false,
      );
    } else {
      Hive.openBox<DrinkAmount>('drink_amounts');
    }
  }

  bool validateWeight() {
    if (weightController.text.isEmpty || int.parse(weightController.text) < 1) {
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

  void nextPage() {
    if (_currentPage < 3) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      onSubmit();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    if (validateWeight() && validateAge()) {
      prefs.setString("unit", activeUnit);
      prefs.setInt(
        "intake_amount",
        calculateIntake(
          num.parse(weightController.text),
          int.parse(ageController.text),
          activeWeightUnit,
          activeUnit,
        ),
      );

      // Save additional fields to SharedPreferences
      prefs.setString("userAge", ageController.text);
      prefs.setString("userWeight", weightController.text);
      prefs.setString("activityLevel", activityLevel);
      prefs.setBool("physicallyDemandingJob", physicallyDemandingJob);
      prefs.setBool("exercisesRegularly", exercisesRegularly);
      prefs.setBool("hasMedicalCondition", hasMedicalCondition);
      prefs.setBool("isPregnantOrBreastfeeding", isPregnantOrBreastfeeding);
      prefs.setBool("takesMedications", takesMedications);
      prefs.setBool("experiencesDehydration", experiencesDehydration);
      prefs.setString("estimatedWaterIntake", estimatedWaterIntake);
      prefs.setBool("drinksDehydratingBeverages", drinksDehydratingBeverages);
      prefs.setBool("wantsReminders", wantsReminders);
      prefs.setBool("wantsToTrackOtherFluids", wantsToTrackOtherFluids);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildProfileScreen(),
          _buildLifestyleScreen(),
          _buildHealthScreen(),
          _buildPreferencesScreen(),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Add padding for better spacing
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align buttons to left and right
          children: [
            // Previous Button (on the left)
            if (_currentPage > 0)
              FloatingActionButton.extended(
                onPressed: previousPage,
                backgroundColor: Theme.of(context).primaryColor,
                label: Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.white),
                    SizedBox(width: 4), // Add spacing between the icon and text
                    Text("Previous", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

            // Next/Finish Button (on the right)
            FloatingActionButton.extended(
              onPressed: (validateWeight() && validateAge()) ? nextPage : null,
              backgroundColor: Theme.of(context).primaryColor,
              label: Row(
                children: [
                  Text(
                    _currentPage == 3 ? "Finish" : "Next",
                    style: TextStyle(color: Colors.white),
                  ),
                  if (_currentPage < 3)
                    SizedBox(width: 4), // Add spacing between text and arrow
                  if (_currentPage < 3)
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return _buildScreen(
      title: "Basic Profile",
      children: [
        _buildTextField("Age", ageController, validateAge, ageIsValid),
        _buildTextField(
          "Weight",
          weightController,
          validateWeight,
          weightIsValid,
        ),
        _buildDropdown("Weight Unit", ["kg", "lbs"], activeWeightUnit, (value) {
          setState(() {
            activeWeightUnit = value!; // Set active weight unit
          });
        }),
      ],
    );
  }

  Widget _buildLifestyleScreen() {
    return _buildScreen(
      title: "Lifestyle & Activity",
      children: [
        _buildDropdown(
          "Activity Level",
          ["Low", "Moderate", "High"],
          activityLevel,
          (value) {
            setState(() {
              activityLevel = value!; // Set activity level
            });
          },
        ),
        _buildSwitch("Physically Demanding Job", physicallyDemandingJob, (
          value,
        ) {
          setState(() {
            physicallyDemandingJob = value;
          });
        }),
        _buildSwitch("Exercises Regularly", exercisesRegularly, (value) {
          setState(() {
            exercisesRegularly = value;
          });
        }),
      ],
    );
  }

  Widget _buildHealthScreen() {
    return _buildScreen(
      title: "Health Conditions",
      children: [
        _buildSwitch(
          "Medical Condition Affecting Hydration",
          hasMedicalCondition,
          (value) {
            setState(() {
              hasMedicalCondition = value;
            });
          },
        ),
        _buildSwitch("Pregnant or Breastfeeding", isPregnantOrBreastfeeding, (
          value,
        ) {
          setState(() {
            isPregnantOrBreastfeeding = value;
          });
        }),
        _buildSwitch("Taking Medications", takesMedications, (value) {
          setState(() {
            takesMedications = value;
          });
        }),
      ],
    );
  }

  Widget _buildPreferencesScreen() {
    return _buildScreen(
      title: "Tracking & Preferences",
      children: [
        _buildDropdown(
          "Estimated Daily Water Intake",
          ["Less than 1L", "1-2 Liters", "More than 2L"],
          estimatedWaterIntake,
          (value) {
            setState(() {
              estimatedWaterIntake = value!; // Set estimated water intake
            });
          },
        ),
        _buildSwitch(
          "Drink Dehydrating Beverages",
          drinksDehydratingBeverages,
          (value) {
            setState(() {
              drinksDehydratingBeverages = value;
            });
          },
        ),
        // _buildSwitch("Enable Water Intake Reminders", wantsReminders, (value) {
        //   setState(() {
        //     wantsReminders = value;
        //   });
        // }),
        _buildSwitch("Track Other Fluids", wantsToTrackOtherFluids, (value) {
          setState(() {
            wantsToTrackOtherFluids = value;
          });
        }),
      ],
    );
  }

  Widget _buildScreen({required String title, required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Function validator,
    bool isValid,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        errorText: isValid ? null : "Invalid $label",
      ),
      onChanged: (_) => validator(),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
