class Tarefa {
  int? id;
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

  // Converte a Tarefa em um Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0, // SQLite não tem bool, usa 0/1
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Cria uma Tarefa a partir de um Map vindo do SQLite
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String? ?? '',
      concluida: (map['concluida'] as int) == 1,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
    );
  }
}