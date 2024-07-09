import 'package:floor/floor.dart';

@entity
class Airplane{

  @PrimaryKey(autoGenerate: true)
  final int? id;

  String name;
  int numberOfPassengers;
  double maxSpeed;
  double range;

  Airplane(this.id, this.name, this.numberOfPassengers, this.maxSpeed, this.range);
}
