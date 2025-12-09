class Contact {
  final String id;
  final String nome;
  final String telefone;
  final String endereco;
  final String relacao;
  final String? observacao; // campo opcional, por isso o ?

  Contact({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.relacao,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
      'relacao': relacao,
      if (observacao != null && observacao!.isNotEmpty)
        'observacao': observacao,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map, String docId) {
    return Contact(
      id: docId,
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      endereco: map['endereco'] ?? '',
      relacao: map['relacao'] ?? '',
      observacao: map['observacao'], // pode ser nulo
    );
  }
}
