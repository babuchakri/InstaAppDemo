import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';
import 'full_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final String currentUserId;

  const ProfileScreen(
      {Key? key, required this.uid, required this.currentUserId})
      : super(key: key);

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
      var snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.currentUserId == widget.uid
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
        title: Text(
          userData['username'] ?? '',
          style: GoogleFonts.nunito(
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
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showSocialMediaDialog(userData);
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
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel:
                                        MaterialLocalizations.of(context)
                                            .modalBarrierDismissLabel,
                                    barrierColor: Colors.black54,
                                    transitionDuration:
                                        const Duration(milliseconds: 200),
                                    pageBuilder: (BuildContext context,
                                        Animation animation,
                                        Animation secondaryAnimation) {
                                      return BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10.0, sigmaY: 10.0),
                                        child: Center(
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  userData['photoUrl'] ?? '',
                                              width: 300,
                                              height: 300,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error,
                                                          size: 100,
                                                          color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: CachedNetworkImageProvider(
                                    userData['photoUrl'] ?? '',
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData['username'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Robotomono",
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Text(
                                    userData['bio'] ?? '',
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.ubuntu(
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
                              _buildStatColumn(
                                  'connected', userData['connected']),
                              _buildStatColumn('hearts', userData['hearts']),
                              _buildStatColumn('likes', userData['likes']),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Recent Posts -',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isPostsLoading)
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (posts.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No posts available',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 5,
                          childAspectRatio: 1.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var doc = posts[index];
                            return PostItem(
                              post: doc.data()!,
                            );
                          },
                          childCount: posts.length,
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
        const SizedBox(height: 0),
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

  void _showSocialMediaDialog(Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: Colors.white, width: 0.3),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Social Media IDs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildSocialLinkRow('Snapchat', userData['snapchatId'],
                    userData['snapchatToggle']),
                Divider(color: Colors.grey[800]),
                _buildSocialLinkRow('Instagram', userData['instagramId'],
                    userData['instagramToggle']),
                Divider(color: Colors.grey[800]),
                _buildSocialLinkRow('Facebook', userData['facebookId'],
                    userData['facebookToggle']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLinkRow(String label, String? id, bool? show) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: show ?? false ? () => launchUrl(Uri.parse(id!)) : null,
              child: Text(
                id ?? 'Not available',
                style: TextStyle(
                  color: show ?? false ? Colors.blue : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: show ?? false
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostItem({Key? key, required this.post}) : super(key: key);

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
//updated version here
