import 'package:flight_reservations/database.dart';

import 'AirplaneDAO.dart';
import 'CustomerDAO.dart';
import 'FlightDAO.dart';
import 'ReservationDAO.dart';

//Not sure if we really need this class, doesn't work in current format.
class DBConnection{
  static late AppDatabase database;

  static late AirplaneDAO airplaneDAO;
  static late CustomerDAO customerDAO;
  static late FlightDAO flightDAO;
  static late ReservationDAO reservationDAO;

  DBConnection(){
    loadData();
  }

  void loadData() async {
    database = await $FloorAppDatabase
        .databaseBuilder('FlightReservations.db')
        .build();
    airplaneDAO = database.airplaneDAO;
    customerDAO = database.customerDAO;
    flightDAO = database.flightDAO;
    reservationDAO = database.reservationDAO;
  }
}