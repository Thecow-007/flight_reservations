import 'package:floor/floor.dart';

import 'Airplane.dart';

@dao
abstract class AirplaneDAO {
  @Query("Select * From Airplane")
  Future<List<Airplane>> selectAllAirplanes();

  @Query("Select * From Airplane Where id = :id")
  Stream<Airplane?> selectAirplane(int id);

  @insert
  Future<int> insertAirplane(Airplane airplane);

  @delete
  Future<int> removeToDo(Airplane airplane);

  @Query("Delete * From Airplane")
  Future<int?> removeAllAirplane();
}