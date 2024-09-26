import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CachedImage extends StatelessWidget {
  String? imageUrl;
  CachedImage(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      progressIndicatorBuilder: (context, url, progress) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(100),
            child: CircularProgressIndicator(
              value: progress.progress,
              color: Colors.black,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) => Container(
        color: Colors.amber,
      ),
    );
  }
}
