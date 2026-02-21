// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavouriteHiveModelAdapter extends TypeAdapter<FavouriteHiveModel> {
  @override
  final int typeId = 3;

  @override
  FavouriteHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavouriteHiveModel(
      favouriteId: fields[0] as String?,
      userId: fields[1] as String,
      hotelId: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.favouriteId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.hotelId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouriteHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
