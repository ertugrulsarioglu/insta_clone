import 'package:flutter/material.dart';
import '../widgets/post_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatefulWidget {
  final dynamic snapshot;
  const PostScreen(this.snapshot, {super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late dynamic postData;

  @override
  void initState() {
    super.initState();
    postData = widget.snapshot;
  }

  void updatePostData() {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postData['postId'])
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          postData = doc.data();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PostWidget(
          postData,
          false,
          onLikeUpdated: updatePostData,
        ),
      ),
    );
  }
}
