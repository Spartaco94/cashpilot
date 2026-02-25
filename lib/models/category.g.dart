part of 'category.dart';

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 2;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      name: fields[0] as String,
      emoji: fields[1] as String,
      colorValue: fields[2] as int,
      isDefault: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.name)
      ..writeByte(1)..write(obj.emoji)
      ..writeByte(2)..write(obj.colorValue)
      ..writeByte(3)..write(obj.isDefault);
  }
}
