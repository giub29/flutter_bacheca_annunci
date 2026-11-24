import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/annuncio.dart';
import '../config/api_config.dart';
import '../models/azienda.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  String? token;

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

  Future<List<Annuncio>> getAnnunci() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/annunci');

    final risposta = await http.get(uri).timeout(ApiConfig.timeout);

    if (risposta.statusCode != 200) {
      throw Exception('Impossibile caricare gli annunci.');
    }

    final dati = jsonDecode(
      utf8.decode(risposta.bodyBytes),
    );

    if (dati is! List) {
      throw const FormatException(
        'La risposta del server deve contenere una lista.',
      );
    }

    return dati.map((elemento) {
      if (elemento is! Map<String, dynamic>) {
        throw const FormatException('Formato annuncio non valido.');
      }

      return Annuncio.fromJson(elemento);
    }).toList();
  }

  Future<Azienda> registraAzienda({
    required String nome,
    required String email,
    required String password,
  }) async {
    final dati = await _post(
      '/api/auth/register',
      {
        'nome': nome.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    return Azienda.fromJson(dati);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final dati = await _post(
      '/api/auth/login',
      {
        'email': email.trim(),
        'password': password,
      },
    );

    if (dati['token'] is! String ||
        (dati['token'] as String).isEmpty ||
        dati['azienda'] is! Map<String, dynamic>) {
      throw const FormatException(
        'Risposta di login non valida.',
      );
    }

    return dati;
  }

  Future<Map<String, dynamic>> _post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final risposta = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    )
        .timeout(ApiConfig.timeout);

    final testo = utf8.decode(risposta.bodyBytes);

    if (risposta.statusCode >= 400) {
      String messaggio = 'Errore del server (${risposta.statusCode}).';

      try {
        final errore = jsonDecode(testo);

        if (errore is Map<String, dynamic> &&
            errore['error'] is String) {
          messaggio = errore['error'] as String;
        }
      } on FormatException {
        // Manteniamo il messaggio generico se il corpo non è JSON.
      }

      throw ApiException(risposta.statusCode, messaggio);
    }

    if (risposta.statusCode < 200 || risposta.statusCode >= 300) {
      throw ApiException(
        risposta.statusCode,
        'Risposta HTTP inattesa.',
      );
    }

    final dati = jsonDecode(testo);

    if (dati is! Map<String, dynamic>) {
      throw const FormatException(
        'La risposta deve contenere un oggetto JSON.',
      );
    }

    return dati;
  }
}