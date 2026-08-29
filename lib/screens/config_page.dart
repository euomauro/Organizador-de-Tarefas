// ==========================
// TELA NOVA Nº 2: CONFIGURAÇÕES
// ==========================
// Aqui usamos o SharedPreferences de verdade: salvamos o nome do usuário
// e uma preferência simples (mostrar ou não uma mensagem de boas-vindas).
// Isso NÃO é o banco de dados, é só uma configuração pequena salva no
// aparelho, exatamente para o que o SharedPreferences serve.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _nomeController = TextEditingController();
  bool _mostrarSaudacao = true;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeController.text = prefs.getString('nome_usuario') ?? '';
      _mostrarSaudacao = prefs.getBool('mostrar_saudacao') ?? true;
      _carregando = false;
    });
  }

  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_usuario', _nomeController.text.trim());
    await prefs.setBool('mostrar_saudacao', _mostrarSaudacao);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configurações salvas!")),
    );

    // volta para a tela anterior avisando que algo mudou (true)
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Seu nome",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      hintText: "Digite seu nome",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.indigo,
                    title: const Text("Mostrar saudação na tela inicial"),
                    subtitle: const Text(
                      "Exibe 'Olá, seu nome' no topo da lista de tarefas",
                    ),
                    value: _mostrarSaudacao,
                    onChanged: (valor) {
                      setState(() {
                        _mostrarSaudacao = valor;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _salvarPreferencias,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}