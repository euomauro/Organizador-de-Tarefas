import 'package:flutter/material.dart';

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

  Tarefa({
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });
}

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> _tarefas = [];

  void _adicionarTarefa(String titulo, String descricao) {
    setState(() {
      _tarefas.add(Tarefa(titulo: titulo, descricao: descricao));
    });
  }

  void _alternarConcluida(int index) {
    setState(() {
      _tarefas[index].concluida = !_tarefas[index].concluida;
    });
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
    });
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
                  hintText: 'Título',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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