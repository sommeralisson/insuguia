class Paciente {
  int? id;
  String nome;
  String sexo;
  int idade;
  double peso;
  int altura;
  double creatinina;

  String localInternacao;
  String classificacaoClinica;
  String sensibilidade;

  Paciente({
    this.id,
    required this.nome,
    required this.sexo,
    required this.idade,
    required this.peso,
    required this.altura,
    required this.creatinina,
    required this.localInternacao,
    required this.classificacaoClinica,
    required this.sensibilidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'sexo': sexo,
      'idade': idade,
      'peso': peso,
      'altura': altura,
      'creatinina': creatinina,
      'local_internacao': localInternacao,
      'classificacao_clinica': classificacaoClinica,
      'sensibilidade': sensibilidade,
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'],
      nome: map['nome'],
      sexo: map['sexo'],
      idade: map['idade'],
      peso: map['peso'],
      altura: map['altura'],
      creatinina: map['creatinina'],
      localInternacao: map['local_internacao'],
      classificacaoClinica: map['classificacao_clinica'],
      sensibilidade: map['sensibilidade'],
    );
  }
}
