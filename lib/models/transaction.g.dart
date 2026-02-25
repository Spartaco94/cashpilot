part of 'transaction.dart';

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0: return TransactionType.income;
      case 1: return TransactionType.expense;
      default: return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income: writer.writeByte(0); break;
      case TransactionType.expense: writer.writeByte(1); break;
    }
  }
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      type: fields[1] as TransactionType,
      amount: fields[2] as double,
      category: fields[3] as String,
      description: fields[4] as String,
      date: fields[5] as DateTime,
      isRecurring: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.type)
      ..writeByte(2)..write(obj.amount)
      ..writeByte(3)..write(obj.category)
      ..writeByte(4)..write(obj.description)
      ..writeByte(5)..write(obj.date)
      ..writeByte(6)..write(obj.isRecurring);
  }
}
