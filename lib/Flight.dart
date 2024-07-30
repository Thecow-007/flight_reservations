import 'package:floor/floor.dart';

import 'Airplane.dart';

@Entity(
  foreignKeys: [
  ForeignKey(childColumns: ['airplaneId'], parentColumns: ['id'], entity: Airplane),
],)
class Flight{

  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String departureCity;
  final String destinationCity;
  final int departureTime; // Store as timestamp (int)
  final int arrivalTime;    // Store as timestamp (int)
  final int airplaneId;

  Flight(this.id, this.departureCity, this.destinationCity, this.departureTime, this.arrivalTime, this.airplaneId);

  DateTime getDepartureDateTime() => DateTime.fromMillisecondsSinceEpoch(departureTime);
  DateTime getArrivalDateTime() => DateTime.fromMillisecondsSinceEpoch(arrivalTime);

  static int dateTimeToTimestamp(DateTime dateTime) => dateTime.millisecondsSinceEpoch;
}
