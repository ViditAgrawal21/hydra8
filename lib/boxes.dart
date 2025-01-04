import 'package:hive/hive.dart';
import 'package:my_app/models/DrinkAmount.dart';

class Boxes {
  static Box<DrinkAmount> getDrinkAmounts() => Hive.box('drink_amounts');
}
