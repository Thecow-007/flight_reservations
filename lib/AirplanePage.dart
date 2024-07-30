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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numOfPassengersController = TextEditingController();
  final TextEditingController maxSpeedController = TextEditingController();
  final TextEditingController rangeController = TextEditingController();

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
  }

  Future<void> deleteItem(Airplane item) async {
    await DAO.removeAirplane(item);
    loadDatabase();
  }

  Future<void> updateItem(Airplane item) async {
    await DAO.updateAirplane(item);
    loadDatabase();
  }

  Widget AirplaneList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Airplane List', style: TextStyle(fontSize: 30)),
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
        Row(
          children: [
            ElevatedButton(
              onPressed: addItem,
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
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: numOfPassengersController,
            decoration: InputDecoration(labelText: '# of Passengers'),
          ),
          TextField(
            controller: maxSpeedController,
            decoration: InputDecoration(labelText: 'Max Speed'),
          ),
          TextField(
            controller: rangeController,
            decoration: InputDecoration(labelText: 'Range'),
          ),
          ElevatedButton(
            child: Text("Update"),
            onPressed: () {
              if (selectedItem != null) {
                final updatedItem = Airplane(
                  selectedItem!.id,
                  nameController.value.text,
                  int.parse(numOfPassengersController.text),
                  double.parse(maxSpeedController.text),
                  double.parse(rangeController.text),
                );
                updateItem(updatedItem);
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
                      title: const Text('Delete this Airplane'),
                      content: const Text('Are you sure you want to delete this item?'),
                      actions: <Widget>[
                        ElevatedButton(
                            onPressed: () {
                              deleteItem(selectedItem!);
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
          ),
          ElevatedButton(
            child: Text("Go Back"),
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
    return Column(children: [
      Text("No item selected"),
    ]);
  }

  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      // Reset selectedItem when switching tabs
      selectedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    Widget menu = AirplaneList();
    Widget display = menu;

    if ((width > height) && (width > 720)) {
      display = Row(
        children: [
          Expanded(
            flex: 1,
            child: menu,
          ),
          Expanded(
            flex: 3,
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
