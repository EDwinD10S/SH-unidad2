// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Prestamo {
  String id;
  String nombreCliente;
  double monto;
  DateTime fecha;

  Prestamo({
    required this.id,
    required this.nombreCliente,
    required this.monto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreCliente': nombreCliente,
      'monto': monto,
      'fecha': fecha.toString(),
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Préstamos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null we instantiate it
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'prestamos.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE prestamos(id TEXT PRIMARY KEY, nombreCliente TEXT, monto REAL, fecha TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertPrestamo(Prestamo prestamo) async {
    final Database db = await database;
    return await db.insert(
      'prestamos',
      prestamo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Prestamo>> getPrestamos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('prestamos');
    return List.generate(maps.length, (i) {
      return Prestamo(
        id: maps[i]['id'],
        nombreCliente: maps[i]['nombreCliente'],
        monto: maps[i]['monto'],
        fecha: DateTime.parse(maps[i]['fecha']),
      );
    });
  }

  Future<int> updatePrestamo(Prestamo prestamo) async {
    final db = await database;
    return await db.update(
      'prestamos',
      prestamo.toMap(),
      where: "id = ?",
      whereArgs: [prestamo.id],
    );
  }

  Future<int> deletePrestamo(String id) async {
    final db = await database;
    return await db.delete(
      'prestamos',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Prestamo> prestamos = [];

  final String usuarioLogueado = "Usuario";

   void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    refreshPrestamos();
  }

  Future<void> refreshPrestamos() async {
    List<Prestamo> prestamosList = await databaseHelper.getPrestamos();
    setState(() {
      prestamos = prestamosList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD de Préstamos'),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: prestamos.length,
        itemBuilder: (context, index) {
          var prestamo = prestamos[index];
          return ListTile(
            title: Text(prestamo.nombreCliente),
            subtitle: Text(
                '\$${prestamo.monto.toStringAsFixed(2)} - ${prestamo.fecha.toString()}'),
            onTap: () {
              _mostrarEditarPrestamoModal(context, prestamo);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarAgregarPrestamoModal(context);
        },
        tooltip: 'Agregar préstamo',
        child: Icon(Icons.add),
      ),
    );
  }

  void _mostrarEditarPrestamoModal(BuildContext context, Prestamo prestamo) {
    TextEditingController nombreController =
        TextEditingController(text: prestamo.nombreCliente);
    TextEditingController montoController =
        TextEditingController(text: prestamo.monto.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Préstamo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Cliente'),
              ),
              TextField(
                controller: montoController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                prestamo.nombreCliente = nombreController.text;
                prestamo.monto = double.parse(montoController.text);
                await databaseHelper.updatePrestamo(prestamo);
                await refreshPrestamos();
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () async {
                await databaseHelper.deletePrestamo(prestamo.id);
                await refreshPrestamos();
                Navigator.pop(context);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAgregarPrestamoModal(BuildContext context) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Préstamo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Cliente'),
              ),
              TextField(
                controller: montoController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Prestamo nuevoPrestamo = Prestamo(
                  id: DateTime.now().toString(),
                  nombreCliente: nombreController.text,
                  monto: double.parse(montoController.text),
                  fecha: DateTime.now(),
                );
                await databaseHelper.insertPrestamo(nuevoPrestamo);
                await refreshPrestamos();
                Navigator.pop(context);
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
