import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../widget/post_card.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin {
  final List<DocumentSnapshot<Map<String, dynamic>>> _cachedPosts = [];
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

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
        .orderBy('datePublished', descending: true)
        .limit(10);

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _loadPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
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
        ),
        title: const Text(
          "connect",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 23),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(),
                ),
              );
            },
          ),
          const ToggleButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _cachedPosts.isEmpty
            ? _buildShimmerList()
            : ListView.builder(
          controller: _scrollController,
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
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 10,
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
        size: 44,
      ),
      onPressed: () {
        setState(() {
          _isSwitched = !_isSwitched;
        });
      },
    );
  }
}
