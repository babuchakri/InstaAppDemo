import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Snapchat extends StatefulWidget {
  const Snapchat({super.key});

  @override
  State<Snapchat> createState() => _SnapchatState();
}

class _SnapchatState extends State<Snapchat> {
  final TextEditingController _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for form validation
  String _successMessage = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentFacebookID();
  }

  Future<void> _loadCurrentFacebookID() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _idController.text = userDoc['snapchatId'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Sharing Social Media IDs',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Assigning the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Snapchat ID Sharing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sharing your ID will display to other users who are nearby you.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    controller: _idController,
                    style: const TextStyle(color: Colors.white),
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      hintText: 'Enter your Snapchat ID',
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: Colors.grey[900],
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Snapchat ID';
                      }
                      return null;
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        _isEditing ? Icons.done : Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate form before updating
                  if (_formKey.currentState!.validate()) {
                    _updateFacebookID();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_successMessage.isNotEmpty)
                Text(
                  _successMessage,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateFacebookID() async {
    // Get the current user ID
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Get the entered Facebook ID
      String facebookId = _idController.text;

      // Update the Facebook ID in Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'snapchatId': facebookId})
          .then((value) {
        setState(() {
          _successMessage = 'Snapchat ID updated successfully';
        });
      }).catchError((error) {
      });
    } else {
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}
