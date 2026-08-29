// ==========================
// BANCO DE DADOS (SQLite)
// ==========================
// Essa classe é responsável por abrir o banco, criar a tabela "tarefas"
// e fazer o CRUD (Inserir, Consultar, Atualizar, Excluir).
// Usamos o padrão "Singleton" bem simples: só existe UM DBHelper no app
// inteiro, guardado na variável estática _instancia.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';

class DBHelper {
  // instância única da classe
  static final DBHelper _instancia = DBHelper._interno();
  factory DBHelper() => _instancia;
  DBHelper._interno();

  static Database? _banco;

  // Retorna o banco já aberto. Se ainda não foi aberto, abre agora.
  Future<Database> get banco async {
    if (_banco != null) {
      return _banco!;
    }
    _banco = await _iniciarBanco();
    return _banco!;
  }

  Future<Database> _iniciarBanco() async {
    final caminho = await getDatabasesPath();
    final caminhoCompleto = join(caminho, 'tarefas.db');

    return await openDatabase(
      caminhoCompleto,
      version: 1,
      onCreate: (db, versao) async {
        // Cria a tabela "tarefas" na primeira vez que o app roda
        await db.execute('''
          CREATE TABLE tarefas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descricao TEXT,
            concluida INTEGER NOT NULL,
            dataCriacao TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ---------- CREATE ----------
  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await banco;
    return await db.insert('tarefas', tarefa.toMap());
  }

  // ---------- READ ----------
  Future<List<Tarefa>> listarTarefas() async {
    final db = await banco;
    final resultado = await db.query('tarefas', orderBy: 'id DESC');
    return resultado.map((linha) => Tarefa.fromMap(linha)).toList();
  }

  // ---------- UPDATE ----------
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await banco;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  // ---------- DELETE ----------
  Future<int> removerTarefa(int id) async {
    final db = await banco;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}