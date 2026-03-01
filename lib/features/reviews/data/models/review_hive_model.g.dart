// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewHiveModelAdapter extends TypeAdapter<ReviewHiveModel> {
  @override
  final int typeId = 4;

  @override
  ReviewHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewHiveModel(
      reviewId: fields[0] as String?,
      userId: fields[1] as String,
      hotelId: fields[2] as String,
      fullName: fields[3] as String,
      email: fields[4] as String,
      rating: fields[5] as double,
      comment: fields[6] as String,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.reviewId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.hotelId)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.comment)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
