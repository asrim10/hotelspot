import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';

class HotelReviewSection extends ConsumerStatefulWidget {
  final String hotelId;

  const HotelReviewSection({super.key, required this.hotelId});

  @override
  ConsumerState<HotelReviewSection> createState() => _HotelReviewSectionState();
}

class _HotelReviewSectionState extends ConsumerState<HotelReviewSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(reviewViewmodelProvider.notifier)
          .getReviewsByHotelId(widget.hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewViewmodelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Guest Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (reviewState.reviews.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E90FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1E90FF).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${reviewState.reviews.length} reviews',
                  style: const TextStyle(
                    color: Color(0xFF1E90FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Rating summary bar
        if (reviewState.reviews.isNotEmpty) ...[
          _RatingSummary(reviews: reviewState.reviews),
          const SizedBox(height: 20),
        ],

        // States
        if (reviewState.status == ReviewStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
            ),
          )
        else if (reviewState.status == ReviewStatus.error)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                reviewState.errorMessage ?? 'Failed to load reviews',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
        else if (reviewState.reviews.isEmpty)
          const _EmptyReviews()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviewState.reviews.length,
            itemBuilder: (context, index) {
              return ReviewCard(review: reviewState.reviews[index]);
            },
          ),
      ],
    );
  }
}

// Rating Summary

class _RatingSummary extends StatelessWidget {
  final List<ReviewEntity> reviews;

  const _RatingSummary({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final avg =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final counts = List.generate(
      5,
      (i) => reviews.where((r) => r.rating.round() == 5 - i).length,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2140),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Average score
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFFFFB74D),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < avg.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFB74D),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${reviews.length} reviews',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Container(width: 1, height: 70, color: Colors.white12),
          const SizedBox(width: 20),
          // Rating bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final starLabel = 5 - i;
                final count = counts[i];
                final pct = reviews.isNotEmpty ? count / reviews.length : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        '$starLabel',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB74D),
                        size: 11,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFFB74D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

//  Individual Review Card

class ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const ReviewCard({super.key, required this.review});

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2140),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _avatarColor(review.fullName),
                ),
                child: Center(
                  child: Text(
                    review.fullName.isNotEmpty
                        ? review.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFFB74D),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timeAgo(review.createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFFFFB74D),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF1E90FF),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

// Empty State

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2140),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: const [
          Icon(Icons.rate_review_outlined, color: Colors.white24, size: 40),
          SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Be the first to share your experience',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
