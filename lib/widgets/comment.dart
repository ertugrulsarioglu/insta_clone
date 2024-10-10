import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/firebase_service/firestore.dart';
import '../util/image_cached.dart';
import 'shimmer.dart';

class Comment extends StatefulWidget {
  final String type;
  final String postId;
  final Function(int) updateCommentCount;

  const Comment({
    super.key,
    required this.type,
    required this.postId,
    required this.updateCommentCount,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _comments = [];
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    _firestore
        .collection(widget.type)
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) {
      setState(() {
        _comments = snapshot.docs;
      });
      _updateCommentCount();
    });
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _isAddingComment = true;
      });
      FirebaseFirestor()
          .Comments(
        comment: _commentController.text,
        type: widget.type,
        postId: widget.postId,
      )
          .then((_) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        _loadComments();
        setState(() {
          _isAddingComment = false;
        });
      });
    }
  }

  void _deleteComment(String commentId) {
    setState(() {
      _comments.removeWhere((comment) => comment.id == commentId);
      _updateCommentCount();
    });
    FirebaseFirestore.instance
        .collection(widget.type)
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .delete()
        .then((_) {})
        .catchError((error) {
      if (kDebugMode) {
        print("An error occurred while deleting the comment: $error");
      }
    });
  }

  void _updateCommentCount() {
    int newCount = _comments.length;
    widget.updateCommentCount(newCount);
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
            _comments.isEmpty && !_isAddingComment
                ? const Center(
                    child: Text(
                    'No comment yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ))
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: ListView.builder(
                      itemCount: _comments.length + (_isAddingComment ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isAddingComment && index == 0) {
                          return _buildShimmerCommentItem;
                        }
                        final commentIndex =
                            _isAddingComment ? index - 1 : index;
                        if (commentIndex >= _comments.length) {
                          return const SizedBox.shrink();
                        }
                        final comment = _comments[commentIndex];
                        final commentData =
                            comment.data() as Map<String, dynamic>?;
                        if (commentData == null) {
                          return const SizedBox.shrink();
                        }
                        return Dismissible(
                          key: Key(comment.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteComment(comment.id);
                          },
                          child: commentItem(commentData),
                        );
                      },
                    ),
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
                      height: MediaQuery.of(context).size.height * 0.052,
                      width: MediaQuery.of(context).size.width * 0.7,
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
                      onTap: () {
                        _addComment();
                        _commentController.clear();
                      },
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

  Widget get _buildShimmerCommentItem {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoading(
              width: 35,
              height: 35,
              shapeBorder: CircleBorder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(
                    width: 100,
                    height: 14,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoading(
                    width: double.infinity,
                    height: 14,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ],
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
