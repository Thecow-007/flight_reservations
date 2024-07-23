// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AirplaneDAO? _airplaneDAOInstance;

  CustomerDAO? _customerDAOInstance;

  FlightDAO? _flightDAOInstance;

  ReservationDAO? _reservationDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Airplane` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `numberOfPassengers` INTEGER NOT NULL, `maxSpeed` REAL NOT NULL, `range` REAL NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `firstname` TEXT NOT NULL, `lastname` TEXT NOT NULL, `address` TEXT NOT NULL, `birthday` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flight` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `departureCity` TEXT NOT NULL, `destinationCity` TEXT NOT NULL, `departureTime` INTEGER NOT NULL, `arrivalTime` INTEGER NOT NULL, `airplaneId` INTEGER NOT NULL, FOREIGN KEY (`airplaneId`) REFERENCES `Airplane` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` INTEGER NOT NULL, `flightId` INTEGER NOT NULL, `date` TEXT NOT NULL, FOREIGN KEY (`customerId`) REFERENCES `Customer` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`flightId`) REFERENCES `Flight` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AirplaneDAO get airplaneDAO {
    return _airplaneDAOInstance ??= _$AirplaneDAO(database, changeListener);
  }

  @override
  CustomerDAO get customerDAO {
    return _customerDAOInstance ??= _$CustomerDAO(database, changeListener);
  }

  @override
  FlightDAO get flightDAO {
    return _flightDAOInstance ??= _$FlightDAO(database, changeListener);
  }

  @override
  ReservationDAO get reservationDAO {
    return _reservationDAOInstance ??=
        _$ReservationDAO(database, changeListener);
  }
}

class _$AirplaneDAO extends AirplaneDAO {
  _$AirplaneDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'Airplane',
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'numberOfPassengers': item.numberOfPassengers,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                },
            changeListener),
        _airplaneDeletionAdapter = DeletionAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'numberOfPassengers': item.numberOfPassengers,
                  'maxSpeed': item.maxSpeed,
                  'range': item.range
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final DeletionAdapter<Airplane> _airplaneDeletionAdapter;

  @override
  Future<List<Airplane>> selectAllAirplanes() async {
    return _queryAdapter.queryList('Select * From Airplane',
        mapper: (Map<String, Object?> row) => Airplane(
            row['id'] as int?,
            row['name'] as String,
            row['numberOfPassengers'] as int,
            row['maxSpeed'] as double,
            row['range'] as double));
  }

  @override
  Stream<Airplane?> selectAirplane(int id) {
    return _queryAdapter.queryStream('Select * From Airplane Where id = ?1',
        mapper: (Map<String, Object?> row) => Airplane(
            row['id'] as int?,
            row['name'] as String,
            row['numberOfPassengers'] as int,
            row['maxSpeed'] as double,
            row['range'] as double),
        arguments: [id],
        queryableName: 'Airplane',
        isView: false);
  }

  @override
  Future<int?> removeAllAirplane() async {
    return _queryAdapter.query('Delete * From Airplane',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertAirplane(Airplane airplane) {
    return _airplaneInsertionAdapter.insertAndReturnId(
        airplane, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeAirplane(Airplane airplane) {
    return _airplaneDeletionAdapter.deleteAndReturnChangedRows(airplane);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstname': item.firstname,
                  'lastname': item.lastname,
                  'address': item.address,
                  'birthday': item.birthday
                },
            changeListener),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstname': item.firstname,
                  'lastname': item.lastname,
                  'address': item.address,
                  'birthday': item.birthday
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> selectAllCustomer() async {
    return _queryAdapter.queryList('Select * From Customer',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int?,
            row['firstname'] as String,
            row['lastname'] as String,
            row['address'] as String,
            row['birthday'] as String));
  }

  @override
  Stream<Customer?> selectCustomer(int id) {
    return _queryAdapter.queryStream('Select * From Customer Where id = ?1',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int?,
            row['firstname'] as String,
            row['lastname'] as String,
            row['address'] as String,
            row['birthday'] as String),
        arguments: [id],
        queryableName: 'Customer',
        isView: false);
  }

  @override
  Future<int?> removeAllToDo() async {
    return _queryAdapter.query('Delete * From Customer',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertCustomer(Customer customer) {
    return _customerInsertionAdapter.insertAndReturnId(
        customer, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeCustomer(Customer customer) {
    return _customerDeletionAdapter.deleteAndReturnChangedRows(customer);
  }
}

class _$FlightDAO extends FlightDAO {
  _$FlightDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _flightInsertionAdapter = InsertionAdapter(
            database,
            'Flight',
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime,
                  'airplaneId': item.airplaneId
                },
            changeListener),
        _flightUpdateAdapter = UpdateAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime,
                  'airplaneId': item.airplaneId
                },
            changeListener),
        _flightDeletionAdapter = DeletionAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime,
                  'airplaneId': item.airplaneId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flight> _flightInsertionAdapter;

  final UpdateAdapter<Flight> _flightUpdateAdapter;

  final DeletionAdapter<Flight> _flightDeletionAdapter;

  @override
  Future<List<Flight>> selectAllFlight() async {
    return _queryAdapter.queryList('Select * From Flight',
        mapper: (Map<String, Object?> row) => Flight(
            row['id'] as int?,
            row['departureCity'] as String,
            row['destinationCity'] as String,
            row['departureTime'] as int,
            row['arrivalTime'] as int,
            row['airplaneId'] as int));
  }

  @override
  Stream<Flight?> selectFlight(int id) {
    return _queryAdapter.queryStream('Select * From Flight Where id = ?1',
        mapper: (Map<String, Object?> row) => Flight(
            row['id'] as int?,
            row['departureCity'] as String,
            row['destinationCity'] as String,
            row['departureTime'] as int,
            row['arrivalTime'] as int,
            row['airplaneId'] as int),
        arguments: [id],
        queryableName: 'Flight',
        isView: false);
  }

  @override
  Future<int?> removeAllToDo() async {
    return _queryAdapter.query('Delete * From Flight',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertFlight(Flight flight) {
    return _flightInsertionAdapter.insertAndReturnId(
        flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(Flight flight) async {
    await _flightUpdateAdapter.update(flight, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeFlight(Flight flight) {
    return _flightDeletionAdapter.deleteAndReturnChangedRows(flight);
  }
}

class _$ReservationDAO extends ReservationDAO {
  _$ReservationDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'date': item.date
                },
            changeListener),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'date': item.date
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> selectAllReservation() async {
    return _queryAdapter.queryList('Select * From Reservation',
        mapper: (Map<String, Object?> row) => Reservation(
            row['id'] as int?,
            row['customerId'] as int,
            row['flightId'] as int,
            row['date'] as String));
  }

  @override
  Stream<Reservation?> selectReservation(int id) {
    return _queryAdapter.queryStream('Select * From Reservation Where id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            row['id'] as int?,
            row['customerId'] as int,
            row['flightId'] as int,
            row['date'] as String),
        arguments: [id],
        queryableName: 'Reservation',
        isView: false);
  }

  @override
  Future<int?> removeAllReservation() async {
    return _queryAdapter.query('Delete * From Reservation',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertReservation(Reservation reservation) {
    return _reservationInsertionAdapter.insertAndReturnId(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeReservation(Reservation reservation) {
    return _reservationDeletionAdapter.deleteAndReturnChangedRows(reservation);
  }
}
