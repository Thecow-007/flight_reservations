import 'Airplane.dart';
import 'AirplaneDAO.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';
import 'Flight.dart';
import 'FlightDAO.dart';
import 'Reservation.dart';
import 'ReservationDAO.dart';

class SampleInserts{
  //Method to insert sample data into database
  static Future<void> insertSampleData(AirplaneDAO airplaneDAO, CustomerDAO customerDAO, FlightDAO flightDAO, ReservationDAO reservationDAO) async {
    // Insert Airplanes
    var airplane1 = Airplane(null, "Boeing 737", 188, 583.0, 3515.0);
    var airplane2 = Airplane(null, "Airbus A320", 180, 590.0, 3300.0);
    var airplane3 = Airplane(null, "Boeing 747", 416, 614.0, 8000.0);
    var airplane4 = Airplane(null, "Airbus A380", 555, 634.0, 8200.0);
    var airplane5 = Airplane(null, "Embraer E190", 114, 541.0, 2900.0);

    int airplane1Id = await airplaneDAO.insertAirplane(airplane1);
    int airplane2Id = await airplaneDAO.insertAirplane(airplane2);
    int airplane3Id = await airplaneDAO.insertAirplane(airplane3);
    int airplane4Id = await airplaneDAO.insertAirplane(airplane4);
    int airplane5Id = await airplaneDAO.insertAirplane(airplane5);

    // Insert Customers
    var customer1 = Customer(null, "John", "Doe", "123 Elm St, Springfield, IL", "1980-01-01");
    var customer2 = Customer(null, "Jane", "Smith", "456 Oak St, Lincoln, NE", "1990-05-15");
    var customer3 = Customer(null, "Alice", "Johnson", "789 Pine St, Madison, WI", "1985-02-20");
    var customer4 = Customer(null, "Robert", "Brown", "101 Maple St, Austin, TX", "1975-08-30");
    var customer5 = Customer(null, "Emily", "Davis", "202 Birch St, Denver, CO", "2000-11-10");

    int customer1Id = await customerDAO.insertCustomer(customer1);
    int customer2Id = await customerDAO.insertCustomer(customer2);
    int customer3Id = await customerDAO.insertCustomer(customer3);
    int customer4Id = await customerDAO.insertCustomer(customer4);
    int customer5Id = await customerDAO.insertCustomer(customer5);

    // Insert Flights
    var flight1 = Flight(
        null,
        "New York",
        "Los Angeles",
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-01 08:00:00")),
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-01 11:00:00")),
        airplane1Id);

    var flight2 = Flight(
        null,
        "Chicago",
        "Miami",
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-02 14:00:00")),
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-02 18:00:00")),
        airplane2Id);

    var flight3 = Flight(
        null,
        "Dallas",
        "San Francisco",
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-03 09:00:00")),
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-03 12:00:00")),
        airplane3Id);

    var flight4 = Flight(
        null,
        "Atlanta",
        "Seattle",
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-04 10:00:00")),
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-04 13:00:00")),
        airplane4Id);

    var flight5 = Flight(
        null,
        "Houston",
        "Boston",
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-05 11:00:00")),
        Flight.dateTimeToTimestamp(DateTime.parse("2024-08-05 15:00:00")),
        airplane5Id);
    int flight1Id = await flightDAO.insertFlight(flight1);
    int flight2Id = await flightDAO.insertFlight(flight2);
    int flight3Id = await flightDAO.insertFlight(flight3);
    int flight4Id = await flightDAO.insertFlight(flight4);
    int flight5Id = await flightDAO.insertFlight(flight5);

    // Insert Reservations
    var reservation1 = Reservation(null, customer1Id, flight1Id, "2024-07-01");
    var reservation2 = Reservation(null, customer2Id, flight2Id, "2024-07-02");
    var reservation3 = Reservation(null, customer3Id, flight3Id, "2024-07-03");
    var reservation4 = Reservation(null, customer4Id, flight4Id, "2024-07-04");
    var reservation5 = Reservation(null, customer5Id, flight5Id, "2024-07-05");

    await reservationDAO.insertReservation(reservation1);
    await reservationDAO.insertReservation(reservation2);
    await reservationDAO.insertReservation(reservation3);
    await reservationDAO.insertReservation(reservation4);
    await reservationDAO.insertReservation(reservation5);
  }

}