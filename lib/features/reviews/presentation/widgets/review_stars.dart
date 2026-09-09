import 'package:flutter/material.dart';

class ReviewStars extends StatelessWidget {
  final int rating;
  final double size;
  final bool showNumber;

  const ReviewStars({super.key, required this.rating, this.size = 20, this.showNumber = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: size,
            )),
        if (showNumber) ...[
          const SizedBox(width: 6),
          Text('$rating/5'),
        ],
      ],
    );
  }
}
