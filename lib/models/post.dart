import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final  datePublished;
  final String postUrl;
  final String profImage;

  const Post({
    required this.description,
    required this.postId,
    required this.postUrl,
    required this.username,
    required this.datePublished,
    required this.profImage,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "description": description,
        "postId": postId,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profImage": profImage,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        username: snapshot['username'],
        uid: snapshot['uid'],
        postId: snapshot['postId'],
        description: snapshot['description'],
        datePublished: snapshot['datePublished'],
        postUrl: snapshot['postUrl'],
        profImage: snapshot['profImage']);
  }
}
