import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flight_reservations/CustomerDAO.dart';
import 'package:flight_reservations/DBConnection.dart';
import 'package:flight_reservations/FlightDAO.dart';
import 'package:flight_reservations/Reservation.dart';
import 'package:flight_reservations/SampleInserts.dart';
import 'package:flutter/material.dart';

<<<<<<< Updated upstream
=======
import 'FlightPage.dart';
import 'AirplanePage.dart';
import 'ReservationPage.dart';
>>>>>>> Stashed changes
import 'ReservationDAO.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
<<<<<<< Updated upstream
      home: const MyHomePage(title: 'Flight Reservations'),
=======
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Flight Reservations'),
        '/flight': (context) => FlightPage(),
        '/plane': (context) => AirplanePage(),
        '/reservations': (context) => ReservationPage(),
      },
>>>>>>> Stashed changes
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
<<<<<<< Updated upstream
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'something',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
=======
            //Customers + Airplanes Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Image.asset("Photos/Customers.png",
                        height: 200.0, width: 200.0),
                    Text("Customers",
                        style: TextStyle(fontSize: 30.0, color: Colors.white))
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/plane");
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Image.asset("Photos/planes.png",
                            height: 200.0, width: 200.0),
                        Text("Airplanes",
                            style:
                            TextStyle(fontSize: 30.0, color: Colors.white))
                      ],
                    )),
              ],
            ),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/flight");
                  },
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Image.asset("Photos/flights.png",
                          height: 200.0, width: 200.0),
                      Text("Flights",
                          style: TextStyle(fontSize: 30.0, color: Colors.white))
                    ],
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/reservations");
                },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Image.asset("Photos/Rez.png", height: 200.0, width: 200.0),
                    Text("Reservations",
                        style: TextStyle(fontSize: 30.0, color: Colors.white))
                  ],
                ),
              ),
            ]),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }
}
