import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../../util/exeption.dart';
import 'firestore.dart';
import 'storage.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String passwordConfirme,
    required String username,
    required String bio,
    required File profile,
  }) async {
    late String URL;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == passwordConfirme) {
          await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          // upload profile image on storage

          if (profile != File('')) {
            URL =
                await StorageMethod().uploadImageToStorage('profile', profile);
          } else {
            URL = '';
          }

          // get information with firestor

          await FirebaseFirestor().createUser(
            email: email.trim(),
            username: username.trim(),
            bio: bio.trim(),
            profile: URL == ''
                ? 'https://firebasestorage.googleapis.com/v0/b/instagramclone-4ac6a.appspot.com/o/person.png?alt=media&token=b405fedc-0d39-428d-a117-a5857633d7e2'
                : URL.trim(),
          );
        } else {
          throw exceptions('password and confirm password should be same');
        }
      } else {
        throw exceptions('enter all the fields');
      }
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }
}
