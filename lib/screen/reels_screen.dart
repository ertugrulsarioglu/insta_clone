import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/reels_item.dart';
import '../widgets/shimmer.dart';

class ReelsScreen extends StatefulWidget {
  final bool isFromProfile;

  const ReelsScreen({this.isFromProfile = false, super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late PageController _pageController;
  int _currentPage = 0;
  bool _isEditing = false;
  final bool _isLoading = false;
  late TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1);
    _captionController = TextEditingController();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges(String postId) {
    FirebaseFirestore.instance.collection('reels').doc(postId).update({
      'caption': _captionController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reels updated')),
      );
      _toggleEditing();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder(
        stream: _firestore
            .collection('reels')
            .where('uid',
                isEqualTo: widget.isFromProfile ? currentUserId : null)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || _isLoading) {
            return const Center(
              child: ShimmerLoading(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reels found'));
          }
          return Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                    _isEditing = false;
                  });
                },
                itemBuilder: (context, index) {
                  var reelsData = snapshot.data!.docs[index].data();
                  _captionController.text = reelsData['caption'];
                  return ReelsItem(
                    reelsData,
                    onEditPressed: _toggleEditing,
                    isEditing: _isEditing,
                    captionController: _captionController,
                    showEditOption: true,
                    onDeleted: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  );
                },
                itemCount: snapshot.data!.docs.length,
              ),
              if (_isEditing)
                Positioned(
                  top: 40,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: () =>
                        _saveChanges(snapshot.data!.docs[_currentPage].id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _captionController.dispose();
    super.dispose();
  }
}
