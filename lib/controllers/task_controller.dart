import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../core/utils.dart';
import '../database/database_helper.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';

enum LoadState { loading, ready, error }

class CategoryStat {
  const CategoryStat(this.category, this.count);
  final TaskCategory? category;
  final int count;
}

/// Controla tarefas, categorias e projetos (estado + persistência SQLite).
class TaskController extends ChangeNotifier {
  TaskController({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  LoadState _state = LoadState.loading;
  String? _error;
  List<Task> _tasks = [];
  List<TaskCategory> _categories = [];
  List<Project> _projects = [];

  LoadState get state => _state;
  String? get error => _error;
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<TaskCategory> get categories => List.unmodifiable(_categories);
  List<Project> get projects => List.unmodifiable(_projects);

  DateTime get _today => dateOnly(DateTime.now());

  // ---------------------------------------------------------------- carga
  Future<void> load() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();
    try {
      await _syncAll();
      _state = LoadState.ready;
    } catch (_) {
      _state = LoadState.error;
      _error = kIsWeb
          ? 'O armazenamento SQLite não funciona no navegador. Execute o app no Android, iOS, Windows ou Linux.'
          : 'Não foi possível carregar os dados salvos no dispositivo.';
    }
    notifyListeners();
  }

  /// Recarrega sem exibir o estado de carregamento. Retorna mensagem de erro.
  Future<String?> refresh() => _run(() async {
        await _syncAll();
        notifyListeners();
      });

  Future<void> _syncAll() async {
    _tasks = await _db.getTasks();
    _categories = await _db.getCategories();
    _projects = await _db.getProjects();
  }

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return 'Já existe um item com esse nome.';
      }
      return 'Erro ao acessar o banco de dados.';
    } catch (_) {
      return 'Algo deu errado. Tente novamente.';
    }
  }

  // ------------------------------------------------------------- consultas
  Task? taskById(int id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  TaskCategory? categoryById(int? id) {
    if (id == null) return null;
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Project? projectById(int? id) {
    if (id == null) return null;
    for (final p in _projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Task> _sorted(Iterable<Task> list) {
    final l = list.toList();
    l.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      final c = a.dueDateTime.compareTo(b.dueDateTime);
      if (c != 0) return c;
      return b.priority.index.compareTo(a.priority.index);
    });
    return l;
  }

  List<Task> get allTasksSorted => _sorted(_tasks);
  List<Task> get pendingTasks => _sorted(_tasks.where((t) => !t.isDone));
  List<Task> get overdueTasks => _sorted(_tasks.where((t) => t.isOverdue));
  List<Task> get favoriteTasks => _sorted(_tasks.where((t) => t.isFavorite));

  List<Task> get todayTasks =>
      _sorted(_tasks.where((t) => isSameDay(t.dueDate, DateTime.now())));

  List<Task> get upcomingTasks =>
      _sorted(_tasks.where((t) => !t.isDone && t.dueDate.isAfter(_today)));

  List<Task> get completedTasks {
    final l = _tasks.where((t) => t.isDone).toList();
    l.sort((a, b) => (b.completedAt ?? b.createdAt)
        .compareTo(a.completedAt ?? a.createdAt));
    return l;
  }

  List<Task> tasksOn(DateTime day) =>
      _sorted(_tasks.where((t) => isSameDay(t.dueDate, day)));

  List<Task> tasksOfCategory(int id) =>
      _sorted(_tasks.where((t) => t.categoryId == id));

  List<Task> tasksOfProject(int id) =>
      _sorted(_tasks.where((t) => t.projectId == id));

  int countForCategory(int id) => _tasks.where((t) => t.categoryId == id).length;
  int countForProject(int id) => _tasks.where((t) => t.projectId == id).length;

  /// Aplica pesquisa e filtros sobre uma lista base.
  List<Task> applyFilters(
    List<Task> base, {
    String query = '',
    TaskFilter filter = const TaskFilter(),
  }) {
    final q = query.trim().toLowerCase();
    return base.where((t) {
      if (!filter.matches(t)) return false;
      if (q.isEmpty) return true;
      final cat = categoryById(t.categoryId)?.name.toLowerCase() ?? '';
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          cat.contains(q);
    }).toList();
  }

  // --------------------------------------------------------------- contagens
  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get pendingCount => _tasks.where((t) => !t.isDone).length;
  int get overdueCount => _tasks.where((t) => t.isOverdue).length;
  int get todayCount => todayTasks.length;
  int get todayDoneCount => todayTasks.where((t) => t.isDone).length;

  // ------------------------------------------------------------- estatísticas
  double get completionRate => totalCount == 0 ? 0 : doneCount / totalCount;

  /// Tarefas concluídas por dia nos últimos [days] dias (do mais antigo ao mais novo).
  List<MapEntry<DateTime, int>> completedPerDay(int days) {
    final today = _today;
    return List.generate(days, (i) {
      final day = DateTime(today.year, today.month, today.day - (days - 1 - i));
      final n = _tasks
          .where((t) => t.completedAt != null && isSameDay(t.completedAt!, day))
          .length;
      return MapEntry(day, n);
    });
  }

  /// Dias consecutivos com ao menos uma tarefa concluída.
  int get streak {
    final days = <DateTime>{
      for (final t in _tasks)
        if (t.completedAt != null) dateOnly(t.completedAt!),
    };
    var cursor = _today;
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  Map<Priority, int> get pendingByPriority => {
        for (final p in Priority.values)
          p: _tasks.where((t) => !t.isDone && t.priority == p).length,
      };

  List<CategoryStat> get categoryStats {
    final result = <CategoryStat>[];
    for (final c in _categories) {
      final n = countForCategory(c.id!);
      if (n > 0) result.add(CategoryStat(c, n));
    }
    final none = _tasks.where((t) => categoryById(t.categoryId) == null).length;
    if (none > 0) result.add(CategoryStat(null, none));
    result.sort((a, b) => b.count.compareTo(a.count));
    return result;
  }

  // ------------------------------------------------------------------ tarefas
  Future<String?> saveTask(Task task) => _run(() async {
        if (task.id == null) {
          await _db.insertTask(task);
        } else {
          await _db.updateTask(task);
        }
        _tasks = await _db.getTasks();
        notifyListeners();
      });

  Future<String?> toggleDone(Task t) =>
      setStatus(t, t.isDone ? TaskStatus.pending : TaskStatus.done);

  Future<String?> setStatus(Task t, TaskStatus status) {
    final done = status == TaskStatus.done;
    return _replace(t.copyWith(
      status: status,
      completedAt: done ? DateTime.now() : null,
      clearCompletedAt: !done,
    ));
  }

  Future<String?> toggleFavorite(Task t) =>
      _replace(t.copyWith(isFavorite: !t.isFavorite));

  /// Atualização otimista: a interface muda na hora e reverte se falhar.
  Future<String?> _replace(Task updated) async {
    final i = _tasks.indexWhere((x) => x.id == updated.id);
    if (i == -1) return null;
    final previous = _tasks[i];
    _tasks = List.of(_tasks)..[i] = updated;
    notifyListeners();
    try {
      await _db.updateTask(updated);
      return null;
    } catch (_) {
      final j = _tasks.indexWhere((x) => x.id == updated.id);
      if (j != -1) {
        _tasks = List.of(_tasks)..[j] = previous;
        notifyListeners();
      }
      return 'Não foi possível atualizar a tarefa.';
    }
  }

  /// Remove a tarefa imediatamente da interface e depois do banco.
  Future<String?> deleteTask(Task t) async {
    _tasks = _tasks.where((x) => x.id != t.id).toList();
    notifyListeners();
    try {
      await _db.deleteTask(t.id!);
      return null;
    } catch (_) {
      return _run(() async {
        _tasks = await _db.getTasks();
        notifyListeners();
      }).then((_) => 'Não foi possível excluir a tarefa.');
    }
  }

  /// Restaura uma tarefa excluída (desfazer).
  Future<String?> restoreTask(Task t) => _run(() async {
        await _db.insertTask(t);
        _tasks = await _db.getTasks();
        notifyListeners();
      });

  Future<String?> clearCompleted() => _run(() async {
        await _db.deleteCompletedTasks();
        _tasks = await _db.getTasks();
        notifyListeners();
      });

  // --------------------------------------------------------------- categorias
  Future<String?> saveCategory(TaskCategory c) => _run(() async {
        if (c.id == null) {
          await _db.insertCategory(c);
        } else {
          await _db.updateCategory(c);
        }
        _categories = await _db.getCategories();
        notifyListeners();
      });

  Future<String?> deleteCategory(int id) => _run(() async {
        await _db.deleteCategory(id);
        await _syncAll();
        notifyListeners();
      });

  // ----------------------------------------------------------------- projetos
  Future<String?> saveProject(Project p) => _run(() async {
        if (p.id == null) {
          await _db.insertProject(p);
        } else {
          await _db.updateProject(p);
        }
        _projects = await _db.getProjects();
        notifyListeners();
      });

  Future<String?> deleteProject(int id) => _run(() async {
        await _db.deleteProject(id);
        await _syncAll();
        notifyListeners();
      });
}
