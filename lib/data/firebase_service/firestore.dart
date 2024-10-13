// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../model/usermodel.dart';
import '../../util/exeption.dart';

class FirebaseFirestor {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<Usermodel?> getUser({String? uidd}) async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(uidd ?? _auth.currentUser!.uid)
          .get();
      final snapuser = user.data()!;

      final posts = await _firebaseFirestore
          .collection('posts')
          .where('uid', isEqualTo: uidd ?? _auth.currentUser!.uid)
          .get();

      List<String> postIds = posts.docs.map((doc) => doc.id).toList();

      return Usermodel(
        snapuser['bio'],
        snapuser['email'],
        snapuser['followers'],
        snapuser['following'],
        snapuser['profile'],
        snapuser['username'],
        posts: postIds,
      );
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

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

  Future<bool> CreateReels({
    required String video,
    required String caption,
  }) async {
    var uid = const Uuid().v4();
    DateTime data = DateTime.now();
    Usermodel? user = await getUser();

    String? thumbnailUrl;
    try {
      final thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: video,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 500,
        quality: 100,
      );

      if (thumbnailFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('reels')
            .child('reelsImage')
            .child('$uid.jpg');
        await ref.putFile(File(thumbnailFile));
        thumbnailUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      print('Error while creating thumbnail: $e');
    }

    await _firebaseFirestore.collection('reels').doc(uid).set({
      'reelsVideo': video,
      'username': user?.username,
      'profileImage': user?.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data,
      'thumbnailUrl': thumbnailUrl,
    });
    return true;
  }

  Future<bool> Comments({
    required String comment,
    required String postId,
    required String type,
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

      print('Comment added successfully: $commentId');
      return true;
    } catch (e) {
      print('Error occurred while adding comment: $e');
      return false;
    }
  }

  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String res = 'some error';
    try {
      if (like.contains(uid)) {
        _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([uid]),
        });
      } else {
        _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([uid]),
        });
      }
      res = 'success';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<Usermodel?> follow({
    required String uid,
  }) async {
    try {
      DocumentSnapshot snap = await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      List follow = (snap.data()! as dynamic)['following'];

      if (follow.contains(uid)) {
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'following': FieldValue.arrayRemove([uid]),
        });
        await _firebaseFirestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([_auth.currentUser!.uid]),
        });
      } else {
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'following': FieldValue.arrayUnion([uid]),
        });
        await _firebaseFirestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([_auth.currentUser!.uid]),
        });
      }

      return await getUser(uidd: uid);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String uid,
    String? bio,
    String? username,
    String? profileImageUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (bio != null) updates['bio'] = bio;
      if (username != null) updates['username'] = username;
      if (profileImageUrl != null) updates['profile'] = profileImageUrl;

      await _firebaseFirestore.collection('users').doc(uid).update(updates);

      // Kullanıcının gönderilerini ve reels'lerini güncelle
      if (username != null || profileImageUrl != null) {
        await updateUserPostsAndReels(uid, username, profileImageUrl);
      }

      return true;
    } catch (e) {
      print('Profil güncellenirken hata oluştu: $e');
      return false;
    }
  }

  Future<void> updateUserPostsAndReels(
      String uid, String? newUsername, String? newProfileImage) async {
    try {
      // Kullanıcının tüm gönderilerini güncelle
      QuerySnapshot postSnapshot = await _firebaseFirestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in postSnapshot.docs) {
        Map<String, dynamic> updates = {};
        if (newUsername != null) updates['username'] = newUsername;
        if (newProfileImage != null) updates['profileImage'] = newProfileImage;
        await doc.reference.update(updates);
      }

      // Kullanıcının tüm reels'lerini güncelle
      QuerySnapshot reelsSnapshot = await _firebaseFirestore
          .collection('reels')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in reelsSnapshot.docs) {
        Map<String, dynamic> updates = {};
        if (newUsername != null) updates['username'] = newUsername;
        if (newProfileImage != null) updates['profileImage'] = newProfileImage;
        await doc.reference.update(updates);
      }

      print('Kullanıcının gönderileri ve reels\'leri başarıyla güncellendi.');
    } catch (e) {
      print('Gönderiler ve reels güncellenirken hata oluştu: $e');
    }
  }

  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      String fileName = 'profile_$uid.jpg';
      Reference ref = _storage.ref().child('profile_images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Profil resmi yüklenirken hata oluştu: $e');
      return null;
    }
  }
}
