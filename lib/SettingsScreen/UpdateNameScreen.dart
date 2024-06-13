import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({Key? key}) : super(key: key);

  @override
  _UpdateNameScreenState createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameUpdated = false;
  bool _showErrorMessage = false; // Added to track whether to show the error message

  void _updateName() async {
    String newName = _nameController.text.trim();
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (newName.isNotEmpty && currentUser != null) {
      try {
        // Update name in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'username': newName,
        });

        setState(() {
          _isNameUpdated = true;
          _showErrorMessage = false; // Reset error message flag
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully', style: TextStyle(color: Colors.green))),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e', style: TextStyle(color: Colors.red))),
        );
      }
    } else {
      // Show error message if name is empty
      setState(() {
        _showErrorMessage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Update Name',
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
        color: Colors.black, // Set the body background color to black
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
                  'The updated name will be visible in the profile page',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white, // Changed text color to white
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter new name',
                labelStyle: TextStyle(color: Colors.white), // Changed label text color to white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: TextStyle(color: Colors.white), // Changed input text color to white
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateName,
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
                    fontSize: 23.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_showErrorMessage)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Please enter a valid name',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isNameUpdated)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Name updated successfully',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
