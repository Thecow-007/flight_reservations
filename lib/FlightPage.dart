import 'package:flight_reservations/Airplane.dart';
import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'DBConnection.dart';
import 'Flight.dart';
import 'FlightDAO.dart';
import 'ReservationDAO.dart';
import 'database.dart';

class FlightPage extends StatefulWidget {
  @override
  State<FlightPage> createState() => ToDoState();
}

class ToDoState extends State<FlightPage> {
  late TextEditingController _departureCity;
  late TextEditingController _destinationCity;
  DateTime? _departureTime;
  DateTime? _arrivalTime;
  late FlightDAO flightDAO;
  late AirplaneDAO airplaneDAO;
  late ReservationDAO reservationDAO;
  late List<Airplane> planeList = [];
  Airplane? selectedAirplane;
  Flight? selectedItem;
  late List<Flight> flights = [];

  bool _showAddFlight = false; // New state variable to track display mode

  @override
  void initState() {
    super.initState();
    _departureCity = TextEditingController();
    _destinationCity = TextEditingController();

    load();
  }

  @override
  void dispose() {
    _departureCity.dispose();
    _destinationCity.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final database = await $FloorAppDatabase
        .databaseBuilder('FlightReservations.db')
        .build();

    flightDAO = database.flightDAO;
    airplaneDAO = database.airplaneDAO;
    reservationDAO = database.reservationDAO;

    flights = await flightDAO.selectAllFlight();
    planeList = await airplaneDAO.selectAllAirplanes();
    setState(() {});
  }

  Future<void> insertData() async {
    if (selectedAirplane != null) {
      final flight = Flight(
          null,
          _departureCity.value.text,
          _destinationCity.value.text,
          Flight.dateTimeToTimestamp(_departureTime!),
          Flight.dateTimeToTimestamp(_arrivalTime!),
          selectedAirplane!.id ?? 0);
      await flightDAO.insertFlight(flight);
      load();
    }
  }

  Future<void> deleteData(Flight flight) async {
    await reservationDAO.deleteReservationByFlightId(flight.id??0);
    await flightDAO.removeFlight(flight);
    load();
  }

  Future<void> updateData(Flight flight) async {
    await flightDAO.updateFlight(flight);
    await load();
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = picked;
        } else {
          _arrivalTime = picked;
        }
      });
    }
  }

  Widget DetailsPage() {
    if (selectedItem != null) {
      _departureCity.text = selectedItem!.departureCity;
      _destinationCity.text = selectedItem!.destinationCity;
      _departureTime = selectedItem!.getDepartureDateTime();
      _arrivalTime = selectedItem!.getArrivalDateTime();
      selectedAirplane = planeList.firstWhere((airplane) => airplane.id == selectedItem!.airplaneId);

      return Column(
        children: [
          TextField(
            controller: _departureCity,
            decoration: InputDecoration(labelText: 'Departure City'),
          ),
          TextField(
            controller: _destinationCity,
            decoration: InputDecoration(labelText: 'Destination City'),
          ),
          ListTile(
            title: Text("Departure Time: ${_departureTime?.toLocal().toString().split(' ')[0]}"),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, true),
          ),
          ListTile(
            title: Text("Arrival Time: ${_arrivalTime?.toLocal().toString().split(' ')[0]}"),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, false),
          ),
          DropdownButton<Airplane>(
            hint: Text('Select Airplane'),
            value: selectedAirplane,
            onChanged: (Airplane? newValue) {
              setState(() {
                selectedAirplane = newValue;
              });
            },
            items: planeList.map<DropdownMenuItem<Airplane>>((Airplane airplane) {
              return DropdownMenuItem<Airplane>(
                value: airplane,
                child: Text(airplane.name),
              );
            }).toList(),
          ),
          ElevatedButton(
            child: Text("Update"),
            onPressed: () {
              if (selectedItem != null) {
                final updatedFlight = Flight(
                  selectedItem!.id,
                  _departureCity.value.text,
                  _destinationCity.value.text,
                  Flight.dateTimeToTimestamp(_departureTime!),
                  Flight.dateTimeToTimestamp(_arrivalTime!),
                  selectedAirplane!.id ?? 0,
                );
                updateData(updatedFlight);
                setState(() {
                  selectedItem = null;
                });
              }
            },
          ),
          ElevatedButton(
            child: Text("Delete"),
            onPressed: () {
              setState(() {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Delete the Flight'),
                      content: const Text('Do you sure you want to delete the item'),
                      actions: <Widget>[
                        ElevatedButton(
                            onPressed: () {
                              deleteData(selectedItem!);
                              Navigator.pop(context);
                              setState(() {
                                selectedItem = null;
                              });
                            },
                            child: Text("Yes")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No"))
                      ],
                    ));
              });
            },
          )
        ],
      );
    }
    return Column(children: [
      Text("No item selected"),
    ]);
  }

  Widget AddFlight(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
    Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets to fill horizontal space
      children: [
        TextField(
          controller: _departureCity,
          decoration: InputDecoration(
            labelText: 'Departure City',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8.0), // Add space between TextFields
        TextField(
          controller: _destinationCity,
          decoration: InputDecoration(
            labelText: 'Destination City',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8.0), // Add space between ListTile and TextFields
        ListTile(
          title: Text("Departure Time: ${_departureTime?.toLocal().toString().split(' ')[0]}"),
          trailing: Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, true),
        ),
        SizedBox(height: 8.0), // Add space between ListTile widgets
        ListTile(
          title: Text("Arrival Time: ${_arrivalTime?.toLocal().toString().split(' ')[0]}"),
          trailing: Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, false),
        ),
        SizedBox(height: 8.0), // Add space between ListTile and DropdownButton
        DropdownButtonFormField<Airplane>(
          decoration: InputDecoration(
            labelText: 'Select Airplane',
            border: OutlineInputBorder(),
          ),
          value: selectedAirplane,
          onChanged: (Airplane? newValue) {
            setState(() {
              selectedAirplane = newValue;
            });
          },
          items: planeList.map<DropdownMenuItem<Airplane>>((Airplane airplane) {
            return DropdownMenuItem<Airplane>(
              value: airplane,
              child: Text(airplane.name),
            );
          }).toList(),
        ),
        SizedBox(height: 8.0), // Add space between DropdownButton and ElevatedButton
        ElevatedButton(
          child: Text("Add Flight"),
          onPressed: () {
            insertData();
            setState(() {
              _departureCity.text = "";
              _destinationCity.text = "";
              _departureTime = null;
              _arrivalTime = null;
              selectedAirplane = null;
              _showAddFlight = false;
            });
          },
        ),
        ElevatedButton(
          child: Text("Cancle"),
          onPressed: () {
            setState(() {
              _departureCity.text = "";
              _destinationCity.text = "";
              _departureTime = null;
              _arrivalTime = null;
              selectedAirplane = null;
              _showAddFlight = false;
            });
          },
        ),
      ],
    )]);
  }

  Widget FlightList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          child: Text("Add New Flight"),
          onPressed: () {
            setState(() {
              _departureCity.text = '';
              _destinationCity.text = '';
              _departureTime = null;
              _arrivalTime = null;
              selectedAirplane = null;
              _showAddFlight = true; // Show AddFlight form
            });
          },
        ),
        Expanded(
            child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, rowNum) {
                  return GestureDetector(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${rowNum + 1}', textAlign: TextAlign.left),
                            Text(flights[rowNum].getArrivalDateTime().toLocal().toString().split(' ')[0], textAlign: TextAlign.right)
                          ]),
                      onTap: () {
                        setState(() {
                          selectedItem = flights[rowNum];
                        });
                      });
                }))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    Widget list = FlightList();
    Widget display;

    if (_showAddFlight) {
      display =  AddFlight();
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
      display = selectedItem == null ? list : DetailsPage();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Flight List"),
      ),
      body: Center(child: display),
    );
  }
}
