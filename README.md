# Organiza

Organizador de tarefas moderno feito com **Flutter + Dart**, **Material Design 3**, **SQLite** e **Provider**.

## Como executar

Pré-requisitos: Flutter 3.27 ou superior (Dart 3.6+) e um emulador ou aparelho Android/iOS.

```bash
# 1. Na pasta do projeto, gere as pastas android/ e ios/ (uma única vez)
./setup.sh
#    (equivale a: flutter create --project-name organiza --org br.com.organiza --platforms=android,ios .
#     + adicionar <uses-permission android:name="android.permission.INTERNET"/> ao AndroidManifest.xml
#     + flutter pub get)

# 2. Verificações
flutter pub get
flutter analyze
flutter test

# 3. Executar
flutter run
```

> `flutter create .` não sobrescreve `lib/`, `pubspec.yaml` nem `test/` existentes.
> No Windows sem bash, rode o `flutter create` manualmente e adicione a permissão de internet no manifesto.

## Funcionalidades

- Splash animada, onboarding (3 páginas) e navegação inferior (Início, Tarefas, Calendário, Estatísticas, Ajustes)
- Dashboard: progresso do dia, contadores (pendentes, concluídas, atrasadas, hoje), frase motivacional, tarefas de hoje e atrasadas
- CRUD completo de tarefas: título, descrição, data, horário (opcional), prioridade, categoria, projeto, status (pendente / em andamento / concluída) e favorita
- Swipe no cartão: direita conclui/reabre, esquerda exclui (com "Desfazer")
- Abas: Hoje, Próximas, Todas, Concluídas, Favoritas, com pesquisa e filtros (prioridade, status, atrasadas, categoria, projeto, data)
- Calendário (mês / 2 semanas / semana) com marcadores por prioridade e lista do dia selecionado
- Categorias (cor + ícone) e projetos personalizados, com contagem e lista de tarefas de cada um
- Estatísticas: taxa de conclusão, sequência de dias, gráfico de barras (7/14/30 dias), pizza por categoria e pendentes por prioridade
- Tema claro/escuro/sistema, validação de formulários, estados de carregamento, vazio e erro

## API pública

[ZenQuotes](https://zenquotes.io): gratuita, sem autenticação. Usa `GET /api/today` (frase do dia) e `GET /api/random` (botão "Nova frase").
Resposta real da API: `[{"q": "...", "a": "autor", "h": "..."}]`. Nada é inventado: se não houver rede, ocorrer timeout ou o limite
gratuito (5 requisições / 30 s) for atingido, o app mostra a mensagem de erro correspondente com opção de tentar novamente.
A atribuição exigida pelo plano gratuito aparece no cartão e em Ajustes.

## Estrutura

```
lib/
  main.dart
  core/         constants, theme (M3 claro/escuro), utils (datas pt_BR, snackbar)
  models/       task, task_category, project, task_filter, quote
  database/     database_helper (SQLite: tarefas, categorias, projetos)
  services/     quote_service (HTTP + tratamento de erros)
  controllers/  task_controller, quote_controller, settings_controller (Provider)
  screens/      splash, onboarding, main_shell, dashboard, tasks, task_list, calendar,
                stats, task_form, task_detail, organization, settings
  widgets/      app_card, task_card, stat_card, quote_card, filter_sheet, empty_state,
                error_view, section_header, fade_in, responsive_body, task_actions
test/           models_test, quote_service_test
```

## Observações

- Persistência local via `sqflite` (Android/iOS). Web e desktop não são alvos.
- Ao excluir uma categoria ou projeto, as tarefas permanecem (ficam sem categoria/projeto).
- Não há notificações/lembretes: não faziam parte dos requisitos.
