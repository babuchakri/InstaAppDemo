import 'package:flutter/cupertino.dart';
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
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
            ),
          ],
        ),
        child: CupertinoTabBar(
          backgroundColor: Colors.black,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4), // Add padding to move the icon down
                child: Icon(Icons.location_history, size: 25, color: _page == 0 ? Colors.white : Colors.grey),
              ),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4), // Add padding to move the icon down
                child: Icon(Icons.home, size: 25, color: _page == 1 ? Colors.white : Colors.grey),
              ),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4), // Add padding to move the icon down
                child: Icon(Icons.photo_camera, size: 25, color: _page == 2 ? Colors.white : Colors.grey),
              ),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4), // Add padding to move the icon down
                child: Icon(Icons.people, size: 25, color: _page == 3 ? Colors.white : Colors.grey),
              ),
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 4), // Add padding to move the icon down
                child: Icon(Icons.message, size: 25, color: _page == 4 ? Colors.white : Colors.grey),
              ),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }
}
