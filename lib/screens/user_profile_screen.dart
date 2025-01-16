import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/user-profile'; // Add a route name for navigation.

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userName;
  String? userEmail;
  String? userAge;
  String? userWeight;
  String? profileImageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load data from SharedPreferences first
      setState(() {
        userName = prefs.getString('userName') ?? 'Unknown User';
        userEmail = prefs.getString('userEmail') ?? 'Unknown Email';
        userAge = prefs.getString('userAge') ?? 'Unknown Age';
        userWeight = prefs.getString('userWeight') ?? 'Unknown Weight';
      });

      // Load data from Firebase Firestore (if logged in)
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
        }
      }
    } catch (error) {
      // Handle error gracefully
      print('Error loading user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null, // Dynamically load from Firestore
                child: profileImageUrl == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                    : null,
              ),
              const SizedBox(height: 20),

              // User Details
              _buildProfileDetail("Name", userName),
              _buildProfileDetail("Email", userEmail),
              _buildProfileDetail("Age", userAge),
              _buildProfileDetail("Weight", userWeight),

              const SizedBox(height: 30),

              // Edit Profile Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit-profile');
                  // Replace '/edit-profile' with the correct route for your EditProfileScreen
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not available',
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
