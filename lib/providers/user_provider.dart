import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../resources/auth_models.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final List<User> _selectedUserProfiles = [];
  List<User> _friends = [];

  User? get getUser => _user;
  List<User> get getSelectedUserProfiles => _selectedUserProfiles;
  List<User> get friends => _friends;

  final AuthMethods _authMethods = AuthMethods();
  final Logger _logger = Logger(); // Example: Initialize a logger instance

  Future<void> refreshUser() async {
    try {
      User user = await _authMethods.getUserDetails();
      setUser(user);
    } catch (error, stackTrace) {
      _handleError(error, 'Error refreshing user', stackTrace);
    }
  }

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void setSelectedUserProfile(User user) {
    if (!_selectedUserProfiles.contains(user)) {
      _selectedUserProfiles.add(user);
      notifyListeners();
    }
  }

  Future<void> fetchFriends(String? currentUserId) async {
    if (currentUserId == null) {
      _handleError('Current user ID is null', 'Fetch Friends', null);
      return;
    }

    try {
      _friends.clear();
      QuerySnapshot<Map<String, dynamic>> friendsSnapshot =
      await FirebaseFirestore.instance
          .collection('friends')
          .doc(currentUserId)
          .collection('user_friends')
          .get();

      if (friendsSnapshot.docs.isNotEmpty) {
        _friends = friendsSnapshot.docs.map((doc) => User.fromSnapshot(doc)).toList();
      } else {
        _handleError('No friends found', 'Fetch Friends', null);
      }

      notifyListeners();
    } catch (error, stackTrace) {
      _handleError(error, 'Error fetching friends', stackTrace);
    }
  }

  Future<void> updateProfilePhoto(String downloadUrl) async {
    if (_user != null) {
      _user!.photoUrl = downloadUrl;
      try {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
          'photoUrl': downloadUrl,
        });
        notifyListeners();
      } catch (error, stackTrace) {
        _handleError(error, 'Error updating profile photo', stackTrace);
      }
    }
  }

  void _handleError(dynamic error, String message, StackTrace? stackTrace) {
    // Example: Use a logging library to log errors
    _logger.e('$message: $error', error: error, stackTrace: stackTrace);
    // You can expand this to handle errors based on your application's needs.
  }
}
