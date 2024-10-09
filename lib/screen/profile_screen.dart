// ignore_for_file: must_be_immutable, camel_case_types, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/firebase_service/firestore.dart';
import '../model/usermodel.dart';
import '../util/image_cached.dart';
import '../widgets/shimmer.dart';
import '../widgets/sizedbox_spacer.dart';
import 'post_screen.dart';

class ProfileScreen extends StatefulWidget {
  String Uid;
  ProfileScreen({super.key, required this.Uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late int postLenght = 0;
  Usermodel? _user;
  bool yours = false;
  List followings = [];
  bool isfollow = false;
  int followerCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = await FirebaseFirestor().getUser(uidd: widget.Uid);
    final currentUserSnap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();

    setState(() {
      _user = user;
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
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: isLoading ? _customShimmerAppBar : _customAppbar,
        body: SafeArea(
          child: isLoading
              ? _buildShimmerContent
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: head(_user!),
                    ),
                    _profilePostsStreamBuilder
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
          child: IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        )
      ],
      backgroundColor: Colors.white,
      title: Text(
        _user!.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>
      get _profilePostsStreamBuilder {
    return StreamBuilder(
      stream: _firebaseFirestore
          .collection('posts')
          .orderBy('time', descending: true)
          .where('uid', isEqualTo: widget.Uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 6.5,
              width: MediaQuery.of(context).size.width,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
          );
        }

        postLenght = snapshot.data!.docs.length;

        return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final snap = snapshot.data!.docs[index];
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PostScreen(snap.data()),
                      ));
                    },
                    child: CachedImage(snap['postImage']));
              },
              childCount: postLenght,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ));
      },
    );
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
            _yoursStateTrueProfileCenterBarVisibility(yours: yours),
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
          Icon(Icons.person),
        ],
      ),
    );
  }

  Widget _profileRow(Usermodel user) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          child: ClipOval(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CachedImage(user.profile),
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
        Text(
          user.username,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          user.bio,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ),
      ],
    );
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
              3,
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
      itemCount: 9, // Örnek olarak 9 post gösteriyoruz
      itemBuilder: (context, index) {
        return const ShimmerLoading();
      },
    );
  }
}

class _yoursStateTrueProfileCenterBarVisibility extends StatelessWidget {
  const _yoursStateTrueProfileCenterBarVisibility({
    required this.yours,
  });

  final bool yours;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: yours,
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            alignment: Alignment.center,
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            child: const Text(
              'Edit Your Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
