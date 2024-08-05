import 'package:flight_reservations/Customer.dart';
import 'package:flight_reservations/CustomerDAO.dart';
import 'package:flight_reservations/Reservation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Flight.dart';
import 'FlightDAO.dart';
import 'ReservationDAO.dart';
import 'database.dart';

class ReservationPage extends StatefulWidget {
  @override
  State<ReservationPage> createState() => _ReservationState();
}

class _ReservationState extends State<ReservationPage> {
  late TextEditingController _reservationNameController;
  Customer? selectedCustomer;
  Flight? selectedFlight;
  late List<Customer> customerList = [];
  late List<Flight> flightList = [];
  late ReservationDAO reservationDAO;
  late CustomerDAO customerDAO;
  late FlightDAO flightDAO;
  late List<Reservation> reservations = [];
  bool _showAddReservation = false;
  bool isEnglish = true; // Language state

  @override
  void initState() {
    super.initState();
    _reservationNameController = TextEditingController();
    load();
  }

  @override
  void dispose() {
    _reservationNameController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final database = await $FloorAppDatabase.databaseBuilder('FlightReservations.db').build();

    reservationDAO = database.reservationDAO;
    customerDAO = database.customerDAO;
    flightDAO = database.flightDAO;

    reservations = await reservationDAO.selectAllReservation();
    customerList = await customerDAO.selectAllCustomer();
    flightList = await flightDAO.selectAllFlight();
    setState(() {});
  }

  Future<void> insertReservation() async {
    if (selectedCustomer != null && selectedFlight != null) {
      final reservation = Reservation(
        null,
        selectedCustomer!.id!,
        selectedFlight!.id!,
        _reservationNameController.text,
      );
      await reservationDAO.insertReservation(reservation);
      await load();
    }
  }

  Future<void> deleteReservation(Reservation reservation) async {
    await reservationDAO.removeReservation(reservation);
    await load();
  }

  Future<void> updateReservation(Reservation reservation) async {
    await reservationDAO.insertReservation(reservation);
    await load();
  }

  Widget DetailsPage() {
    if (selectedCustomer != null && selectedFlight != null) {
      return Column(
        children: [
          TextField(
            controller: _reservationNameController,
            decoration: InputDecoration(labelText: 'Reservation Name'),
          ),
          DropdownButton<Customer>(
            hint: Text('Select Customer'),
            value: selectedCustomer,
            onChanged: (Customer? newValue) {
              setState(() {
                selectedCustomer = newValue;
              });
            },
            items: customerList.map<DropdownMenuItem<Customer>>((Customer customer) {
              return DropdownMenuItem<Customer>(
                value: customer,
                child: Text(customer.firstname),
              );
            }).toList(),
          ),
          DropdownButton<Flight>(
            hint: Text('Select Flight'),
            value: selectedFlight,
            onChanged: (Flight? newValue) {
              setState(() {
                selectedFlight = newValue;
              });
            },
            items: flightList.map<DropdownMenuItem<Flight>>((Flight flight) {
              return DropdownMenuItem<Flight>(
                value: flight,
                child: Text('${flight.departureCity} to ${flight.destinationCity}'),
              );
            }).toList(),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.update),
            label: Text("Update"),
            onPressed: () {
              if (selectedCustomer != null && selectedFlight != null) {
                final updatedReservation = Reservation(
                  null, // id is null for a new reservation
                  selectedCustomer!.id!,
                  selectedFlight!.id!,
                  _reservationNameController.text,
                );
                updateReservation(updatedReservation);
                setState(() {
                  selectedCustomer = null;
                  selectedFlight = null;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete),
            label: Text("Delete"),
            onPressed: () {
              setState(() {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete the Reservation'),
                    content: const Text('Do you want to delete this reservation?'),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          if (selectedCustomer != null && selectedFlight != null) {
                            final reservation = reservations.firstWhere(
                                    (res) => res.customerId == selectedCustomer!.id && res.flightId == selectedFlight!.id && res.date == _reservationNameController.text);
                            deleteReservation(reservation);
                            Navigator.pop(context);
                            setState(() {
                              selectedCustomer = null;
                              selectedFlight = null;
                            });
                          }
                        },
                        child: Text("Yes"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No"),
                      ),
                    ],
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Text("No item selected"),
      ],
    );
  }

  Widget AddReservation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _reservationNameController,
              decoration: InputDecoration(
                labelText: 'Reservation Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField<Customer>(
              decoration: InputDecoration(
                labelText: 'Select Customer',
                border: OutlineInputBorder(),
              ),
              value: selectedCustomer,
              onChanged: (Customer? newValue) {
                setState(() {
                  selectedCustomer = newValue;
                });
              },
              items: customerList.map<DropdownMenuItem<Customer>>((Customer customer) {
                return DropdownMenuItem<Customer>(
                  value: customer,
                  child: Text(customer.firstname),
                );
              }).toList(),
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField<Flight>(
              decoration: InputDecoration(
                labelText: 'Select Flight',
                border: OutlineInputBorder(),
              ),
              value: selectedFlight,
              onChanged: (Flight? newValue) {
                setState(() {
                  selectedFlight = newValue;
                });
              },
              items: flightList.map<DropdownMenuItem<Flight>>((Flight flight) {
                return DropdownMenuItem<Flight>(
                  value: flight,
                  child: Text('${flight.departureCity} to ${flight.destinationCity}'),
                );
              }).toList(),
            ),
            SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Add Reservation"),
              onPressed: () {
                insertReservation();
                setState(() {
                  _reservationNameController.text = "";
                  selectedCustomer = null;
                  selectedFlight = null;
                  _showAddReservation = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.cancel),
              label: Text("Cancel"),
              onPressed: () {
                setState(() {
                  _reservationNameController.text = "";
                  selectedCustomer = null;
                  selectedFlight = null;
                  _showAddReservation = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget ReservationList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text("Add New Reservation"),
          onPressed: () {
            setState(() {
              _reservationNameController.text = '';
              selectedCustomer = null;
              selectedFlight = null;
              _showAddReservation = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${rowNum + 1}', textAlign: TextAlign.left),
                    Text(
                      reservations[rowNum].date,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    selectedCustomer = customerList.firstWhere((customer) => customer.id == reservations[rowNum].customerId);
                    selectedFlight = flightList.firstWhere((flight) => flight.id == reservations[rowNum].flightId);
                    _reservationNameController.text = reservations[rowNum].date;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void toggleLanguage() {
    setState(() {
      isEnglish = !isEnglish;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    Widget list = ReservationList();
    Widget display;

    if (_showAddReservation) {
      display = AddReservation();
    } else if ((width > height) && (width > 720)) {
      display = Row(
        children: [
          Expanded(
            flex: 1,
            child: list,
          ),
          Expanded(
            flex: 3,
            child: DetailsPage(),
          ),
        ],
      );
    } else {
      display = selectedCustomer == null ? list : DetailsPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: toggleLanguage,
          ),
        ],
      ),
      body: display,
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English
        Locale('zh', ''), // Chinese
      ],
      home: ReservationPage(),
    ),
  );
}
