import 'package:floor/floor.dart';

@entity
class Customer{

  @PrimaryKey(autoGenerate: true)
  final int? id;

  String firstname;
  String lastname;
  String address;
  String birthday;

  Customer(this.id, this.firstname, this.lastname, this.address, this.birthday);

}
