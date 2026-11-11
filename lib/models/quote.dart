/// Frase motivacional retornada pela API ZenQuotes.
class Quote {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;

  /// A API responde com `{"q": "texto", "a": "autor", "h": "html"}`.
  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: (json['q'] ?? '').toString().trim(),
        author: (json['a'] ?? '').toString().trim(),
      );
}
