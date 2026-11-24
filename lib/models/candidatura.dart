class Candidatura {
  final int id;
  final int annuncioId;
  final String nome;
  final String cognome;
  final String email;
  final String cvNomeOriginale;
  final int cvDimensione;

  const Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.cvNomeOriginale,
    required this.cvDimensione,
  });

  factory Candidatura.fromJson(Map<String, dynamic> json) {
    return Candidatura(
      id: json['id'] as int,
      annuncioId: json['annuncioId'] as int,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      email: json['email'] as String,
      cvNomeOriginale: json['cvNomeOriginale'] as String,
      cvDimensione: json['cvDimensione'] as int,
    );
  }
}
