import 'package:flutter/material.dart';
import 'database.dart';
import 'Airplane.dart';

void main() {
  runApp(const AirplanePage());
}

class AirplanePage extends StatelessWidget {
  const AirplanePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airplane List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Airplane List'),
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
  List<Airplane> allItems = [];
  var DAO;
  var selectedItem;
  var selectedItemIndex;
  bool addPageRequest = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numOfPassengersController = TextEditingController();
  final TextEditingController maxSpeedController = TextEditingController();
  final TextEditingController rangeController = TextEditingController();
  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();


  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  void loadDatabase() async {
    final database = await $FloorAppDatabase
        .databaseBuilder('FlightReservations.db')
        .build();
    DAO = database.airplaneDAO;
    allItems = await DAO.selectAllAirplanes();
    setState(() {});
  }

  Future<void> addItem() async {
    final int nextId = (await DAO.selectAllAirplanes()).length + 1;
    Airplane todo = Airplane(nextId, nameController.text, int.parse(numOfPassengersController.text),
                    double.parse(maxSpeedController.text), double.parse(rangeController.text));
    await DAO.insertAirplane(todo);
    setState(() {
      nameController.text = '';
      numOfPassengersController.text = '';
      maxSpeedController.text = '';
      rangeController.text = '';
    });
    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Airplane has been added'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> deleteItem(Airplane item) async {
    await DAO.removeAirplane(item);
    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Airplane has been deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> updateItem(Airplane item) async {
    await DAO.updateAirplane(item);
    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Airplane has been updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void validateAndAddItem() {
    // Check if any text fields are empty
    if (nameController.text.isEmpty ||
        numOfPassengersController.text.isEmpty ||
        maxSpeedController.text.isEmpty ||
        rangeController.text.isEmpty) {
      // Show Snackbar if any text field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All text fields must be filled'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Call addItem function if all text fields are filled
      addItem();
    }
  }

  void validateAndUpdate() {
    // Check if any text fields are empty
    if (nameController.text.isEmpty ||
        numOfPassengersController.text.isEmpty ||
        maxSpeedController.text.isEmpty ||
        rangeController.text.isEmpty) {
      // Show Snackbar if any text field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All text fields must be filled'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      if (selectedItem != null) {
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
  }

  Widget AddPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Add an Airplane',
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter name",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: numOfPassengersController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter number of passengers",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: maxSpeedController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter max speed",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: rangeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter range",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Add Airplane"),
              onPressed: () {
                setState(() {
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
                                setState(() {
                                  selectedItem = null;
                                });
                              },
                              child: const Text("Yes")),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"))
                        ],
                      ));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Back to List"),
        ),
      ],
    );
  }


  Widget AirplaneList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Airplane List', style: TextStyle(fontSize: 30)),
        Row(
          children: [
            ElevatedButton(
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
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => setState(() {
                  selectedItem = allItems[index];
                  selectedItemIndex = index;
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(allItems[index].name),
                    Text(allItems[index].numberOfPassengers.toString()),
                    Text(allItems[index].maxSpeed.toString()),
                    Text(allItems[index].range.toString()),
                  ],
                ),
              );
            },
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

      return Column(
        children: [
          const Text(
            'Update Airplane',
            style: TextStyle(fontSize: 30),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: numOfPassengersController,
            decoration: const InputDecoration(labelText: '# of Passengers'),
          ),
          TextField(
            controller: maxSpeedController,
            decoration: const InputDecoration(labelText: 'Max Speed'),
          ),
          TextField(
            controller: rangeController,
            decoration: const InputDecoration(labelText: 'Range'),
          ),
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () {
              setState(() {
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
                              setState(() {
                                selectedItem = null;
                              });
                            },
                            child: const Text("Yes")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No"))
                      ],
                    ));
              });
            },
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () {
              setState(() {
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
                              setState(() {
                                selectedItem = null;
                              });
                            },
                            child: const Text("Yes")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No"))
                      ],
                    ));
              });
            },
          ),
          ElevatedButton(
            child: const Text("Go Back"),
            onPressed: () {
              if (selectedItem != null) {
                setState(() {
                  selectedItem = null;
                  nameController.text = '';
                  numOfPassengersController.text = '';
                  maxSpeedController.text = '';
                  rangeController.text = '';
                });
              }
            },
          ),
        ],
      );
    }
    return const Column(children: [
      Text("No item selected"),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    Widget menu = AirplaneList();
    Widget display = menu;

    if (addPageRequest == true) {
      display = AddPage();
    } else if ((width > height) && (width > 720)) {
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
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(child: display),
    );
  }
}
