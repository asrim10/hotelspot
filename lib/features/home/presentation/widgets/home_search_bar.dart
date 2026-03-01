import 'package:flutter/material.dart';
import 'package:hotelspot/features/home/presentation/widgets/home_app_color.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final bool filterActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilter;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    required this.onFilter,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration.collapsed(
                hintText: 'Search Hotels...',
                hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              cursorColor: HomeAppColors.primary,
            ),
          ),
          if (searchQuery.isNotEmpty)
            SizedBox(
              width: 34,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: onClear,
                splashRadius: 18,
              ),
            )
          else
            SizedBox(
              width: 34,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.filter_list,
                      color: filterActive
                          ? HomeAppColors.primary
                          : Colors.black54,
                    ),
                    onPressed: onFilter,
                    splashRadius: 18,
                  ),
                  // Active dot indicator
                  if (filterActive)
                    Positioned(
                      top: 8,
                      right: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: HomeAppColors.priceBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
