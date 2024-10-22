import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../data/firebase_service/firestore.dart';
import '../model/usermodel.dart';
import '../screen/profile_screen/profile_screen.dart';
import '../util/image_cached.dart';
import 'comment.dart';
import 'like_animation.dart';
import 'shimmer.dart';
import 'sizedbox_spacer.dart';

class ReelsItem extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snapshot;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeleted;
  final bool isEditing;
  final TextEditingController? captionController;
  final bool showEditOption;

  const ReelsItem(
    this.snapshot, {
    this.onEditPressed,
    this.onDeleted,
    this.isEditing = false,
    this.captionController,
    this.showEditOption = false,
    super.key,
  });

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  late VideoPlayerController controller;
  bool play = true;
  bool isInitialized = false;
  bool isAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isFollowing = false;
  int likeCount = 0;
  bool isLiked = false;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
    initializeVideoPlayer();
    checkFollowStatus();
    likeCount = widget.snapshot['like'].length;
    isLiked = widget.snapshot['like']?.contains(user) ?? false;
    commentCount = widget.snapshot['commentCount'] ?? 0;
  }

  Future<void> checkFollowStatus() async {
    Usermodel? currentUser = await FirebaseFirestor().getUser();
    if (mounted) {
      setState(() {
        isFollowing =
            currentUser?.following.contains(widget.snapshot['uid']) ?? false;
      });
    }
  }

  void toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
    FirebaseFirestor().follow(uid: widget.snapshot['uid']);
  }

  Future<void> initializeVideoPlayer() async {
    final videoUri = Uri.parse(widget.snapshot['reelsVideo']);
    controller = VideoPlayerController.networkUrl(videoUri);
    try {
      await controller.initialize();
      setState(() {
        controller.setLooping(true);
        controller.setVolume(1);
        controller.play();
        isInitialized = true;
      });
    } catch (error) {
      print('An error occurred while loading the video: $error');
    }
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      isAnimating = isLiked;
    });

    FirebaseFirestor().like(
      like: widget.snapshot['like'],
      type: 'reels',
      uid: user,
      postId: widget.snapshot['postId'],
    );
  }

  void updateCommentCount(int newCount) {
    setState(() {
      commentCount = newCount;
    });

    FirebaseFirestore.instance
        .collection('reels')
        .doc(widget.snapshot['postId'])
        .update({'commentCount': newCount});
  }

  void _deleteReels() {
    if (widget.snapshot['uid'] != user) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You don't have permission to delete these reels")),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('reels')
        .doc(widget.snapshot['postId'])
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reels deleted')),
      );
      widget.onDeleted?.call();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    });
  }

  void _reportReels() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reels reported')),
    );
  }

  @override
  void dispose() {
    controller.setLooping(false);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onDoubleTap: () {
            if (!isLiked) {
              toggleLike();
            }
            setState(() {
              isAnimating = true;
            });
          },
          onTap: () {
            setState(() {
              play = !play;
            });
            play ? controller.play() : controller.pause();
          },
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: isInitialized
                ? VideoPlayer(controller)
                : const ShimmerLoading(),
          ),
        ),
        if (!play)
          const Center(
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 35,
              child: Icon(
                Icons.play_arrow,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
        Center(
          child: AnimatedOpacity(
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
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.58,
          right: MediaQuery.of(context).size.width * 0.03,
          child: Column(
            children: [
              LikeAnimation(
                isAnimation: isAnimating,
                child: IconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Text(
                likeCount.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.6,
                          minChildSize: 0.2,
                          maxChildSize: 0.75,
                          builder: (_, controller) {
                            return Comment(
                              type: 'reels',
                              postId: widget.snapshot['postId'],
                              updateCommentCount: updateCommentCount,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                child: const Icon(
                  Icons.comment,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Text(
                commentCount.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Icon(
                Icons.send,
                color: Colors.white,
                size: 28,
              ),
              const Text(
                '0',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      bool isCurrentUserOwner = widget.snapshot['uid'] == user;
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
                                  _deleteReels();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                            ListTile(
                              leading: const Icon(Icons.flag),
                              title: const Text('Report'),
                              onTap: () {
                                _reportReels();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.06,
          left: MediaQuery.of(context).size.width * 0.03,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: CachedImage(widget.snapshot['profileImage']),
                    ),
                  ),
                  SizedBoxSpacer.w10,
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(Uid: widget.snapshot['uid']),
                        ),
                      );
                    },
                    child: Text(
                      widget.snapshot['username'],
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (user != widget.snapshot['uid'])
                    GestureDetector(
                      onTap: toggleFollow,
                      child: Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBoxSpacer.h8,
              widget.isEditing
                  ? TextField(
                      controller: widget.captionController,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add caption...',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    )
                  : Text(
                      widget.snapshot['caption'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
