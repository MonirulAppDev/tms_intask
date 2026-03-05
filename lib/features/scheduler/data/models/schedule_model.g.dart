// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 0;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleModel(
      id: fields[0] as String,
      appName: fields[1] as String,
      packageName: fields[2] as String,
      scheduledTime: fields[3] as DateTime,
      label: fields[4] as String?,
      isExecuted: fields[5] as bool,
      isEnabled: fields[6] as bool,
      frequency: fields[7] as ScheduleFrequencyModel?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.packageName)
      ..writeByte(3)
      ..write(obj.scheduledTime)
      ..writeByte(4)
      ..write(obj.label)
      ..writeByte(5)
      ..write(obj.isExecuted)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.frequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleFrequencyModelAdapter
    extends TypeAdapter<ScheduleFrequencyModel> {
  @override
  final int typeId = 1;

  @override
  ScheduleFrequencyModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleFrequencyModel.once;
      case 1:
        return ScheduleFrequencyModel.daily;
      default:
        return ScheduleFrequencyModel.once;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleFrequencyModel obj) {
    switch (obj) {
      case ScheduleFrequencyModel.once:
        writer.writeByte(0);
        break;
      case ScheduleFrequencyModel.daily:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleFrequencyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
