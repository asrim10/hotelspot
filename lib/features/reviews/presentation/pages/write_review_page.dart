import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/reviews/presentation/pages/my_review_page.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/star_rating_selector.dart';

class WriteReviewPage extends ConsumerStatefulWidget {
  final String hotelId;
  final String hotelName;
  final String? imageUrl;

  const WriteReviewPage({
    super.key,
    required this.hotelId,
    required this.hotelName,
    this.imageUrl,
  });

  @override
  ConsumerState<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends ConsumerState<WriteReviewPage> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
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
        .createReview(
          hotelId: widget.hotelId,
          rating: _selectedRating.toDouble(),
          comment: _commentController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(reviewViewmodelProvider).status == ReviewStatus.loading;

    ref.listen<ReviewState>(reviewViewmodelProvider, (previous, next) {
      if (next.status == ReviewStatus.created &&
          previous?.status != ReviewStatus.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted! Thank you.'),
            backgroundColor: Color(0xFF00D084),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyReviewsPage()),
        );
      } else if (next.status == ReviewStatus.error &&
          previous?.status != ReviewStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Failed to submit review'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write a Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HotelInfoCard(
                hotelName: widget.hotelName,
                imageUrl: widget.imageUrl,
              ),
              const SizedBox(height: 32),
              const Text(
                'Your Rating',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StarRatingSelector(
                selectedRating: _selectedRating,
                onRatingSelected: (rating) =>
                    setState(() => _selectedRating = rating),
              ),
              const SizedBox(height: 32),
              const Text(
                'Your Experience',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 1000,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'What made your stay memorable?',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A2140),
                  counterStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E90FF)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Comment must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: isLoading ? null : _submitReview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isLoading
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF1E90FF), Color(0xFF0066CC)],
                            ),
                      color: isLoading ? Colors.grey[700] : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF1E90FF).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SUBMIT REVIEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotelInfoCard extends StatelessWidget {
  final String hotelName;
  final String? imageUrl;

  const _HotelInfoCard({required this.hotelName, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2140),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.hotel, color: Colors.white38),
                    ),
                  )
                : const Icon(Icons.hotel, color: Colors.white38),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 12,
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
        ],
      ),
    );
  }
}
