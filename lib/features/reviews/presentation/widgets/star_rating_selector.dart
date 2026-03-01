import 'package:flutter/material.dart';

class StarRatingSelector extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int> onRatingSelected;

  const StarRatingSelector({
    super.key,
    required this.selectedRating,
    required this.onRatingSelected,
  });

  static const _labels = ['', 'Terrible', 'Poor', 'Okay', 'Good', 'Excellent'];
  static const _colors = [
    Colors.transparent,
    Colors.redAccent,
    Color(0xFFFF7043),
    Color(0xFFFFB74D),
    Color(0xFF66BB6A),
    Color(0xFF00D084),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final star = index + 1;
            final isSelected = star <= selectedRating;
            return GestureDetector(
              onTap: () => onRatingSelected(star),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: isSelected ? 50 : 42,
                  color: isSelected ? const Color(0xFFFFB74D) : Colors.white24,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selectedRating > 0
              ? Container(
                  key: ValueKey(selectedRating),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _colors[selectedRating].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _colors[selectedRating].withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _labels[selectedRating],
                    style: TextStyle(
                      color: _colors[selectedRating],
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                )
              : const SizedBox(
                  key: ValueKey(0),
                  height: 30,
                  child: Center(
                    child: Text(
                      'Tap a star to rate',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
