import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/prescricao_repository.dart';
import '../models/prescricao.dart';
import '../models/paciente.dart';
import '../services/calculation_service.dart';

class PrescricaoScreen extends StatefulWidget {
  final Paciente paciente;
  const PrescricaoScreen({super.key, required this.paciente});

  @override
  State<PrescricaoScreen> createState() => _PrescricaoScreenState();
}

class _PrescricaoScreenState extends State<PrescricaoScreen> {
  late final PrescricaoRepository _repo;

  String sensibilidade = 'usual';
  String dieta = 'oral';
  String corticoide = 'nao';
  bool doencaHepatica = false;
  String classificacaoClinica = 'nao_critico';

  String insulinaBasalTipo = 'NPH';
  String insulinaBasalSchedule = '3x';
  String insulinaRapidaTipo = 'Regular';
  String bolusPrandial = 'padrao_3x';
  double step = 1;
  CalcResult? resultado;

  @override
  void initState() {
    super.initState();
    _repo = PrescricaoRepository();

    sensibilidade = widget.paciente.sensibilidade.isNotEmpty
        ? widget.paciente.sensibilidade
        : 'usual';

    classificacaoClinica = widget.paciente.classificacaoClinica.isNotEmpty
        ? widget.paciente.classificacaoClinica
        : 'nao_critico';
  }

  void _calcular() {
    setState(() {
      resultado = CalculationService.calcular(
        peso: widget.paciente.peso,
        sensibilidade: sensibilidade,
        dieta: dieta,
        corticoide: corticoide,
        doencaHepatica: doencaHepatica,
        step: step,
      );
    });
  }

  Future<void> _salvar() async {
    if (resultado == null) return;

    final pres = Prescricao(
      pacienteId: widget.paciente.id!,
      tipoBasal: insulinaBasalTipo,
      step: step,
      tdd: resultado!.tdd,
      basalTotal: resultado!.basalRounded,
      prandialTotal: resultado!.prandialTotal,
      prandialPerMeal: resultado!.prandialRef,
      dieta: dieta,
      corticoide: corticoide,
      doencaHepatica: doencaHepatica ? 1 : 0,
      classificacaoClinica: classificacaoClinica,
      insulinaBasalSchedule: insulinaBasalSchedule,
      insulinaRapidaTipo: insulinaRapidaTipo,
      bolusPrandial: bolusPrandial,
      notas: 'Gerado automaticamente; individualizar.',
    );

    await _repo.inserir(pres);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prescrição salva com sucesso!')),
    );
  }

  Future<void> _gerarPdf() async {
    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calcule a prescrição antes de gerar o PDF.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) =>
            _buildPdfPage(ctx, widget.paciente, resultado!),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildPdfPage(pw.Context ctx, Paciente p, CalcResult r) {
    String uiStr(num v, {int decimals = 0}) => v.toStringAsFixed(decimals);

    final double bolusFixo = r.prandialRef;
    final int fs = r.fatorSensibilidade;
    final double step = r.step;

    double calcDoseTotal(int glicemiaRef) {
      double correcao = (glicemiaRef - 100) / fs;
      if (correcao < 0) correcao = 0;

      double total = bolusFixo + correcao;

      if (step == 2) {
        return (total / step).ceil() * step;
      }
      return ((total / step).round()) * step;
    }

    final tabelaRows = [
      ['Glicemia (mg/dL)', 'Dose Total ($insulinaRapidaTipo SC)'],
      ['< 100', '${uiStr(bolusFixo)} UI (apenas se ingerir refeição)'],
      [
        '100–140',
        '${uiStr(calcDoseTotal(120))} UI (Correção baseada em ~120mg/dL)',
      ],
      [
        '141–180',
        '${uiStr(calcDoseTotal(160))} UI (Correção baseada em ~160mg/dL)',
      ],
      [
        '181–220',
        '${uiStr(calcDoseTotal(200))} UI (Correção baseada em ~200mg/dL)',
      ],
      [
        '221–260',
        '${uiStr(calcDoseTotal(240))} UI (Correção baseada em ~240mg/dL)',
      ],
      [
        '261–300',
        '${uiStr(calcDoseTotal(280))} UI (Correção baseada em ~280mg/dL)',
      ],
      ['> 300', '${uiStr(calcDoseTotal(320))} UI (+ checar cetonas)'],
    ];

    final tabela22h = [
      ['Glicemia (mg/dL)', 'Conduta às 22h'],
      ['< 100', 'Oferecer lanche'],
      ['100–250', 'Não aplicar'],
      ['250–350', 'Aplicar 2 UI $insulinaRapidaTipo SC'],
      ['> 350', 'Aplicar 4 UI $insulinaRapidaTipo SC'],
    ];

    String basalScheduleText;
    if (insulinaBasalTipo == 'NPH' || insulinaBasalSchedule == '3x') {
      basalScheduleText =
          'NPH SC preferencial em 3 doses (ex.: 6h, 11h e 22h). Total basal: ${uiStr(r.basalRounded)} UI/dia.';
    } else if (insulinaBasalSchedule == '2x') {
      basalScheduleText =
          '${insulinaBasalTipo} SC em 2 doses (ex.: 2/3 manhã, 1/3 noite) — total basal ${uiStr(r.basalRounded)} UI/dia.';
    } else {
      basalScheduleText =
          '${insulinaBasalTipo} SC 1x/dia (ex.: 22h) — total basal ${uiStr(r.basalRounded)} UI/dia.';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 0, text: 'Prescrição Médica — InsuGuia'),
        pw.Text('Paciente: ${p.nome} — ${p.idade} anos — Peso: ${p.peso} kg'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Classificação clínica: ${_labelClassificacao(classificacaoClinica)}',
        ),
        pw.Text('Dieta: ${_labelDieta(dieta)}'),
        pw.Text('Uso de corticoide: ${_labelCorticoide(corticoide)}'),
        pw.Text('Doença hepática: ${doencaHepatica ? "Sim" : "Não"}'),
        pw.Text('Sensibilidade considerada: $sensibilidade (Fator: 1:${fs})'),

        pw.SizedBox(height: 12),
        pw.Text(
          'Cálculo (orientativo):',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Bullet(text: 'TDD estimada: ${uiStr(r.tdd, decimals: 0)} UI/dia'),
        pw.Bullet(
          text: 'Basal (50% TDD): ${uiStr(r.basalRounded, decimals: 0)} UI/dia',
        ),
        pw.Bullet(
          text: 'Prandial total: ${uiStr(r.prandialTotal, decimals: 0)} UI/dia',
        ),
        if (r.prandialRef > 0)
          pw.Bullet(
            text:
                'Bôlus fixo por refeição (antes da correção): ${uiStr(r.prandialRef, decimals: 0)} UI',
          ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Insulina basal — sugestão:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(basalScheduleText),
        pw.SizedBox(height: 8),
        pw.Text(
          'Insulina prandial / correção:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Tipo: $insulinaRapidaTipo\nMétodo: ${_labelBolus(bolusPrandial)}',
        ),
        pw.SizedBox(height: 12),

        pw.Text(
          'Tabela de Dosagem (Antes do café/almoço/jantar):',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Dose = Bôlus Fixo (${uiStr(bolusFixo)} UI) + Correção (Fator 1:${fs})',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(),
          children: tabelaRows.map((r) {
            return pw.TableRow(
              children: r
                  .map(
                    (c) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(c),
                    ),
                  )
                  .toList(),
            );
          }).toList(),
        ),

        pw.SizedBox(height: 12),
        pw.Text(
          'Conduta para glicemia das 22h:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(),
          children: tabela22h.map((r) {
            return pw.TableRow(
              children: r
                  .map(
                    (c) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(c),
                    ),
                  )
                  .toList(),
            );
          }).toList(),
        ),

        pw.SizedBox(height: 12),
        pw.Text(
          'Hipoglicemia — conduta:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Se glicemia capilar < 70 mg/dL:'),
        pw.Bullet(
          text:
              'Consciente: oferecer 30 mL de glicose 50% (ou líquido açucarado).',
        ),
        pw.Bullet(
          text:
              'Inconsciente: aplicar 30 mL de glicose 50% IV em veia calibrosa.',
        ),
        pw.Text('Repetir glicemia a cada 15 min até > 100 mg/dL.'),

        pw.Spacer(),
        pw.Divider(),
        pw.Text(
          'Documento gerado pelo InsuGuia — ${DateTime.now().toLocal().toString().substring(0, 16)}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildResultado(BuildContext context) {
    final r = resultado!;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado do cálculo (orientativo)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('TDD (UI/dia): ${r.tdd.toStringAsFixed(0)}'),
            Text(
              'Basal estimada (UI/dia): ${r.basalRounded.toStringAsFixed(0)}',
            ),
            Text(
              'Prandial total (UI/dia): ${r.prandialTotal.toStringAsFixed(0)}',
            ),
            if (r.prandialRef > 0)
              Text(
                'Bôlus aprox por refeição: ${r.prandialRef.toStringAsFixed(0)} UI',
              ),
            const SizedBox(height: 12),
            const Text(
              'Sugestão de prescrição:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text('• Dieta: ${_labelDieta(dieta)}'),
            Text('• Monitorização: ${_labelMonitorizacao(dieta)}'),
            Text(
              '• Insulina basal sugerida: ${insulinaBasalTipo} — ${r.basalRounded.toStringAsFixed(0)} UI/dia (${_labelBasalSchedule(insulinaBasalTipo, insulinaBasalSchedule, r.basalRounded)})',
            ),
            if (r.prandialRef > 0)
              Text(
                '• Insulina prandial: ${insulinaRapidaTipo} — ${r.prandialRef.toStringAsFixed(0)} UI (fixo) + Correção conforme tabela.',
              ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Verifique a tabela completa gerando o PDF.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelDieta(String d) {
    switch (d) {
      case 'enteral':
        return 'Enteral contínua';
      case 'npo':
        return 'NPO (jejum)';
      case 'oral_ma':
        return 'Oral (má aceitação)';
      default:
        return 'Oral';
    }
  }

  String _labelCorticoide(String c) {
    switch (c) {
      case 'pred_baixa':
        return 'Prednisona baixa dose';
      case 'pred_media':
        return 'Prednisona média dose';
      case 'pred_alta':
        return 'Prednisona alta dose';
      default:
        return 'Não';
    }
  }

  String _labelBolus(String b) {
    switch (b) {
      case 'enteral_4x':
        return 'Enteral: 4 doses a cada 6h (metade do bôlus total)';
      case 'correcao_apenas':
        return 'Correção apenas (sem bôlus pré-prandial)';
      default:
        return 'Bôlus padrão 3x (50% da TDD dividido em 3)';
    }
  }

  String _labelMonitorizacao(String d) {
    if (d.contains('oral')) {
      return 'Glicemia capilar antes do café, do almoço, do jantar e às 22h';
    } else {
      return 'Glicemia capilar a cada 4-6 horas (ou 6/6h) conforme dieta enteral/parenteral';
    }
  }

  String _labelBasalSchedule(String tipo, String schedule, num basal) {
    if (tipo == 'NPH' || schedule == '3x') {
      final each = (basal / 3).round();
      return 'sugestão NPH 3x: ${each} UI às 6h, ${each} UI ao almoço e ${each} UI às 22h';
    } else if (schedule == '2x') {
      final each = (basal / 2).round();
      return '2x: ${each} UI (manhã) e ${each} UI (noite)';
    } else {
      return '1x: ${basal.round()} UI (uma vez ao dia)';
    }
  }

  String _labelClassificacao(String c) {
    switch (c) {
      case 'gestante':
        return 'Gestante';
      case 'critico':
        return 'Paciente crítico';
      case 'paliativo':
        return 'Cuidados paliativos';
      case 'periop':
        return 'Perioperatório';
      default:
        return 'Não crítico (Hiperglicemia hospitalar)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.paciente;
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescrição - ${p.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Salvar/Compartilhar PDF',
            onPressed: _gerarPdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text('${p.nome} — ${p.idade} anos — ${p.peso} kg'),
            const SizedBox(height: 8),

            const Text('Classificação clínica:'),
            DropdownButton<String>(
              value: classificacaoClinica,
              isExpanded: true,
              onChanged: (v) => setState(() => classificacaoClinica = v!),
              items: const [
                DropdownMenuItem(
                  value: 'nao_critico',
                  child: Text('1. Não crítico (Hiperglicemia hospitalar)'),
                ),
                DropdownMenuItem(value: 'gestante', child: Text('2. Gestante')),
                DropdownMenuItem(
                  value: 'critico',
                  child: Text('3. Paciente crítico'),
                ),
                DropdownMenuItem(
                  value: 'paliativo',
                  child: Text('4. Cuidados paliativos'),
                ),
                DropdownMenuItem(
                  value: 'periop',
                  child: Text('5. Perioperatório'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Sensibilidade insulínica (Baseada no IMC/Histórico):'),
            DropdownButton<String>(
              value: sensibilidade,
              isExpanded: true,
              onChanged: (v) => setState(() => sensibilidade = v!),
              items: const [
                DropdownMenuItem(
                  value: 'sensivel',
                  child: Text('Sensível (Fator 80)'),
                ),
                DropdownMenuItem(
                  value: 'usual',
                  child: Text('Usual (Fator 40)'),
                ),
                DropdownMenuItem(
                  value: 'resistente',
                  child: Text('Resistente (Fator 20)'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Dieta:'),
            DropdownButton<String>(
              value: dieta,
              isExpanded: true,
              onChanged: (v) => setState(() => dieta = v!),
              items: const [
                DropdownMenuItem(
                  value: 'oral',
                  child: Text('Oral (Boa aceitação)'),
                ),
                DropdownMenuItem(
                  value: 'oral_ma',
                  child: Text('Oral (Má aceitação)'),
                ),
                DropdownMenuItem(
                  value: 'enteral',
                  child: Text('Enteral contínua'),
                ),
                DropdownMenuItem(value: 'npo', child: Text('NPO (jejum)')),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Uso de corticoide:'),
            DropdownButton<String>(
              value: corticoide,
              isExpanded: true,
              onChanged: (v) => setState(() => corticoide = v!),
              items: const [
                DropdownMenuItem(value: 'nao', child: Text('Não')),
                DropdownMenuItem(
                  value: 'pred_baixa',
                  child: Text('Prednisona baixa dose'),
                ),
                DropdownMenuItem(
                  value: 'pred_media',
                  child: Text('Prednisona média dose'),
                ),
                DropdownMenuItem(
                  value: 'pred_alta',
                  child: Text('Prednisona alta dose'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const SizedBox(height: 8),
            const Text('Doença hepática (Reduz dose total):'),
            DropdownButton<String>(
              value: doencaHepatica ? 'sim' : 'nao',
              isExpanded: true,
              onChanged: (v) {
                setState(() {
                  doencaHepatica = (v == 'sim');
                });
              },
              items: const [
                DropdownMenuItem(value: 'nao', child: Text('Não')),
                DropdownMenuItem(value: 'sim', child: Text('Sim')),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Insulina basal (escolha tipo):'),
            DropdownButton<String>(
              value: insulinaBasalTipo,
              isExpanded: true,
              onChanged: (v) => setState(() => insulinaBasalTipo = v!),
              items: const [
                DropdownMenuItem(value: 'NPH', child: Text('NPH')),
                DropdownMenuItem(value: 'Glargina', child: Text('Glargina')),
                DropdownMenuItem(value: 'Degludeca', child: Text('Degludeca')),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Posologia basal (sugestões):'),
            DropdownButton<String>(
              value: insulinaBasalSchedule,
              isExpanded: true,
              onChanged: (v) => setState(() => insulinaBasalSchedule = v!),
              items: const [
                DropdownMenuItem(
                  value: '1x',
                  child: Text('1x/dia (glargina/degludeca)'),
                ),
                DropdownMenuItem(value: '2x', child: Text('2x/dia (NPH 2x)')),
                DropdownMenuItem(
                  value: '3x',
                  child: Text('3x/dia (NPH 3x preferencial)'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Insulina de ação rápida:'),
            DropdownButton<String>(
              value: insulinaRapidaTipo,
              isExpanded: true,
              onChanged: (v) => setState(() => insulinaRapidaTipo = v!),
              items: const [
                DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                DropdownMenuItem(value: 'Aspart', child: Text('Aspart')),
                DropdownMenuItem(value: 'Lispro', child: Text('Lispro')),
                DropdownMenuItem(value: 'Glulisina', child: Text('Glulisina')),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Estratégia de bôlus / correção:'),
            DropdownButton<String>(
              value: bolusPrandial,
              isExpanded: true,
              onChanged: (v) => setState(() => bolusPrandial = v!),
              items: const [
                DropdownMenuItem(
                  value: 'padrao_3x',
                  child: Text('Bôlus pré-prandial 3x (padrão)'),
                ),
                DropdownMenuItem(
                  value: 'enteral_4x',
                  child: Text('Enteral: 4 doses a cada 6h'),
                ),
                DropdownMenuItem(
                  value: 'correcao_apenas',
                  child: Text('Correção apenas'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Graduação do dispositivo (UI):'),
            DropdownButton<double>(
              value: step,
              isExpanded: true,
              onChanged: (v) => setState(() => step = v!),
              items: const [
                DropdownMenuItem(value: 0.5, child: Text('0.5 UI')),
                DropdownMenuItem(value: 1, child: Text('1 UI')),
                DropdownMenuItem(value: 2, child: Text('2 UI')),
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular Prescrição'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            if (resultado != null) _buildResultado(context),
            if (resultado != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Prescrição'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _buscarUltimaPrescricao() async {
    final lista = await _repo.listarPorPaciente(widget.paciente.id!);

    if (lista.isNotEmpty) {
      final ultima = lista.last;

      setState(() {
        dieta = ultima.dieta;
        corticoide = ultima.corticoide;
        doencaHepatica = ultima.doencaHepatica == 1;
        classificacaoClinica = ultima.classificacaoClinica;

        insulinaBasalTipo = ultima.tipoBasal;
        insulinaBasalSchedule = ultima.insulinaBasalSchedule;
        insulinaRapidaTipo = ultima.insulinaRapidaTipo;
        bolusPrandial = ultima.bolusPrandial;
        step = ultima.step;
      });

      _calcular();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Última prescrição carregada com sucesso.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
