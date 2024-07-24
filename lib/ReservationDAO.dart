import 'package:floor/floor.dart';

import 'Reservation.dart';

@dao
abstract class ReservationDAO {
  @Query("Select * From Reservation")
  Future<List<Reservation>> selectAllReservation();

  @Query("Select * From Reservation Where id = :id")
  Stream<Reservation?> selectReservation(int id);

  @insert
  Future<int> insertReservation(Reservation reservation);

  @delete
  Future<int> removeReservation(Reservation reservation);

  @Query("Delete * From Reservation")
  Future<int?> removeAllReservation();

  @Query("DELETE FROM Reservation WHERE flightId = :flightId")
  Future<void> deleteReservationByFlightId(int flightId);

  @Query("DELETE FROM Reservation WHERE customerId = :customerId")
  Future<void> deleteReservationByCustomerId(int customerId);

}