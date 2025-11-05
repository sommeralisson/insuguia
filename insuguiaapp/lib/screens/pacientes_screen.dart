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
  // 1. Em vez de inicializar agora, marque como 'late final'
  late final PacienteRepository repo;

  final nomeCtrl = TextEditingController();
  final idadeCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();
  final creatininaCtrl = TextEditingController();

  String sexo = 'M';
  String sensibilidade = 'usual';
  List<Paciente> pacientes = [];

  @override
  void initState() {
    super.initState();
    // 2. Inicialize o repositório AQUI, dentro do initState.
    //    Neste ponto, o FFI do main.dart já foi executado.
    repo = PacienteRepository();

    // 3. Agora podemos carregar os dados com segurança.
    _load();
  }

  Future<void> _load() async {
    // Adicionado um try-catch por segurança
    try {
      final data = await repo.listar();
      setState(() => pacientes = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pacientes: $e')),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (nomeCtrl.text.isEmpty || pesoCtrl.text.isEmpty) return;

    await repo.inserir(
      Paciente(
        nome: nomeCtrl.text,
        sexo: sexo,
        idade: int.tryParse(idadeCtrl.text) ?? 0,
        peso: double.tryParse(pesoCtrl.text) ?? 0,
        altura: double.tryParse(alturaCtrl.text) ?? 0,
        creatinina: double.tryParse(creatininaCtrl.text) ?? 0,
        sensibilidade: sensibilidade,
      ),
    );

    nomeCtrl.clear();
    idadeCtrl.clear();
    pesoCtrl.clear();
    alturaCtrl.clear();
    creatininaCtrl.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente salvo com sucesso!')),
      );
    }
    _load();
  }

  Future<void> _deletar(int id) async {
    await repo.deletar(id);
    _load();
  }

  void _abrirOpcoesPaciente(Paciente p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Ver Prescrição'),
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
              title: const Text('Acompanhamento Glicêmico'),
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
              title: const Text('Excluir Paciente'),
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
        title: Text(
            'Pacientes - Dr(a). ${medico.nome.split(" ").first}'), // Mostra só o primeiro nome
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Convertido para ListView para o formulário ficar acima da lista
        child: ListView(
          children: [
            const Text(
              'Novo Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome completo'),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: sexo,
                    decoration: const InputDecoration(labelText: 'Sexo'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Masculino')),
                      DropdownMenuItem(value: 'F', child: Text('Feminino')),
                    ],
                    onChanged: (v) => setState(() => sexo = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: sensibilidade,
                    decoration: const InputDecoration(
                      labelText: 'Sensibilidade',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sensivel',
                        child: Text('Sensível'),
                      ),
                      DropdownMenuItem(value: 'usual', child: Text('Usual')),
                      DropdownMenuItem(
                        value: 'resistente',
                        child: Text('Resistente'),
                      ),
                    ],
                    onChanged: (v) => setState(() => sensibilidade = v!),
                  ),
                ),
              ],
            ),
            TextField(
              controller: idadeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Idade (anos)'),
            ),
            TextField(
              controller: pesoCtrl,
              keyboardType: TextInputType.number, // <<--- CORRIGIDO AQUI
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            TextField(
              controller: alturaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Altura (m)'),
            ),
            TextField(
              controller: creatininaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Creatinina (mg/dL)',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Paciente'),
            ),
            const Divider(height: 32),
            const Text(
              'Pacientes Cadastrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            pacientes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Nenhum paciente cadastrado ainda.'),
                    ),
                  )
                // Usei um Column+shrinkWrap para a lista dentro de outra lista
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pacientes.length,
                    itemBuilder: (_, i) {
                      final p = pacientes[i];
                      return Card(
                        child: ListTile(
                          title: Text(p.nome),
                          subtitle: Text(
                            '${p.idade} anos • ${p.peso} kg • ${p.sensibilidade}',
                          ),
                          onTap: () => _abrirOpcoesPaciente(p),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
