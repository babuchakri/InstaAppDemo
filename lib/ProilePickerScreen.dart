import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_form_one/LoginScreen.dart';
import 'package:login_form_one/resources/auth_models.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Utils/utils.dart';

class ProfilePickerScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String gender;
  final String email;
  final String password;
  final String phone;
  final String bio;

  const ProfilePickerScreen({
    super.key, // Fixed super.key to Key? key
    required this.name,
    required this.birth,
    required this.gender,
    required this.email,
    required this.password,
    required this.phone,
    required this.bio,
  }); // Added super(key: key);

  @override
  State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  void requestLocationPermission() async {
    if (await Permission.location.request().isDenied) {
      // Handle the case when the user denies location permission
      // You can show an error message or request permission again
      // For simplicity, we'll just go back to the previous screen
      Navigator.pop(context);
    }
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
      });
    }
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: widget.email,
      password: widget.password,
      name: widget.name,
      phone: widget.phone,
      bio: widget.bio,
      gender: widget.gender,
      file: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      Fluttertoast.showToast(
        msg: 'Registration Successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      showSnackBar(res, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use leading property to add the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registration', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 150,
                  height: 210,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _image!,
                      width: 150,
                      height: 210,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const SizedBox(), // Empty SizedBox if _image is null
                ),
                if (_image == null) // Only show the plus icon if _image is null
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      size: 25, // Adjust the size of the icon
                      color: Colors.white,
                    ),
                    onPressed: selectImage,
                  ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUpUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 80), // Adjust vertical padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 10.0, // Adjust the size as needed
                height: 10.0, // Adjust the size as needed
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : const Text(
                'submit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
