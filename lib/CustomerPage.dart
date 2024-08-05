import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart'; // For encrypted shared preferences
import 'package:flutter_localizations/flutter_localizations.dart'; // For localization
import 'AppLocalizations.dart';
import 'Customer.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// This widget sets up the [MaterialApp] and manages locale changes
/// using the [setLocal] method.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  /// Changes the locale of the application.
  ///
  /// This method is used to update the locale of the app at runtime.
  ///
  /// [context] The [BuildContext] to find the state of the application.
  /// [locale] The new [Locale] to set.
  static void setLocal(BuildContext context, Locale locale){
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  /// Sets the locale of the application.
  ///
  /// Updates the state to change the locale.
  ///
  /// [locale] The new [Locale] to set.
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
      home: CustomerPage(
        setLocale: setLocale,
      ),
    );
  }
}

/// A page that displays a list of customers and allows the user
/// to add, edit, and manage customer records.
///
/// It also handles localization and interacts with encrypted shared preferences
/// for storing temporary data.
class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key, required this.setLocale});
  final String title = "Customer Page";
  final void Function(Locale locale) setLocale;

  @override
  State<CustomerPage> createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  List<Customer> customers = [];
  Customer? selectedCustomer;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  DateTime? birthday;

  // Translation variables
  late String customerTitle;
  late String customersText;
  late String addCustomerText;
  late String firstNameText;
  late String lastNameText;
  late String addressText;
  late String birthdayText;
  late String copyText;
  late String editCustomerText;
  late String updateText;
  late String deleteText;
  late String recordUpdatedText;

  var CustomerDAO;
  final _encryptedPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    loadDatabase();
    loadSavedData();
  }

  @override
  void dispose() {
    CustomerDAO.removeAllCustomer();
    CustomerDAO.insertCustomers(customers);
    saveData();
    super.dispose();
  }

  /// Loads the customer data from the database.
  ///
  /// This method asynchronously builds the database and retrieves
  /// all customer records.
  void loadDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('FlightReservations.db').build();
    CustomerDAO = database.customerDAO;
    customers = await CustomerDAO.selectAllCustomer();
    setState(() {});
  }

  /// Adds a new customer to the list.
  ///
  /// The method checks if all required fields are filled and then adds
  /// a new [Customer] to the list. The fields are then cleared.
  void addCustomer() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        birthday == null) {
      return;
    }
    setState(() {
      customers.add(Customer(
        null,
        firstNameController.text,
        lastNameController.text,
        addressController.text,
        DateFormat('yyyy-MM-dd').format(birthday!),
      ));
      clearFields();
    });
  }

  /// Clears all input fields and resets the birthday.
  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    addressController.clear();
    birthday = null;
  }

  /// Copies the details of the selected customer to the input fields.
  void copyCustomer() {
    if (selectedCustomer != null) {
      firstNameController.text = selectedCustomer!.firstname;
      lastNameController.text = selectedCustomer!.lastname;
      addressController.text = selectedCustomer!.address;
      birthday = DateFormat('yyyy-MM-dd').parse(selectedCustomer!.birthday);
    }
  }

  /// Saves data to encrypted shared preferences.
  ///
  /// The data includes the first name, last name, address, and birthday.
  void saveData() async {
    await _encryptedPrefs.setString('firstName', firstNameController.text);
    await _encryptedPrefs.setString('lastName', lastNameController.text);
    await _encryptedPrefs.setString('address', addressController.text);
    if (birthday != null) {
      await _encryptedPrefs.setString('birthday', birthday!.toIso8601String());
    }
  }

  /// Loads saved data from encrypted shared preferences.
  ///
  /// Retrieves the first name, last name, address, and birthday from preferences
  /// and updates the input fields.
  void loadSavedData() async {
    String? firstName = await _encryptedPrefs.getString('firstName');
    String? lastName = await _encryptedPrefs.getString('lastName');
    String? address = await _encryptedPrefs.getString('address');
    String? birthdayString = await _encryptedPrefs.getString('birthday');

    setState(() {
      if (firstName != null) firstNameController.text = firstName;
      if (lastName != null) lastNameController.text = lastName;
      if (address != null) addressController.text = address;
      if (birthdayString != null) birthday = DateTime.parse(birthdayString);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize translation variables
    customerTitle = AppLocalizations.of(context)?.translate('Customer Title') ?? 'Customer List';
    customersText = AppLocalizations.of(context)?.translate('Customers') ?? "Customers";
    addCustomerText = AppLocalizations.of(context)?.translate('Add Customer') ?? 'Add Customer';
    firstNameText = AppLocalizations.of(context)?.translate('First Name') ?? 'First Name';
    lastNameText = AppLocalizations.of(context)?.translate('Last Name') ?? 'Last Name';
    addressText = AppLocalizations.of(context)?.translate('Address') ?? 'Address';
    birthdayText = AppLocalizations.of(context)?.translate('Birthday') ?? 'Birthday';
    copyText = AppLocalizations.of(context)?.translate('Copy') ?? 'Copy';
    editCustomerText = AppLocalizations.of(context)?.translate('Edit Customer') ?? 'Edit Customer';
    updateText = AppLocalizations.of(context)?.translate('Update') ?? 'Update';
    deleteText = AppLocalizations.of(context)?.translate('Delete') ?? 'Delete';
    recordUpdatedText = AppLocalizations.of(context)?.translate('Record Successfully Updated') ?? 'Record successfully updated';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(customerTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Locale newLocale = Localizations.localeOf(context).languageCode == 'en'
                  ? Locale('zh', 'CN')
                  : Locale('en');
              widget.setLocale(newLocale);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    customersText,
                    style: TextStyle(
                        decoration: TextDecoration.underline, fontSize: 24),
                  ),
                ],
              ),

              // Customer Entry Row
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: addCustomer,
                    child: Text(addCustomerText),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(hintText: firstNameText),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(hintText: lastNameText),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: addressController,
                      decoration: InputDecoration(hintText: addressText),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));
                      if (picked != null && picked != birthday) {
                        setState(() {
                          birthday = picked;
                        });
                      }
                    },
                    child: Text(birthdayText),
                  ),
                  ElevatedButton(
                    onPressed: copyCustomer,
                    child: Text(copyText),
                  ),
                ],
              ),
              // Customer List Widget
              CustomerList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a list of customers.
  ///
  /// Displays each customer in a [ListTile] and allows interaction with
  /// each item, including long press to edit or delete.
  Widget CustomerList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            selectedCustomer = customers[index];
          },
          onLongPress: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController firstNameController =
                  TextEditingController(text: customers[index].firstname);
                  final TextEditingController lastNameController =
                  TextEditingController(text: customers[index].lastname);
                  final TextEditingController addressController =
                  TextEditingController(text: customers[index].address);
                  DateTime? birthday = DateFormat('yyyy-MM-dd')
                      .parse(customers[index].birthday);

                  return AlertDialog(
                    title: Text(editCustomerText),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(hintText: firstNameText),
                        ),
                        TextField(
                          controller:                          lastNameController,
                          decoration: InputDecoration(hintText: lastNameText),
                        ),
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(hintText: addressText),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: birthday ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            if (picked != null && picked != birthday) {
                              setState(() {
                                birthday = picked;
                              });
                            }
                          },
                          child: Text(birthdayText),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            customers[index] = Customer(
                              null,
                              firstNameController.text,
                              lastNameController.text,
                              addressController.text,
                              DateFormat('yyyy-MM-dd').format(birthday!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(recordUpdatedText)),
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(updateText),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            customers.removeAt(index);
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(deleteText),
                      ),
                    ],
                  );
                });
          },
          child: ListTile(
            title: Text(
              '${customers[index].firstname} ${customers[index].lastname}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customers[index].address,
                    style: TextStyle(decoration: TextDecoration.underline)),
                Text(customers[index].birthday),
              ],
            ),
          ),
        );
      },
    );
  }
}