import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/firebase_service/firestore.dart';
import '../util/image_cached.dart';
import 'shimmer.dart';

class Comment extends StatefulWidget {
  final String type;
  final String postId;
  const Comment({super.key, required this.type, required this.postId});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      FirebaseFirestor()
          .Comments(
        comment: _commentController.text,
        type: widget.type,
        postId: widget.postId,
      )
          .then((_) {
        setState(() {
          _commentController.clear();
        });
        FocusScope.of(context).unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: Container(
        color: Colors.white,
        height: 200,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: (MediaQuery.of(context).size.width - 100) / 2,
              child: Container(
                width: 100,
                height: 3,
                color: Colors.black,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(widget.type)
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ShimmerLoading());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comment yet.'));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: ListView.builder(
                    itemCount:
                        snapshot.data == null ? 0 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (!snapshot.hasData) {
                        return const Center(child: ShimmerLoading());
                      }
                      return commentItem(snapshot.data!.docs[index].data()
                          as Map<String, dynamic>);
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 45,
                      width: 260,
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _addComment,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentItem(Map<String, dynamic> snapshot) => ListTile(
        leading: ClipOval(
          child: SizedBox(
            height: 35,
            width: 35,
            child: CachedImage(
              snapshot['profileImage'],
            ),
          ),
        ),
        title: Text(
          snapshot['username'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          snapshot['comment'],
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      );
}
