import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 54,
          color: Colors.white,
          child: Center(
            child: ListTile(
              leading: ClipOval(
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: Image.asset('images/person.png'),
                ),
              ),
              title: const Text(
                'username',
                style: TextStyle(fontSize: 13),
              ),
              subtitle: const Text(
                'location',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.more_horiz),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            // width: 375,
            height: 375,
            child: Image.asset(
              'images/post.jpg',
              fit: BoxFit.cover,
            ),
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
                  const Text(
                    '13,9K',
                    style: TextStyle(
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                child: Row(
                  children: [
                    Text(
                      'username' ' ',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'caption',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, top: 20, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'dateformat',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
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
