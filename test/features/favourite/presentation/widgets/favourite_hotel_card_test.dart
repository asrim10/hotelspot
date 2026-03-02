import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hotelspot/features/favourites/domain/entities/favourite_entity.dart';
import 'package:hotelspot/features/favourites/presentation/widgets/favourite_hotel_card.dart';

class _FakeHotel {
  final String hotelName;
  final double price;
  final double rating;
  final String city;
  final String? imageUrl;

  _FakeHotel({
    required this.hotelName,
    required this.price,
    required this.rating,
    required this.city,
    this.imageUrl,
  });
}

FavouriteEntity _makeFavourite() =>
    FavouriteEntity(hotelId: 'hotel_abc', userId: 'user_123');

_FakeHotel _makeHotel({
  String hotelName = 'Grand Hotel',
  double price = 2000,
  double rating = 4.5,
  String city = 'Kathmandu',
  String? imageUrl,
}) => _FakeHotel(
  hotelName: hotelName,
  price: price,
  rating: rating,
  city: city,
  imageUrl: imageUrl,
);

Widget buildWidget({
  _FakeHotel? hotel,
  FavouriteEntity? favourite,
  Color priceBlue = const Color(0xFF1E90FF),
  VoidCallback? onRemove,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 300,
        width: 200,
        child: FavouriteHotelCard(
          hotel: hotel ?? _makeHotel(),
          favourite: favourite ?? _makeFavourite(),
          priceBlue: priceBlue,
          onRemove: onRemove ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('rendering', () {
    testWidgets('shows hotel name', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Grand Hotel'), findsOneWidget);
    });

    testWidgets('shows price badge', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('NRs.2000'), findsOneWidget);
    });

    testWidgets('shows rating', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('shows city', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Kathmandu'), findsOneWidget);
    });

    testWidgets('shows View details label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('View details'), findsOneWidget);
    });

    testWidgets('shows star icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows location icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('shows favourite heart icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows bed icon in footer', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.bed_outlined), findsOneWidget);
    });

    testWidgets('shows arrow forward icon in footer', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
  });

  group('image', () {
    testWidgets('shows hotel icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(buildWidget(hotel: _makeHotel(imageUrl: null)));
      expect(find.byIcon(Icons.hotel), findsOneWidget);
    });

    testWidgets('shows hotel icon when imageUrl is empty', (tester) async {
      await tester.pumpWidget(buildWidget(hotel: _makeHotel(imageUrl: '')));
      expect(find.byIcon(Icons.hotel), findsOneWidget);
    });
  });

  group('price formatting', () {
    testWidgets('shows price with no decimals', (tester) async {
      await tester.pumpWidget(buildWidget(hotel: _makeHotel(price: 3500)));
      expect(find.text('NRs.3500'), findsOneWidget);
    });

    testWidgets('shows price rounded for decimal price', (tester) async {
      await tester.pumpWidget(buildWidget(hotel: _makeHotel(price: 1999.9)));
      expect(find.text('NRs.2000'), findsOneWidget);
    });
  });

  group('callback', () {
    testWidgets('calls onRemove when heart button is tapped', (tester) async {
      bool removed = false;
      await tester.pumpWidget(buildWidget(onRemove: () => removed = true));
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();
      expect(removed, isTrue);
    });
  });
}
