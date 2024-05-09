import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white70),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Display current user profile
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              User? currentUser = userProvider.getUser;
              return currentUser != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.photoUrl),
                      radius: 32,
                    ),
                  ),
                  const SizedBox(height: 5),

                ],
              )
                  : const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 10),
          // Display selected user profiles
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                User? selectedUser = userProvider.getSelectedUserProfile;
                List<User>? selectedUsers =
                selectedUser != null ? [selectedUser] : null;
                if (selectedUsers != null && selectedUsers.isNotEmpty) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: (selectedUsers.length / 3).ceil(),
                    itemBuilder: (context, index) {
                      return Row(
                        children: selectedUsers
                            .skip(index * 3)
                            .take(3)
                            .map(
                              (user) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(user.photoUrl),
                                    radius: 32,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    user.username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}