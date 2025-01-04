import 'package:hive/hive.dart';

part 'DrinkAmount.g.dart';

@HiveType(typeId: 0)
class DrinkAmount extends HiveObject {
  @HiveField(0)
  late int amount;
  @HiveField(1)
  late String unit;
  @HiveField(2)
  late DateTime createdDate;
  @HiveField(3)
  late String drinkType;
}
