import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app/main.dart';

void main() {
  testWidgets('App inicializa corretamente', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verifica se o título está presente
    expect(find.text('Organizador de Tarefas'), findsOneWidget);
    
    // Verifica se a mensagem de "Nenhuma tarefa" aparece
    expect(find.text('Nenhuma tarefa'), findsOneWidget);
    
    // Verifica se o botão de adicionar existe
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Adicionar nova tarefa', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Clica no botão de adicionar
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Preenche o formulário
    await tester.enterText(find.widgetWithText(TextField, 'Título da tarefa'), 'Estudar Flutter');
    await tester.enterText(find.widgetWithText(TextField, 'Descrição'), 'Aprender a fazer apps');
    
    // Clica em adicionar
    await tester.tap(find.text('Adicionar'));
    await tester.pump();

    // Verifica se a tarefa foi adicionada
    expect(find.text('Estudar Flutter'), findsOneWidget);
  });
}