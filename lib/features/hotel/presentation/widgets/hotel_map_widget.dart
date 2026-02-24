import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HotelMapWidget extends StatelessWidget {
  final double lat;
  final double lng;
  final String hotelName;

  const HotelMapWidget({
    super.key,
    required this.lat,
    required this.lng,
    required this.hotelName,
  });

  @override
  Widget build(BuildContext context) {
    final location = LatLng(lat, lng);

    return FlutterMap(
      options: MapOptions(
        initialCenter: location,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.asrim.hotelspot.hotelspot',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: location,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_pin,
                color: Color(0xFFc9a96e),
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
