import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneOTPVerification extends StatefulWidget {
  final String phoneNumber; // Add this

  const PhoneOTPVerification({required this.phoneNumber, Key? key})
    : super(key: key);
  @override
  _PhoneOTPVerificationState createState() => _PhoneOTPVerificationState();
}

class _PhoneOTPVerificationState extends State<PhoneOTPVerification> {
  late final TextEditingController _phoneController;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  String _verificationId = '';
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.phoneNumber,
    ); // Initialize with phone number
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber, // Use the phone number from the widget
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Verification successful!')));
        Navigator.pop(context, true);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final otp = _otpControllers.map((controller) => controller.text).join();
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification successful!')));
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_otpSent)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_otpSent)
              Column(
                children: [
                  Text('Enter the OTP sent to ${_phoneController.text}'),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 40,
                        child: TextField(
                          controller: _otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
