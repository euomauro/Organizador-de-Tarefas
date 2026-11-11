import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/quote.dart';

enum QuoteErrorType { offline, timeout, rateLimit, server, invalid }

class QuoteException implements Exception {
  const QuoteException(this.type);
  final QuoteErrorType type;

  String get message => switch (type) {
        QuoteErrorType.offline =>
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        QuoteErrorType.timeout =>
          'O servidor demorou demais para responder. Tente novamente.',
        QuoteErrorType.rateLimit =>
          'Muitas solicitações em pouco tempo. Aguarde alguns segundos.',
        QuoteErrorType.server =>
          'O serviço de frases está indisponível no momento.',
        QuoteErrorType.invalid => 'Resposta inesperada do serviço de frases.',
      };

  @override
  String toString() => 'QuoteException($type)';
}

/// Consome a API pública ZenQuotes (https://zenquotes.io), gratuita e sem
/// autenticação. Endpoints: `/api/today` e `/api/random`.
class QuoteService {
  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  static const String _base = 'https://zenquotes.io/api';
  final http.Client _client;

  Future<Quote> fetchToday() => _fetch('today');
  Future<Quote> fetchRandom() => _fetch('random');

  Future<Quote> _fetch(String endpoint) async {
    try {
      final response = await _client
          .get(Uri.parse('$_base/$endpoint'),
              headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 429) {
        throw const QuoteException(QuoteErrorType.rateLimit);
      }
      if (response.statusCode != 200) {
        throw const QuoteException(QuoteErrorType.server);
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
        throw const QuoteException(QuoteErrorType.invalid);
      }
      final quote =
          Quote.fromJson(Map<String, dynamic>.from(decoded.first as Map));
      if (quote.text.isEmpty) {
        throw const QuoteException(QuoteErrorType.invalid);
      }
      // Ao exceder o limite gratuito, a API devolve uma mensagem informativa
      // no lugar da frase.
      if (quote.text.toLowerCase().contains('too many requests')) {
        throw const QuoteException(QuoteErrorType.rateLimit);
      }
      return quote;
    } on SocketException {
      throw const QuoteException(QuoteErrorType.offline);
    } on http.ClientException {
      throw const QuoteException(QuoteErrorType.offline);
    } on TimeoutException {
      throw const QuoteException(QuoteErrorType.timeout);
    } on FormatException {
      throw const QuoteException(QuoteErrorType.invalid);
    }
  }
}
