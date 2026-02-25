part of 'budget.dart';

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 3;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      monthlyLimit: fields[0] as double,
      month: fields[1] as int,
      year: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)..write(obj.monthlyLimit)
      ..writeByte(1)..write(obj.month)
      ..writeByte(2)..write(obj.year);
  }
}
