import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/post_widget.dart';

class PostScreen extends StatefulWidget {
  final dynamic snapshot;
  const PostScreen(this.snapshot, {super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late dynamic postData;
  bool isEditing = false;
  late TextEditingController captionController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    postData = widget.snapshot;
    captionController = TextEditingController(text: postData['caption']);
    locationController =
        TextEditingController(text: postData['location'] ?? '');
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
          captionController.text = postData['caption'];
          locationController.text = postData['location'] ?? '';
        });
      }
    });
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveChanges() {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postData['postId'])
        .update({
      'caption': captionController.text,
      'location': locationController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated')),
      );
      updatePostData();
      toggleEditing();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Post' : 'Posts'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveChanges,
            ),
        ],
      ),
      body: SafeArea(
        child: PostWidget(
          postData,
          false,
          onLikeUpdated: updatePostData,
          onEditPressed: toggleEditing,
          isEditing: isEditing,
          captionController: captionController,
          locationController: locationController,
          showEditOption: true,
        ),
      ),
    );
  }
}
