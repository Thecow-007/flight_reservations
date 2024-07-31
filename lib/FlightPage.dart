import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flight_reservations/Airplane.dart';
import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flutter/material.dart';

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
  late TextEditingController _login;
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

  bool _showAddFlight = false;

  @override
  void initState() {
    super.initState();
    _departureCity = TextEditingController();
    _destinationCity = TextEditingController();

    load();
    loadEncrypted();
  }

  @override
  void dispose() {
    _departureCity.dispose();
    _destinationCity.dispose();
    super.dispose();
    saveEncrypted();
  }

  void loadEncrypted() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedResult = await prefs.getInstance();
    var departureCity = encryptedResult.getString("departureCity");
    var destinationCity = encryptedResult.getString("destinationCity");
    if (destinationCity != null) {
      _destinationCity.text = destinationCity;
    }
    if (departureCity != null) {
      _departureCity.text = departureCity;
    }

      if(departureCity!.length > 0  || destinationCity!.length > 0){
        SnackBar snackBar = SnackBar(
            content: Text('Previous data have been loaded!'),
            action: SnackBarAction(
                label: 'Clear saved data',
                onPressed: () {
                  _destinationCity.text = "";
                  _departureCity.text = "";
                  cleanData();
                }));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
  }

  void saveEncrypted() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedResult = await prefs.getInstance();
    encryptedResult.setString("departureCity", _departureCity.text);
    encryptedResult.setString("destinationCity", _destinationCity.text);

  }

  void cleanData() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedResult = await prefs.getInstance();
    await encryptedResult.remove("departureCity");
    await encryptedResult.remove("destinationCity");

  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        selectedAirplane!.id ?? 0,
      );
      await flightDAO.insertFlight(flight);
      load();
    }
  }

  Future<void> deleteData(Flight flight) async {
    await reservationDAO.deleteReservationByFlightId(flight.id ?? 0);
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
      selectedAirplane = planeList
          .firstWhere((airplane) => airplane.id == selectedItem!.airplaneId);

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
            title: Text(
                "Departure Time: ${_departureTime?.toLocal().toString().split(' ')[0]}"),
            trailing: Icon(Icons.calendar_today),
            onTap: () => _selectDate(context, true),
          ),
          ListTile(
            title: Text(
                "Arrival Time: ${_arrivalTime?.toLocal().toString().split(' ')[0]}"),
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
            items:
                planeList.map<DropdownMenuItem<Airplane>>((Airplane airplane) {
              return DropdownMenuItem<Airplane>(
                value: airplane,
                child: Text(airplane.name),
              );
            }).toList(),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              child: Text("Update"),
              onPressed: () {
                if (_departureCity.text.isNotEmpty &&
                    _destinationCity.text.isNotEmpty &&
                    _departureTime != null &&
                    _arrivalTime != null &&
                    selectedAirplane != null) {
                  if (selectedItem != null) {
                    final updatedFlight = Flight(
                      selectedItem!.id,
                      _departureCity.text,
                      _destinationCity.text,
                      Flight.dateTimeToTimestamp(_departureTime!),
                      Flight.dateTimeToTimestamp(_arrivalTime!),
                      selectedAirplane!.id ?? 0,
                    );
                    updateData(updatedFlight);
                    setState(() {
                      selectedItem = null;
                    });
                    showSnackBar("Successfully updated the flight");
                  }
                } else {
                  showSnackBar("Please fill out the entire form");
                }
              },
            ),
            ElevatedButton(
              child: Text("Delete"),
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete the Flight'),
                    content:
                        const Text('Are you sure you want to delete the item?'),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          deleteData(selectedItem!);
                          Navigator.pop(context);
                          setState(() {
                            selectedItem = null;
                          });
                          showSnackBar("Successfully deleted the flight");
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
              },
            ),
          ]),
          ElevatedButton(
            child: Text("Cancel"),
            onPressed: () {
              setState(() {
                selectedItem = null;
              });
            },
          ),
        ],
      );
    }
    return Column(children: [
      Text("No item selected"),
    ]);
  }

  Widget AddFlight() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _departureCity,
              decoration: InputDecoration(
                labelText: 'Departure City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _destinationCity,
              decoration: InputDecoration(
                labelText: 'Destination City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            ListTile(
              title: Text(
                  "Departure Time: ${_departureTime?.toLocal().toString().split(' ')[0]}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            SizedBox(height: 8.0),
            ListTile(
              title: Text(
                  "Arrival Time: ${_arrivalTime?.toLocal().toString().split(' ')[0]}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            SizedBox(height: 8.0),
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
              items: planeList
                  .map<DropdownMenuItem<Airplane>>((Airplane airplane) {
                return DropdownMenuItem<Airplane>(
                  value: airplane,
                  child: Text(airplane.name),
                );
              }).toList(),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                child: Text("Add Flight"),
                onPressed: () {
                  if (_departureCity.text != null &&
                      _destinationCity.text != null &&
                      _departureTime != null &&
                      _arrivalTime != null &&
                      selectedAirplane != null) {
                    insertData();
                    setState(() {
                      _departureCity.text = "";
                      _destinationCity.text = "";
                      _departureTime = null;
                      _arrivalTime = null;
                      selectedAirplane = null;
                      _showAddFlight = false;
                    });
                    showSnackBar("Successfully add the new flight");
                  } else {
                    showSnackBar("Please fill out the entire form");
                  }
                },
              ),
              ElevatedButton(
                child: Text("Cancel"),
                onPressed: () async {
                  saveEncrypted();
                  setState(() {
                    _showAddFlight = false;
                  });
                },
              )
            ])
          ],
        )
      ],
    );
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
              _showAddFlight = true;
            });
            loadEncrypted();
          },
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Departure Time'), Text('Departure City')]),
        Expanded(
          child: ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      flights[rowNum]
                          .getDepartureDateTime()
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      flights[rowNum].departureCity,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    selectedItem = flights[rowNum];
                  });
                },
              );
            },
          ),
        )
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
      display = AddFlight();
    } else if ((width > height) && (width > 720)) {
      display = Row(
        children: [
          Expanded(flex: 1, child: list),
          Expanded(flex: 3, child: DetailsPage()),
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
