// ==========================
// TELA DE DETALHES
// ==========================
// Igual à tela original. A única mudança é o botão "Editar", que leva
// para a EditarTarefaPage (parte do CRUD), e o botão "Voltar" agora
// retorna "true" quando a tarefa foi editada, para a tela principal
// saber que precisa recarregar a lista.

import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import 'editar_tarefa_page.dart';

class DetalhesPage extends StatefulWidget {
  final Tarefa tarefa;

  const DetalhesPage({
    super.key,
    required this.tarefa,
  });

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  // guarda se algo foi alterado, para avisar a tela anterior
  bool _foiAlterado = false;

  @override
  Widget build(BuildContext context) {
    final tarefa = widget.tarefa;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _foiAlterado);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tarefa.titulo),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 5,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Editar",
              onPressed: () async {
                final atualizou = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarTarefaPage(tarefa: tarefa),
                  ),
                );
                if (atualizou == true) {
                  setState(() {
                    _foiAlterado = true;
                  });
                }
              },
            ),
          ],
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
                      color: tarefa.concluida ? Colors.green : Colors.orange,
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
                      backgroundColor:
                          tarefa.concluida ? Colors.green : Colors.orange,
                      label: Text(
                        tarefa.concluida ? "Concluída" : "Pendente",
                        style: const TextStyle(color: Colors.white),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Criada em: "
                            "${tarefa.dataCriacao.day.toString().padLeft(2, '0')}/"
                            "${tarefa.dataCriacao.month.toString().padLeft(2, '0')}/"
                            "${tarefa.dataCriacao.year}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  label: const Text("Voltar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _foiAlterado);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}