import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/features/hotel/presentation/pages/hotel_details_page.dart';
import 'hotel_card.dart';

class HotelGrid extends ConsumerWidget {
  final List<dynamic> hotels;
  final Set<String> favouriteHotelIds;
  final String? currentUserId;

  const HotelGrid({
    super.key,
    required this.hotels,
    required this.favouriteHotelIds,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: List.generate((hotels.length / 2).ceil(), (rowIndex) {
        final startIndex = rowIndex * 2;
        final endIndex = (startIndex + 2).clamp(0, hotels.length);
        final rowHotels = hotels.sublist(startIndex, endIndex);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (rowHotels[0].hotelId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HotelDetailsPage(hotelId: rowHotels[0].hotelId!),
                        ),
                      );
                    }
                  },
                  child: HotelCard(
                    hotel: rowHotels[0],
                    favouriteHotelIds: favouriteHotelIds,
                    currentUserId: currentUserId,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (rowHotels.length > 1)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (rowHotels[1].hotelId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelDetailsPage(
                              hotelId: rowHotels[1].hotelId!,
                            ),
                          ),
                        );
                      }
                    },
                    child: HotelCard(
                      hotel: rowHotels[1],
                      favouriteHotelIds: favouriteHotelIds,
                      currentUserId: currentUserId,
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }
}
