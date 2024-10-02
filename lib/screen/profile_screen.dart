import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../data/firebase_service/firestore.dart';
import '../model/usermodel.dart';
import 'post_screen.dart';
import '../util/image_cached.dart';
import '../widgets/shimmer.dart';
import '../widgets/sizedbox_spacer.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usermodel? _user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestor().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Veri yüklenirken göstereceğimiz loading ekranı
          return Scaffold(
              appBar: AppBar(
                title: Shimmer(
                    gradient: const LinearGradient(colors: Colors.primaries),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    )),
                backgroundColor: Colors.white,
              ),
              body: const ShimmerLoading());
        }

        if (snapshot.hasData) {
          _user = snapshot.data;
          return _buildProfileScreen;
        }

        return const Scaffold(
          body: Center(child: Text('Error loading data')),
        );
      },
    );
  }

  Widget get _buildProfileScreen {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              _user!.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ), // Yüklenen kullanıcı verisiyle AppBar başlığı
          ),
          body: SafeArea(
              child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: head(_user!), // Kullanıcı bilgileri gösterilecek
              ),
              StreamBuilder(
                stream: _firebaseFirestore
                    .collection('posts')
                    .orderBy('time', descending: true)
                    .where('uid', isEqualTo: _auth.currentUser!.uid)
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
                  var snapLength = snapshot.data!.docs.length;
                  return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var snap = snapshot.data!.docs[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PostScreen(snap.data()),
                                ));
                              },
                              child: CachedImage(snap['postImage']));
                        },
                        childCount: snapLength,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ));
                },
              )
            ],
          ))),
    );
  }

  Widget head(Usermodel user) => Container(
        padding: const EdgeInsets.only(bottom: 5),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CachedImage(user.profile),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 25),
                        const Column(
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBoxSpacer.h4,
                            Text(
                              'Posts',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        SizedBoxSpacer.w35,
                        Column(
                          children: [
                            Text(
                              user.followers.length.toString(),
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
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.bio,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBoxSpacer.h20,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                alignment: Alignment.center,
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                child: const Text('Edit Your Profile'),
              ),
            ),
            SizedBoxSpacer.h5,
            const SizedBox(
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
            ),
            SizedBoxSpacer.h5,
          ],
        ),
      );
}
