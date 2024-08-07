import 'package:floor/floor.dart';

import 'Customer.dart';

@dao
abstract class CustomerDAO {
  @Query("Select * From Customer")
  Future<List<Customer>> selectAllCustomer();

  @Query("Select * From Customer Where id = :id")
  Stream<Customer?> selectCustomer(int id);

  @insert
  Future<int> insertCustomer(Customer customer);

  @insert
  Future<List<int>> insertCustomers(List<Customer> customers);

  @delete
  Future<int> removeCustomer(Customer customer);

  @Query("Delete * From Customer")
  Future<int?> removeAllCustomer();
}