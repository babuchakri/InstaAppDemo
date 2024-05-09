
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
 // bool _isPressed = false; // Define _isPressed variable

  Position? _currentPosition;
  final List<CustomUser.User> _nearbyUsers = [];
  bool _isLoading = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    // Ask for location permission and enable location services when the screen is first loaded
    _checkLocationPermission();
  }

  void _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show dialog to enable
      _showLocationServiceDisabledDialog();
    } else {
      // Location services are enabled, check permission
      _askLocationPermission();
    }
  }

  void _askLocationPermission() async {
    // Show dialog to request location permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Permission denied, handle accordingly
      _showLocationPermissionDeniedDialog();
    } else {
      // Permission granted, start updating location
      _updateLocation();
    }
  }

  void _updateLocation() {
    // Set up continuous location updates
    Geolocator.getPositionStream().listen((Position position) async {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _currentPosition = position;
          if (!_isLoading) {
            _updateNearbyUsers(); // Update nearby users whenever the location changes
          }
        });

        // Update the current user's location in Firestore
        if (_currentPosition != null) {
          double currentLat = _currentPosition!.latitude;
          double currentLong = _currentPosition!.longitude;

          // Update the user's location in Firestore
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
                // Open location settings
                await Geolocator.openLocationSettings();
                // Check location permission after enabling location services
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

      // Get the current user's location
      if (_currentPosition != null) {
        double currentLat = _currentPosition!.latitude;
        double currentLong = _currentPosition!.longitude;

        // Get the current user's ID
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;

        for (var doc in usersSnapshot.docs) {
          CustomUser.User user = CustomUser.User.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          );

          // Check if the user's document has latitude and longitude fields
          Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;

          if (userData != null &&
              userData.containsKey('latitude') &&
              userData.containsKey('longitude')) {
            double userLatitude = userData['latitude'];
            double userLongitude = userData['longitude'];

            // Calculate the distance between the current user and the other user
            double distanceInMeters = Geolocator.distanceBetween(
              currentLat,
              currentLong,
              userLatitude,
              userLongitude,
            );

            // If the distance is within or equal to 20 meters and the user is not the current user, add the user to the nearby users list
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
      // Handle errors
      print('Error fetching nearby users: $e');
      setState(() {
        _isLoading = false;
      });
      if (_nearbyUsers.isEmpty) {
        // Trigger rebuild of widget to show "No nearby users found" message
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: SafeArea(
        // Wrap the body with SafeArea
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _nearbyUsers.isEmpty
            ? const Center(
            child: Text(
              'No nearby users found',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ))
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
            (MediaQuery.of(context).size.width -
                80); // Subtracting avatar radius
        double top = _random.nextDouble() *
            (MediaQuery.of(context).size.height -
                80); // Subtracting avatar radius
        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () {
              _showUserProfileDialog(user);
            },
            child: CircleAvatar(
              radius: 35, // Increase size of circle avatar
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 300, // Adjust the height as needed
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog when tapped outside
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey, width: 0.0),
                    ),
                    child: SingleChildScrollView(
                      // Wrap the Column with SingleChildScrollView
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
                                      onPressed: () {
                                        // Change color to green when pressed
                                        setState(() {
                                          //_isPressed = true;
                                        });

                                        // Store the selected user's profile in UserProvider
                                        Provider.of<UserProvider>(context, listen: false)
                                            .setSelectedUserProfile(user);
                                        Navigator.of(context).pop(); // Close the dialog

                                        // Show a Snackbar indicating that the user has been added to the friends list
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('User added to friends list'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },

                                    ),
                                    const Text('Connect',
                                        style: TextStyle(color: Colors.white)),
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



