import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:organiza/services/quote_service.dart';

void main() {
  test('interpreta o formato documentado da ZenQuotes', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://zenquotes.io/api/today');
      return http.Response(
        '[{"q":"Texto de exemplo","a":"Autor","h":"<blockquote></blockquote>"}]',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final quote = await QuoteService(client: client).fetchToday();
    expect(quote.text, 'Texto de exemplo');
    expect(quote.author, 'Autor');
  });

  test('detecta limite de requisições', () async {
    final client = MockClient((_) async => http.Response(
        '[{"q":"Too many requests. Obtain an auth key for unlimited access.","a":"zenquotes.io"}]',
        200));
    expect(
      () => QuoteService(client: client).fetchRandom(),
      throwsA(isA<QuoteException>()
          .having((e) => e.type, 'type', QuoteErrorType.rateLimit)),
    );
  });

  test('sem conexão vira erro offline', () async {
    final client = MockClient((_) async => throw const SocketException('x'));
    expect(
      () => QuoteService(client: client).fetchToday(),
      throwsA(isA<QuoteException>()
          .having((e) => e.type, 'type', QuoteErrorType.offline)),
    );
  });
}
