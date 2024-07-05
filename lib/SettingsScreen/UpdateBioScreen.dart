import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';

class UpdateBioScreen extends StatefulWidget {
  const UpdateBioScreen({super.key});

  @override
  State<UpdateBioScreen> createState() => _UpdateBioScreenState();
}

class _UpdateBioScreenState extends State<UpdateBioScreen> {
  final TextEditingController _bioController = TextEditingController();
  bool _isBioUpdated = false;
  String? _errorMessage;

  void _updateBio() async {
    String newBio = _bioController.text.trim();
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (newBio.isNotEmpty && currentUser != null) {
      try {
        // Update bio in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'bio': newBio,
        });

        setState(() {
          _isBioUpdated = true;
          _errorMessage = null;
        });

      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update bio: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Please enter a valid bio';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Update Bio',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Text(
                  'The updated bio will appear in the profile screen',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _bioController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your bio here...',
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateBio,
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
            if (_isBioUpdated)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Bio updated successfully',
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
