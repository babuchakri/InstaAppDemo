import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String password; // Not recommended to store passwords in plaintext
  final String phone;
  final String bio;
  final String gender;
  String? snapchatId; // Add this property
  String? instagramId; // Add this property
  String? facebookId; // Add this property

  late final String photoUrl;
  final double latitude;
  final double longitude;
  int likes; // Add this field
  int hearts; // Add this field
  int connected;

  bool visibilityToggle; // Add visibility toggle


  User({
    required this.uid,
    required this.username,
    this.snapchatId, // Initialize it in the constructor
     this.instagramId, // Initialize it in the constructor
    this.facebookId, // Initialize it in the constructor

    required this.email,
    required this.password,
    required this.phone,
    required this.bio,
    required this.gender,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.likes, // Initialize likes count
    required this.hearts, // Initialize hearts count
    required this.connected,
    required this.visibilityToggle, // Initialize visibility toggle

  });

  factory User.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!; // Ensure data is not null

    return User(
      uid: snapshot.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      // Not recommended to store passwords in plaintext
      phone: data['phone'] ?? '',
      bio: data['bio'] ?? '',
      snapchatId: data['snapchatId'],
      // Initialize the snapchatId property
      instagramId: data['instagramId'],
      // Initialize the snapchatId property
      facebookId: data['facebookId'],
      // Initialize the snapchatId property

      gender: data['gender'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      // Provide a default value for photoUrl
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      // Default value in case not provided
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      // Default value in case not provided
      likes: data['likes'] ?? 0,
      // Default value in case not provided
      hearts: data['hearts'] ?? 0,
      // Default value in case not provided
      connected: data['connected'] ?? 0,
      visibilityToggle: data['visibilityToggle'] ??
          false, // Initialize visibility toggle

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
      'snapchatId': snapchatId,
      'instagramId': instagramId,
      'facebookId': facebookId,

      'longitude': longitude,
      'likes': likes, // Include likes count in JSON representation
      'hearts': hearts, // Include hearts count in JSON representation
      'connected': connected,
      'visibilityToggle': visibilityToggle,

    };
  }
}
