// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DrinkAmount.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrinkAmountAdapter extends TypeAdapter<DrinkAmount> {
  @override
  final int typeId = 0;

  @override
  DrinkAmount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrinkAmount()
      ..amount = fields[0] as int
      ..unit = fields[1] as String
      ..createdDate = fields[2] as DateTime
      ..drinkType = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, DrinkAmount obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.createdDate)
      ..writeByte(3)
      ..write(obj.drinkType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrinkAmountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
