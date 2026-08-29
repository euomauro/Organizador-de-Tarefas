// ==========================
// TELA NOVA Nº 1: SPLASH SCREEN
// ==========================
// Essa tela aparece por alguns segundos quando o app é aberto,
// e depois manda o usuário para a tela principal (TarefasPage).

import 'package:flutter/material.dart';
import 'tarefas_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _irParaTelaPrincipal();
  }

  Future<void> _irParaTelaPrincipal() async {
    // espera 2 segundos e meio só para mostrar a splash
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TarefasPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              "Minhas Tarefas",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}