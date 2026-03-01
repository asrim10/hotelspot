import 'package:flutter/material.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_app_color.dart';

class FilterOptions {
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? city;

  const FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.city,
  });

  bool get isActive =>
      minPrice != null || maxPrice != null || minRating != null || city != null;

  FilterOptions copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? city,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
    bool clearCity = false,
  }) {
    return FilterOptions(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      city: clearCity ? null : (city ?? this.city),
    );
  }
}

class HomeFilterSheet extends StatefulWidget {
  final FilterOptions current;
  final List<String> availableCities;
  final void Function(FilterOptions) onApply;

  const HomeFilterSheet({
    super.key,
    required this.current,
    required this.availableCities,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required FilterOptions current,
    required List<String> availableCities,
    required void Function(FilterOptions) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeFilterSheet(
        current: current,
        availableCities: availableCities,
        onApply: onApply,
      ),
    );
  }

  @override
  State<HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<HomeFilterSheet> {
  late RangeValues _priceRange;
  late double _minRating;
  String? _selectedCity;

  static const double _maxPrice = 50000;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.current.minPrice ?? 0,
      widget.current.maxPrice ?? _maxPrice,
    );
    _minRating = widget.current.minRating ?? 0;
    _selectedCity = widget.current.city;
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, _maxPrice);
      _minRating = 0;
      _selectedCity = null;
    });
  }

  void _apply() {
    widget.onApply(
      FilterOptions(
        minPrice: _priceRange.start > 0 ? _priceRange.start : null,
        maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
        minRating: _minRating > 0 ? _minRating : null,
        city: _selectedCity,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2E2B4E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Hotels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Price Range ──────────────────────────────────────────────
              _SectionLabel(label: 'Price Range (NRs.)'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PriceChip(
                    label: 'NRs.${_priceRange.start.toStringAsFixed(0)}',
                  ),
                  const Text('—', style: TextStyle(color: Colors.white54)),
                  _PriceChip(
                    label: 'NRs.${_priceRange.end.toStringAsFixed(0)}',
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: _maxPrice,
                divisions: 100,
                activeColor: HomeAppColors.priceBlue,
                inactiveColor: Colors.white24,
                onChanged: (v) => setState(() => _priceRange = v),
              ),
              const SizedBox(height: 24),

              // ── Minimum Rating ───────────────────────────────────────────
              _SectionLabel(label: 'Minimum Rating'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0.0, 1.0, 2.0, 3.0, 4.0, 5.0].map((rating) {
                  final selected = _minRating == rating;
                  return GestureDetector(
                    onTap: () => setState(() => _minRating = rating),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 46,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? HomeAppColors.priceBlue
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? HomeAppColors.priceBlue
                              : Colors.white24,
                        ),
                      ),
                      child: Center(
                        child: rating == 0
                            ? const Text(
                                'Any',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── City ─────────────────────────────────────────────────────
              if (widget.availableCities.isNotEmpty) ...[
                _SectionLabel(label: 'City'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CityChipWidget(
                      label: 'All',
                      selected: _selectedCity == null,
                      onTap: () => setState(() => _selectedCity = null),
                    ),
                    ...widget.availableCities.map(
                      (city) => _CityChipWidget(
                        label: city,
                        selected: _selectedCity == city,
                        onTap: () => setState(() => _selectedCity = city),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // ── Apply button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeAppColors.priceBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  const _PriceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _CityChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChipWidget({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? HomeAppColors.priceBlue : Colors.white12,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? HomeAppColors.priceBlue : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
