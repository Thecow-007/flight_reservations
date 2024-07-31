import 'package:floor/floor.dart';

import 'Customer.dart';
import 'Flight.dart';

@Entity(
  foreignKeys: [
    ForeignKey(childColumns: ['customerId'], parentColumns: ['id'], entity: Customer),
    ForeignKey(childColumns: ['flightId'], parentColumns: ['id'], entity: Flight),
  ]
)
class Reservation{

  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int customerId;
  final int flightId;
  String date;


  Reservation(this.id, this.customerId, this.flightId, this.date);
}