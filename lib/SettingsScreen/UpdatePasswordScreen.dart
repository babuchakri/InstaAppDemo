import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPasswordUpdated = false;
  bool _showSuccessMessage = false;

  void _updatePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
      try {
        User? currentUser = _auth.currentUser;

        if (currentUser != null) {
          // Reauthenticate the user
          AuthCredential credential = EmailAuthProvider.credential(
            email: currentUser.email!,
            password: currentPassword,
          );

          await currentUser.reauthenticateWithCredential(credential);

          // Update the password
          await currentUser.updatePassword(newPassword);

          // Update the password in Firestore
          await _firestore.collection('users').doc(currentUser.uid).update({
            'password': newPassword,
          });

          if (mounted) {
            setState(() {
              _isPasswordUpdated = true;
              _showSuccessMessage = true;
            });
          }

          // Delay navigation to ensure setState has completed
          Future.delayed(Duration.zero, () {
            _navigateToSettingsScreen();
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isPasswordUpdated = false;
            _showSuccessMessage = false;
          });
        }

        debugPrint('Failed to update password: $e');
      }
    } else {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
      debugPrint('Please enter both current and new password');
    }
  }

  void _navigateToSettingsScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Update Password',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _navigateToSettingsScreen();
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
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Text(
                  'The updated password will be used for secure access',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Enter current password',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true, // Hide the entered password
              enabled: !_isPasswordUpdated, // Disable controller if password is updated
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Enter new password',
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              obscureText: true, // Hide the entered password
              enabled: !_isPasswordUpdated, // Disable controller if password is updated
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: !_isPasswordUpdated ? _updatePassword : null, // Disable button if password is updated
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
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
            if (_showSuccessMessage)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Password updated successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
