import 'package:flutter/material.dart';

class FavouriteButton extends StatefulWidget {
  final bool isFavourited;
  final VoidCallback onTap;

  const FavouriteButton({
    super.key,
    required this.isFavourited,
    required this.onTap,
  });

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.reverse();
    widget.onTap();
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: widget.isFavourited
                ? Colors.red.withOpacity(0.85)
                : Colors.white.withOpacity(0.22),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isFavourited ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
