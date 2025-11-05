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
  // Corrigido: Inicialização tardia para evitar erros de banco de dados
  late final PrescricaoRepository _repo;

  String sensibilidade = 'usual';
  String dieta = 'oral';
  String corticoide = 'nao';
  double step = 1;
  CalcResult? resultado;

  @override
  void initState() {
    super.initState();
    // Inicializa o repositório aqui
    _repo = PrescricaoRepository();

    // Define a sensibilidade padrão com base no paciente
    sensibilidade = widget.paciente.sensibilidade;
  }

  void _calcular() {
    setState(() {
      resultado = CalculationService.calcular(
        peso: widget.paciente.peso,
        sensibilidade: sensibilidade,
        dieta: dieta,
        corticoide: corticoide,
        step: step,
      );
    });
  }

  Future<void> _salvar() async {
    if (resultado == null) return;
    await _repo.inserir(
      Prescricao(
        pacienteId: widget.paciente.id!,
        tipoBasal: 'nph',
        step: step,
        tdd: resultado!.tdd,
        basalTotal: resultado!.basalRounded,
        prandialTotal: resultado!.prandial,
        notas: 'Gerado automaticamente conforme SBD 2025.',
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescrição salva com sucesso!')),
      );
    }
  }

  // --- Funções de Geração de PDF ---

  Future<void> _gerarPdf() async {
    // Só gera o PDF se um cálculo já foi feito
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
        build: (pw.Context context) {
          return _buildPdfPage(context, widget.paciente, resultado!);
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfPage(pw.Context context, Paciente paciente, CalcResult r) {
    // Usa os dados REAIS do paciente e do resultado para montar o PDF
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 0, text: 'Prescrição Médica - InsuGuia'),
        pw.Paragraph(
          text: 'Dados do Paciente:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Nome: ${paciente.nome}'),
        pw.Text('Idade: ${paciente.idade} anos'),
        pw.Text('Peso: ${paciente.peso} kg'),
        pw.Text('Sensibilidade: $sensibilidade'),
        pw.Text('Dieta: $dieta'),
        pw.Text('Uso de Corticoide: $corticoide'),
        // --- CORREÇÃO AQUI ---
        // O 'pw.Divider' não tem 'margin', usamos 'pw.Padding'
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 16),
          child: pw.Divider(),
        ),
        // --- FIM DA CORREÇÃO ---
        pw.Paragraph(
          text: 'Prescrição de Insulina (Cálculo Orientativo)',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.Bullet(
          text: 'Dose total diária (TDD): ${r.tdd.toStringAsFixed(1)} UI',
        ),
        pw.Bullet(text: 'Basal: ${r.basalRounded.toStringAsFixed(1)} UI'),
        pw.Bullet(text: 'Prandial total: ${r.prandial.toStringAsFixed(1)} UI'),
        if (r.prandialPerMealRounded > 0)
          pw.Bullet(
            text:
                'Bôlus por refeição: ${r.prandialPerMealRounded.toStringAsFixed(1)} UI',
          ),
        pw.SizedBox(height: 24),
        pw.Paragraph(
          text: 'Sugestão de prescrição:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Bullet(text: 'Dieta para diabético'),
        pw.Bullet(text: 'Monitorização da glicemia capilar'),
        pw.Bullet(
          text: 'Insulina NPH SC – ${r.basalRounded.toStringAsFixed(0)} UI/dia',
        ),
        if (r.prandialPerMealRounded > 0)
          pw.Bullet(
            text:
                'Insulina Regular/Ação rápida – ${r.prandialPerMealRounded.toStringAsFixed(0)} UI antes das refeições',
          ),
        pw.SizedBox(height: 40),
        pw.Paragraph(
          text:
              '⚠️ Este cálculo é apenas orientativo. A decisão terapêutica final é do médico.',
          style: pw.TextStyle(
            color: PdfColors.orange700,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.Expanded(child: pw.Container()),
        pw.Footer(
          title: pw.Text(
            'Documento gerado via InsuGuia - ${DateTime.now().toLocal().toString().substring(0, 16)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  // --- Fim das Funções de PDF ---

  @override
  Widget build(BuildContext context) {
    final p = widget.paciente;
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescrição - ${p.nome}'),
        actions: [
          // Botão para gerar o PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Salvar/Compartilhar PDF',
            onPressed: _gerarPdf, // Chama a nova função
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Peso: ${p.peso} kg   •   Sensibilidade insulínica:'),
            DropdownButton<String>(
              value: sensibilidade,
              isExpanded: true, // Garante que o dropdown ocupe a largura
              onChanged: (v) => setState(() => sensibilidade = v!),
              items: const [
                DropdownMenuItem(value: 'sensivel', child: Text('Sensível')),
                DropdownMenuItem(value: 'usual', child: Text('Usual')),
                DropdownMenuItem(
                  value: 'resistente',
                  child: Text('Resistente'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Dieta:'),
            DropdownButton<String>(
              value: dieta,
              isExpanded: true,
              onChanged: (v) => setState(() => dieta = v!),
              items: const [
                DropdownMenuItem(value: 'oral', child: Text('Oral')),
                DropdownMenuItem(value: 'enteral', child: Text('Enteral')),
                DropdownMenuItem(value: 'npo', child: Text('NPO (jejum)')),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            const Text('Graduação do dispositivo:'),
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular Prescrição'),
            ),
            const SizedBox(height: 16),
            if (resultado != null) _buildResultado(context),
            if (resultado != null)
              Padding(
                // Adiciona um espaçamento
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

  Widget _buildResultado(BuildContext context) {
    final r = resultado!;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dose total diária (TDD): ${r.tdd.toStringAsFixed(1)} UI'),
            Text('Basal: ${r.basalRounded.toStringAsFixed(1)} UI'),
            Text('Prandial total: ${r.prandial.toStringAsFixed(1)} UI'),
            if (r.prandialPerMealRounded > 0)
              Text(
                'Bôlus por refeição: ${r.prandialPerMealRounded.toStringAsFixed(1)} UI',
              ),
            const SizedBox(height: 8),
            const Text('Sugestão de prescrição:'),
            const Divider(),
            Text('• Dieta para diabético'),
            Text('• Monitorização da glicemia capilar'),
            Text(
              '• Insulina NPH SC – ${r.basalRounded.toStringAsFixed(0)} UI/dia',
            ),
            if (r.prandialPerMealRounded > 0)
              Text(
                '• Insulina Regular/Ação rápida – ${r.prandialPerMealRounded.toStringAsFixed(0)} UI antes das refeições',
              ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Este cálculo é apenas orientativo. A decisão terapêutica final é do médico.',
              style: TextStyle(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
