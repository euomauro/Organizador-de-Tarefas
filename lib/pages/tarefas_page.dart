import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tarefa.dart';
import 'detalhes_page.dart';

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  // ==========================
  // CARREGAR DO BANCO
  // ==========================

  Future<void> _carregarTarefas() async {
    final tarefas = await DatabaseHelper.instance.listarTarefas();
    setState(() {
      _tarefas = tarefas;
      _carregando = false;
    });
  }

  // ==========================
  // PROCESSAMENTO (CÁLCULOS)
  // ==========================

  int get totalTarefas => _tarefas.length;

  int get tarefasConcluidas =>
      _tarefas.where((t) => t.concluida).length;

  int get tarefasPendentes =>
      totalTarefas - tarefasConcluidas;

  double get porcentagemConclusao {
    if (totalTarefas == 0) {
      return 0;
    }

    return tarefasConcluidas / totalTarefas;
  }

  // ==========================
  // MÉTODOS (CRUD)
  // ==========================

  Future<void> _adicionarTarefa(
    String titulo,
    String descricao,
  ) async {
    final novaTarefa = Tarefa(
      titulo: titulo,
      descricao: descricao,
    );

    await DatabaseHelper.instance.inserirTarefa(novaTarefa);
    await _carregarTarefas();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tarefa adicionada!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _alternarConcluida(Tarefa tarefa) async {
    tarefa.concluida = !tarefa.concluida;
    await DatabaseHelper.instance.atualizarTarefa(tarefa);
    await _carregarTarefas();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tarefa.concluida
              ? "Tarefa concluída!"
              : "Tarefa marcada como pendente!",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removerTarefa(Tarefa tarefa) async {
    await DatabaseHelper.instance.excluirTarefa(tarefa.id!);
    await _carregarTarefas();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tarefa removida!"),
      ),
    );
  }

  // ==========================
  // DIALOG PARA ADICIONAR
  // ==========================

  void _mostrarDialogAdicionar() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_task),
              SizedBox(width: 10),
              Text("Nova Tarefa"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: "Título",
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Adicionar"),
              onPressed: () {
                if (tituloController.text.trim().isEmpty) {
                  return;
                }

                _adicionarTarefa(
                  tituloController.text.trim(),
                  descricaoController.text.trim(),
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ==========================
  // BUILD
  // ==========================

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      body: Column(
        children: [
          // ==========================
          // PAINEL DE ESTATÍSTICAS
          // ==========================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.indigo.shade300,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Resumo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.list_alt, color: Colors.white),
                        const SizedBox(height: 6),
                        Text(
                          "$totalTarefas",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Total", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.greenAccent),
                        const SizedBox(height: 6),
                        Text(
                          "$tarefasConcluidas",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Feitas", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.pending_actions, color: Colors.amber),
                        const SizedBox(height: 6),
                        Text(
                          "$tarefasPendentes",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Pendentes", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: porcentagemConclusao,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${(porcentagemConclusao * 100).toStringAsFixed(0)}% concluído",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _tarefas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.assignment_outlined,
                            size: 90,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Nenhuma tarefa",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Clique no botão abaixo para adicionar."),
                        ],
                      ),
                    )
                  : ListView.builder(
                      key: ValueKey(_tarefas.length),
                      itemCount: _tarefas.length,
                      itemBuilder: (context, index) {
                        final tarefa = _tarefas[index];

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tarefa.concluida
                                ? Colors.green.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              tarefa.concluida
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: tarefa.concluida ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              tarefa.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: tarefa.concluida
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              tarefa.descricao.isEmpty
                                  ? "Sem descrição."
                                  : tarefa.descricao,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: tarefa.concluida,
                                  activeColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (_) {
                                    _alternarConcluida(tarefa);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _removerTarefa(tarefa);
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalhesPage(tarefa: tarefa),
                                ),
                              );
                              // Ao voltar dos detalhes, recarrega (pode ter editado)
                              _carregarTarefas();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: 1,
        child: FloatingActionButton.extended(
          elevation: 6,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          onPressed: _mostrarDialogAdicionar,
          icon: const Icon(Icons.add),
          label: const Text("Nova tarefa"),
        ),
      ),
    );
  }
}