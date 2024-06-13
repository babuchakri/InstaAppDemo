import 'package:flutter/material.dart';
import 'package:login_form_one/SettingsScreen/UpdateProfilePhoto.dart';
import 'package:login_form_one/social_media_ids_sharing/instagarm.dart';
import 'package:login_form_one/social_media_ids_sharing/snapchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../LoginScreen.dart';
import '../social_media_ids_sharing/facebook.dart';
import 'SuggestionsScreen.dart';
import 'UpdateBioScreen.dart';
import 'UpdateEmailScreen.dart';
import 'UpdateNameScreen.dart';
import 'UpdateNumberScreen.dart';
import 'UpdatePasswordScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool facebookToggleState = false;
  bool snapchatToggleState = false;
  bool instagramToggleState = false;

  String username = '';
  String useremail = '';
  String usernumber = '';

  @override
  void initState() {
    super.initState();
    _loadToggleStates();
    _loadUserDetails();
  }

  Future<void> _loadToggleStates() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      facebookToggleState = data['facebookToggle'] ?? false;
      snapchatToggleState = data['snapchatToggle'] ?? false;
      instagramToggleState = data['instagramToggle'] ?? false;
    });
  }

  Future<void> _loadUserDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // Debugging: Print retrieved data
    print("User data: $data");

    setState(() {
      username = data['name'] ?? 'Unknown';
      useremail = data['email'] ?? 'Unknown';
      usernumber = data['phoneNumber'] ?? 'Unknown';
    });


  }

  Future<void> _saveToggleState(String key, bool value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({key: value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeading('Share Social Media Accounts'),

            _buildSocialMediaItem('Facebook', Icons.facebook, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Facebook()),
              );
            }, facebookToggleState, (value) {
              setState(() {
                facebookToggleState = value;
                _saveToggleState('facebookToggle', value);
              });
            }),

            _buildSocialMediaItem('Snapchat', Icons.snapchat, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Snapchat()),
              );
            }, snapchatToggleState, (value) {
              setState(() {
                snapchatToggleState = value;
                _saveToggleState('snapchatToggle', value);
              });
            }),

            _buildSocialMediaItem('Instagram', Icons.camera, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Instagram()),
              );
            }, instagramToggleState, (value) {
              setState(() {
                instagramToggleState = value;
                _saveToggleState('instagramToggle', value);
              });
            }),

            const SizedBox(height: 20),

            _buildSectionHeading('Account Settings'),
            _buildSettingsItem('Update Profile', Icons.person, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UpdateProfilePhoto()),
              );
            }),
            _buildSettingsItem('Update Name', Icons.person_outline, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UpdateNameScreen()),
              );
            }),
            _buildSettingsItem('Update Bio', Icons.info_outline, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UpdateBioScreen()),
              );
            }),
            _buildSettingsItem('Update Number', Icons.phone, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UpdateNumberScreen()),
              );
            }),
            _buildSettingsItem('Update Email', Icons.email, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UpdateEmailScreen()),
              );
            }),
            _buildSettingsItem('Update Password', Icons.lock, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()),
              );
            }),
            SizedBox(height: 20),
            _buildSectionHeading('Personal Information'),
            _buildInfoItem('Email', useremail, Icons.email),
            _buildInfoItem('Number', usernumber, Icons.phone),
            SizedBox(height: 20),
            _buildSectionHeading('Manage privacy'),
            _buildSettingsItem('Privacy', Icons.privacy_tip, () {
              // Privacy logic
            }),
            _buildSettingsItem('Notifications', Icons.notifications, () {
              // Notifications logic
            }),
            SizedBox(height: 20),
            _buildSectionHeading('Suggestions & About'),
            _buildSettingsItem('Suggestions', Icons.lightbulb_outline, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SuggestionsScreen()),
              );
            }),
            _buildSettingsItem('About', Icons.info, () {
              // About logic
            }),
            const SizedBox(height: 20),
            ListTile(
              title: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              onTap: () {
                // Logout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildSocialMediaItem(String title, IconData icon, VoidCallback onTap, bool isOn, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: isOn,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
