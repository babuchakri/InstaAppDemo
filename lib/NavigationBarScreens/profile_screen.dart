import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';
import 'full_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final String currentUserId;

  const ProfileScreen({super.key, required this.uid, required this.currentUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = false;
  List<DocumentSnapshot<Map<String, dynamic>>> posts = [];
  bool isPostsLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getData();
    getPosts();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var snap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (snap.exists) {
        setState(() {
          userData = snap.data() as Map<String, dynamic>;
        });
      } else {
        setState(() {
          userData = {};
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getPosts() async {
    setState(() {
      isPostsLoading = true;
    });

    try {
      var snap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      setState(() {
        posts = snap.docs;
      });
    } catch (e) {
      print("Error fetching posts: $e");
    } finally {
      setState(() {
        isPostsLoading = false;
      });
    }
  }

  Future<void> refreshData() async {
    await getData();
    await getPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black45,
        elevation: 0,
        leading: widget.currentUserId == widget.uid
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.currentUserId == widget.uid)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                // Handle more options
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(
                            userData['photoUrl'] ?? '',
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['username'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData['bio'] ?? '',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn('connected', userData['connected']),
                        _buildStatColumn('hearts', userData['hearts']),
                        _buildStatColumn('likes', userData['likes']),
                      ],
                    ),
                    const SizedBox(height: 30), // Adjusted to reduce gap

                  ],
                ),
              ),
            ),
            isPostsLoading
                ? const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
                : posts.isEmpty
                ? const SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'No posts available',
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                ),
              ),
            )
                : SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: MasonryGridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 5,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var doc = posts[index];
                    return PostItem(
                      post: doc.data()!,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildStatColumn(String label, int? count) {
    return Column(
      children: [
        Text(
          count?.toString() ?? '0',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostItem({super.key, required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem>
    with AutomaticKeepAliveClientMixin<PostItem> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullPostScreen(post: widget.post),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: CachedNetworkImage(
          imageUrl: widget.post['postUrl'] ?? '',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
