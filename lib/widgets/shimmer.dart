import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final ShapeBorder shapeBorder;
  final Widget? child;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child ??
          Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: shapeBorder,
            ),
          ),
    );
  }
}
