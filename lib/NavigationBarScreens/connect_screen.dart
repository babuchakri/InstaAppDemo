import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart' as custom_user;
import 'dart:math';
import '../providers/user_provider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Position? _currentPosition;
  final List<custom_user.User> _nearbyUsers = [];
  bool _isLoading = false;
  final _random = Random();
  StreamSubscription<Position>? _positionStreamSubscription; // Updated to nullable

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Cancel the subscription if it is not null
    super.dispose();
  }

  void _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
    } else {
      _askLocationPermission();
    }
  }

  void _askLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showLocationPermissionDeniedDialog();
    } else {
      _updateLocation();
    }
  }

  void _updateLocation() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
          setState(() {
            _currentPosition = position;
            if (!_isLoading) {
              _updateNearbyUsers();
            }
          });

          if (_currentPosition != null) {
            double currentLat = _currentPosition!.latitude;
            double currentLong = _currentPosition!.longitude;

            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'latitude': currentLat,
              'longitude': currentLong,
            });
          }
        });
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Service Disabled"),
          content: const Text(
              "Please enable location services to use this feature."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                _checkLocationPermission();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Denied"),
          content: const Text(
              "Please grant location permission to use this feature."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _updateNearbyUsers() async {
    try {
      _nearbyUsers.clear();
      QuerySnapshot usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      if (_currentPosition != null) {
        double currentLat = _currentPosition!.latitude;
        double currentLong = _currentPosition!.longitude;
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;

        for (var doc in usersSnapshot.docs) {
          custom_user.User user = custom_user.User.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );

          Map<String, dynamic>? userData =
          doc.data() as Map<String, dynamic>?;

          if (userData != null &&
              userData.containsKey('latitude') &&
              userData.containsKey('longitude') &&
              userData['visibilityToggle'] == true) {
            double userLatitude = userData['latitude'];
            double userLongitude = userData['longitude'];

            double distanceInMeters = Geolocator.distanceBetween(
              currentLat,
              currentLong,
              userLatitude,
              userLongitude,
            );

            if (distanceInMeters <= 20 && doc.id != currentUserId) {
              _nearbyUsers.add(user);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      //print('Error updating nearby users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _nearbyUsers.isEmpty
            ? const Center(
          child: Text(
            'No nearby users found',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        )
            : _buildNearbyUsersList(),
      ),
    );
  }

  Widget _buildNearbyUsersList() {
    double bottomNavBarHeight = kBottomNavigationBarHeight;
    double screenHeight = MediaQuery.of(context).size.height;
    double avatarRadius = 38; // Radius of the circle avatar
    double minDistance = avatarRadius * 2.5; // Minimum distance between avatars

    List<Positioned> positionedAvatars = [];

    for (custom_user.User user in _nearbyUsers) {
      double left = 0, top = 0; // Initialize left and top here

      bool positionFound = false;

      // Try to find a non-overlapping position
      while (!positionFound) {
        left = _random.nextDouble() * (MediaQuery.of(context).size.width - 80);
        top = _random.nextDouble() *
            (screenHeight -
                MediaQuery.of(context).padding.bottom -
                bottomNavBarHeight -
                90);

        // Check against already positioned avatars
        bool overlaps = positionedAvatars.any((positionedAvatar) {
          double existingLeft = positionedAvatar.left!;
          double existingTop = positionedAvatar.top!;
          double distance =
          sqrt(pow(left - existingLeft, 2) + pow(top - existingTop, 2));
          return distance < minDistance;
        });

        if (!overlaps) {
          positionFound = true;
        }
      }

      Positioned positionedAvatar = Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: () {
            _showUserProfileDialog(user);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.0, // Slightly thicker border
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.black,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
          ),
        ),
      );

      positionedAvatars.add(positionedAvatar);
    }

    return Stack(
      children: positionedAvatars,
    );
  }
  void _showUserProfileDialog(custom_user.User user) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String currentUsername = FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown';

    bool userAlreadyAdded = false;

    // Check if the user is already added to the friends list
    DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUserId)
        .collection('user_friends')
        .doc(user.uid)
        .get();

    if (friendSnapshot.exists) {
      userAlreadyAdded = true;
    }

    bool connected = false;

    // Fetch user's social media sharing settings
    DocumentSnapshot userSettingsSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    Map<String, dynamic> userSettings = userSettingsSnapshot.data() as Map<String, dynamic>;

    bool showSnapchat = userSettings['snapchatToggle'] ?? false;
    bool showInstagram = userSettings['instagramToggle'] ?? false;
    bool showFacebook = userSettings['facebookToggle'] ?? false;
    String snapchatId = user.snapchatId ?? 'Not available';
    String instagramId = user.instagramId ?? 'Not available';
    String facebookId = user.facebookId ?? 'Not available';

    bool connectDisabled = userAlreadyAdded;

    // Check if the current user has already liked or loved the user
    DocumentSnapshot likeSnapshot = await FirebaseFirestore.instance
        .collection('actions')
        .doc(currentUserId)
        .collection('user_actions')
        .doc('like_${user.uid}')
        .get();

    DocumentSnapshot loveSnapshot = await FirebaseFirestore.instance
        .collection('actions')
        .doc(currentUserId)
        .collection('user_actions')
        .doc('love_${user.uid}')
        .get();

    bool alreadyLiked = likeSnapshot.exists;
    bool alreadyLoved = loveSnapshot.exists;

    // Ensure the widget is still mounted before showing the dialog
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),  // Added padding to all sides
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border.all(color: Colors.white, width: 0.3),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 120,
                    backgroundImage: NetworkImage(user.photoUrl),
                    backgroundColor: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[800]),
                  _buildSocialLinkRow('Snapchat', snapchatId, showSnapchat),
                  Divider(color: Colors.grey[800]),
                  _buildSocialLinkRow('Instagram', instagramId, showInstagram),
                  Divider(color: Colors.grey[800]),
                  _buildSocialLinkRow('Facebook', facebookId, showFacebook),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[800]),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionIcon(
                        icon: Icons.people_alt_rounded,
                        color: connected ? Colors.green : (userAlreadyAdded ? Colors.green : Colors.white),
                        label: userAlreadyAdded ? 'Connected' : 'Connect',
                        onPressed: connectDisabled ? null : () async {
                          DocumentReference friendRef = FirebaseFirestore.instance
                              .collection('friends')
                              .doc(currentUserId)
                              .collection('user_friends')
                              .doc(user.uid);

                          try {
                            await friendRef.set({
                              'username': user.username,
                              'uid': user.uid,
                              'email': user.email,
                              'photoUrl': user.photoUrl,
                            });
                            setState(() {
                              connected = true;
                            });
                            Provider.of<UserProvider>(context, listen: false)
                                .setSelectedUserProfile(user);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  'User added to friends list',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23),
                                ),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            await _incrementConnectCount(user);
                            await _sendNotification(
                                user,
                                'Connected',
                                'You are now connected with $currentUsername',
                                currentUsername,
                                FirebaseAuth.instance.currentUser!.photoURL);
                          } catch (e) {
                            // Handle error
                          }
                        },
                      ),
                      _buildActionIcon(
                        icon: Icons.favorite,
                        color: alreadyLoved ? Colors.red : Colors.white,
                        label: 'Love',
                        onPressed: alreadyLoved ? null : () async {
                          await _incrementHeartCount(user);

                          await FirebaseFirestore.instance
                              .collection('actions')
                              .doc(currentUserId)
                              .collection('user_actions')
                              .doc('love_${user.uid}')
                              .set({
                            'action': 'love',
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          setState(() {
                            alreadyLoved = true;
                          });
                          Navigator.of(context).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'You sent a heart to user',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23),
                              ),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          await _sendNotification(
                              user,
                              'Love',
                              'You received a heart from $currentUsername',
                              currentUsername,
                              FirebaseAuth.instance.currentUser!.photoURL);
                        },
                      ),
                      _buildActionIcon(
                        icon: Icons.thumb_up,
                        color: alreadyLiked ? Colors.blue : Colors.white,
                        label: 'Like',
                        onPressed: alreadyLiked ? null : () async {
                          await _incrementLikeCount(user);

                          await FirebaseFirestore.instance
                              .collection('actions')
                              .doc(currentUserId)
                              .collection('user_actions')
                              .doc('like_${user.uid}')
                              .set({
                            'action': 'like',
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          setState(() {
                            alreadyLiked = true;
                          });
                          Navigator.of(context).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.blue,
                              content: Text(
                                'You sent a like to user',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23),
                              ),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          await _sendNotification(
                              user,
                              'Liked',
                              'You have been liked by $currentUsername',
                              currentUsername,
                              FirebaseAuth.instance.currentUser!.photoURL);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLinkRow(String label, String id, bool show) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: show ? () => launchUrl(Uri.parse(id)) : null,
              child: Text(
                show ? id : 'Not available',
                style: TextStyle(
                  color: show ? Colors.blue : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: show ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required String label, required VoidCallback? onPressed}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }



  //veera babu
  Future<void> _incrementLikeCount(custom_user.User user) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        int newLikeCount =
            (snapshot.data() as Map<String, dynamic>)['likes'] + 1;
        transaction.update(userRef, {'likes': newLikeCount});
      });
    } catch (e) {
     // print('Error incrementing like count: $e');
    }
  }

  Future<void> _incrementConnectCount(custom_user.User user) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        int newConnectCount =
            (snapshot.data() as Map<String, dynamic>)['connected'] + 1;
        transaction.update(userRef, {'connected': newConnectCount});
      });
    } catch (e) {
      //print('Error incrementing connect count: $e');
    }
  }

  Future<void> _incrementHeartCount(custom_user.User user) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        int newHeartCount =
            (snapshot.data() as Map<String, dynamic>)['hearts'] + 1;
        transaction.update(userRef, {'hearts': newHeartCount});
      });
    } catch (e) {
     // print('Error incrementing heart count: $e');
    }
  }

  Future<void> _sendNotification(custom_user.User recipient, String title,
      String body, String senderUsername, String? senderPhotoUrl) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': recipient.uid,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'senderUsername': recipient.username,
        'senderPhotoUrl': recipient.photoUrl,
        // Ensure sender's photoUrl is saved
      });
    } catch (e) {
     // print('Error sending notification: $e');
    }
  }
}
