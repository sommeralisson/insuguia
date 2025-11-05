class Paciente {
  int? id;
  String nome;
  String sexo;
  int idade;
  double peso;
  double altura;
  double creatinina;
  String sensibilidade;

  Paciente({
    this.id,
    required this.nome,
    required this.sexo,
    required this.idade,
    required this.peso,
    required this.altura,
    required this.creatinina,
    required this.sensibilidade,
  });

  /// Converte um objeto Paciente em um Map.
  /// Usado para inserir/atualizar dados no banco de dados.
  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'sexo': sexo,
    'idade': idade,
    'peso': peso,
    'altura': altura,
    'creatinina': creatinina,
    'sensibilidade': sensibilidade,
  };

  factory Paciente.fromMap(Map<String, dynamic> map) => Paciente(
    id: map['id'],
    nome: map['nome'],
    sexo: map['sexo'],
    idade: map['idade'],
    peso: map['peso'],
    altura: map['altura'],
    creatinina: map['creatinina'],
    sensibilidade: map['sensibilidade'],
  );
}
