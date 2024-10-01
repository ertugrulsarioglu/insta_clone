import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import 'package:insta_clone/util/image_cached.dart';

class PostWidget extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snapshot;
  const PostWidget(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 54,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: CachedImage(snapshot['profileImage']),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: snapshot['location'] != null &&
                            snapshot['location'].isNotEmpty
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot['username'],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      if (snapshot['location'] != null &&
                          snapshot['location'].isNotEmpty)
                        Text(
                          snapshot['location'],
                          style: const TextStyle(fontSize: 11),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: CachedImage(snapshot['postImage']),
          ),
        ),
        Container(
          // height: 375,
          color: Colors.white,
          child: Column(
            children: [
              //const SizedBox(height: 14),
              //22
              Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.favorite_outline, size: 25),
                  const SizedBox(width: 2),
                  Text(
                    snapshot['like'].length.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 17),
                  Image.asset('images/comment.webp', height: 28),
                  const SizedBox(width: 2),
                  const Text(
                    '156',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 17),
                  Image.asset('images/send.jpg', height: 28),
                  const SizedBox(width: 2),
                  const Text(
                    '356',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Image.asset(
                      'images/save.png',
                      height: 28,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                child: Row(
                  children: [
                    Text(
                      snapshot['username'] + ' ',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      snapshot['caption'],
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 20, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      formatDate(
                          snapshot['time'].toDate(), [yyyy, '-', mm, '-', dd]),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}