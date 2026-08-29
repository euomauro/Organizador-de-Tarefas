// ==========================
// MODELO DA TAREFA
// ==========================
// Esse Model representa uma linha da tabela "tarefas" no banco SQLite.
// Ele é o mesmo Tarefa de antes, só que agora com "id" (chave do banco)
// e com os métodos toMap() e fromMap() para converter entre o objeto
// Dart e o formato que o SQLite entende (um Map).

class Tarefa {
  int? id; // vem nulo quando a tarefa ainda não foi salva no banco
  String titulo;
  String descricao;
  bool concluida;
  DateTime dataCriacao;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  // Converte a tarefa em um Map para poder salvar no banco.
  // O SQLite não tem tipo "bool" nem "DateTime", por isso:
  // - concluida vira 0 ou 1
  // - dataCriacao vira uma String
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Faz o caminho inverso: pega um Map que veio do banco e monta um Tarefa.
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      concluida: (map['concluida'] as int) == 1,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
    );
  }
}