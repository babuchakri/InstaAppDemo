import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login_form_one/NavigationBarScreens/add_post_screen.dart';
import 'package:login_form_one/NavigationBarScreens/chat_screen.dart';
import 'package:login_form_one/NavigationBarScreens/connect_screen.dart';
import 'package:login_form_one/NavigationBarScreens/feed_screen.dart';
import '../NavigationBarScreens/FriendsScreen.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({Key? key}) : super(key: key);

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
          print('Location permission denied.');
        } else if (locationPermission == LocationPermission.deniedForever) {
          print('Location permission permanently denied.');
        } else {
          positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
            setState(() {
              // Handle location updates here
            });
          });
          setState(() {
            isLocationServiceEnabled = true;
          });
          print('Location service activated.');
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
      print('Location service stopped.');
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
        children: const [
          ConnectScreen(),
          FeedScreen(),
          AddPostScreen(),
          FriendsScreen(),
          ChatScreen(currentUserId: ''),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.0,
            color: Colors.grey,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade900,
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey[500],
              currentIndex: _page,
              onTap: navigationTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_history, size: 28),
                  label: 'connect',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore, size: 28),
                  label: 'explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle, size: 28),
                  label: 'upload',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded, size: 28),
                  label: 'friends',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble, size: 28),
                  label: 'chat',
                ),
              ],
              selectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
