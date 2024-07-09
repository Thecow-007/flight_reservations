import 'package:floor/floor.dart';

import 'Airplane.dart';

@Entity(
  foreignKeys: [
  ForeignKey(childColumns: ['airplaneId'], parentColumns: ['id'], entity: Airplane),
],)
class Flight{

  @PrimaryKey(autoGenerate: true)
  final int? id;

  String departureCity;
  String destinationCity;
  String departureTime;
  String arrivalTime;
  int airplaneId;

  Flight(this.id, this.departureCity, this.destinationCity, this.departureTime, this.arrivalTime, this.airplaneId);
}
