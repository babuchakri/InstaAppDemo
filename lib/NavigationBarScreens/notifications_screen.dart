import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyNotification {
  final String id;
  final String title;
  final String body;
  final String? photoUrl; // Make photoUrl nullable
  final DateTime dateTime;
  final String senderUsername; // Add senderUsername
  final String senderPhotoUrl; // Add senderPhotoUrl
  bool isRead;

  MyNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.photoUrl,
    required this.dateTime,
    required this.senderUsername,
    required this.senderPhotoUrl,
    this.isRead = false,
  });

  factory MyNotification.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MyNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      senderUsername: data['senderUsername'] ?? '', // Null check for senderUsername
      senderPhotoUrl: data['senderPhotoUrl'] ?? '', // Null check for senderPhotoUrl
      dateTime: (data['timestamp'] as Timestamp).toDate(),
      isRead: data.containsKey('isRead') ? data['isRead'] : false,
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Stream<List<MyNotification>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _fetchNotifications();
  }

  Stream<List<MyNotification>> _fetchNotifications() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MyNotification.fromDocument(doc))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<List<MyNotification>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching notifications: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          List<MyNotification> notifications = snapshot.data!;
          notifications.sort((a, b) => b.dateTime
              .compareTo(a.dateTime)); // Sort notifications by dateTime in descending order
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              MyNotification notification = notifications[index];
              return ListTile(
                leading: _buildLeadingIcon(notification),
                title: Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notification.body,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDateTime(notification.dateTime),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                tileColor: notification.isRead ? Colors.black : Colors.black,
                onTap: () {
                  setState(() {
                    notification.isRead = true;
                  });
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notification.id)
                      .update({'isRead': true});
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLeadingIcon(MyNotification notification) {
    IconData iconData;
    Color iconColor;

    if (notification.title == 'Liked') {
      iconData = Icons.thumb_up;
      iconColor = Colors.blue;
    } else if (notification.title == 'Love') { // Updated condition for Love
      iconData = Icons.favorite;
      iconColor = Colors.red;
    } else {
      // Default icon if notification type is unknown
      iconData = Icons.people_alt_rounded;
      iconColor = Colors.green;
    }

    return Icon(
      iconData,
      size: 30,
      color: iconColor,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
