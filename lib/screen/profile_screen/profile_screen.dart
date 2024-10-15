// ignore_for_file: must_be_immutable, use_build_context_synchronously, invalid_use_of_protected_member, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../data/firebase_service/firestore.dart';
import '../../model/usermodel.dart';
import '../../util/image_cached.dart';
import '../../widgets/shimmer.dart';
import '../../widgets/sizedbox_spacer.dart';
import '../post_screen/post_screen.dart';
import 'profile_edit_widget.dart';
import '../reels_screen.dart';

class ProfileScreen extends StatefulWidget {
  // ignore: non_constant_identifier_names
  String Uid;
  ProfileScreen({super.key, required this.Uid});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int postLength = 0;

  Usermodel? userr;
  bool yours = false;
  List followings = [];
  bool isfollow = false;
  int followerCount = 0;
  bool isLoading = true;
  bool isEditing = false;
  late TextEditingController bioController;
  late TextEditingController usernameController;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    bioController = TextEditingController();
    usernameController = TextEditingController();
  }

  @override
  void dispose() {
    bioController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final user = await FirebaseFirestor().getUser(uidd: widget.Uid);
    final currentUserSnap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();

    setState(() {
      userr = user;
      followerCount = user?.followers.length ?? 0;
      yours = _auth.currentUser!.uid == widget.Uid;
      isfollow = (currentUserSnap.data() as dynamic)['following']
              ?.contains(widget.Uid) ??
          false;
      isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    setState(() {
      isfollow = !isfollow;
      followerCount += isfollow ? 1 : -1;
    });

    await FirebaseFirestor().follow(uid: widget.Uid);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: isLoading ? _customShimmerAppBar : _customAppbar,
        body: SafeArea(
          child: isLoading
              ? _buildShimmerContent
              : Column(
                  children: [
                    head(userr!),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPostsGrid(),
                          _buildReelsGrid(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  AppBar get _customShimmerAppBar {
    return AppBar(
      backgroundColor: Colors.white,
      title: ShimmerLoading(
        child: Container(
          width: 200,
          height: 20,
          color: Colors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: ShimmerLoading(
            child: Container(
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  AppBar get _customAppbar {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: isEditing
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _cancelEditing,
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _saveProfileChanges,
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _signOut,
                ),
        )
      ],
      backgroundColor: Colors.white,
      title: Text(
        userr!.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    setState(() {
      isLoading = true;
    });

    String? newProfileImageUrl;
    if (_newProfileImage != null) {
      try {
        newProfileImageUrl = await FirebaseFirestor()
            .uploadProfileImage(widget.Uid, _newProfileImage!);
      } catch (e) {
        print('Error occurred while uploading profile picture: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'An error occurred while uploading the profile picture.')),
        );
      }
    }

    try {
      bool success = await FirebaseFirestor().updateUserProfile(
        uid: widget.Uid,
        bio: bioController.text,
        username: usernameController.text,
        profileImageUrl: newProfileImageUrl,
      );

      if (success) {
        final updatedUser = await FirebaseFirestor().getUser(uidd: widget.Uid);

        setState(() {
          userr = updatedUser;
          isEditing = false;
          _newProfileImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      } else {
        throw Exception('Profile could not be updated.');
      }
    } catch (e) {
      print('Error occurred while updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while updating the profile.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _newProfileImage = null;
      bioController.text = userr!.bio;
      usernameController.text = userr!.username;
    });
  }

  Widget head(Usermodel user) => Container(
        padding: const EdgeInsets.only(bottom: 5),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileRow(user),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _userNameAndBioColumn(user),
            ),
            SizedBoxSpacer.h20,
            if (!isEditing)
              yoursStateTrueProfileCenterBarVisibility(yours: yours),
            _yoursStateFalseProfileCenterBarVisibility,
            __yoursStateFalseIsfollowStateTrueProfileCenterBarVisibility,
            SizedBoxSpacer.h10,
            _profileTabBar,
            SizedBoxSpacer.h5,
          ],
        ),
      );

  Widget get _profileTabBar {
    return const SizedBox(
      width: double.infinity,
      height: 30,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.grey,
        labelColor: Colors.black,
        indicatorColor: Colors.black,
        tabs: [
          Icon(Icons.grid_on),
          Icon(Icons.video_collection),
        ],
      ),
    );
  }

  Widget _profileRow(Usermodel user) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          child: GestureDetector(
            onTap: isEditing ? _changeProfilePicture : null,
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _newProfileImage != null
                        ? Image.file(_newProfileImage!, fit: BoxFit.cover)
                        : CachedImage(user.profile),
                  ),
                ),
                if (isEditing)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 15,
                      child: Icon(Icons.edit, size: 15, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _postsFollowersFollowingColumn(user),
      ],
    );
  }

  Widget _postsFollowersFollowingColumn(Usermodel user) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 25),
            Column(
              children: [
                Text(
                  user.posts.length.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBoxSpacer.h4,
                const Text(
                  'Posts',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            SizedBoxSpacer.w35,
            Column(
              children: [
                Text(
                  followerCount.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBoxSpacer.h4,
                const Text(
                  'Followers',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(width: 35),
            Column(
              children: [
                Text(
                  user.following.length.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Following',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _userNameAndBioColumn(Usermodel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isEditing
            ? TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                  border: InputBorder.none,
                ),
                cursorColor: Colors.black54,
                keyboardType: TextInputType.name,
              )
            : Text(
                user.username,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
        const SizedBox(height: 5),
        isEditing
            ? TextFormField(
                style: const TextStyle(color: Colors.black),
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                  border: InputBorder.none,
                ),
                cursorColor: Colors.black54,
                maxLines: null,
                keyboardType: TextInputType.text,
              )
            : Text(
                user.bio,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
      ],
    );
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newProfileImage = File(image.path);
      });
    }
  }

  Widget get __yoursStateFalseIsfollowStateTrueProfileCenterBarVisibility {
    return Visibility(
      visible: isfollow && !yours,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleFollow,
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text(
                    'Unfollow',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ),
            SizedBoxSpacer.w10,
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 30,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _yoursStateFalseProfileCenterBarVisibility {
    return Visibility(
      visible: !isfollow && !yours,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleFollow,
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildShimmerContent {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerProfileHeader,
          _buildShimmerPosts,
        ],
      ),
    );
  }

  Widget get _buildShimmerProfileHeader {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoading(
                width: 100,
                height: 100,
                shapeBorder: CircleBorder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) => _buildShimmerStats()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerLoading(width: 150, height: 16),
          const SizedBox(height: 8),
          const ShimmerLoading(width: double.infinity, height: 16),
          const SizedBox(height: 4),
          const ShimmerLoading(width: 200, height: 16),
          const SizedBox(height: 16),
          const ShimmerLoading(height: 40),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              2,
              (index) => const ShimmerLoading(
                width: 30,
                height: 30,
                shapeBorder: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStats() {
    return const Column(
      children: [
        ShimmerLoading(width: 50, height: 20),
        SizedBox(height: 4),
        ShimmerLoading(width: 60, height: 16),
      ],
    );
  }

  Widget get _buildShimmerPosts {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 9, // We're showing 9 posts as an example
      itemBuilder: (context, index) {
        return const ShimmerLoading();
      },
    );
  }

  Widget _buildPostsGrid() {
    return StreamBuilder(
      stream: _firebaseFirestore
          .collection('posts')
          .orderBy('time', descending: true)
          .where('uid', isEqualTo: widget.Uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts found'));
        }

        final posts = snapshot.data!.docs;
        postLength = posts.length;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: postLength,
          itemBuilder: (context, index) {
            final snap = posts[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostScreen(snap.data()),
                ));
              },
              child: CachedImage(snap['postImage']),
            );
          },
        );
      },
    );
  }

  Widget _buildReelsGrid() {
    return StreamBuilder(
      stream: _firebaseFirestore
          .collection('reels')
          .orderBy('time', descending: true)
          .where('uid', isEqualTo: widget.Uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reels found'));
        }

        final reels = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 2 / 3,
          ),
          itemCount: reels.length,
          itemBuilder: (context, index) {
            final reel = reels[index].data();
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ReelsScreen(),
                ));
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  reel['thumbnailUrl'] != null
                      ? CachedImage(reel['thumbnailUrl'])
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library,
                              color: Colors.grey),
                        ),
                  const Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
