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

          Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;

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
    return Stack(
      children: _nearbyUsers
          .where((user) => _isWithinRange(user.latitude, user.longitude, 20))
          .map((user) {
        double left = _random.nextDouble() *
            (MediaQuery.of(context).size.width - 80);
        double top = _random.nextDouble() *
            (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.bottom -
                80);
        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () {
              _showUserProfileDialog(user);
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(user.photoUrl),
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

  void _showUserProfileDialog(CustomUser.User user) {
    bool userAlreadyAdded = Provider.of<UserProvider>(context, listen: false)
        .getSelectedUserProfiles
        .any((selectedUser) => selectedUser.uid == user.uid);

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
                                      icon: const Icon(
                                        Icons.people_alt_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: userAlreadyAdded
                                          ? null
                                          : () async {
                                        String currentUserId =
                                            FirebaseAuth.instance
                                                .currentUser!.uid;
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
                                          setState(() {});
                                          Provider.of<UserProvider>(
                                              context,
                                              listen: false)
                                              .setSelectedUserProfile(
                                              user);
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
                                        } catch (e) {
                                          print(
                                              'Error adding friend: $e');
                                        }
                                      },
                                    ),
                                    Text(
                                      userAlreadyAdded
                                          ? 'connected'
                                          : 'Connect',
                                      style: TextStyle(
                                        color: userAlreadyAdded
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.person_add_alt_1,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Handle request action
                                      },
                                    ),
                                    const Text('Request',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Handle heart action
                                      },
                                    ),
                                    const Text('Favorite',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.thumb_up,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Handle like action
                                      },
                                    ),
                                    const Text('Like',
                                        style: TextStyle(color: Colors.white)),
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
}
