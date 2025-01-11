import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:my_app/screens/setup_screen.dart';

class StartScreen extends StatefulWidget {
  final Function changePage;
  const StartScreen(this.changePage, {super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false; // To toggle password visibility
  String _responseMessage = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<void> _loginWithGoogle() async {
    toggleLoading();

    try {
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid', // Additional scopes for fetching user details
        ],
      );

      // Trigger the Google Sign-In process
      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

      if (googleAccount == null) {
        // User canceled the sign-in process
        setState(() {
          _responseMessage = 'Google Sign-In was canceled by the user.';
          _isLoading = false;
        });
        return;
      }

      // Retrieve authentication details from the user's Google account
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      if (googleAuth.idToken == null) {
        setState(() {
          _responseMessage = 'Google Sign-In failed: ID Token is null.';
          _isLoading = false;
        });
        return;
      }

      // Create Firebase credential using Google authentication tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the generated credentials
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        setState(() {
          _responseMessage =
              'Welcome ${user.displayName}, you are logged in successfully!';
          _isLoading = false;
        });

        widget.changePage(1); // Navigate to the next screen
      } else {
        setState(() {
          _responseMessage = 'Google Sign-In failed: User data is null.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Google Sign-In failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithEmailPassword() async {
    toggleLoading();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _responseMessage = 'Logged in successfully';
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetupScreen(),
        ), // Replace with your desired screen
      );
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signUpWithEmailPassword() async {
    toggleLoading();
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        _responseMessage = 'Account created successfully';
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetupScreen(),
        ), // Replace with your desired screen
      );
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/icons/icon_transparent.png",
                  height: 110,
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? "Login to Hydra8" : "Sign Up for Hydra8",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color:
                        isDarkTheme
                            ? Colors.white
                            : const Color.fromRGBO(0, 0, 0, 0.8),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15), // Added spacing
                        TextFormField(
                          controller: _birthDateController,
                          decoration: InputDecoration(
                            labelText: "Birth Date (YYYY-MM-DD)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your birth date";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15), // Added spacing
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(
                            r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                          ).hasMatch(value)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_isLogin) {
                                _loginWithEmailPassword();
                              } else {
                                _signUpWithEmailPassword();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _isLogin ? "Login" : "Sign Up",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _loginWithGoogle,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.blueAccent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/icons/google.png',
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
