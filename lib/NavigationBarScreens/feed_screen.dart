import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/post_card.dart';
import 'profile_screen.dart'; // Import the ProfileScreen

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid)),
            );
          },
        ),
        title: const Text(
          "connect",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 21),
            onPressed: () {
              // Add your notification handling logic here
            },
          ),
          const ToggleButton(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            const Divider(
              color: Colors.black45,
              height: 3,
              thickness: 5,
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('posts').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) => PostCard(
                      snap: snapshot.data!.docs[index].data(),
                    ),
                  );
                },
              ),
            ),
          ],
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
        size: 42,
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
