import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_clone/data/firebase_service/firestore.dart';
import 'package:insta_clone/data/firebase_service/storage.dart';

class AddPostTextScreen extends StatefulWidget {
  final File _file;
  const AddPostTextScreen(this._file, {super.key});

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final captionText = TextEditingController();
  final locationText = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  String postUrl = await StorageMethod()
                      .uploadImageToStorage('post', widget._file);
                  await FirebaseFirestor().CreatePost(
                      postImage: postUrl,
                      caption: captionText.text,
                      location: locationText.text);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Share',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.black,
                ))
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(widget._file),
                                      fit: BoxFit.cover)),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 280,
                              height: 60,
                              child: TextField(
                                controller: captionText,
                                decoration: const InputDecoration(
                                    hintText: 'Write a caption ...',
                                    border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: 280,
                          height: 30,
                          child: TextField(
                            controller: locationText,
                            decoration: const InputDecoration(
                                hintText: 'Add locatıon',
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }
}
