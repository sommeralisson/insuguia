import 'package:flutter/material.dart';
import '../models/medico.dart';
import '../models/paciente.dart';
import '../data/paciente_repository.dart';
import 'prescricao_screen.dart';
import 'acompanhamento_screen.dart';

class PacientesScreen extends StatefulWidget {
  final Medico medico;
  const PacientesScreen({super.key, required this.medico});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  late final PacienteRepository repo;

  final nomeCtrl = TextEditingController();
  final idadeCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();
  final creatininaCtrl = TextEditingController();
  final localCtrl = TextEditingController();

  String sexo = 'M';
  String sensibilidade = 'usual';
  String classificacao = 'nao_critico';

  List<Paciente> pacientes = [];

  @override
  void initState() {
    super.initState();
    repo = PacienteRepository();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await repo.listar();
      setState(() => pacientes = data);
    } catch (_) {}
  }

  Future<void> _salvar() async {
    if (nomeCtrl.text.isEmpty) return;

    await repo.inserir(
      Paciente(
        nome: nomeCtrl.text,
        sexo: sexo,
        idade: int.tryParse(idadeCtrl.text) ?? 0,
        peso: double.tryParse(pesoCtrl.text) ?? 0.0,
        altura: int.tryParse(alturaCtrl.text) ?? 0,
        creatinina: double.tryParse(creatininaCtrl.text) ?? 0.0,
        localInternacao: localCtrl.text,
        classificacaoClinica: classificacao,
        sensibilidade: sensibilidade,
      ),
    );

    nomeCtrl.clear();
    idadeCtrl.clear();
    pesoCtrl.clear();
    alturaCtrl.clear();
    creatininaCtrl.clear();
    localCtrl.clear();

    _load();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente salvo com sucesso!')),
      );
    }
  }

  Future<void> _deletar(int id) async {
    await repo.deletar(id);
    _load();
  }

  void _abrirOpcoes(Paciente p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text("Ver Prescrição"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrescricaoScreen(paciente: p),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text("Acompanhamento Glicêmico"),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcompanhamentoScreen(paciente: p),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Excluir"),
              onTap: () {
                Navigator.pop(ctx);
                _deletar(p.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medico = widget.medico;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pacientes - Dr(a). ${medico.nome.split(" ").first}"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Novo Paciente",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: nomeCtrl,
            decoration: const InputDecoration(labelText: "Nome completo"),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  value: sexo,
                  items: const [
                    DropdownMenuItem(value: "M", child: Text("Masculino")),
                    DropdownMenuItem(value: "F", child: Text("Feminino")),
                  ],
                  onChanged: (v) => setState(() => sexo = v!),
                  decoration: const InputDecoration(labelText: "Sexo"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField(
                  value: sensibilidade,
                  items: const [
                    DropdownMenuItem(
                      value: "sensivel",
                      child: Text("Sensível"),
                    ),
                    DropdownMenuItem(value: "usual", child: Text("Usual")),
                    DropdownMenuItem(
                      value: "resistente",
                      child: Text("Resistente"),
                    ),
                  ],
                  onChanged: (v) => setState(() => sensibilidade = v!),
                  decoration: const InputDecoration(labelText: "Sensibilidade"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: idadeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Idade (anos)"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: pesoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Peso (kg)"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: alturaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Altura (cm)"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: creatininaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Creatinina (mg/dL)",
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: localCtrl,
            decoration: const InputDecoration(labelText: "Local de Internação"),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField(
            value: classificacao,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: "nao_critico",
                child: Text("Não crítico (DM/Hiperglicemia hospitalar)"),
              ),
              DropdownMenuItem(value: "gestante", child: Text("Gestante")),
              DropdownMenuItem(
                value: "critico",
                child: Text("Paciente crítico"),
              ),
              DropdownMenuItem(
                value: "paliativo",
                child: Text("Cuidados paliativos"),
              ),
              DropdownMenuItem(value: "periop", child: Text("Perioperatório")),
            ],
            decoration: const InputDecoration(
              labelText: "Classificação Clínica",
            ),
            onChanged: (v) => setState(() => classificacao = v!),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Salvar Paciente"),
            onPressed: _salvar,
          ),

          const SizedBox(height: 32),
          const Text(
            "Pacientes cadastrados",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),

          pacientes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text("Nenhum paciente cadastrado."),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pacientes.length,
                  itemBuilder: (_, i) {
                    final p = pacientes[i];
                    return Card(
                      child: ListTile(
                        title: Text(p.nome),
                        subtitle: Text("${p.idade} anos • ${p.peso} kg"),
                        onTap: () => _abrirOpcoes(p),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
