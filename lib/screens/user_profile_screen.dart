import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/user-profile';

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userName;
  String? userEmail;
  String? userAge;
  String? userWeight;
  String? profileImageUrl;
  File? localProfileImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from SharedPreferences and Firestore
  Future<void> _loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        userName = prefs.getString('userName') ?? 'Unknown User';
        userEmail = prefs.getString('userEmail') ?? 'Unknown Email';
        userAge = prefs.getString('userAge') ?? 'Unknown Age';
        userWeight = prefs.getString('userWeight') ?? 'Unknown Weight';
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? userName;
            userEmail = userDoc['email'] ?? userEmail;
            userAge = userDoc['age'] ?? userAge;
            userWeight = userDoc['weight'] ?? userWeight;
            profileImageUrl = userDoc['profileImage'] ?? null;
          });

          await prefs.setString('userName', userName!);
          await prefs.setString('userEmail', userEmail!);
          await prefs.setString('userAge', userAge!);
          await prefs.setString('userWeight', userWeight!);
          if (profileImageUrl != null) {
            await prefs.setString('profileImage', profileImageUrl!);
          }
        }
      }
    } catch (error) {
      print('Error loading user data: $error');
    }
  }

  /// Update Profile Picture
  Future<void> _updateProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        localProfileImage = File(pickedFile.path);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', pickedFile.path);

      // Optionally, upload to Firestore
      // (Requires Firebase Storage integration)
    }
  }

  /// Save edited profile
  Future<void> _saveProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('userName', userName!);
      await prefs.setString('userEmail', userEmail!);
      await prefs.setString('userAge', userAge!);
      await prefs.setString('userWeight', userWeight!);

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'name': userName,
          'email': userEmail,
          'age': userAge,
          'weight': userWeight,
          'profileImage': profileImageUrl,
        }, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (error) {
      print('Error saving profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: localProfileImage != null
                        ? FileImage(localProfileImage!)
                        : profileImageUrl != null
                            ? NetworkImage(profileImageUrl!) as ImageProvider
                            : null,
                    child: localProfileImage == null && profileImageUrl == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: () => _showImagePickerDialog(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Editable Fields
              _buildEditableField("Name", userName, (value) => userName = value),
              _buildEditableField("Email", userEmail, (value) => userEmail = value),
              _buildEditableField("Age", userAge, (value) => userAge = value),
              _buildEditableField("Weight", userWeight, (value) => userWeight = value),

              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String? value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
