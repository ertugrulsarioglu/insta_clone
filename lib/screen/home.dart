import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/post_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
          width: 105,
          height: 28,
          child: Image.asset('images/instagram.jpg'),
        ),
        leading: Image.asset('images/camera.jpg'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Wrap(
              children: [
                const Icon(
                  Icons.favorite_border_outlined,
                  color: Colors.black,
                ),
                const SizedBox(width: 20),
                Image.asset('images/send.jpg')
              ],
            ),
          )
        ],
        backgroundColor: const Color(0xffFAFAFA),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream: _firebaseFirestore
                .collection('posts')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return PostWidget(snapshot.data!.docs[index].data(), true);
                },
                    childCount:
                        snapshot.data == null ? 0 : snapshot.data!.docs.length),
              );
            },
          )
        ],
      ),
    );
  }
}
