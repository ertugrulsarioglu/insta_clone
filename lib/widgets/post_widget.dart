import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/firebase_service/firestore.dart';
import '../screen/profile_screen.dart';
import '../util/image_cached.dart';
import 'comment.dart';
import 'like_animation.dart';
import 'sizedbox_spacer.dart';

class PostWidget extends StatefulWidget {
  final dynamic snapshot;
  final bool hasAppBar;
  final VoidCallback? onLikeUpdated;
  final VoidCallback? onEditPressed;
  final bool isEditing;
  final TextEditingController? captionController;
  final TextEditingController? locationController;
  final bool showEditOption;

  const PostWidget(
    this.snapshot,
    this.hasAppBar, {
    this.onLikeUpdated,
    this.onEditPressed,
    this.isEditing = false,
    this.captionController,
    this.locationController,
    this.showEditOption = false,
    super.key,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int likeCount = 0;
  bool isLiked = false;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
    likeCount = widget.snapshot['like'].length;
    isLiked = widget.snapshot['like']?.contains(user) ?? false;
    commentCount = widget.snapshot['commentCount'] ?? 0;
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      isAnimating = isLiked;
    });

    FirebaseFirestor()
        .like(
      like: widget.snapshot['like'],
      type: 'posts',
      uid: user,
      postId: widget.snapshot['postId'],
    )
        .then((_) {
      if (widget.onLikeUpdated != null) {
        widget.onLikeUpdated!();
      }
    });
  }

  void updateCommentCount(int newCount) {
    setState(() {
      commentCount = newCount;
    });

    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snapshot['postId'])
        .update({'commentCount': newCount});
  }

  void _deletePost() {
    if (widget.snapshot['uid'] != user) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You do not have permission to delete this post')),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snapshot['postId'])
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    });
  }

  void _reportPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post reported')),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasLocation = widget.snapshot['location'] != null &&
        widget.snapshot['location'].isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(top: widget.hasAppBar ? 0.0 : 10),
      child: Column(
        children: [
          Container(
            height: 54,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: CachedImage(widget.snapshot['profileImage']),
                    ),
                  ),
                  SizedBoxSpacer.w10,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: hasLocation || widget.isEditing
                          ? MainAxisAlignment.spaceEvenly
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.isEditing
                            ? Text(
                                widget.snapshot['username'],
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              )
                            : GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                          Uid: widget.snapshot['uid']),
                                    ),
                                  );
                                },
                                child: Text(
                                  widget.snapshot['username'],
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                        if (widget.isEditing)
                          SizedBox(
                            height: 20,
                            child: TextField(
                              controller: widget.locationController,
                              decoration: const InputDecoration(
                                hintText: 'Add location',
                                hintStyle: TextStyle(fontSize: 11),
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 4),
                              ),
                              style: const TextStyle(fontSize: 11),
                            ),
                          )
                        else if (hasLocation)
                          Text(
                            widget.snapshot['location'],
                            style: const TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          bool isCurrentUserOwner =
                              widget.snapshot['uid'] == user;
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (isCurrentUserOwner &&
                                    widget.showEditOption) ...[
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit'),
                                    onTap: () {
                                      widget.onEditPressed?.call();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                                if (isCurrentUserOwner) ...[
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Delete'),
                                    onTap: () {
                                      _deletePost();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                                ListTile(
                                  leading: const Icon(Icons.flag),
                                  title: const Text('Report post'),
                                  onTap: () {
                                    _reportPost();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              if (!isLiked) {
                toggleLike();
              }
              setState(() {
                isAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: CachedImage(
                      widget.snapshot['postImage'],
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isAnimating ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: LikeAnimation(
                    isAnimation: isAnimating,
                    duration: const Duration(milliseconds: 400),
                    iconLike: false,
                    end: () {
                      setState(() {
                        isAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBoxSpacer.w2,
                    LikeAnimation(
                      isAnimation: isAnimating,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: toggleLike,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    Text(
                      likeCount.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBoxSpacer.w17,
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: DraggableScrollableSheet(
                                initialChildSize: 0.6,
                                minChildSize: 0.2,
                                maxChildSize: 0.75,
                                builder: (_, controller) {
                                  return Comment(
                                    type: 'posts',
                                    postId: widget.snapshot['postId'],
                                    updateCommentCount: updateCommentCount,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: Image.asset('images/comment.webp', height: 28),
                    ),
                    SizedBoxSpacer.w2,
                    Text(
                      commentCount.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBoxSpacer.w15,
                    Image.asset('images/send.jpg', height: 28),
                    const SizedBox(width: 2),
                    const Text(
                      '356',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer()
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                  child: Row(
                    children: [
                      Text(
                        widget.snapshot['username'] + ' ',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: widget.isEditing
                            ? TextField(
                                controller: widget.captionController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 13),
                              )
                            : Text(
                                widget.snapshot['caption'],
                                style: const TextStyle(fontSize: 13),
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, top: 20, bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        formatDate(widget.snapshot['time'].toDate(),
                            [yyyy, '-', mm, '-', dd]),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//duzenleme mevzularina bir daha bak. bunun haricinde profilden reels ekranini ayarla
