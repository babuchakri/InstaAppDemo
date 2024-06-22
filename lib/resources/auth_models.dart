import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login_form_one/models/user.dart' as model;
import 'package:login_form_one/resources/storage_method.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot<Map<String, dynamic>> snap =
    await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnapshot(snap);
  }
  // Method to get the currently logged-in user
  Future<model.User?> getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return model.User.fromSnapshot(snap);
    }
    return null;
  }
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String bio,
    required String gender,
    required Uint8List file,
    double latitude = 0,
    double longitude = 0,
    bool visibilityToggle = true, // Default visibility is true (visible)

  }) async {
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          name.isNotEmpty &&
          phone.isNotEmpty &&
          bio.isNotEmpty &&

          gender.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // Get current user's location
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.User user = model.User(
          username: name,
          uid: cred.user!.uid,
          password: password, // Note: Storing passwords in plaintext is not recommended. Use Firebase Authentication instead.
          email: email,
          phone: phone,
          bio: bio,
          gender: gender,
          photoUrl: photoUrl,
          latitude: position.latitude,
          longitude: position.longitude,
          likes: 0, // Initialize likes count to zero
          hearts: 0, // Initialize hearts count to zero
          connected: 0,
          visibilityToggle: visibilityToggle, // Set visibility toggle based on parameter

        );

        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        return "success";
      } else {
        throw Exception("Please fill in all the fields");
      }
    } catch (err) {
      throw Exception("Failed to sign up: $err");
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        return "success";
      } else {
        return "Please enter all the fields";
      }
    } catch (err) {
      return "incorrect email or password please try again";
    }
  }
}
