import 'package:flutter/foundation.dart';

import '../models/quote.dart';
import '../services/quote_service.dart';

enum QuoteState { loading, success, error }

/// Estado da frase motivacional vinda da API.
class QuoteController extends ChangeNotifier {
  QuoteController({QuoteService? service})
      : _service = service ?? QuoteService();

  final QuoteService _service;

  QuoteState _state = QuoteState.loading;
  Quote? _quote;
  String? _error;
  bool _refreshing = false;

  QuoteState get state => _state;
  Quote? get quote => _quote;
  String? get error => _error;
  bool get isRefreshing => _refreshing;

  /// Carrega a frase do dia.
  Future<void> loadToday() async {
    if (_quote == null) {
      _state = QuoteState.loading;
      notifyListeners();
    }
    try {
      _quote = await _service.fetchToday();
      _state = QuoteState.success;
      _error = null;
    } on QuoteException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Não foi possível carregar a frase.');
    }
    notifyListeners();
  }

  /// Busca outra frase. Retorna uma mensagem de erro, ou null em caso de sucesso.
  Future<String?> loadRandom() async {
    _refreshing = true;
    notifyListeners();
    String? failure;
    try {
      _quote = await _service.fetchRandom();
      _state = QuoteState.success;
      _error = null;
    } on QuoteException catch (e) {
      failure = e.message;
    } catch (_) {
      failure = 'Não foi possível carregar a frase.';
    }
    if (failure != null && _quote == null) {
      _setError(failure);
    }
    _refreshing = false;
    notifyListeners();
    return failure;
  }

  void _setError(String message) {
    // Mantém a última frase real exibida, se existir.
    if (_quote == null) {
      _state = QuoteState.error;
    }
    _error = message;
  }
}
