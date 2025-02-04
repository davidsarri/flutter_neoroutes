import 'package:flutter/material.dart';

Widget starsRatingWidget(num rating) {
  int fullStars = rating.floor();
  bool hasHalfStar = (rating - fullStars) >= 0.5;

  return Row(
    children: List.generate(5, (index) {
      if (index < fullStars) {
        return const Icon(Icons.star, color: Colors.amber, size: 16);
      } else if (index == fullStars && hasHalfStar) {
        return const Icon(Icons.star_half, color: Colors.amber, size: 16);
      } else {
        return const Icon(Icons.star_border, color: Colors.amber, size: 16);
      }
    }),
  );
}
