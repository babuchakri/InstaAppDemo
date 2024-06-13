import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Facebook extends StatefulWidget {
  const Facebook({Key? key}) : super(key: key);

  @override
  State<Facebook> createState() => _FacebookState();
}

class _FacebookState extends State<Facebook> {
  TextEditingController _idController = TextEditingController();
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
          _idController.text = userDoc['facebookId'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Sharing Social Media IDs',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              Text(
                'Facebook ID Sharing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Sharing your ID will display to other users who are nearby you.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    controller: _idController,
                    style: TextStyle(color: Colors.white),
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      hintText: 'Enter your Facebook ID',
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Colors.grey[900],
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Facebook ID';
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
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              if (_successMessage.isNotEmpty)
                Text(
                  _successMessage,
                  style: TextStyle(
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
          .update({'facebookId': facebookId})
          .then((value) {
        setState(() {
          _successMessage = 'Facebook ID updated successfully';
        });
        print('Facebook ID updated successfully');
      }).catchError((error) {
        print('Error updating Facebook ID: $error');
      });
    } else {
      print('No user is currently signed in');
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}
