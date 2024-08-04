import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flight_reservations/Airplane.dart';
import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // For localization

import 'DBConnection.dart';
import 'Flight.dart';
import 'FlightDAO.dart';
import 'ReservationDAO.dart';
import 'database.dart';

/// Main function to run the Flutter application.
void main() {
  runApp(const MyApp());
}

/// Main application widget.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  /// Method to set the locale of the application.
  static void setLocal(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }
}

/// State for the MyApp widget.
class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  /// Method to update the locale of the application.
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh', 'CN'),
      ],
      home: FlightPage(
        setLocale: setLocale,
      ),
    );
  }
}

/// Page displaying the flight information.
class FlightPage extends StatefulWidget {
  const FlightPage({super.key, required this.setLocale});
  final String title = "Customer Page";
  final void Function(Locale locale) setLocale;
  @override
  State<FlightPage> createState() => FlightState();
}

/// State for the FlightPage widget.
class FlightState extends State<FlightPage> {
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

  late String departureCity;
  late String destinationCity;
  late String selectAirplane;
  late String successfullyUpdatedFlight;
  late String pleaseFillOutEntireForm;
  late String deleteTheFlight;
  late String areYouSureToDeleteItem;
  late String successfullyDeletedFlight;
  late String yes;
  late String no;
  late String cancel;
  late String noItemSelected;
  late String addFlight;
  late String successfullyAddedNewFlight;
  late String saveInfoForNextTime;
  late String wouldYouLikeToSaveDataForNextTime;
  late String ok;
  late String previous;
  late String departureTime;
  late String addNewFlight;
  late String loadSavedInfo;
  late String wouldYouLikeToLoadSavedData;
  late String pressPreviousToLoadSavedData;
  late String flightList;
  late String addFight;
  late String updateDelete;
  late String howToAddNewFlight;
  late String pressAddNewFlightButton;
  late String clickOnRecordToModify;
  late String updateText;
  late String deleteText;
  late String previousDataLoaded;
  late String clearSavedData;

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

  /// Method to load encrypted data.
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

    if (departureCity!.length > 0 || destinationCity!.length > 0) {
      SnackBar snackBar = SnackBar(
          content: Text(previousDataLoaded),
          action: SnackBarAction(
              label: clearSavedData,
              onPressed: () {
                _destinationCity.text = "";
                _departureCity.text = "";
                cleanData();
              }));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /// Method to save encrypted data.
  void saveEncrypted() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedResult = await prefs.getInstance();
    encryptedResult.setString("departureCity", _departureCity.text);
    encryptedResult.setString("destinationCity", _destinationCity.text);
  }

  /// Method to clear saved encrypted data.
  void cleanData() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedResult = await prefs.getInstance();
    await encryptedResult.remove("departureCity");
    await encryptedResult.remove("destinationCity");
  }

  /// Method to display a snack bar with a given message.
  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Method to load data from the database.
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

  /// Method to insert a new flight into the database.
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

  /// Method to delete a flight from the database.
  Future<void> deleteData(Flight flight) async {
    await reservationDAO.deleteReservationByFlightId(flight.id ?? 0);
    await flightDAO.removeFlight(flight);
    load();
  }

  /// Method to update a flight in the database.
  Future<void> updateData(Flight flight) async {
    await flightDAO.updateFlight(flight);
    await load();
  }

  /// Method to show a date picker and update the departure or arrival time.
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

  @override
  Widget build(BuildContext context) {
    departureCity = AppLocalizations.of(context)?.translate('Departure City') ??
        'Departure City';
    destinationCity =
        AppLocalizations.of(context)?.translate('Destination City') ??
            'Destination City';
    selectAirplane =
        AppLocalizations.of(context)?.translate('Select Airplane') ??
            'Select Airplane';
    successfullyUpdatedFlight = AppLocalizations.of(context)
            ?.translate('Successfully updated the flight') ??
        'Successfully updated the flight';
    pleaseFillOutEntireForm = AppLocalizations.of(context)
            ?.translate('Please fill out the entire form') ??
        'Please fill out the entire form';
    deleteTheFlight =
        AppLocalizations.of(context)?.translate('Delete the Flight') ??
            'Delete the Flight';
    areYouSureToDeleteItem = AppLocalizations.of(context)
            ?.translate('Are you sure you want to delete the item?') ??
        'Are you sure you want to delete the item?';
    successfullyDeletedFlight = AppLocalizations.of(context)
            ?.translate('Successfully deleted the flight') ??
        'Successfully deleted the flight';
    yes = AppLocalizations.of(context)?.translate('Yes') ?? 'Yes';
    no = AppLocalizations.of(context)?.translate('No') ?? 'No';
    cancel = AppLocalizations.of(context)?.translate('Cancel') ?? 'Cancel';
    noItemSelected =
        AppLocalizations.of(context)?.translate('No item selected') ??
            'No item selected';
    addFlight =
        AppLocalizations.of(context)?.translate('Add Flight') ?? 'Add Flight';
    successfullyAddedNewFlight = AppLocalizations.of(context)
            ?.translate('Successfully added the new flight') ??
        'Successfully added the new flight';
    saveInfoForNextTime = AppLocalizations.of(context)
            ?.translate('Save Information for next time') ??
        'Save Information for next time';
    wouldYouLikeToSaveDataForNextTime = AppLocalizations.of(context)?.translate(
            'Would you like to save data for the next time you add the flight?') ??
        'Would you like to save data for the next time you add the flight?';
    ok = AppLocalizations.of(context)?.translate('Ok') ?? 'Ok';
    previous =
        AppLocalizations.of(context)?.translate('Previous') ?? 'Previous';
    departureTime = AppLocalizations.of(context)?.translate('Departure Time') ??
        'Departure Time';
    addNewFlight = AppLocalizations.of(context)?.translate('Add New Flight') ??
        'Add New Flight';
    loadSavedInfo =
        AppLocalizations.of(context)?.translate('Load the Saved Information') ??
            'Load the Saved Information';
    wouldYouLikeToLoadSavedData = AppLocalizations.of(context)
            ?.translate('Would you like to load the saved data?') ??
        'Would you like to load the saved data?';
    pressPreviousToLoadSavedData = AppLocalizations.of(context)
            ?.translate('Press the Previous to load the saved data') ??
        'Press the Previous to load the saved data';
    flightList =
        AppLocalizations.of(context)?.translate('Flight List') ?? 'Flight List';
    addFlight =
        AppLocalizations.of(context)?.translate('Add Flight') ?? 'Add Flight';
    updateDelete = AppLocalizations.of(context)?.translate('Update/Delete') ??
        'Update/Delete';
    howToAddNewFlight =
        AppLocalizations.of(context)?.translate('How to Add New Flight') ??
            'How to Add New Flight';
    pressAddNewFlightButton = AppLocalizations.of(context)?.translate(
            'Press the "Add New Flight" button, fill up all the fields, then click the Add button.') ??
        'Press the "Add New Flight" button, fill up all the fields, then click the Add button.';
    clickOnRecordToModify = AppLocalizations.of(context)?.translate(
            'Click on the record you want to modify, fill up all the fields to update or press the Delete button to delete the record.') ??
        'Click on the record you want to modify, fill up all the fields to update or press the Delete button to delete the record.';
    updateText = AppLocalizations.of(context)?.translate('Update') ?? 'Update';
    deleteText = AppLocalizations.of(context)?.translate('Delete') ?? 'Delete';
    previousDataLoaded = AppLocalizations.of(context)
            ?.translate('Previous data have been loaded!') ??
        'Previous data have been loaded!';
    clearSavedData =
        AppLocalizations.of(context)?.translate('Clear saved data') ??
            'Clear saved data';

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
              decoration: InputDecoration(labelText: departureCity),
            ),
            TextField(
              controller: _destinationCity,
              decoration: InputDecoration(labelText: destinationCity),
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
              hint: Text(selectAirplane),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton(
                child: Text(updateText),
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
                      showSnackBar(successfullyAddedNewFlight);
                    }
                  } else {
                    showSnackBar(pleaseFillOutEntireForm);
                  }
                },
              ),
              ElevatedButton(
                child: Text(deleteText),
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text(deleteTheFlight),
                      content: Text(areYouSureToDeleteItem),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            deleteData(selectedItem!);
                            Navigator.pop(context);
                            setState(() {
                              selectedItem = null;
                            });
                            showSnackBar(successfullyDeletedFlight);
                          },
                          child: Text(yes),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(no),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]),
            ElevatedButton(
              child: Text(cancel),
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
        Text(noItemSelected),
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
                  labelText: departureCity,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _destinationCity,
                decoration: InputDecoration(
                  labelText: destinationCity,
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
                  labelText: selectAirplane,
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
                  child: Text(addFlight),
                  onPressed: () async {
                    if (_departureCity.text.isNotEmpty &&
                        _destinationCity.text.isNotEmpty &&
                        _departureTime != null &&
                        _arrivalTime != null &&
                        selectedAirplane != null) {
                      saveEncrypted();
                      insertData();
                      showSnackBar(successfullyAddedNewFlight);
                      _departureTime = null;
                      _arrivalTime = null;
                      selectedAirplane = null;
                      _showAddFlight = false;
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(saveInfoForNextTime),
                                content:
                                    Text(wouldYouLikeToSaveDataForNextTime),
                                actions: <Widget>[
                                  ElevatedButton(
                                      onPressed: () {
                                        saveEncrypted();
                                        Navigator.pop(context);
                                      },
                                      child: Text(ok)),
                                  ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          cleanData();
                                          _departureCity.text = "";
                                          _destinationCity.text = "";
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text(cancel))
                                ],
                              ));
                    } else {
                      showSnackBar(pleaseFillOutEntireForm);
                    }
                  },
                ),
                ElevatedButton(
                  child: Text(cancel),
                  onPressed: () {
                    setState(() {
                      _showAddFlight = false;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text(previous),
                  onPressed: () async {
                    loadEncrypted();
                  },
                ),
              ])
            ],
          )
        ],
      );
    }

    Widget FlightList() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  departureTime,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  departureCity,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, rowNum) {
                  // Alternate background colors for rows
                  Color backgroundColor =
                      rowNum % 2 == 0 ? Colors.grey.shade200 : Colors.white;

                  return GestureDetector(
                    child: Container(
                      color: backgroundColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
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
                    ),
                    onTap: () {
                      setState(() {
                        selectedItem = flights[rowNum];
                      });
                    },
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text(addNewFlight),
                onPressed: () async {
                  setState(() {
                    _departureTime = null;
                    _arrivalTime = null;
                    selectedAirplane = null;
                    _showAddFlight = false;
                  });
                  EncryptedSharedPreferences prefs =
                      EncryptedSharedPreferences();
                  final encryptedResult = await prefs.getInstance();
                  var departureCity =
                      encryptedResult.getString("departureCity");
                  var destinationCity =
                      encryptedResult.getString("destinationCity");

                  if (departureCity!.isNotEmpty ||
                      destinationCity!.isNotEmpty) {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(loadSavedInfo),
                        content: Text(wouldYouLikeToLoadSavedData),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              if (destinationCity != null) {
                                _destinationCity.text = destinationCity;
                              }
                              if (departureCity != null) {
                                _departureCity.text = departureCity;
                              }
                              Navigator.pop(context);
                            },
                            child: Text(ok),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _departureCity.text = '';
                              _destinationCity.text = '';
                              showSnackBar(pressPreviousToLoadSavedData);
                              Navigator.pop(context);
                            },
                            child: Text(cancel),
                          ),
                        ],
                      ),
                    );
                    setState(() {
                      _showAddFlight = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

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
          backgroundColor: Colors.greenAccent,
          title: Text(flightList),
        ),
        body: Center(child: display),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.flight),
              label: 'Add FLight',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: 'Update/Delete',
            ),
          ],
          onTap: (buttonIndex) {
            if (buttonIndex == 0) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(howToAddNewFlight),
                  content: Text(pressAddNewFlightButton),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(ok),
                    ),
                  ],
                ),
              );
            }
            if (buttonIndex == 1) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text(updateDelete),
                  content: Text(clickOnRecordToModify),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(ok),
                    ),
                  ],
                ),
              );
            }
          },
        ));
  }
}
