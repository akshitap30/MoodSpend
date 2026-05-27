// GENERATED CODE - DO NOT MODIFY BY HAND
// HabitModel TypeAdapter (typeId: 0)

part of 'models.dart';

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      category: fields[3] as String,
      costPerInstance: fields[4] as double,
      frequencyPerMonth: fields[5] as int,
      triggerTime: fields[6] as String?,
      createdAt: fields[7] as String,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.costPerInstance)
      ..writeByte(5)
      ..write(obj.frequencyPerMonth)
      ..writeByte(6)
      ..write(obj.triggerTime)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodLogModelAdapter extends TypeAdapter<MoodLogModel> {
  @override
  final int typeId = 1;

  @override
  MoodLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as String,
      mood: fields[3] as int,
      energy: fields[4] as int,
      contextTags: (fields[5] as List).cast<String>(),
      habitId: fields[6] as String?,
      amount: fields[7] as double?,
      note: fields[8] as String?,
      hourOfDay: fields[9] as int,
      dayOfWeek: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MoodLogModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.energy)
      ..writeByte(5)
      ..write(obj.contextTags)
      ..writeByte(6)
      ..write(obj.habitId)
      ..writeByte(7)
      ..write(obj.amount)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.hourOfDay)
      ..writeByte(10)
      ..write(obj.dayOfWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 2;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      weekStart: fields[2] as String,
      habitId: fields[3] as String,
      habitName: fields[4] as String,
      triggerDescription: fields[5] as String,
      replacementAction: fields[6] as String,
      targetSaving: fields[7] as double,
      status: fields[8] as String,
      completedAt: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.weekStart)
      ..writeByte(3)
      ..write(obj.habitId)
      ..writeByte(4)
      ..write(obj.habitName)
      ..writeByte(5)
      ..write(obj.triggerDescription)
      ..writeByte(6)
      ..write(obj.replacementAction)
      ..writeByte(7)
      ..write(obj.targetSaving)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedJarEntryAdapter extends TypeAdapter<SavedJarEntry> {
  @override
  final int typeId = 3;

  @override
  SavedJarEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedJarEntry(
      id: fields[0] as String,
      userId: fields[1] as String,
      amount: fields[2] as double,
      sourceChallengeId: fields[3] as String?,
      createdAt: fields[4] as String,
      note: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedJarEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.sourceChallengeId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedJarEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
