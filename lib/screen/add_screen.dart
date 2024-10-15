import 'package:flutter/material.dart';

import 'post_screen/add_post_screen.dart';
import 'add_reels_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

int _currentIndex = 0;

class _AddScreenState extends State<AddScreen> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
    _currentIndex = 0;
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double containerWidth = 120;
    double rightPosition = ((screenWidth - containerWidth) / 2) - 25;

    return Scaffold(
      body: SafeArea(
          child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: const [
              AddPostScreen(),
              AddReelsScreen(),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: 10,
            right: _currentIndex == 0 ? rightPosition : rightPosition + 50,
            child: Container(
              width: containerWidth,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      navigationTapped(0);
                    },
                    child: Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _currentIndex == 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      navigationTapped(1);
                    },
                    child: Text(
                      'Reels',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _currentIndex == 1 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
