import 'package:flutter/material.dart';

import 'ProilePickerScreen.dart';

class BioScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String gender;
  final String email;
  final String password;
  final String phone;

  const BioScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.gender,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  State<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends State<BioScreen> {
  final TextEditingController _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use leading property to add the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registration',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Add bio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                String bio = _bioController.text;
                List<String> lines = bio.split('\n');
                if (lines.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a bio with at least three lines'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePickerScreen(
                        name: widget.name,
                        birth: widget.birth,
                        gender: widget.gender,
                        email: widget.email,
                        password: widget.password,
                        phone: widget.phone,
                        bio: bio,
                      ),
                    ),
                  );
                }
              },

              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust border radius
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Text('Continue',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),),
              ),            ),
        )],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
