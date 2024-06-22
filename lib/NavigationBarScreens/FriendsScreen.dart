import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart'; // Import the ProfileScreen

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.getUser;
      if (currentUser != null) {
        final currentUserId = currentUser.uid;
        userProvider.fetchFriends(currentUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Explicitly control the back button
        backgroundColor: Colors.black,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 58.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF323232),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isCollapsed: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                      padding: const EdgeInsets.only(left: 25),
                      child: UserProfile(
                        user: currentUser,
                        isCurrentUser: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                )
                    : const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
            // Display selected user profiles
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                // Retrieve friends' data from the provider
                List<User>? selectedUsers = userProvider.friends;
                if (selectedUsers.isNotEmpty) {
                  // Filter selected users based on search query
                  List<User> filteredUsers = selectedUsers
                      .where((user) => user.username
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                      .toList();

                  return _buildUserRows(filteredUsers);
                } else {
                  // Handle case where no friends data is available
                  return const Center(
                    child: Text(
                      'No friends available',
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRows(List<User> users) {
    List<Widget> rows = [];
    List<Widget> currentRowUsers = [];

    for (int i = 0; i < users.length; i++) {
      currentRowUsers.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: users[i].uid,
                    currentUserId: '', // Ensure this is populated correctly
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: UserProfile(user: users[i]),
            ),
          ),
        ),
      );

      // If the current row is full or it's the last user, add the row to the list of rows
      if (currentRowUsers.length == 3 || i == users.length - 1) {
        // If less than 3 users in the current row, add empty Expanded widgets
        while (currentRowUsers.length < 3) {
          currentRowUsers.add(Expanded(child: Container()));
        }

        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currentRowUsers,
            ),
          ),
        );
        currentRowUsers = []; // Clear the current row users list for the next row
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class UserProfile extends StatelessWidget {
  final User user;
  final bool isCurrentUser;

  const UserProfile({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 65, // Adjust the size as needed
          height: 65, // Adjust the size as needed
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey, // Placeholder color
          ),
          child: user.photoUrl.isNotEmpty
              ? CircleAvatar(
            backgroundImage: NetworkImage(user.photoUrl),
            radius: 30,
            backgroundColor:
            isCurrentUser ? Colors.grey : Colors.transparent,
          )
              : const Icon(
            Icons.person,
            size: 40, // Adjust size as needed
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.username,
          style: TextStyle(
            color: isCurrentUser ? Colors.green : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
//updated code version