import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _verificationEmailSent = false;
  bool _emailUpdated = false;

  void _updateEmail() async {
    String newEmail = _emailController.text.trim();

    if (newEmail.isNotEmpty) {
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          // Send email verification before updating email
          await currentUser.verifyBeforeUpdateEmail(newEmail);

          setState(() {
            _verificationEmailSent = true;
            _emailUpdated = false; // Reset email updated flag
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send verification email: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email')),
      );
    }
  }

  Future<void> _checkEmailVerified() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null && currentUser.emailVerified) {
      try {
        // Update email in Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'email': currentUser.email,
        });

        setState(() {
          _emailUpdated = true;
          _verificationEmailSent = false; // Hide verification message
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update email in Firestore: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Periodically check if the email is verified
    _auth.userChanges().listen((User? user) {
      if (user != null && _verificationEmailSent) {
        _checkEmailVerified();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Update Email',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'The updated email will be used for notifications',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter new email',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_verificationEmailSent) ...[
              SizedBox(height: 16.0),
              Text(
                'Verification link sent to your email. Please verify.',
                style: TextStyle(color: Colors.yellow),
                textAlign: TextAlign.center,
              ),
            ],
            if (_emailUpdated) ...[
              SizedBox(height: 16.0),
              Text(
                'Email updated successfully!',
                style: TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
