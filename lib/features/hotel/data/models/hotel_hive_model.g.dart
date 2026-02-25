// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HotelHiveModelAdapter extends TypeAdapter<HotelHiveModel> {
  @override
  final int typeId = 0;

  @override
  HotelHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HotelHiveModel(
      hotelId: fields[0] as String?,
      hotelName: fields[1] as String,
      city: fields[2] as String,
      price: fields[3] as double,
      country: fields[4] as String,
      address: fields[5] as String,
      availableRooms: fields[6] as int,
      rating: fields[7] as double,
      description: fields[8] as String?,
      imageUrl: fields[9] as String?,
      coordinateLat: fields[10] as double?,
      coordinateLng: fields[11] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, HotelHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.hotelId)
      ..writeByte(1)
      ..write(obj.hotelName)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.availableRooms)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.imageUrl)
      ..writeByte(10)
      ..write(obj.coordinateLat)
      ..writeByte(11)
      ..write(obj.coordinateLng);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotelHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
