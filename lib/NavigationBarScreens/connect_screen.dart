import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as CustomUser;
import 'dart:math';
import '../providers/user_provider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Position? _currentPosition;
  final List<CustomUser.User> _nearbyUsers = [];
  bool _isLoading = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
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
    Geolocator.getPositionStream().listen((Position position) async {
      if (mounted) {
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
          CustomUser.User user = CustomUser.User.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );

          Map<String, dynamic>? userData =
          doc.data() as Map<String, dynamic>?;

          if (userData != null &&
              userData.containsKey('latitude') &&
              userData.containsKey('longitude')) {
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

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching nearby users: $e');
      setState(() {
        _isLoading = false;
      });
      if (_nearbyUsers.isEmpty) {
        setState(() {});
      }
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
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
            : _buildNearbyUsersList(),
      ),
    );
  }

  Widget _buildNearbyUsersList() {
    double bottomNavBarHeight = kBottomNavigationBarHeight;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: _nearbyUsers
          .where((user) =>
          _isWithinRange(user.latitude, user.longitude, 20))
          .map((user) {
        double left = _random.nextDouble() *
            (MediaQuery.of(context).size.width - 80);
        double top = _random.nextDouble() *
            (screenHeight -
                MediaQuery.of(context).padding.bottom -
                bottomNavBarHeight -
                90); // Adjusted height to avoid bottom navigation bar
        return Positioned(
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
                  width: 0.7, // Adjust border width as needed
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isWithinRange(double lat, double long, double range) {
    if (_currentPosition == null) return false;

    double currentLat = _currentPosition!.latitude;
    double currentLong = _currentPosition!.longitude;

    double distanceInMeters = Geolocator.distanceBetween(
      currentLat,
      currentLong,
      lat,
      long,
    );

    return distanceInMeters <= range;
  }

  void _showUserProfileDialog(CustomUser.User user) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
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

    bool liked = false;
    bool favorited = false;
    bool connected = false;

    // Check if user.likes and user.hearts are integers or lists
    // Convert integer values to lists
    List<int> likesList = [user.likes];
    List<int> heartsList = [user.hearts];

    liked = likesList.contains(FirebaseAuth.instance.currentUser!.uid);
    favorited = heartsList.contains(FirebaseAuth.instance.currentUser!.uid);

    // Disable actions if already performed or within 24-hour window
    bool likeDisabled = liked; // Disable if already liked
    bool favoriteDisabled = favorited; // Disable if already favorited
    bool connectDisabled = userAlreadyAdded; // Disable if already connected

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              height: 300,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey, width: 0.0),
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(user.photoUrl),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.people_alt_rounded,
                                        color: connected
                                            ? Colors.green
                                            : (userAlreadyAdded
                                            ? Colors.green
                                            : Colors.white),
                                      ),
                                      onPressed: connectDisabled
                                          ? null
                                          : () async {
                                        String currentUserId =
                                            FirebaseAuth.instance
                                                .currentUser!
                                                .uid;
                                        DocumentReference friendRef =
                                        FirebaseFirestore.instance
                                            .collection('friends')
                                            .doc(currentUserId)
                                            .collection('user_friends')
                                            .doc(user.uid);

                                        try {
                                          await friendRef.set({
                                            'username': user.username,
                                            'uid': user.uid,
                                            'email': user.email,
                                          });
                                          setState(() {
                                            connected = true;
                                          });
                                          Provider.of<UserProvider>(
                                            context,
                                            listen: false,
                                          ).setSelectedUserProfile(user);
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'User added to friends list'),
                                              duration:
                                              Duration(seconds: 2),
                                            ),
                                          );
                                          // Increment connect count when user is added as a friend
                                          await _incrementConnectCount(
                                              user);
                                        } catch (e) {
                                          print(
                                              'Error adding friend: $e');
                                        }
                                      },
                                    ),
                                    Text(
                                      userAlreadyAdded
                                          ? 'Connected'
                                          : 'Connect',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.person_add_alt_1,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Handle request action
                                      },
                                    ),
                                    Text(
                                      'Request',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color:
                                        favorited ? Colors.red : Colors.white,
                                      ),
                                      onPressed: favoriteDisabled
                                          ? null
                                          : () async {
                                        await _incrementHeartCount(user);
                                        setState(() {
                                          favorited = true;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Favorite',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: liked ? Colors.blue : Colors.white,
                                      ),
                                      onPressed: likeDisabled
                                          ? null
                                          : () async {
                                        await _incrementLikeCount(user);
                                        setState(() {
                                          liked = true;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Like',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _incrementLikeCount(CustomUser.User user) async {
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
      print('Error incrementing like count: $e');
    }
  }

  Future<void> _incrementConnectCount(CustomUser.User user) async {
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
      print('Error incrementing connect count: $e');
    }
  }

  Future<void> _incrementHeartCount(CustomUser.User user) async {
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
      print('Error incrementing heart count: $e');
    }
  }
}
