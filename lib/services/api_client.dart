import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/annuncio.dart';
import '../config/api_config.dart';
import '../models/azienda.dart';
import '../models/candidatura.dart';

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

    final dati = jsonDecode(utf8.decode(risposta.bodyBytes));

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

    final dati = jsonDecode(utf8.decode(risposta.bodyBytes));

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
    final dati = await _post('/api/auth/register', {
      'nome': nome.trim(),
      'email': email.trim(),
      'password': password,
    });

    return Azienda.fromJson(dati);
  }

  Future<void> logout() async {
    final sessionToken = token;

    if (sessionToken == null) return;

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/logout');

    final risposta = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $sessionToken',
            'Accept': 'application/json',
          },
        )
        .timeout(ApiConfig.timeout);

    if (risposta.statusCode == 204 || risposta.statusCode == 401) {
      return;
    }

    String messaggio = 'Impossibile completare il logout.';

    try {
      final dati = jsonDecode(utf8.decode(risposta.bodyBytes));

      if (dati is Map<String, dynamic> && dati['error'] is String) {
        messaggio = dati['error'] as String;
      }
    } on FormatException {
      // Manteniamo il messaggio generico.
    }

    throw ApiException(risposta.statusCode, messaggio);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final dati = await _post('/api/auth/login', {
      'email': email.trim(),
      'password': password,
    });

    if (dati['token'] is! String ||
        (dati['token'] as String).isEmpty ||
        dati['azienda'] is! Map<String, dynamic>) {
      throw const FormatException('Risposta di login non valida.');
    }

    return dati;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    bool autenticata = false,
  }) async {
    final sessionToken = token;

    if (autenticata && (sessionToken == null || sessionToken.isEmpty)) {
      throw const ApiException(401, 'Accesso richiesto.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    final risposta = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
            if (autenticata) 'Authorization': 'Bearer $sessionToken',
          },
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);

    final testo = utf8.decode(risposta.bodyBytes);

    if (risposta.statusCode >= 400) {
      String messaggio = 'Errore del server (${risposta.statusCode}).';

      try {
        final errore = jsonDecode(testo);

        if (errore is Map<String, dynamic> && errore['error'] is String) {
          messaggio = errore['error'] as String;
        }
      } on FormatException {
        // Manteniamo il messaggio generico se il corpo non è JSON.
      }

      throw ApiException(risposta.statusCode, messaggio);
    }

    if (risposta.statusCode < 200 || risposta.statusCode >= 300) {
      throw ApiException(risposta.statusCode, 'Risposta HTTP inattesa.');
    }

    final dati = jsonDecode(testo);

    if (dati is! Map<String, dynamic>) {
      throw const FormatException(
        'La risposta deve contenere un oggetto JSON.',
      );
    }

    return dati;
  }

  Future<Annuncio> creaAnnuncio({
    required String titolo,
    required String descrizione,
  }) async {
    final dati = await _post('/api/annunci', {
      'titolo': titolo.trim(),
      'descrizione': descrizione.trim(),
    }, autenticata: true);

    return Annuncio.fromJson(dati);
  }

  Future<List<Annuncio>> getMieiAnnunci() async {
    final sessionToken = token;

    if (sessionToken == null || sessionToken.isEmpty) {
      throw const ApiException(401, 'Accesso richiesto.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/azienda/annunci');

    final risposta = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $sessionToken',
          },
        )
        .timeout(ApiConfig.timeout);

    final testo = utf8.decode(risposta.bodyBytes);

    if (risposta.statusCode >= 400) {
      String messaggio = 'Errore del server (${risposta.statusCode}).';

      try {
        final errore = jsonDecode(testo);

        if (errore is Map<String, dynamic> && errore['error'] is String) {
          messaggio = errore['error'] as String;
        }
      } on FormatException {
        // Manteniamo il messaggio generico.
      }

      throw ApiException(risposta.statusCode, messaggio);
    }

    if (risposta.statusCode != 200) {
      throw ApiException(risposta.statusCode, 'Risposta HTTP inattesa.');
    }

    final dati = jsonDecode(testo);

    if (dati is! List) {
      throw const FormatException(
        'La risposta deve contenere una lista di annunci.',
      );
    }

    return dati.map((elemento) {
      if (elemento is! Map<String, dynamic>) {
        throw const FormatException('Formato annuncio non valido.');
      }

      return Annuncio.fromJson(elemento);
    }).toList();
  }

  Future<int> inviaCandidatura({
    required int annuncioId,
    required String nome,
    required String cognome,
    required String email,
    required String cvNomeOriginale,
    required List<int> cvBytes,
  }) async {
    if (token != null) {
      throw const ApiException(
        403,
        'Effettua il logout per candidarti come visitatore.',
      );
    }

    if (cvBytes.isEmpty) {
      throw const ApiException(422, 'Seleziona un curriculum non vuoto.');
    }

    if (cvBytes.length > 5 * 1024 * 1024) {
      throw const ApiException(413, 'Il curriculum supera il limite di 5 MiB.');
    }

    final dati = await _post('/api/annunci/$annuncioId/candidature', {
      'nome': nome.trim(),
      'cognome': cognome.trim(),
      'email': email.trim(),
      'cvNomeOriginale': cvNomeOriginale,
      'cvBase64': base64Encode(cvBytes),
    });

    final id = dati['id'];

    if (id is! int || id <= 0) {
      throw const FormatException('Risposta di invio candidatura non valida.');
    }

    return id;
  }

  Future<List<Candidatura>> getCandidature(int annuncioId) async {
    final sessionToken = token;

    if (sessionToken == null || sessionToken.isEmpty) {
      throw const ApiException(401, 'Accesso richiesto.');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/annunci/$annuncioId/candidature',
    );

    final risposta = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $sessionToken',
          },
        )
        .timeout(ApiConfig.timeout);

    final testo = utf8.decode(risposta.bodyBytes);

    if (risposta.statusCode != 200) {
      String messaggio =
          'Impossibile caricare le candidature '
          '(${risposta.statusCode}).';

      try {
        final errore = jsonDecode(testo);

        if (errore is Map<String, dynamic> && errore['error'] is String) {
          messaggio = errore['error'] as String;
        }
      } on FormatException {
        // Manteniamo il messaggio generico.
      }

      throw ApiException(risposta.statusCode, messaggio);
    }

    final dati = jsonDecode(testo);

    if (dati is! List) {
      throw const FormatException(
        'La risposta deve contenere una lista di candidature.',
      );
    }

    return dati.map((elemento) {
      if (elemento is! Map<String, dynamic>) {
        throw const FormatException('Formato candidatura non valido.');
      }

      return Candidatura.fromJson(elemento);
    }).toList();
  }
}
