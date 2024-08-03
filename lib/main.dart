import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_sqflite/locator.dart';
import 'package:flutter_sqflite/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  Database? db;

  try {
    db = await getIt.get<DatabaseService>().initDatabase();
    log("DB: ${await db?.database.getVersion()}");

    await db?.insert(
      "Test",
      {
        "id": 1,
        "value": "Test Value",
        "name": "John Doe",
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  } catch (e) {
    log("ERROR: $e");
  }

  runApp(
    MyApp(db: db),
  );
}

class MyApp extends StatelessWidget {
  final Database? db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        db: db?.database,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Database? db;

  const MyHomePage({
    super.key,
    required this.title,
    required this.db,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    log("DB_TABLE: ${await widget.db?.query("Test")}");
    setState(() {
      _counter++;
    });
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
