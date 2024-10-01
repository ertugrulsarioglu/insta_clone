import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:insta_clone/data/firebase_service/firestore.dart';
import 'package:insta_clone/data/firebase_service/storage.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class ReelsEditScreen extends StatefulWidget {
  File videoFile;
  ReelsEditScreen(this.videoFile, {super.key});

  @override
  State<ReelsEditScreen> createState() => _ReelsEditScreenState();
}

class _ReelsEditScreenState extends State<ReelsEditScreen> {
  final captionController = TextEditingController();
  late VideoPlayerController controller;
  bool Loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    captionController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Reels',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Loading
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: SizedBox(
                          width: controller.value.isInitialized
                              ? controller.value.size.width
                              : 270,
                          height: controller.value.isInitialized
                              ? controller.value.size.height
                              : 640,
                          child: controller.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.black)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 60,
                        width: 280,
                        child: TextField(
                          controller: captionController,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption ...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 45,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Save draft',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              controller.pause();

                              setState(() {
                                Loading = true;
                              });
                              String reelsUrl = await StorageMethod()
                                  .uploadImageToStorage(
                                      'reels', widget.videoFile);
                              await FirebaseFirestor().CreateReels(
                                video: reelsUrl,
                                caption: captionController.text,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 45,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Share',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
// 9. videodasin buna gecmeden once ses isini hallet