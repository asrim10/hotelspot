import 'package:flutter/material.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';

class MyReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final String? hotelName;
  final String? imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyReviewCard({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
    this.hotelName,
    this.imageUrl,
  });

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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2140),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: Color(0xFF1E90FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel info row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.hotel,
                                  color: Colors.white38,
                                  size: 22,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.hotel,
                              color: Colors.white38,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotelName ?? 'Hotel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: const [
                              Icon(
                                Icons.verified_outlined,
                                size: 11,
                                color: Color(0xFF00D084),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified Stay',
                                style: TextStyle(
                                  color: Color(0xFF00D084),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _timeAgo(review.createdAt),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.white.withOpacity(0.07), height: 1),
                const SizedBox(height: 14),

                // Stars + rating badge
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFB74D),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFFFFB74D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Comment
                Text(
                  review.comment,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.07), height: 1),
                const SizedBox(height: 12),

                // Edit + Delete
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E90FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1E90FF).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Color(0xFF1E90FF),
                                size: 15,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: Color(0xFF1E90FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 15,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
