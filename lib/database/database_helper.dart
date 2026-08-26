import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tarefa.dart';

class DatabaseHelper {
  // Singleton: só existe uma instância do banco no app inteiro
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'tarefas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        concluida INTEGER NOT NULL,
        dataCriacao TEXT NOT NULL
      )
    ''');
  }

  // CREATE
  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await database;
    return await db.insert('tarefas', tarefa.toMap());
  }

  // READ (todas as tarefas)
  Future<List<Tarefa>> listarTarefas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tarefas',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Tarefa.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  // DELETE
  Future<int> excluirTarefa(int id) async {
    final db = await database;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}