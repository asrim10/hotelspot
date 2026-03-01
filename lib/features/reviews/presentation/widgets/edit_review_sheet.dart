import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/star_rating_selector.dart';

class EditReviewSheet extends ConsumerStatefulWidget {
  final ReviewEntity review;

  const EditReviewSheet({super.key, required this.review});

  @override
  ConsumerState<EditReviewSheet> createState() => _EditReviewSheetState();
}

class _EditReviewSheetState extends ConsumerState<EditReviewSheet> {
  late int _selectedRating;
  late TextEditingController _commentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.review.rating.round();
    _commentController = TextEditingController(text: widget.review.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(reviewViewmodelProvider.notifier)
        .updateReview(
          reviewId: widget.review.reviewId!,
          userId: widget.review.userId,
          hotelId: widget.review.hotelId,
          fullName: widget.review.fullName,
          email: widget.review.email,
          rating: _selectedRating.toDouble(),
          comment: _commentController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(reviewViewmodelProvider);

    if (state.status == ReviewStatus.updated) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review updated!'),
          backgroundColor: Color(0xFF00D084),
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(reviewViewmodelProvider.notifier).getMyReviews();
    } else if (state.status == ReviewStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Failed to update review'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(reviewViewmodelProvider).status == ReviewStatus.loading;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1631),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit Review',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            StarRatingSelector(
              selectedRating: _selectedRating,
              onRatingSelected: (r) => setState(() => _selectedRating = r),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 1000,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Update your experience...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1A2140),
                counterStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E90FF)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 5) {
                  return 'Comment must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: isLoading ? null : _saveEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: isLoading
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF1E90FF), Color(0xFF0066CC)],
                          ),
                    color: isLoading ? Colors.grey[700] : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
