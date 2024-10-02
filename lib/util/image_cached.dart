import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../widgets/shimmer.dart';

// ignore: must_be_immutable
class CachedImage extends StatelessWidget {
  String? imageUrl;

  CachedImage(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: imageUrl!,
      progressIndicatorBuilder: (context, url, progress) {
        return const Center(
          child: ShimmerLoading(),
        );
      },
      errorWidget: (context, url, error) => Container(
        color: Colors.amber,
      ),
    );
  }
}
