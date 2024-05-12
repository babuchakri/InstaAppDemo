import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.getUser;
    if (currentUser != null) {
      final currentUserId = currentUser.uid;
      print('Current user ID: $currentUserId');
      userProvider.fetchFriends(currentUserId);
    } else {
      print('Current user is null');
    }
  }

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
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white70),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
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
                    child: UserProfile(
                      user: currentUser,
                      isCurrentUser: true,
                    ), // Pass true for the current user
                  ),
                  const SizedBox(height: 20),
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
                List<User>? selectedUsers =
                    userProvider.getSelectedUserProfiles;
                if (selectedUsers != null && selectedUsers.isNotEmpty) {
                  // Filter selected users based on search query
                  List<User> filteredUsers = selectedUsers
                      .where((user) => user.username
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Wrap(
                      spacing: 63.0, // Horizontal spacing between user profiles
                      runSpacing:
                      25.0, // Vertical spacing between user profiles
                      children: [
                        for (int i = 0; i < filteredUsers.length; i += 3)
                          _buildUserRow(filteredUsers.sublist(i, i + 3)),
                      ],
                    ),
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

  Widget _buildUserRow(List<User> users) {
    return Row(
      children: users
          .map(
            (user) => Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: user.uid,
                    currentUserId: '',
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: UserProfile(user: user),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class UserProfile extends StatelessWidget {
  final User user;
  final bool isCurrentUser;

  const UserProfile({
    Key? key,
    required this.user,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.photoUrl),
          radius: 30,
          backgroundColor: isCurrentUser
              ? Colors.grey
              : Colors
              .transparent, // Example: Set background color for the current user
        ),
        const SizedBox(height: 5),
        Text(
          user.username,
          style: TextStyle(
            color: isCurrentUser ? Colors.green : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
