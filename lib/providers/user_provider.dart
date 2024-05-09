

import 'package:flutter/cupertino.dart';
import 'package:login_form_one/models/user.dart';
import 'package:login_form_one/resources/auth_models.dart';

class UserProvider with ChangeNotifier {
User? _user;


User? _selectedUserProfile; // Add a variable to store the selected user's profile

final AuthMethods _authMethods = AuthMethods();

User? get getUser => _user;



User? get getSelectedUserProfile => _selectedUserProfile; // Getter for selected user's profile

// Method to refresh the current user's profile
Future<void> refreshUser() async {
  User user = await _authMethods.getUserDetails();
  _user = user;
  notifyListeners();
}

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }
// Method to set the selected user's profile
void setSelectedUserProfile(User user) {
  _selectedUserProfile = user;
  notifyListeners();
}
}




