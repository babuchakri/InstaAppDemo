import 'package:cached_network_image/cached_network_image.dart';
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

        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 37,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(10.0),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display friends
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  List<User>? selectedUsers = userProvider.friends;
                  if (selectedUsers.isNotEmpty) {
                    List<User> filteredUsers = selectedUsers
                        .where((user) => user.username
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                        .toList();

                    return _buildUserGrid(filteredUsers);
                  } else {
                    return const Center(
                      child: Text(
                        'No friends available',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserGrid(List<User> users) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 45,
        mainAxisSpacing: 15,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  uid: users[index].uid,
                  currentUserId: '', // Ensure this is populated correctly
                ),
              ),
            );
          },
          child: UserProfile(user: users[index]),
        );
      },
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
        Container(
          width: 63,
          height: 63,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.grey, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white,
              width: 0.7,
            ),
          ),
          child: ClipOval(
            child: user.photoUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: user.photoUrl,
              fit: BoxFit.cover,
              width: 65,
              height: 65,
            )
                : const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Flexible(
          child: Text(
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrentUser ? Colors.green : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
