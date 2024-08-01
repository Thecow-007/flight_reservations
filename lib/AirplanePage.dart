import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'AirplaneDAO.dart';
import 'database.dart';
import 'Airplane.dart';

class AirplanePage extends StatefulWidget {
  const AirplanePage({super.key});

  @override
  State<AirplanePage> createState() => _AirplanePageState();
}

class _AirplanePageState extends State<AirplanePage> {
  List<Airplane> allItems = [];
  late AirplaneDAO DAO;
  bool addPageRequest = false;
  Airplane? selectedItem;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numOfPassengersController = TextEditingController();
  final TextEditingController maxSpeedController = TextEditingController();
  final TextEditingController rangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  Future<void> loadDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('FlightReservations.db').build();
    DAO = database.airplaneDAO;
    allItems = await DAO.selectAllAirplanes();
    setState(() {});
  }

  Future<void> addItem() async {
    final int nextId = (await DAO.selectAllAirplanes()).length + 1;
    Airplane airplane = Airplane(
      nextId,
      nameController.text,
      int.parse(numOfPassengersController.text),
      double.parse(maxSpeedController.text),
      double.parse(rangeController.text),
    );
    await DAO.insertAirplane(airplane);

    // Save data using EncryptedSharedPreferences
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedprefs = await prefs.getInstance();
    await encryptedprefs.setString('name', nameController.text);
    await encryptedprefs.setString('numOfPassengers', numOfPassengersController.text);
    await encryptedprefs.setString('maxSpeed', maxSpeedController.text);
    await encryptedprefs.setString('range', rangeController.text);

    setState(() {
      nameController.clear();
      numOfPassengersController.clear();
      maxSpeedController.clear();
      rangeController.clear();
    });

    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Airplane has been added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> deleteItem(Airplane item) async {
    try {
      await DAO.removeAirplane(item);
      loadDatabase();
      setState(() {
        selectedItem = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Airplane has been deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting item: $e'); // Debug line
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete airplane. Airplanes must finish all flights before being removed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateItem(Airplane item) async {
    await DAO.updateAirplane(item);
    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Airplane has been updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void validateAndAddItem() {
    if (nameController.text.isEmpty ||
        numOfPassengersController.text.isEmpty ||
        maxSpeedController.text.isEmpty ||
        rangeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All fields must be filled'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      addItem();
    }
  }

  void validateAndUpdate() {
    if (nameController.text.isEmpty ||
        numOfPassengersController.text.isEmpty ||
        maxSpeedController.text.isEmpty ||
        rangeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All fields must be filled'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (selectedItem != null) {
      final updatedItem = Airplane(
        selectedItem!.id,
        nameController.text,
        int.parse(numOfPassengersController.text),
        double.parse(maxSpeedController.text),
        double.parse(rangeController.text),
      );
      updateItem(updatedItem);
      setState(() {
        selectedItem = null;
      });
    }
  }

  Widget addPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Add an Airplane',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Name',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numOfPassengersController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Number of Passengers',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxSpeedController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Max Speed',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rangeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Range',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Add this Airplane'),
                      content: const Text('Are you sure you want to add this airplane?'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            validateAndAddItem();
                            Navigator.pop(context);
                          },
                          child: const Text('Yes'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Add Airplane'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
                    final encryptedprefs = await prefs.getInstance();
                    setState(() {
                      nameController.text = (encryptedprefs.getString('name')) ?? '';
                      numOfPassengersController.text = (encryptedprefs.getString('numOfPassengers')) ?? '';
                      maxSpeedController.text = (encryptedprefs.getString('maxSpeed')) ?? '';
                      rangeController.text = (encryptedprefs.getString('range')) ?? '';
                    });
                  },
                  child: const Text('Copy Last Airplane'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      addPageRequest = false; // Hide AddPage
                      if (MediaQuery.of(context).size.width > 1000) {
                        // Show the list and details side by side
                        selectedItem = null; // Ensure no item is selected
                      }
                    });
                  },
                  child: const Text('Back to List'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget airplaneList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Airplane List',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                nameController.clear();
                numOfPassengersController.clear();
                maxSpeedController.clear();
                rangeController.clear();
                selectedItem = null;
                addPageRequest = true; // Show AddPage
              });
            },
            child: const Text('Add Airplane'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final airplane = allItems[index];
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedItem = airplane;
                    }),
                    child: Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.deepPurpleAccent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          airplane.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Passengers: ${airplane.numberOfPassengers}\n'
                              'Speed: ${airplane.maxSpeed} km/h\n'
                              'Range: ${airplane.range} km',
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        isThreeLine: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailsPage() {
    if (selectedItem != null) {
      nameController.text = selectedItem!.name;
      numOfPassengersController.text = selectedItem!.numberOfPassengers.toString();
      maxSpeedController.text = selectedItem!.maxSpeed.toString();
      rangeController.text = selectedItem!.range.toString();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Airplane',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: (value) {
                  if (selectedItem != null) {
                    setState(() {
                      selectedItem = Airplane(
                        selectedItem!.id,
                        value,
                        selectedItem!.numberOfPassengers,
                        selectedItem!.maxSpeed,
                        selectedItem!.range,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numOfPassengersController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of Passengers',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: (value) {
                  if (selectedItem != null) {
                    setState(() {
                      selectedItem = Airplane(
                        selectedItem!.id,
                        selectedItem!.name,
                        int.tryParse(value) ?? selectedItem!.numberOfPassengers,
                        selectedItem!.maxSpeed,
                        selectedItem!.range,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: maxSpeedController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Max Speed',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: (value) {
                  if (selectedItem != null) {
                    setState(() {
                      selectedItem = Airplane(
                        selectedItem!.id,
                        selectedItem!.name,
                        selectedItem!.numberOfPassengers,
                        double.tryParse(value) ?? selectedItem!.maxSpeed,
                        selectedItem!.range,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rangeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Range',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onChanged: (value) {
                  if (selectedItem != null) {
                    setState(() {
                      selectedItem = Airplane(
                        selectedItem!.id,
                        selectedItem!.name,
                        selectedItem!.numberOfPassengers,
                        selectedItem!.maxSpeed,
                        double.tryParse(value) ?? selectedItem!.range,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // Use Row to align buttons horizontally
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Update this Airplane'),
                          content: const Text('Are you sure you want to update this airplane?'),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                validateAndUpdate();
                                Navigator.pop(context);
                              },
                              child: const Text("Yes"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Update"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete this Airplane'),
                          content: const Text('Are you sure you want to delete this airplane?'),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                deleteItem(selectedItem!);
                                Navigator.pop(context);
                              },
                              child: const Text("Yes"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Delete"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedItem = null;
                        nameController.clear();
                        numOfPassengersController.clear();
                        maxSpeedController.clear();
                        rangeController.clear();
                      });
                    },
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const Center(child: Text("No item selected"));
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    Widget menu = airplaneList();
    Widget display = menu;

    if (addPageRequest) {
      display = addPage();
    } else if (width > 1000) {
      display = Row(
        children: [
          Expanded(
            flex: 3,
            child: menu,
          ),
          Expanded(
            flex: 1,
            child: detailsPage(),
          ),
        ],
      );
    } else if (selectedItem != null) {
      display = detailsPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airplane Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(child: display),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'How to add Airplanes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'How to Update/Delete Airplanes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Return Home',
          ),
        ],
        onTap: (buttonIndex) {
          if (buttonIndex == 0) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('How to Add to Airplane List'),
                content: const Text('Press the "Add Airplane" button above the list, write your data into the textfields, then click "Add Airplane".'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (buttonIndex == 1) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('How to Update or Delete an Airplane'),
                content: const Text('Click on the airplane you want to update/delete, edit the fields and click "Update" or "Delete".'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (buttonIndex == 2) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
