import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TarefasPage(),
    );
  }
}

// Classe da Tarefa (simplificada)
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

// Tela Principal
class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> _tarefas = [];

  // Adicionar tarefa
  void _adicionarTarefa(String titulo, String descricao) {
    setState(() {
      _tarefas.add(Tarefa(titulo: titulo, descricao: descricao));
    });
    
    // SnackBar - Widget de feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa adicionada!')),
    );
  }

  // Alternar concluída
  void _alternarConcluida(int index) {
    setState(() {
      _tarefas[index].concluida = !_tarefas[index].concluida;
    });
  }

  // Remover tarefa
  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
    });
    
    // SnackBar - Widget de feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarefa removida!')),
    );
  }

  // Diálogo para adicionar tarefa
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
                  const Text(
                    'Nenhuma tarefa',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque no + para adicionar',
                    style: TextStyle(fontSize: 14),
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
                    // NAVEGAÇÃO: ao clicar, abre a tela de detalhes
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalhesPage(tarefa: tarefa),
                        ),
                      );
                    },
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

// TELA DE DETALHES (Navegação)
class DetalhesPage extends StatelessWidget {
  final Tarefa tarefa;

  const DetalhesPage({super.key, required this.tarefa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tarefa.titulo),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  tarefa.concluida ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: tarefa.concluida ? Colors.green : Colors.grey,
                ),
                title: Text(
                  tarefa.titulo,
                  style: TextStyle(
                    fontSize: 20,
                    decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  tarefa.concluida ? 'Concluída' : 'Pendente',
                  style: TextStyle(
                    color: tarefa.concluida ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descrição',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tarefa.descricao.isEmpty ? 'Sem descrição' : tarefa.descricao,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}