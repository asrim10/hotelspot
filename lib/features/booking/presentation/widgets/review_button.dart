import 'package:flutter/material.dart';
import 'package:hotelspot/features/reviews/presentation/pages/write_review_page.dart';

class ReviewButton extends StatelessWidget {
  final String hotelId;
  final String hotelName;
  final String? imageUrl;

  const ReviewButton({
    super.key,
    required this.hotelId,
    required this.hotelName,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WriteReviewPage(
            hotelId: hotelId,
            hotelName: hotelName,
            imageUrl: imageUrl,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFB74D).withOpacity(0.12),
              const Color(0xFFFF8F00).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated stars
            ...List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: i < 4
                      ? const Color(0xFFFFB74D)
                      : const Color(0xFFFFB74D).withOpacity(0.4),
                ),
              );
            }),
            const SizedBox(width: 10),
            const Text(
              'Rate Your Stay',
              style: TextStyle(
                color: Color(0xFFFFB74D),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFFFB74D),
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
