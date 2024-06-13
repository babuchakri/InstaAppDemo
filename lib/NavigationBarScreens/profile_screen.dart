import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';
import 'individual_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final String currentUserId;

  const ProfileScreen({Key? key, required this.uid, required this.currentUserId})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true; // Required for keeping the state alive

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var snap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      userData = snap.data() as Map<String, dynamic>;
    } catch (e) {
      // Handle error
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> refreshData() async {
    await getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure to call super.build(context) to maintain state

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
                await refreshData(); // Refresh data when returning from settings
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IndividualChatScreen(
                      currentUserId: widget.currentUserId,
                      otherUserId: widget.uid,
                    ),
                  ),
                );
              },
            ),
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(userData['photoUrl'] ?? ''),
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
                    const SizedBox(height: 3),
                    Text(
                      userData['bio'] ?? '',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      userData['connected'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Connected',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      userData['hearts'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Hearts',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      userData['likes'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Likes',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Recent Posts',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo: widget.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    var doc = docs[index];
                    return PostItem(
                      postUrl: doc['postUrl'],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final String postUrl;

  const PostItem({Key? key, required this.postUrl}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem>
    with AutomaticKeepAliveClientMixin<PostItem> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure to call super.build(context) to maintain state

    return GestureDetector(
      onTap: () {
        // Handle onTap event
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
            image: NetworkImage(widget.postUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
