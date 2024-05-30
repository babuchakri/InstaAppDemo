import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_form_one/SettingsScreen/settings_screen.dart';
import 'feed_screen.dart';
import 'individual_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final String currentUserId;

  const ProfileScreen({Key? key, required this.uid, required this.currentUserId})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};
  bool isLoading = false;

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
                return Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (var doc in snapshot.data!.docs)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                imageUrl: doc['postUrl'],
                                username: doc['username'],
                                profImage: doc['profImage'],
                                description: doc['description'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width -
                              50) /
                              3,
                          height: (MediaQuery.of(context).size.width -
                              50) /
                              3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: NetworkImage(doc['postUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
