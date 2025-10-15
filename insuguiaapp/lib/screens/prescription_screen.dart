import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  void _copyPrescription(BuildContext context) {
    const prescriptionText = """
1. Insulina Basal: NPH 10 UI SC 22h.
2. Insulina Prandial (Bolus): Regular 5 UI SC antes do café, almoço e jantar.
3. Correção (Sliding Scale): Se glicemia > 180, administrar Insulina Regular...
4. Monitorar glicemia capilar 4x/dia.
""";
    Clipboard.setData(const ClipboardData(text: prescriptionText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescrição copiada para a área de transferência!'),
      ),
    );
  }

  void _exportPrescription() {
    print("Exportando prescrição...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescrição Sugerida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Prescrição Sugerida',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text('Blocos prontos para copiar/registrar.'),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    "1. Insulina Basal: NPH 10 UI SC 22h.\n"
                    "2. Insulina Prandial (Bolus): Regular 5 UI SC antes do café, almoço e jantar.\n"
                    "3. Correção (Sliding Scale): Se glicemia > 180, administrar Insulina Regular...\n"
                    "4. Monitorar glicemia capilar 4x/dia.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyPrescription(context),
                      label: const Text('Copiar'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print),
                      onPressed: _exportPrescription,
                      label: const Text('Exportar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
