import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flight_reservations/CustomerDAO.dart';
import 'package:flight_reservations/DBConnection.dart';
import 'package:flight_reservations/FlightDAO.dart';
import 'package:flight_reservations/Reservation.dart';
import 'package:flight_reservations/SampleInserts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AppLocalizations.dart';

import 'FlightPage.dart';
import 'AirplanePage.dart';
import 'ReservationPage.dart';
import 'ReservationDAO.dart';
import 'CustomerPage.dart';
import 'database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  Locale _locale = const Locale('en');

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh', 'CN'),
      ],
      home: MyHomePage(setLocale: setLocale),
      initialRoute: '/',
      routes: {
        '/flight': (context) => FlightPage(),
        '/plane': (context) => AirplanePage(),
        '/reservations': (context) => ReservationPage(),
        '/customer': (context) => CustomerPage(setLocale: setLocale),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.setLocale});

  final void Function(Locale locale) setLocale;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AirplaneDAO airplaneDAO;
  late CustomerDAO customerDAO;
  late FlightDAO flightDAO;
  late ReservationDAO reservationDAO;

  // Translation variables
  late String flightReservationsTitle;
  late String customersTitle;
  late String airplanesTitle;
  late String flightsTitle;
  late String reservationsTitle;

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
  }

  @override
  Widget build(BuildContext context) {
    // Initialize translation variables
    flightReservationsTitle = AppLocalizations.of(context)?.translate('flightReservations') ?? 'Flight Reservations';
    customersTitle = AppLocalizations.of(context)?.translate('customers') ?? 'Customers';
    airplanesTitle = AppLocalizations.of(context)?.translate('airplanes') ?? 'Airplanes';
    flightsTitle = AppLocalizations.of(context)?.translate('flights') ?? 'Flights';
    reservationsTitle = AppLocalizations.of(context)?.translate('reservations') ?? 'Reservations';

    debugPaintSizeEnabled = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(flightReservationsTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Locale newLocale = Localizations.localeOf(context).languageCode == 'en'
                  ? Locale('zh', 'CN')
                  : Locale('en');
              widget.setLocale(newLocale);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: [
                  // Customers + Airplanes Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/customer");
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Image.asset("Photos/Customers.png",
                                height: 200.0, width: 200.0),
                            Text(
                              customersTitle,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            )
                          ],
                        ),
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
                            Text(
                              airplanesTitle,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/flight");
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Image.asset("Photos/flights.png",
                                height: 200.0, width: 200.0),
                            Text(
                              flightsTitle,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/reservations");
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Image.asset("Photos/Rez.png",
                                height: 200.0, width: 200.0),
                            Text(
                              reservationsTitle,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
