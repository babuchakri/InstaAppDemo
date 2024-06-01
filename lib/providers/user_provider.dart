// user_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../resources/auth_models.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  List<User> _selectedUserProfiles = [];
  List<User> _friends = [];

  User? get getUser => _user;

  List<User> get getSelectedUserProfiles => _selectedUserProfiles;

  List<User> get friends => _friends;

  final AuthMethods _authMethods = AuthMethods();

  Future<void> refreshUser() async {
    try {
      User user = await _authMethods.getUserDetails();
      setUser(user);
    } catch (error) {
      print('Error refreshing user: $error');
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
      print('Current user ID is null');
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
        print('No friends found for the user.');
      }

      notifyListeners();
    } catch (error) {
      print('Error fetching friends: $error');
    }
  }
}
