import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';

class UpdateProfilePhoto extends StatefulWidget {
  const UpdateProfilePhoto({super.key});

  @override
  State<UpdateProfilePhoto> createState() => _UpdateProfilePhotoState();
}

class _UpdateProfilePhotoState extends State<UpdateProfilePhoto> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isPhotoUpdated = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isPhotoUpdated = false; // Reset photo updated status if a new image is picked
      });
    }
  }

  Future<void> _updateProfilePhoto(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && _selectedImage != null) {
      String fileName = basename(_selectedImage!.path);
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Clear any previous error message
      });
      try {
        // Upload image to Firebase Storage
        Reference storageReference = FirebaseStorage.instance.ref().child('profilePhotos/$fileName');
        UploadTask uploadTask = storageReference.putFile(_selectedImage!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore document with the new photo URL
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'photoUrl': downloadUrl,
        });

        setState(() {
          _isPhotoUpdated = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to update profile photo: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Please select an image to upload';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Update Profile Photo', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
                  'The updated profile photo will be visible on the profile page',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150.0,
                height: 150.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: _selectedImage != null
                      ? DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 50.0,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20.0),
            Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _updateProfilePhoto(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: const Size(double.infinity, 50), // Button size
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
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
              ],
            ),
            if (_isPhotoUpdated)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Profile photo updated successfully',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
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
