import 'package:floor/floor.dart';

import 'Flight.dart';

@dao
abstract class FlightDAO {
  @Query("Select * From Flight")
  Future<List<Flight>> selectAllFlight();

  @Query("Select * From Flight Where id = :id")
  Stream<Flight?> selectFlight(int id);

  @insert
  Future<int> insertFlight(Flight flight);

  @delete
  Future<int> removeFlight(Flight flight);

  @Query("Delete * From Flight")
  Future<int?> removeAllToDo();

  @update
  Future<void> updateFlight(Flight flight);
}