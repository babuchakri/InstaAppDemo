import 'package:flutter/material.dart';
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
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    // Animating Page
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children:  const [
          ConnectScreen(),
          FeedScreen(),
          AddPostScreen(),
          FriendsScreen(),
          ChatScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thick line above the bottom navigation bar
          Container(
            height: 0.20, // Adjust the height of the line as needed
            color: Colors.grey,
          ),
          BottomNavigationBar(
            backgroundColor: Colors.black, // Set bottom navigation bar background color to black
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white, // Set selected item color
            unselectedItemColor: Colors.grey[500], // Set unselected item color
            currentIndex: _page,
            onTap: navigationTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.location_history, size: 26),
                label: 'connect',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore, size: 26),
                label: 'explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle, size: 26),
                label: 'upload',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group, size: 26),
                label: 'friends',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble, size: 26),
                label: 'chat',
              ),
            ],
            selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), // Adjust the selected label font size and weight
            unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal), // Adjust the unselected label font size and weight
          ),
        ],
      ),
    );
  }
}
