
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String password; // Not recommended to store passwords in plaintext
  final String phone;
  final String bio;
  final String gender;
  final String photoUrl;
  final double latitude;
  final double longitude;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.bio,
    required this.gender,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
  });

  factory User.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;

    return User(
      uid: snapshot.id,
      username: data['username'],
      email: data['email'],
      password: data['password'],
      phone: data['phone'],
      bio: data['bio'],
      gender: data['gender'],
      photoUrl: data['photoUrl'],
      latitude: data['latitude'] ?? 0.0, // Default value in case not provided
      longitude: data['longitude'] ?? 0.0, // Default value in case not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password, // Not recommended to store passwords in plaintext
      'phone': phone,
      'bio': bio,
      'gender': gender,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
