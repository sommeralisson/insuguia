import 'package:flutter/material.dart';

class DischargeScreen extends StatelessWidget {
  const DischargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orientações de Alta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orientações de Alta (modelo)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                const ListTile(
                  leading: Icon(Icons.medication),
                  title: Text(
                    'Reconciliação de medicamentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('(insulinas/ADO prévios)'),
                ),
                const ListTile(
                  leading: Icon(Icons.home_work),
                  title: Text(
                    'Plano domiciliar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Metas, automonitorização, ajustes simples.'),
                ),
                const ListTile(
                  leading: Icon(Icons.warning_amber),
                  title: Text(
                    'Sinais de alerta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('E retorno ambulatorial.'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Este bloco é um modelo; no produto final, será gerado sob medida a partir dos dados coletados.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
