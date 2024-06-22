import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login_form_one/NavigationBarScreens/add_post_screen.dart';
import 'package:login_form_one/NavigationBarScreens/connect_screen.dart';
import 'package:login_form_one/NavigationBarScreens/feed_screen.dart';
import '../NavigationBarScreens/FriendsScreen.dart';
import '../NavigationBarScreens/profile_screen.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  int _page = 0;
  late PageController pageController;
  late StreamSubscription<Position>? positionStreamSubscription; // Nullable subscription
  bool isLocationServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    stopLocationService(); // Ensure to stop location updates when disposing the screen
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
    if (page == 0) {
      activateLocationService();
    } else {
      stopLocationService();
    }
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
    if (page == 0) {
      activateLocationService();
    } else {
      stopLocationService();
    }
  }

  void activateLocationService() {
    if (!isLocationServiceEnabled) {
      Geolocator.requestPermission().then((locationPermission) {
        if (locationPermission == LocationPermission.denied) {
        } else if (locationPermission == LocationPermission.deniedForever) {
        } else {
          positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
            setState(() {
              // Handle location updates here
            });
          });
          setState(() {
            isLocationServiceEnabled = true;
          });
        }
      });
    }
  }

  void stopLocationService() {
    if (isLocationServiceEnabled) {
      positionStreamSubscription?.cancel(); // Cancel the subscription to stop listening to location updates
      setState(() {
        isLocationServiceEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const ConnectScreen(),
          const FeedScreen(),
          const AddPostScreen(),
          const FriendsScreen(),
          ProfileScreen(
            uid: FirebaseAuth.instance.currentUser!.uid,
            currentUserId: FirebaseAuth.instance.currentUser!.uid,
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.4,
            color: Colors.grey.shade900,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade900,
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black45,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey[500],
              currentIndex: _page,
              onTap: navigationTapped,
              items: [
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage(
                      _page == 0
                          ? 'lib/images/veera.png'
                          : 'lib/images/globe-network.png',
                    ),
                    size: 23,
                  ),
                  label: 'connect',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage(
                      _page == 1
                          ? 'lib/images/home.png'
                          : 'lib/images/homeoutlined.png',
                    ),
                    size: 23,
                  ),
                  label: 'explore',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage(
                      _page == 2
                          ? 'lib/images/add.png'
                          : 'lib/images/circle.png',
                    ),
                    size: 25,
                  ),
                  label: 'upload',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage(
                      _page == 3
                          ? 'lib/images/user.png'
                          : 'lib/images/people-outlinede.png',
                    ),
                    size: 23,
                  ),
                  label: 'friends',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage(
                      _page == 4
                          ? 'lib/images/profile-user.png'
                          : 'lib/images/useroutlined.png',
                    ),
                    size: 23,
                  ),
                  label: 'profile',
                ),
              ],
              selectedLabelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
