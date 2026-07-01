import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minhas Tarefas',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const TarefasPage(),
    );
  }
}

// ==========================
// MODELO DA TAREFA
// ==========================

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

// ==========================
// TELA PRINCIPAL
// ==========================

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  final List<Tarefa> _tarefas = [];

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
  // MÉTODOS
  // ==========================

  void _adicionarTarefa(
      String titulo,
      String descricao,
      ) {
    setState(() {
      _tarefas.add(
        Tarefa(
          titulo: titulo,
          descricao: descricao,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tarefa adicionada!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _alternarConcluida(int index) {
    setState(() {
      _tarefas[index].concluida =
      !_tarefas[index].concluida;
    });
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
    });

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
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: descricaoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  prefixIcon:
                  const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
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
                  tituloController.text,
                  descricaoController.text,
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

        return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [

                    Column(
                      children: [
                        const Icon(
                          Icons.list_alt,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$totalTarefas",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Total",
                          style:
                              TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$tarefasConcluidas",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Feitas",
                          style:
                              TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$tarefasPendentes",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Pendentes",
                          style:
                              TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: porcentagemConclusao,
                    minHeight: 10,
                    backgroundColor:
                        Colors.white30,
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

          // ==========================
          // LISTA
          // ==========================

          Expanded(
            child: AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: 500),

              child: _tarefas.isEmpty

                  ? Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
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
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "Clique no botão abaixo para adicionar.",
                          ),
                        ],
                      ),
                    )

                  : ListView.builder(
                      itemCount: _tarefas.length,
                      itemBuilder: (context, index) {

                        final tarefa = _tarefas[index];

                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 350,
                          ),

                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: tarefa.concluida
                                ? Colors.green.shade50
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(16),
                            boxShadow: [

                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.15),
                                blurRadius: 6,
                                offset:
                                    const Offset(0, 3),
                              ),

                            ],
                          ),

                          child: ListTile(

                            leading: Checkbox(
                              value:
                                  tarefa.concluida,
                              onChanged: (_) {
                                _alternarConcluida(
                                    index);
                              },
                            ),

                            title: Text(
                              tarefa.titulo,
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                decoration:
                                    tarefa.concluida
                                        ? TextDecoration
                                            .lineThrough
                                        : null,
                              ),
                            ),

                            subtitle:
                                tarefa.descricao.isEmpty
                                    ? null
                                    : Text(
                                        tarefa.descricao,
                                      ),

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _removerTarefa(index);
                              },
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalhesPage(
                                    tarefa: tarefa,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(

        backgroundColor: Colors.indigo,

        foregroundColor: Colors.white,

        onPressed: _mostrarDialogAdicionar,

        icon: const Icon(Icons.add),

        label: const Text("Nova tarefa"),
      ),
    );
  }
}

// ==========================
// TELA DE DETALHES
// ==========================

class DetalhesPage extends StatelessWidget {
  final Tarefa tarefa;

  const DetalhesPage({
    super.key,
    required this.tarefa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tarefa.titulo),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tarefa.concluida
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  Icon(
                    tarefa.concluida
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    size: 70,
                    color: tarefa.concluida
                        ? Colors.green
                        : Colors.orange,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    tarefa.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Chip(
                    backgroundColor: tarefa.concluida
                        ? Colors.green
                        : Colors.orange,
                    label: Text(
                      tarefa.concluida
                          ? "Concluída"
                          : "Pendente",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Row(
                      children: [

                        Icon(Icons.description),

                        SizedBox(width: 8),

                        Text(
                          "Descrição",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    const SizedBox(height: 10),

                    Text(
                      tarefa.descricao.isEmpty
                          ? "Esta tarefa não possui descrição."
                          : tarefa.descricao,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Voltar"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}