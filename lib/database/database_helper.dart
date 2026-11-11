import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../core/constants.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/task_category.dart';

/// Acesso ao banco SQLite local (singleton).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        color INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        due_date TEXT NOT NULL,
        due_minutes INTEGER,
        priority INTEGER NOT NULL,
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        project_id INTEGER REFERENCES projects(id) ON DELETE SET NULL,
        status INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER
      )''');
    await db.execute('CREATE INDEX idx_tasks_due ON tasks(due_date)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');

    // Categorias iniciais (padrão do app; o usuário pode editar ou excluir).
    final batch = db.batch();
    const defaults = [
      ['Pessoal', 0xFF6C4CF1, 0],
      ['Trabalho', 0xFF3B82F6, 1],
      ['Estudos', 0xFF06B6D4, 2],
      ['Saúde', 0xFF10B981, 3],
      ['Finanças', 0xFFF59E0B, 4],
    ];
    for (final d in defaults) {
      batch.insert('categories', {'name': d[0], 'color': d[1], 'icon': d[2]});
    }
    await batch.commit(noResult: true);
  }

  // ---------- Tarefas ----------
  Future<List<Task>> getTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'due_date ASC, due_minutes ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCompletedTasks() async {
    final db = await database;
    return db.delete('tasks',
        where: 'status = ?', whereArgs: [TaskStatus.done.index]);
  }

  // ---------- Categorias ----------
  Future<List<TaskCategory>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map(TaskCategory.fromMap).toList();
  }

  Future<int> insertCategory(TaskCategory c) async {
    final db = await database;
    return db.insert('categories', c.toMap());
  }

  Future<void> updateCategory(TaskCategory c) async {
    final db = await database;
    await db.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Projetos ----------
  Future<List<Project>> getProjects() async {
    final db = await database;
    final rows = await db.query('projects', orderBy: 'name COLLATE NOCASE');
    return rows.map(Project.fromMap).toList();
  }

  Future<int> insertProject(Project p) async {
    final db = await database;
    return db.insert('projects', p.toMap());
  }

  Future<void> updateProject(Project p) async {
    final db = await database;
    await db.update('projects', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deleteProject(int id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}
