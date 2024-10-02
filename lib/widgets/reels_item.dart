import 'package:flutter/material.dart';
import 'package:insta_clone/util/image_cached.dart';
import 'package:insta_clone/widgets/shimmer.dart';
import 'package:insta_clone/widgets/sizedbox_spacer.dart';
import 'package:video_player/video_player.dart';

class ReelsItem extends StatefulWidget {
  final snapshot;
  const ReelsItem(this.snapshot, {super.key});

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> {
  late VideoPlayerController controller;
  bool play = true;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  Future<void> initializeVideoPlayer() async {
    final videoUri = Uri.parse(widget.snapshot['reelsVideo']);
    controller = VideoPlayerController.networkUrl(videoUri);
    try {
      await controller.initialize();
      setState(() {
        controller.setLooping(true);
        controller.setVolume(1);
        controller.play();
        isInitialized = true;
      });
    } catch (error) {
      print('Video yüklenirken hata oluştu: $error');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.setLooping(false);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              play = !play;
            });
            play ? controller.play() : controller.pause();
          },
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: isInitialized
                ? VideoPlayer(controller)
                : const ShimmerLoading(),
          ),
        ),
        if (!play)
          const Center(
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 35,
              child: Icon(
                Icons.play_arrow,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.58,
          right: MediaQuery.of(context).size.width * 0.03,
          child: const Column(
            children: [
              Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 28,
              ),
              Text(
                '0',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              SizedBox(height: 10),
              Icon(
                Icons.comment,
                color: Colors.white,
                size: 28,
              ),
              Text(
                '0',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              SizedBox(height: 10),
              Icon(
                Icons.send,
                color: Colors.white,
                size: 28,
              ),
              Text(
                '0',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.06,
          left: MediaQuery.of(context).size.width * 0.03,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: CachedImage(widget.snapshot['profileImage']),
                    ),
                  ),
                  SizedBoxSpacer.w10,
                  Text(
                    widget.snapshot['username'],
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    alignment: Alignment.center,
                    width: 60,
                    height: 25,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBoxSpacer.h8,
              Text(
                widget.snapshot['caption'],
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
