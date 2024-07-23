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
    Airplane todo = Airplane(nextId, nameController.text, numOfPassengersController.text as int,
                    maxSpeedController.text as double, rangeController.text as double);
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

  Widget AirplaneList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Airplane List', style: TextStyle(fontSize: 30)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: addItem,
              child: const Text("Add Airplane"),
            ),
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter name",
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: numOfPassengersController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter number of passengers",
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: maxSpeedController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter max speed",
                ),
              ),
            ),
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
                    Text(allItems[index].numberOfPassengers as String),
                    Text(allItems[index].maxSpeed as String),
                    Text(allItems[index].range as String),
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
      int databaseID = selectedItemIndex + 1;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ' + selectedItem.content),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ID: ' + databaseID.toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await deleteItem(selectedItem);
                  setState(() {
                    selectedItem = null;
                  });
                },
                child: Text('Delete'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedItem = null;
                  });
                },
                child: Text('Back'),
              )
            ],
          )
        ],
      );
    }
    return Column(
      children: [
        Text('Nothing is selected'),
      ],
    );
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
