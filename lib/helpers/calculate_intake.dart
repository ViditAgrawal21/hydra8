int calculateIntake(weight, age, weightUnit, waterUnit) {
  num correctWeight = weight;
  if (weightUnit == "lbs") {
    correctWeight = weight / 2.205;
  }
  num result = correctWeight * 30;
  if (waterUnit == "oz US") {
    return result ~/ 29.574;
  }
  if (waterUnit == "oz UK") {
    return result ~/ 28.413;
  }
  return result.toInt();
}

enum DrinkType {
  water,
  coffee,
  tea,
  juice,
  softDrink,
  milk,
}
