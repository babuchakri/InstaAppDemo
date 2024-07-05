import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../widget/post_card.dart';
import 'notifications_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  final List<DocumentSnapshot<Map<String, dynamic>>> _cachedPosts = [];
  bool _isLoadingMore = false;
  late ScrollController _scrollController;
  bool _isCrushOfTheDayExpanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadInitialPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
    _loadPosts(isRefresh: true);
  }

  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('datePublished', descending: true);

    if (!isRefresh && _cachedPosts.isNotEmpty) {
      query = query.startAfterDocument(_cachedPosts.last);
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    setState(() {
      if (isRefresh) {
        _cachedPosts.clear();
      }
      _cachedPosts.addAll(snapshot.docs);
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshPosts() async {
    await _loadPosts(isRefresh: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _loadPosts();
      }
    }
  }

  Widget _buildCrushOfTheDay() {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _fetchCrushOfTheDay(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container();
        }

        var crushData = snapshot.data!.data()!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
              color: Colors.grey[900],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "Crush of the Day",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _showProfileDialog(crushData['photoUrl']);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            CachedNetworkImageProvider(crushData['photoUrl']),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Today's most loved profile's",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 13.0, sigmaY: 13.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width *
                    0.8, // Adjust height to maintain aspect ratio
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 0),
                  // Adjust border width as needed
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imageUrl),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Disable the automatic back button
        elevation: 0,
        backgroundColor: Colors.black45,
        title: const Text(
          "connect_me",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
        actions: [
          IconButton(
            icon: const ImageIcon(
              AssetImage('lib/images/babu.png'),
              size: 21,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isCrushOfTheDayExpanded ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: 25,
            ),
            onPressed: () {
              setState(() {
                _isCrushOfTheDayExpanded = !_isCrushOfTheDayExpanded;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: SingleChildScrollView(
          controller: _scrollController, // Attach the scroll controller
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isCrushOfTheDayExpanded) ...[
                const SizedBox(height: 20),
                _buildCrushOfTheDay(),
                Divider(color: Colors.grey.shade900, height: 0),
                const SizedBox(height: 10),
              ],
              _cachedPosts.isEmpty ? _buildShimmerList() : _buildPostList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cachedPosts.length,
      itemBuilder: (context, index) {
        var snap = _cachedPosts[index].data()!;
        return Column(
          children: [
            PostCard(snap: snap),
            if (index < _cachedPosts.length - 1)
              Divider(color: Colors.grey.shade900),
          ],
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10, // You can adjust this number for the shimmer effect
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[800],
            ),
            title: Container(
              width: double.infinity,
              height: 20,
              color: Colors.grey[800],
            ),
            subtitle: Container(
              width: double.infinity,
              height: 20,
              color: Colors.grey[800],
            ),
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchCrushOfTheDay() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .orderBy('hearts', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      throw Exception("No crush of the day found");
    }
  }
}
