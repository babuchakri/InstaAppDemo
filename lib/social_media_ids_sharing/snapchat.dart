import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Snapchat extends StatefulWidget {
  const Snapchat({Key? key}) : super(key: key);

  @override
  State<Snapchat> createState() => _SnapchatState();
}

class _SnapchatState extends State<Snapchat> {
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _successMessage = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSnapchatURL();
  }

  Future<void> _loadCurrentSnapchatURL() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _urlController.text = userDoc['snapchatId'] ?? '';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Snapchat URL Sharing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sharing your URL will display to other users who are nearby you.',
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
                      controller: _urlController,
                      style: const TextStyle(color: Colors.blue),
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        hintText: 'Enter your Snapchat URL',
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
                          return 'Please enter your Snapchat URL';
                        } else if (!isURL(value)) {
                          return 'Please enter a valid URL';
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
                    if (_formKey.currentState!.validate()) {
                      _updateSnapchatURL();
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
                const SizedBox(height: 20),
                Text(
                  'Instructions:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '1. Open Snapchat\n'
                      '2. Go to your profile\n'
                      '3. Click on "Share"\n'
                      '4. Copy the link\n'
                      '5. Paste the link here\n'
                      '6. Click "Update"',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateSnapchatURL() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String snapchatId = _urlController.text;

      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'snapchatId': snapchatId})
          .then((value) {
        setState(() {
          _successMessage = 'Snapchat URL updated successfully';
        });
      }).catchError((error) {
        // Handle error
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

bool isURL(String url) {
  return Uri.tryParse(url)?.isAbsolute ?? false;
}
