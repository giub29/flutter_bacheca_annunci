class Annuncio {
  final int id;
  final int aziendaId;
  final String titolo;
  final String descrizione;

  const Annuncio({
    required this.id,
    required this.aziendaId,
    required this.titolo,
    required this.descrizione,
  });

  factory Annuncio.fromJson(Map<String, dynamic> json) {
    return Annuncio(
      id: json['id'] as int,
      aziendaId: json['aziendaId'] as int,
      titolo: json['titolo'] as String,
      descrizione: json['descrizione'] as String,
    );
  }
}