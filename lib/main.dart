import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flight_reservations/CustomerDAO.dart';
import 'package:flight_reservations/DBConnection.dart';
import 'package:flight_reservations/FlightDAO.dart';
import 'package:flight_reservations/Reservation.dart';
import 'package:flight_reservations/SampleInserts.dart';
import 'package:flutter/material.dart';

import 'ReservationDAO.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flight Hub'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AirplaneDAO airplaneDAO;
  late CustomerDAO customerDAO;
  late FlightDAO flightDAO;
  late ReservationDAO reservationDAO;


  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    final database = await $FloorAppDatabase
        .databaseBuilder('FlightReservations.db')
        .build();
    airplaneDAO = database.airplaneDAO;
    customerDAO = database.customerDAO;
    flightDAO = database.flightDAO;
    reservationDAO = database.reservationDAO;

    SampleInserts.insertSampleData(airplaneDAO, customerDAO, flightDAO, reservationDAO);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Customers + Airplanes Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Image.asset("Photos/Customers.png", height:200.0, width:200.0),
                    Text("Customers")
                  ],
                ),
                Stack(
                  children: [
                    Image.asset("Photos/planes.png", height:200.0, width:200.0),
                    Text("Airplanes")
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Image.asset("Photos/flights.png", height: 200.0, width:200.0),
                    Text("Flights")
                  ],
                ),
                Stack(
                  children: [
                    Image.asset("Photos/Rez.png", height:200.0, width:200.0),
                    Text("Reservations")
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}