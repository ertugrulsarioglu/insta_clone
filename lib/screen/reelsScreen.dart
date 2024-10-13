import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/reels_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: _firestore
          .collection('reels')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.black,
          ));
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reels found'));
        }
        return PageView.builder(
          scrollDirection: Axis.vertical,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          itemBuilder: (context, index) {
            return ReelsItem(snapshot.data!.docs[index].data());
          },
          itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
        );
      },
    ));
  }
}
//10. videoya gecmeden once buglari hallet