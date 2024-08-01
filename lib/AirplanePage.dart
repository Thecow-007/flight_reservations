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
    Airplane todo = Airplane(
      nextId,
      nameController.text,
      int.parse(numOfPassengersController.text),
      double.parse(maxSpeedController.text),
      double.parse(rangeController.text),
    );
    await DAO.insertAirplane(todo);

    // Save data using EncryptedSharedPreferences
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    final encryptedprefs = await prefs.getInstance();
    await encryptedprefs.setString('name', nameController.text);
    await encryptedprefs.setString('numOfPassengers', numOfPassengersController.text);
    await encryptedprefs.setString('maxSpeed', maxSpeedController.text);
    await encryptedprefs.setString('range', rangeController.text);

    setState(() {
      nameController.text = '';
      numOfPassengersController.text = '';
      maxSpeedController.text = '';
      rangeController.text = '';
    });

    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Airplane has been added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> deleteItem(Airplane item) async {
    await DAO.removeAirplane(item);
    loadDatabase();
    setState(() {
      selectedItem = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Airplane has been deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> updateItem(Airplane item) async {
    await DAO.updateAirplane(item);
    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Airplane has been updated'),
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
        const SnackBar(
          content: Text('All text fields must be filled'),
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
        const SnackBar(
          content: Text('All text fields must be filled'),
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
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Add an Airplane',
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter name",
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: numOfPassengersController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter number of passengers",
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: maxSpeedController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter max speed",
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: rangeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter range",
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: const Text("Add Airplane"),
                onPressed: () {
                  showDialog<String>(
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
              ),
              ElevatedButton(
                child: const Text("Copy Last Airplane"),
                onPressed: () async {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Copy Last Airplane'),
                      content: const Text('Are you sure you want to copy the last created airplane?'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
                            final encryptedprefs = await prefs.getInstance();
                            setState(() {
                              nameController.text = (encryptedprefs.getString('name')) ?? '';
                              numOfPassengersController.text = (encryptedprefs.getString('numOfPassengers')) ?? '';
                              maxSpeedController.text = (encryptedprefs.getString('maxSpeed')) ?? '';
                              rangeController.text = (encryptedprefs.getString('range')) ?? '';
                            });
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
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    addPageRequest = false; // Hide AddPage
                    if (MediaQuery.of(context).size.width > 720) {
                      // Show the list and details side by side
                      selectedItem = null; // Ensure no item is selected
                    }
                  });
                },
                child: const Text("Back to List"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget airplaneList() {
    return Column(
      children: <Widget>[
        const Text('Airplane List', style: TextStyle(fontSize: 30)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                nameController.text = '';
                numOfPassengersController.text = '';
                maxSpeedController.text = '';
                rangeController.text = '';
                selectedItem = null;
                addPageRequest = true; // Show AddPage
              });
            },
            child: const Text("Add Airplane"),
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedItem = allItems[index];
                  }),
                  child: ListTile(
                    title: Text(allItems[index].name),
                    subtitle: Text(
                      'Passengers: ${allItems[index].numberOfPassengers}, Speed: ${allItems[index].maxSpeed}, Range: ${allItems[index].range}',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget detailsPage() {
    if (selectedItem != null) {
      nameController.text = selectedItem!.name;
      numOfPassengersController.text = selectedItem!.numberOfPassengers.toString();
      maxSpeedController.text = selectedItem!.maxSpeed.toString();
      rangeController.text = selectedItem!.range.toString();

      return SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Update Airplane',
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: numOfPassengersController,
                decoration: const InputDecoration(labelText: '# of Passengers'),
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: maxSpeedController,
                decoration: const InputDecoration(labelText: 'Max Speed'),
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: rangeController,
                decoration: const InputDecoration(labelText: 'Range'),
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
            ),
            const SizedBox(height: 20),
            // Use Row to align buttons horizontally
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  child: const Text("Update"),
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
                ),
                ElevatedButton(
                  child: const Text("Delete"),
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
                ),
                ElevatedButton(
                  child: const Text("Go Back"),
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                      nameController.text = '';
                      numOfPassengersController.text = '';
                      maxSpeedController.text = '';
                      rangeController.text = '';
                    });
                  },
                ),
              ],
            ),
          ],
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
      // Display the list and details side by side if width > 720
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
      // Display details page if an item is selected and width <= 720
      display = detailsPage();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"),
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"),
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
