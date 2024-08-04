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
  List<Map<String, Object?>>? maps;

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    await widget.db?.insert(
      "Test",
      {
        "value": "Test Value $_counter",
        "name": "John Doe",
        "count": "$_counter",
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );

    _getData();

    log("DB_TABLE: $maps");
  }

  Future<void> _getData() async {
    maps = await widget.db?.query("Test");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _getData,
                child: const Text('Get Data'),
              ),
              const Text(
                'You have pushed the button this many times:',
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: maps?.length ?? 0,
                itemBuilder: (context, index) {
                  if (maps == null || (maps ?? []).isEmpty) {
                    return const Text('NO DATA!');
                  }

                  return Center(
                    child: Text(
                      '${maps?[index]['value'] ?? ''}, ${maps?[index]['name'] ?? ''}, ${maps?[index]['count'] ?? ''}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  );
                },
              ),
            ],
          ),
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
