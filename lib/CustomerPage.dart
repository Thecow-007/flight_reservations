import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'Customer.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CustomerPage(title: 'Customer List'),
    );
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key, required this.title});
  final String title;

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

  var CustomerDAO;

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  @override
  void dispose() {
    CustomerDAO.removeAllCustomer();
    CustomerDAO.insertCustomers(customers);
  }

  void loadDatabase() async {
    final database = await $FloorAppDatabase
        .databaseBuilder('FlightReservations.db')
        .build();
    CustomerDAO = database.customerDAO;
    customers = await CustomerDAO.selectAllCustomer();
    setState(() {});
  }

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

  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    addressController.clear();
    birthday = null;
  }

  void copyCustomer() {
    if (selectedCustomer != null) {
      firstNameController.text = selectedCustomer!.firstname;
      lastNameController.text = selectedCustomer!.lastname;
      addressController.text = selectedCustomer!.address;
      birthday = DateFormat('yyyy-MM-dd').parse(selectedCustomer!.birthday);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Customers",
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
                    child: Text('Add Customer'),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(hintText: 'First Name'),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(hintText: 'Last Name'),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: addressController,
                      decoration: InputDecoration(hintText: 'Address'),
                    ),
                  ),
                  SizedBox(width: 10),
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
                    child: Text('Birthday'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: copyCustomer,
                    child: Text('Copy'),
                  ),
                ],
              ),
              // Customer List Widget
              Expanded(child: CustomerList()),
            ])));
  }

  Widget CustomerList() {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
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
                          TextEditingController(
                              text: customers[index].firstname);
                      final TextEditingController lastNameController =
                          TextEditingController(
                              text: customers[index].lastname);
                      final TextEditingController addressController =
                          TextEditingController(text: customers[index].address);
                      DateTime? birthday = DateFormat('yyyy-MM-dd')
                          .parse(customers[index].birthday);

                      return AlertDialog(
                        title: Text('Edit Customer'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: firstNameController,
                              decoration:
                                  InputDecoration(hintText: 'First Name'),
                            ),
                            TextField(
                              controller: lastNameController,
                              decoration:
                                  InputDecoration(hintText: 'Last Name'),
                            ),
                            TextField(
                              controller: addressController,
                              decoration: InputDecoration(hintText: 'Address'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: birthday ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100));
                                if (picked != null && picked != birthday) {
                                  birthday = picked;
                                }
                              },
                              child: Text('Birthday'),
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
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Update'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                customers.removeAt(index);
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
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
        ))
      ],
    );
  }
}
