import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tarefa.dart';

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
  late Tarefa _tarefa;

  @override
  void initState() {
    super.initState();
    _tarefa = widget.tarefa;
  }

  void _editarTarefa() {
    final tituloController = TextEditingController(text: _tarefa.titulo);
    final descricaoController = TextEditingController(text: _tarefa.descricao);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 10),
              Text("Editar Tarefa"),
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
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Salvar"),
              onPressed: () async {
                if (tituloController.text.trim().isEmpty) return;

                _tarefa.titulo = tituloController.text.trim();
                _tarefa.descricao = descricaoController.text.trim();

                await DatabaseHelper.instance.atualizarTarefa(_tarefa);

                if (!mounted) return;
                setState(() {});
                Navigator.pop(context);
              },
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
        title: Text(_tarefa.titulo),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarTarefa,
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
                color: _tarefa.concluida
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    _tarefa.concluida ? Icons.check_circle : Icons.pending_actions,
                    size: 70,
                    color: _tarefa.concluida ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _tarefa.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    backgroundColor: _tarefa.concluida ? Colors.green : Colors.orange,
                    label: Text(
                      _tarefa.concluida ? "Concluída" : "Pendente",
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
                      _tarefa.descricao.isEmpty
                          ? "Esta tarefa não possui descrição."
                          : _tarefa.descricao,
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
                          "${_tarefa.dataCriacao.day.toString().padLeft(2, '0')}/"
                          "${_tarefa.dataCriacao.month.toString().padLeft(2, '0')}/"
                          "${_tarefa.dataCriacao.year}",
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