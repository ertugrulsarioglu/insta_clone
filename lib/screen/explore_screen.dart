import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:insta_clone/screen/profile_screen.dart';

import '../util/image_cached.dart';
import '../widgets/shimmer.dart';
import '../widgets/sizedbox_spacer.dart';
import 'post_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: searchBox,
        ),
        body: SafeArea(
            child: CustomScrollView(
          slivers: [
            !showSearch
                ? StreamBuilder(
                    stream: _firebaseFirestore.collection('posts').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: ShimmerLoading(),
                          ),
                        );
                      }

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final snap = snapshot.data!.docs[index];
                            final data = snap.data() as Map<String, dynamic>?;
                            final postImage = data != null
                                ? data['postImage'] as String?
                                : null;

                            return GestureDetector(
                              onTap: () {
                                if (data != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostScreen(data),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                ),
                                child: postImage != null
                                    ? CachedImage(postImage)
                                    : const Center(child: Text('Resim yok')),
                              ),
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                        gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 3,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          pattern: [
                            const QuiltedGridTile(2, 1),
                            const QuiltedGridTile(2, 2),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                          ],
                        ),
                      );
                    },
                  )
                : StreamBuilder(
                    stream: _firebaseFirestore
                        .collection('users')
                        .where('username',
                            isGreaterThanOrEqualTo: searchController.text)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SliverToBoxAdapter(
                            child: Center(
                          child: ShimmerLoading(),
                        ));
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            final snap = snapshot.data!.docs[index];
                            final userData =
                                snap.data() as Map<String, dynamic>?;

                            if (userData == null) {
                              return const SizedBox
                                  .shrink(); // Veri yoksa boş bir widget döndür
                            }

                            final username = userData['username'] as String?;
                            final profileUrl = userData['profile'] as String?;

                            return Column(
                              children: [
                                SizedBoxSpacer.h10,
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileScreen(Uid: snap.id),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: profileUrl != null
                                            ? NetworkImage(profileUrl)
                                            : null,
                                        child: profileUrl == null
                                            ? const Icon(Icons
                                                .person) // Profil resmi yoksa ikon göster
                                            : null,
                                      ),
                                      SizedBoxSpacer.w15,
                                      Text(username ?? 'Anonymous User'),
                                    ],
                                  ),
                                )
                              ],
                            );
                          }, childCount: snapshot.data!.docs.length),
                        ),
                      );
                    },
                  ),
          ],
        )));
  }

  Widget get searchBox {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.black,
            ),
            SizedBoxSpacer.w10,
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      showSearch = true;
                    } else {
                      showSearch = false;
                    }
                  });
                },
                controller: searchController,
                cursorColor: Colors.black,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: 'Search User',
                  hintStyle: TextStyle(color: Colors.black),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
