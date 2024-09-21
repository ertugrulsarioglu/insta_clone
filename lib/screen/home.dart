import 'package:flutter/material.dart';
import '../widgets/post_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
          width: 105,
          height: 28,
          child: Image.asset('images/instagram.jpg'),
        ),
        leading: Image.asset('images/camera.jpg'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Wrap(
              children: [
                const Icon(
                  Icons.favorite_border_outlined,
                  color: Colors.black,
                ),
                const SizedBox(width: 20),
                Image.asset('images/send.jpg')
              ],
            ),
          )
        ],
        backgroundColor: const Color(0xffFAFAFA),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const PostWidget();
              },
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
