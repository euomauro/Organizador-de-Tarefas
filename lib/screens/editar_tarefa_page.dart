// ==========================
// TELA NOVA Nº 3: EDITAR TAREFA
// ==========================
// Essa tela é o "Update" do CRUD. Ela abre já preenchida com os dados
// da tarefa escolhida, o usuário altera o que quiser e salva no banco.

import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../db/db_helper.dart';

class EditarTarefaPage extends StatefulWidget {
  final Tarefa tarefa;

  const EditarTarefaPage({super.key, required this.tarefa});

  @override
  State<EditarTarefaPage> createState() => _EditarTarefaPageState();
}

class _EditarTarefaPageState extends State<EditarTarefaPage> {
  final _dbHelper = DBHelper();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tarefa.titulo);
    _descricaoController =
        TextEditingController(text: widget.tarefa.descricao);
  }

  Future<void> _salvarEdicao() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O título não pode ficar vazio.")),
      );
      return;
    }

    widget.tarefa.titulo = _tituloController.text.trim();
    widget.tarefa.descricao = _descricaoController.text.trim();

    await _dbHelper.atualizarTarefa(widget.tarefa);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tarefa atualizada!")),
    );

    // volta para a tela anterior avisando que precisa recarregar a lista
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Tarefa"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
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
              controller: _descricaoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descrição",
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Salvar alterações"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _salvarEdicao,
              ),
            ),
          ],
        ),
      ),
    );
  }
}