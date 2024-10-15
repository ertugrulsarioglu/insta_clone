import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/reels_item.dart';
import '../widgets/shimmer.dart'; // ShimmerLoading widget'ını import edin

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late PageController _pageController;
  int _currentPage = 0;
  bool _isEditing = false;
  bool _isLoading = false;
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
        const SnackBar(content: Text('Reels güncellendi')),
      );
      _toggleEditing();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $error')),
      );
    });
  }

  void _onReelsDeleted() {
    setState(() {
      _isLoading = true;
    });
    // Kısa bir gecikme ekleyerek, kullanıcıya yükleme göstergesini gösterme fırsatı veriyoruz
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore
            .collection('reels')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || _isLoading) {
            return const Center(
              child: ShimmerLoading(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Reels bulunamadı'));
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
