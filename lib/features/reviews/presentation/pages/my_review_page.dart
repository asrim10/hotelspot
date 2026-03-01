import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/api/api_endpoints.dart';
import 'package:hotelspot/features/hotel/presentation/view_model/hotel_viewmodel.dart';
import 'package:hotelspot/features/reviews/domain/entities/review_entity.dart';
import 'package:hotelspot/features/reviews/presentation/state/review_state.dart';
import 'package:hotelspot/features/reviews/presentation/view_model/review_viewmodel.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/edit_review_sheet.dart';
import 'package:hotelspot/features/reviews/presentation/widgets/my_review_card.dart';

class MyReviewsPage extends ConsumerStatefulWidget {
  const MyReviewsPage({super.key});

  @override
  ConsumerState<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends ConsumerState<MyReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewViewmodelProvider.notifier).getMyReviews();
      ref.read(hotelViewmodelProvider.notifier).getAllHotels();
    });
  }

  String? _resolveHotelName(String hotelId) {
    try {
      return ref
          .read(hotelViewmodelProvider)
          .hotels
          .firstWhere((h) => h.hotelId == hotelId)
          .hotelName;
    } catch (_) {
      return null;
    }
  }

  String? _resolveImageUrl(String hotelId) {
    try {
      final hotel = ref
          .read(hotelViewmodelProvider)
          .hotels
          .firstWhere((h) => h.hotelId == hotelId);
      final rawPath = hotel.imageUrl ?? '';
      if (rawPath.isEmpty) return null;
      final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
      return '$baseUrl$rawPath';
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirmDelete(ReviewEntity review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2140),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Review?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(reviewViewmodelProvider.notifier)
        .deleteReview(reviewId: review.reviewId!, hotelId: review.hotelId);

    if (!mounted) return;
    final state = ref.read(reviewViewmodelProvider);
    if (state.status == ReviewStatus.deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review deleted'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(reviewViewmodelProvider.notifier).getMyReviews();
    }
  }

  void _openEditSheet(ReviewEntity review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditReviewSheet(review: review),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewViewmodelProvider);

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
          'My Reviews',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ReviewState state) {
    if (state.status == ReviewStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
      );
    }

    if (state.status == ReviewStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Failed to load reviews',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  ref.read(reviewViewmodelProvider.notifier).getMyReviews(),
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFF1E90FF)),
              ),
            ),
          ],
        ),
      );
    }

    if (state.myReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.rate_review_outlined, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your submitted reviews will appear here',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: state.myReviews.length,
      itemBuilder: (context, index) {
        final review = state.myReviews[index];
        return MyReviewCard(
          review: review,
          hotelName: _resolveHotelName(review.hotelId),
          imageUrl: _resolveImageUrl(review.hotelId),
          onEdit: () => _openEditSheet(review),
          onDelete: () => _confirmDelete(review),
        );
      },
    );
  }
}
