import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/glicemia_repository.dart';
import '../models/glicemia.dart';
import '../models/paciente.dart';

class AcompanhamentoScreen extends StatefulWidget {
  final Paciente paciente;
  const AcompanhamentoScreen({super.key, required this.paciente});

  @override
  State<AcompanhamentoScreen> createState() => _AcompanhamentoScreenState();
}

class _AcompanhamentoScreenState extends State<AcompanhamentoScreen> {
  final _repo = GlicemiaRepository();
  final _valorCtrl = TextEditingController();
  String tipo = 'jejum';
  List<Glicemia> glicemias = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.listarPorPaciente(widget.paciente.id!);
    setState(() => glicemias = data);
  }

  Future<void> _salvar() async {
    if (_valorCtrl.text.isEmpty) return;
    await _repo.inserir(
      Glicemia(
        pacienteId: widget.paciente.id!,
        valor: int.parse(_valorCtrl.text),
        horario: TimeOfDay.now().format(context),
        tipo: tipo,
      ),
    );
    _valorCtrl.clear();
    _load();
  }

  String _sugestaoAjuste(int valor) {
    if (valor < 70) return '⚠️ Hipoglicemia: reduzir dose e oferecer glicose.';
    if (valor >= 70 && valor <= 100)
      return 'Alvo inferior: manter esquema atual.';
    if (valor > 100 && valor <= 180) return '✅ Dentro do alvo (100–180 mg/dl).';
    if (valor > 180 && valor <= 250)
      return '🔸 Leve hiperglicemia: avaliar adesão e correção leve.';
    return '🔴 Glicemia >250 mg/dl: revisar esquema basal/bôlus e considerar ajuste.';
  }

  Widget _graficoGlicemias() {
    if (glicemias.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Sem dados suficientes para o gráfico")),
      );
    }

    final spots = glicemias
        .asMap()
        .entries
        .map((e) {
          final index = e.key;
          final g = e.value;
          return FlSpot(index.toDouble(), g.valor.toDouble());
        })
        .toList()
        .reversed
        .toList();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY:
              (glicemias.map((g) => g.valor).reduce((a, b) => a > b ? a : b) +
                      20)
                  .toDouble(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.paciente;

    return Scaffold(
      appBar: AppBar(title: Text('Acompanhamento - ${p.nome}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _graficoGlicemias(),

            const SizedBox(height: 20),

            const Text(
              'Registrar glicemia capilar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _valorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor (mg/dl)',
                prefixIcon: Icon(Icons.bloodtype),
              ),
            ),

            const SizedBox(height: 8),

            DropdownButton<String>(
              value: tipo,
              onChanged: (v) => setState(() => tipo = v!),
              items: const [
                DropdownMenuItem(value: 'jejum', child: Text('Jejum')),
                DropdownMenuItem(
                  value: 'pre-almoco',
                  child: Text('Antes do almoço'),
                ),
                DropdownMenuItem(
                  value: 'pre-jantar',
                  child: Text('Antes do jantar'),
                ),
                DropdownMenuItem(value: '22h', child: Text('22 horas')),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: const Text('Registrar'),
            ),

            const Divider(height: 24),

            Expanded(
              child: glicemias.isEmpty
                  ? const Center(child: Text('Nenhum registro ainda'))
                  : ListView.builder(
                      itemCount: glicemias.length,
                      itemBuilder: (_, i) {
                        final g = glicemias[i];
                        final msg = _sugestaoAjuste(g.valor);
                        final color = g.valor < 70
                            ? Colors.orange
                            : (g.valor > 250 ? Colors.red : Colors.green);

                        return Card(
                          child: ListTile(
                            title: Text('${g.valor} mg/dl (${g.tipo})'),
                            subtitle: Text(
                              msg,
                              style: TextStyle(color: color, fontSize: 13),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _repo.deletar(g.id!);
                                _load();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
