import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // For web
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = "/user_profile";
  final String phoneNumber;

  const UserProfileScreen({Key? key, required this.phoneNumber})
    : super(key: key);
  // const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String userName = "";
  String userEmail = "";
  String phoneNumber = "";
  String userAge = "";
  String userWeight = "";
  String activityLevel = "";
  bool physicallyDemandingJob = false;
  bool exercisesRegularly = false;
  bool hasMedicalCondition = false;
  bool isPregnantOrBreastfeeding = false;
  bool takesMedications = false;
  bool experiencesDehydration = false;
  String estimatedWaterIntake = "";
  bool drinksDehydratingBeverages = false;
  bool wantsReminders = true;
  bool wantsToTrackOtherFluids = false;
  bool phoneNumberChanged = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args != null && args.containsKey('phoneNumber')) {
      setState(() {
        phoneNumber = args['phoneNumber']; // Fetch from Signup Page
        _phoneController.text = phoneNumber;
      });

      // Save it to SharedPreferences
      _savePhoneNumber(phoneNumber);
    }
  }

  // Save phone number to SharedPreferences
  Future<void> _savePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("phoneNumber", phone);
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      if (user != null) {
        userName = user.displayName ?? "";
        userEmail = user.email ?? "";
        phoneNumber = user.phoneNumber ?? "";
      } else {
        userName = prefs.getString("userName") ?? "";
        userEmail = prefs.getString("userEmail") ?? "";
        phoneNumber = prefs.getString("phoneNumber") ?? "";
      }

      userAge = prefs.getString("userAge") ?? "";
      userWeight = prefs.getString("userWeight") ?? "";
      activityLevel = prefs.getString("activityLevel") ?? "";
      physicallyDemandingJob = prefs.getBool("physicallyDemandingJob") ?? false;
      exercisesRegularly = prefs.getBool("exercisesRegularly") ?? false;
      hasMedicalCondition = prefs.getBool("hasMedicalCondition") ?? false;
      isPregnantOrBreastfeeding =
          prefs.getBool("isPregnantOrBreastfeeding") ?? false;
      takesMedications = prefs.getBool("takesMedications") ?? false;
      experiencesDehydration = prefs.getBool("experiencesDehydration") ?? false;
      estimatedWaterIntake = prefs.getString("estimatedWaterIntake") ?? "";
      drinksDehydratingBeverages =
          prefs.getBool("drinksDehydratingBeverages") ?? false;
      wantsReminders = prefs.getBool("wantsReminders") ?? true;
      wantsToTrackOtherFluids =
          prefs.getBool("wantsToTrackOtherFluids") ?? false;

      _nameController.text = userName;
      _emailController.text = userEmail;
      _phoneController.text = phoneNumber;
      _ageController.text = userAge;
      _weightController.text = userWeight;

      // Load profile image if saved
      final imagePath = prefs.getString("profileImagePath");
      if (imagePath != null) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb) {
      // For web, use file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _profileImage = File(result.files.single.path!);
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("profileImagePath", result.files.single.path!);
      }
    } else {
      // For mobile, use image_picker
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("profileImagePath", pickedFile.path);
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _profileImage = null;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("profileImagePath");
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateProfile(displayName: _nameController.text);
    }

    prefs.setString("userName", _nameController.text);
    prefs.setString("userEmail", _emailController.text);
    prefs.setString("phoneNumber", _phoneController.text);
    prefs.setString("userAge", _ageController.text);
    prefs.setString("userWeight", _weightController.text);
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile saved successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text("Save", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage(
                                  "assets/images/others/default_profile.jpg",
                                )
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder:
                                (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text("Choose from Gallery"),
                                      onTap: () {
                                        _pickImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text("Take a Photo"),
                                      onTap: () {
                                        _pickImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    if (_profileImage != null)
                                      ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          "Remove Photo",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onTap: () {
                                          _removeImage();
                                          Navigator.pop(context);
                                        },
                                      ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildEditableField("Name", _nameController),
            _buildEditableField("Email", _emailController),
            _buildEditableField(
              "Phone Number",
              _phoneController,
              onChanged: (value) async {
                setState(() {
                  phoneNumberChanged = value != phoneNumber;
                  phoneNumber = value;
                });
                // Save the phone number to SharedPreferences immediately
                final prefs = await SharedPreferences.getInstance();
                prefs.setString("phoneNumber", value);
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            _buildEditableField("Age", _ageController),
            _buildEditableField("Weight", _weightController),
            _buildDropdown(
              "Activity Level",
              ["Low", "Moderate", "High"],
              activityLevel,
              (value) {
                setState(() {
                  activityLevel = value!;
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
            _buildSwitch("Has Medical Condition", hasMedicalCondition, (value) {
              setState(() {
                hasMedicalCondition = value;
              });
            }),
            _buildSwitch(
              "Pregnant or Breastfeeding",
              isPregnantOrBreastfeeding,
              (value) {
                setState(() {
                  isPregnantOrBreastfeeding = value;
                });
              },
            ),
            _buildSwitch("Takes Medications", takesMedications, (value) {
              setState(() {
                takesMedications = value;
              });
            }),
            _buildSwitch("Experiences Dehydration", experiencesDehydration, (
              value,
            ) {
              setState(() {
                experiencesDehydration = value;
              });
            }),
            _buildDropdown(
              "Estimated Water Intake",
              ["Less than 1L", "1-2 Liters", "More than 2L"],
              estimatedWaterIntake,
              (value) {
                setState(() {
                  estimatedWaterIntake = value!;
                });
              },
            ),
            _buildSwitch(
              "Drinks Dehydrating Beverages",
              drinksDehydratingBeverages,
              (value) {
                setState(() {
                  drinksDehydratingBeverages = value;
                });
              },
            ),
            _buildSwitch("Enable Water Intake Reminders", wantsReminders, (
              value,
            ) {
              setState(() {
                wantsReminders = value;
              });
            }),
            _buildSwitch("Track Other Fluids", wantsToTrackOtherFluids, (
              value,
            ) {
              setState(() {
                wantsToTrackOtherFluids = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(selectedValue) ? selectedValue : null,
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
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
