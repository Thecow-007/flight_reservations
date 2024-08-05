import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'AirplaneDAO.dart';
import 'AppLocalizations.dart';
import 'database.dart';
import 'Airplane.dart';

/// The [AirplanePage] widget provides a user interface for managing airplanes.
/// It allows users to view a list of airplanes, add new airplanes,
/// view details of an airplane, update existing airplanes, and delete airplanes.
class AirplanePage extends StatefulWidget {
  /// Callback function to set the locale of the app
  final void Function(Locale locale) setLocale;
  /// Creates an [AirplanePage] widget.
  const AirplanePage({super.key, required this.setLocale});

  @override
  State<AirplanePage> createState() => _AirplanePageState();
}

class _AirplanePageState extends State<AirplanePage> {
  /// List of all airplanes in the database.
  List<Airplane> allItems = [];
  /// Data access object for airplanes.
  late AirplaneDAO DAO;
  /// Flag to indicate whether the add page is requested.
  bool addPageRequest = false;
  /// The currently selected airplane.
  Airplane? selectedItem;
  /// Controller for the airplane name text field.
  final TextEditingController nameController = TextEditingController();
  /// Controller for the number of passengers text field.
  final TextEditingController numOfPassengersController = TextEditingController();
  /// Controller for the max speed text field.
  final TextEditingController maxSpeedController = TextEditingController();
  /// Controller for the range text field.
  final TextEditingController rangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  /// Loads the airplane database and updates the list of airplanes.
  /// Initializes the database connection, retrieves all airplanes from the
  /// database, updates the `allItems` list, and rebuilds the widget tree
  /// to reflect the changes.
  Future<void> loadDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('FlightReservations.db').build();
    DAO = database.airplaneDAO;
    allItems = await DAO.selectAllAirplanes();
    setState(() {});
  }

  /// Adds a new airplane to the database.
  /// Creates a new [Airplane] object using the values from the input
  /// controllers, inserts it into the database, saves the data using
  /// EncryptedSharedPreferences, clears the input fields, reloads the
  /// airplane list, and displays a success message.
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
        content: Text(AppLocalizations.of(context)?.translate("airplane_added") ?? "Airplane has been added"),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Deletes an airplane from the database.
  /// Takes an [Airplane] object as input and attempts to delete it
  /// from the database. If successful, reloads the airplane list,
  /// clears the selected item, and displays a success message.
  /// If an error occurs (due to constraints), shows an error message.
  Future<void> deleteItem(Airplane item) async {
    try {
      await DAO.removeAirplane(item);
      loadDatabase();
      setState(() {
        selectedItem = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate("airplane_deleted") ?? "Airplane has been deleted"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate("failed_to_delete_airplane") ?? "Failed to delete airplane. Airplanes must finish all flights before being removed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Updates an existing airplane in the database.
  /// Takes an [Airplane] object as input and updates its corresponding
  /// entry in the database. After updating, reloads the airplane list
  /// and displays a success message.
  Future<void> updateItem(Airplane item) async {
    await DAO.updateAirplane(item);
    loadDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.translate("airplane_updated") ?? "Airplane has been updated"),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Validates input fields and adds a new airplane.
  /// Checks if all required fields are filled. If so, proceeds to add
  /// a new airplane with the entered details. If any field is empty,
  /// displays an error message.
  void validateAndAddItem() {
    if (nameController.text.isEmpty ||
        numOfPassengersController.text.isEmpty ||
        maxSpeedController.text.isEmpty ||
        rangeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate("all_fields_required") ?? "All fields must be filled"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      addItem();
    }
  }

  /// Validates input fields and updates the selected airplane.
  /// Checks if all required fields are filled. If so, updates the selected
  /// airplane with the entered values and clears the selection. If any
  /// field is empty, displays an error message.
  void validateAndUpdate() {
    if (nameController.text.isEmpty ||
        numOfPassengersController.text.isEmpty ||
        maxSpeedController.text.isEmpty ||
        rangeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate("all_fields_required") ?? "All fields must be filled"),
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
  /// Builds the page for adding a new airplane.
  /// Provides text fields for entering airplane details (name, number of passengers,
  /// max speed, range). Includes buttons to add the airplane, copy details from
  /// the last added airplane, and return to the airplane list.
  Widget addPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)?.translate("add_airplane") ?? "Add an Airplane",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)?.translate("enter_name") ?? "Enter Name",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numOfPassengersController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)?.translate("enter_num_of_passengers") ?? "Enter Number of Passengers",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxSpeedController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)?.translate("enter_max_speed") ?? "Enter Max Speed",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rangeController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)?.translate("enter_range") ?? "Enter Range",
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
                      title: Text(AppLocalizations.of(context)?.translate("add_airplane_dialog_title") ?? "Add this Airplane"),
                      content: Text(AppLocalizations.of(context)?.translate("add_airplane_dialog_content") ?? "Are you sure you want to add this airplane?"),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            validateAndAddItem();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)?.translate("Yes") ?? "Yes"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)?.translate("No") ?? "No"),
                        ),
                      ],
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)?.translate("add_airplane_button") ?? "Add Airplane"),
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
                  child: Text(AppLocalizations.of(context)?.translate("copy_last_airplane_button") ?? "Copy Last Airplane"),
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
                  child: Text(AppLocalizations.of(context)?.translate("back_to_list_button") ?? "Back to List"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of airplanes.
  /// Displays a scrollable list of airplane cards, each showing basic
  /// information about an airplane. Tapping a card selects the airplane
  /// for viewing or editing details. Also includes a button to add a new airplane.
  Widget airplaneList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)?.translate("airplane_list") ?? "Airplane List",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: Text(AppLocalizations.of(context)?.translate("add_airplane_button") ?? "Add Airplane"),
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
                          '${AppLocalizations.of(context)?.translate('Number_of_passengers') ?? 'Number of Passengers'}: ${airplane.numberOfPassengers}\n ${AppLocalizations.of(context)?.translate('Max_speed') ?? 'Max Speed'}: ${airplane.maxSpeed}\n ${AppLocalizations.of(context)?.translate('Range') ?? 'Range'}: ${airplane.range}',
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
  /// Builds the details page for the selected airplane.
  /// If an airplane is selected, displays its details in editable text fields
  /// and provides buttons to update or delete the airplane.
  /// If no airplane is selected, displays a message indicating so.
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
              Text(
                AppLocalizations.of(context)?.translate("update_airplane") ?? "Update Airplane",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.translate("Name") ?? "Name",
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
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.translate("Number_of_passengers") ?? "Number of Passengers",
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
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.translate("Max_speed") ?? "Max Speed",
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
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.translate("Range") ?? "Range",
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
                          title: Text(AppLocalizations.of(context)?.translate("update_airplane_dialog_title") ?? "Update this Airplane"),
                          content: Text(AppLocalizations.of(context)?.translate("update_airplane_dialog_content") ?? "Are you sure you want to update this airplane?"
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                validateAndUpdate();
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)?.translate("Yes") ?? "Yes"
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)?.translate("No") ?? "No"
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)?.translate("update_button") ?? "Update"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)?.translate("delete_airplane_dialog_title") ?? "Delete this Airplane"),
                          content: Text(AppLocalizations.of(context)?.translate("delete_airplane_dialog_content") ?? "Are you sure you want to delete this airplane?"),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                deleteItem(selectedItem!);
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)?.translate("Yes") ?? "Yes"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)?.translate("No") ?? "No"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)?.translate("delete_button") ?? "Delete"),
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
                    child: Text(AppLocalizations.of(context)?.translate("go_back_button") ?? "Go Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Center(child: Text(AppLocalizations.of(context)?.translate("no_airplane_selected") ?? "No airplane is selected"));
  }

  /// Builds the UI for the AirplanePage.
  /// Displays either the airplane list, the add airplane page, or the airplane details page
  /// depending on the screen size and user interaction.
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
        title: Text(AppLocalizations.of(context)?.translate("app_bar_title") ?? "Airplane Management"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(child: display),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: AppLocalizations.of(context)?.translate("how_to_add_airplanes") ?? "How to add Airplanes",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.update),
            label: AppLocalizations.of(context)?.translate("how_to_update_delete_airplanes") ?? "How to Update/Delete Airplanes",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.language),
            label: AppLocalizations.of(context)?.translate("change_language") ?? "Change Language",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.translate("return_home") ?? "Return Home",
          ),
        ],
        onTap: (buttonIndex) {
          if (buttonIndex == 0) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(AppLocalizations.of(context)?.translate("how_to_add_airplanes") ?? "How to add Airplanes"),
                content: Text(AppLocalizations.of(context)?.translate("how_to_add_airplanes_content") ?? "Press the 'Add Airplane' button above the list, write your data into the textfields, then click 'Add Airplane'."),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)?.translate("Ok") ?? "Ok"),
                  ),
                ],
              ),
            );
          }
          if (buttonIndex == 1) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(AppLocalizations.of(context)?.translate("how_to_update_delete_airplanes") ?? "How to Update or Delete an Airplane"),
                content: Text(AppLocalizations.of(context)?.translate("how_to_update_delete_airplanes_content") ?? "Click on the airplane you want to update/delete, edit the fields and click 'Update' or 'Delete'."),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)?.translate("Ok") ?? "Ok")),
                ],
              ),
            );
          }
          if (buttonIndex == 2) {
            Locale newLocale = Localizations.localeOf(context).languageCode == 'en'
                ? const Locale('zh')
                : const Locale('en');
            if (widget.setLocale != null) {
              widget.setLocale(newLocale);
            }
          }
          if (buttonIndex == 3) {
            Navigator.pop(context);
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.deepPurple,
        selectedLabelStyle: const TextStyle(color: Colors.deepPurple),
        unselectedLabelStyle: const TextStyle(color: Colors.deepPurple),
      ),
    );
  }
}