import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/annuncio.dart';
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
}