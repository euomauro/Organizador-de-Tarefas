import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organizador de Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TarefasPage(),
    );
  }
}

class Tarefa {
  String titulo;
  String descricao;
  bool concluida;
  DateTime dataCriacao;

  Tarefa({
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'descricao': descricao,
    'concluida': concluida,
    'dataCriacao': dataCriacao.toIso8601String(),
  };

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      titulo: json['titulo'],
      descricao: json['descricao'],
      concluida: json['concluida'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }
}

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> _tarefas = [];
  final String _arquivoSalvamento = 'tarefas.json';

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    try {
      final arquivo = File(_arquivoSalvamento);
      if (await arquivo.exists()) {
        final conteudo = await arquivo.readAsString();
        final listaJson = jsonDecode(conteudo) as List;
        setState(() {
          _tarefas = listaJson.map((json) => Tarefa.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar: $e');
    }
  }

  Future<void> _salvarTarefas() async {
    try {
      final arquivo = File(_arquivoSalvamento);
      final listaJson = _tarefas.map((t) => t.toJson()).toList();
      await arquivo.writeAsString(jsonEncode(listaJson));
    } catch (e) {
      debugPrint('Erro ao salvar: $e');
    }
  }

  void _adicionarTarefa(String titulo, String descricao) {
    setState(() {
      _tarefas.add(Tarefa(titulo: titulo, descricao: descricao));
    });
    _salvarTarefas();
  }

  void _alternarConcluida(int index) {
    setState(() {
      _tarefas[index].concluida = !_tarefas[index].concluida;
    });
    _salvarTarefas();
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
    });
    _salvarTarefas();
  }

  void _mostrarDialogAdicionar() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  hintText: 'Título da tarefa',
                  icon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  hintText: 'Descrição',
                  icon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty) {
                  _adicionarTarefa(tituloController.text, descricaoController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  int get _totalConcluidas => _tarefas.where((t) => t.concluida).length;
  double get _progresso => _tarefas.isEmpty ? 0 : _totalConcluidas / _tarefas.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizador de Tarefas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_tarefas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '${(_progresso * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _progresso,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: _tarefas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no + para adicionar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: tarefa.concluida,
                      onChanged: (_) => _alternarConcluida(index),
                    ),
                    title: Text(
                      tarefa.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                        color: tarefa.concluida ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: tarefa.descricao.isNotEmpty
                        ? Text(
                            tarefa.descricao,
                            style: TextStyle(
                              decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                              color: tarefa.concluida ? Colors.grey[400] : Colors.grey[600],
                            ),
                          )
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerTarefa(index),
                    ),
                    onTap: () => _alternarConcluida(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogAdicionar,
        child: const Icon(Icons.add),
      ),
    );
  }
}