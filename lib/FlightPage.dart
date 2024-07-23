import 'package:flight_reservations/Airplane.dart';
import 'package:flight_reservations/AirplaneDAO.dart';
import 'package:flutter/material.dart';

import 'DBConnection.dart';
import 'Flight.dart';
import 'FlightDAO.dart';
import 'database.dart';

class FlightPage extends StatefulWidget {
  @override
  State<FlightPage> createState() => ToDoState();
}

class ToDoState extends State<FlightPage> {
  late TextEditingController _departureCity;
  late TextEditingController _destinationCity;
  late TextEditingController _departureTime;
  late TextEditingController _arrivalTime;
  late FlightDAO flightDAO;
  late AirplaneDAO airplaneDAO;
  late List<Airplane> planeList = [];
  Airplane? selectedAirplane;
  // List<String> items =  ["Add your to do items here, long press to delete the item"] ;
  // List<String> items = [];

  late var selectedItem = null;
  late List<Flight> flights = [];
  @override
  void initState() {
    super.initState();
    _departureCity = TextEditingController();
    _destinationCity = TextEditingController();
    _departureTime = TextEditingController();
    _arrivalTime = TextEditingController();

    load();
  }

  @override
  void dispose() {
    _departureCity.dispose();
    _destinationCity.dispose();
    _departureTime.dispose();
    _arrivalTime.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final database = await $FloorAppDatabase
        .databaseBuilder('FlightReservations.db')
        .build();

    flightDAO = database.flightDAO;
    airplaneDAO = database.airplaneDAO;

    flights = await flightDAO.selectAllFlight();
    planeList = await airplaneDAO.selectAllAirplanes();
    // items.clear();
    // for(int i = 0; i < todos.length; i++ ){
    //   items.add(todos[i].name);
    //   ToDoItem.ID = i +1;
    // }
    setState(() {});
    // ToDoItem.ID = todos.length;
  }

  Future<void> insertData() async {
    // if( await toDoItemDAO.findAllToDoItem() != null){
    //   int? maxID = await toDoItemDAO.getMaxId();
    //   newID = maxID ?? 0;
    // }
    if (selectedAirplane != null) {
      final flight = Flight(
          null,
          _departureCity.value.text,
          _destinationCity.value.text,
          _departureTime.value.text,
          _arrivalTime.value.text,
          selectedAirplane!.id??0);
      await flightDAO.insertFlight(flight);
      load();
    }
  }

  Future<void> deleteData(Flight flight) async {
    await flightDAO.removeFlight(flight);
    load();
  }

  Future<void> updateData(Flight flight) async {
    await flightDAO.updateFlight(flight);
    await load();
  }

  Widget DetailsPage() {
    if (selectedItem != null) {
      //Show some layout to represent the object's variables
      return Column(
        children: [
          Text(selectedItem.id.toString()),
          Text(selectedItem.name),
          ElevatedButton(
              child: Text("Delete"),
              onPressed: () {
                setState(() {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: const Text('Delete the Flight'),
                            content: const Text(
                                'Do you sure you want to delete the item'),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    // setState(() {
                                    //   items.removeAt(rowNum);
                                    // });
                                    deleteData(selectedItem);
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
              })
        ],
      );
    }
    return Column(children: [
      Text("no item selected"),
    ]);
  }

  Widget FlightList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: TextField(controller: _departureCity),
          ),
          Expanded(
            child: TextField(controller: _destinationCity),
          ),
          Expanded(
            child: TextField(controller: _departureTime),
          ),
          Expanded(
            child: TextField(controller: _arrivalTime),
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
              child: Text("add item"),
              onPressed: () {
                insertData();
                setState(() {
                  // items.add(_addList.value.text);

                  _departureCity.text = "";
                  _destinationCity.text = "";
                  _departureTime.text = "";
                  _arrivalTime.text = "";

                });
              })
        ]),
        Expanded(
            child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, rowNum) {
                  return GestureDetector(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${rowNum + 1}', textAlign: TextAlign.left),
                            Text(flights[rowNum].arrivalTime, textAlign: TextAlign.right)
                          ]),
                      onTap: () {
                        setState(() {
                          selectedItem = flights[rowNum];
                        });

                        // if(items.length == 1){
                        //   SnackBar snackBar = SnackBar( content: Text('There are no items in the list'),
                        //       action:SnackBarAction( label:'Hide', onPressed: () {
                        //       } ));
                        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // }else if(rowNum == 0 ){
                        //   SnackBar snackBar = SnackBar( content: Text('You cannot delete this one'),
                        //       action:SnackBarAction( label:'Hide', onPressed: () {
                        //       } ));
                        //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        //   }else{
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
    Widget display = list;
    if ((width > height) && (width > 720)) {
      display = Row(children: [
        Expanded(
          flex: 1, // takes  a/(a+b)  of available width
          child: list,
        ),
        Expanded(
          flex: 3, // takes b(a+b) of available width
          child: DetailsPage(),
        ),
      ]);
    } else {
      if (selectedItem == null) {
        display = FlightList(); // reuse the code from the tablet Left side,
      } else {
        display = DetailsPage(); //reuse the code from the tablet Right side
      }
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Flight List"),
      ),
      body: Center(child: display),
    ); // //create a layout for this page using Column, Row, Stack() etc
  }
}
