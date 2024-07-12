import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

//DTO's
import 'Airplane.dart';
import 'Customer.dart';
import 'Flight.dart';
import 'Reservation.dart';

//DAO's
import 'AirplaneDAO.dart';
import 'CustomerDAO.dart';
import 'FlightDAO.dart';
import 'ReservationDAO.dart';

//Command to generate database `flutter packages pub run build_runner build`
part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Airplane, Customer, Flight, Reservation])
abstract class AppDatabase extends FloorDatabase {
  AirplaneDAO get airplaneDAO;
  CustomerDAO get customerDAO;
  FlightDAO get flightDAO;
  ReservationDAO get reservationDAO;
}