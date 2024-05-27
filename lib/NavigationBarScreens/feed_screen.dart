import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:login_form_one/NavigationBarScreens/notifications_screen.dart';
import 'profile_screen.dart';
import '../widget/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, double> postHeightFactors = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 1, vsync: this); // Only one tab in this case
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts() async {
    // Implement logic to refresh posts
    // For example, you can fetch new posts from the database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 23,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            );
          },
        ),
        title: const Text(
          "connect",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon:
            const Icon(Icons.notifications, color: Colors.white, size: 23),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(),
                ),
              );

              // Add your notification handling logic here
            },
          ),
          const ToggleButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const Divider(
                color: Colors.black,
                height: 3,
                thickness: 5,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var random = math.Random();
                          return MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 5,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var snap = snapshot.data!.docs[index].data();
                              String postId = snapshot.data!.docs[index].id;

                              // Generate height factor only once per post
                              if (!postHeightFactors.containsKey(postId)) {
                                postHeightFactors[postId] = random.nextDouble();
                              }

                              snap['postHeightFactor'] =
                              postHeightFactors[postId];

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                        imageUrl: snap['postUrl'],
                                        username: snap['username'],
                                        profImage: snap['profImage'],
                                        description: snap['description'],
                                      ),
                                    ),
                                  );
                                },
                                child:
                                PostCard(snap: snap), // Use PostCard here
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleButton extends StatefulWidget {
  const ToggleButton({Key? key}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isSwitched ? Icons.toggle_on : Icons.toggle_off,
        color: _isSwitched ? Colors.green : Colors.red,
        size: 43,
      ),
      onPressed: () {
        setState(() {
          _isSwitched = !_isSwitched;
        });
        // Add your toggle button handling logic here
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String profImage;
  final String description;

  const DetailPage({
    Key? key,
    required this.imageUrl,
    required this.username,
    required this.profImage,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) =>
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      // Adjust left padding here
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(profImage),
                      ),
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      description,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                // Adjust width and height according to your preference
                height: 40,
                padding: EdgeInsets.all(0),
                // Adjust padding as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(
                      0.5), // Adjust opacity and color as needed
                ),
                child: Center(
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}
