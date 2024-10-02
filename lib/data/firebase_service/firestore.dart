import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/usermodel.dart';
import '../../util/exeption.dart';
import 'package:uuid/uuid.dart';

class FirebaseFirestor {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser({
    required String email,
    required String username,
    required String bio,
    required String profile,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'email': email,
      'username': username,
      'bio': bio,
      'profile': profile,
      'followers': [],
      'following': [],
    });
    return true;
  }

  Future<Usermodel?> getUser() async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      final snapuser = user.data()!;
      return Usermodel(
          snapuser['bio'],
          snapuser['email'],
          snapuser['followers'],
          snapuser['following'],
          snapuser['profile'],
          snapuser['username']);
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  // ignore: non_constant_identifier_names
  Future<bool> CreatePost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    var uid = const Uuid().v4();
    DateTime data = DateTime.now();
    Usermodel? user = await getUser();
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user?.username,
      'profileImage': user?.profile,
      'caption': caption,
      'location': location,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  // ignore: non_constant_identifier_names
  Future<bool> CreateReels({
    required String video,
    required String caption,
  }) async {
    var uid = const Uuid().v4();
    DateTime data = DateTime.now();
    Usermodel? user = await getUser();
    await _firebaseFirestore.collection('reels').doc(uid).set({
      'reelsVideo': video,
      'username': user?.username,
      'profileImage': user?.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  // ignore: non_constant_identifier_names
  Future<bool> Comments({
    required String comment,
    required String postId,
    required String type, // 'posts' veya 'reels' için
  }) async {
    var commentId = const Uuid().v4();
    Usermodel? user = await getUser();

    try {
      DocumentReference postRef =
          _firebaseFirestore.collection(type).doc(postId);

      await postRef.collection('comments').doc(commentId).set({
        'comment': comment,
        'username': user?.username,
        'profileImage': user?.profile,
        'commentId': commentId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await postRef.update({'commentCount': FieldValue.increment(1)});

      print('Yorum başarıyla eklendi: $commentId');
      return true;
    } catch (e) {
      print('Yorum eklenirken hata oluştu: $e');
      return false;
    }
  }
}
