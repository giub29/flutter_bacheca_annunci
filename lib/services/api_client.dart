import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiClient {
  Future<bool> verificaConnessione() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/health');

    final risposta = await http.get(uri).timeout(ApiConfig.timeout);

    if (risposta.statusCode != 200) {
      throw Exception('Il server ha restituito un errore.');
    }

    final dati = jsonDecode(
      utf8.decode(risposta.bodyBytes),
    );

    if (dati is! Map || dati['status'] != 'ok') {
      throw Exception('Risposta del server non valida.');
    }

    return true;
  }
}