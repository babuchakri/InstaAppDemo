import 'package:flutter/material.dart';
import 'BioScreen.dart';

class PhoneNumberScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String gender;
  final String email;
  final String password;

  const PhoneNumberScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.gender,
    required this.email,
    required this.password,
  });

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use leading property to add the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                String phone = _phoneNumberController.text;
                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 10-digit phone number'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BioScreen(
                        name: widget.name,
                        birth: widget.birth,
                        gender: widget.gender,
                        email: widget.email,
                        password: widget.password,
                        phone: phone,
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
              ),
            ),
        )],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }
}
