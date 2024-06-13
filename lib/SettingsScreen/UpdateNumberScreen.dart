import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';

class UpdateNumberScreen extends StatefulWidget {
  const UpdateNumberScreen({Key? key}) : super(key: key);

  @override
  State<UpdateNumberScreen> createState() => _UpdateNumberScreenState();
}

class _UpdateNumberScreenState extends State<UpdateNumberScreen> {
  final TextEditingController _numberController = TextEditingController();
  bool _isNumberUpdated = false;
  String? _errorMessage;

  void _updateNumber() async {
    String newNumber = _numberController.text.trim();
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (newNumber.isNotEmpty && currentUser != null) {
      try {
        // Update number in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'phoneNumber': newNumber,
        });

        setState(() {
          _isNumberUpdated = true;
          _errorMessage = null;
        });

      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update number: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Update Number',
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
                  'The updated number will be used for verification purposes',
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
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter new number',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateNumber,
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
            if (_isNumberUpdated)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Number updated successfully',
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
