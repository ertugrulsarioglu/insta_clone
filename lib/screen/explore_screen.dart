import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:insta_clone/screen/post_screen.dart';
import 'package:insta_clone/util/image_cached.dart';
import 'package:insta_clone/widgets/shimmer.dart';
import 'package:insta_clone/widgets/sizedbox_spacer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            searchBox,
            StreamBuilder(
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(
                                snap.data(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: CachedImage(
                            snap['postImage'],
                          ),
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
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter get searchBox {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.05,
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
                  controller: searchController,
                  cursorColor: Colors.black,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    hintText: 'Search User',
                    hintStyle: TextStyle(color: Colors.black),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
