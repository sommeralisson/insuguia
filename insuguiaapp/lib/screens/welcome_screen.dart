import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Boas-vindas',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protótipo para auxílio à prescrição de insulina hospitalar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Card(
                    elevation: 0,
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade800,
                        ),
                        title: Text(
                          'Aviso Importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        subtitle: Text(
                          'As doses são sugestões baseadas nas diretrizes da SBD. A prescrição final é de responsabilidade médica.',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Entrar ou Registrar'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                    child: const Text('Ir direto para Cadastro do Paciente'),
                  ),
                  const Divider(height: 48),

                  ExpansionTile(
                    title: const Text(
                      'Como funciona o aplicativo?',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: <Widget>[
                      const ListTile(
                        leading: Text("1."),
                        title: Text('Entrar ou registrar'),
                      ),
                      const ListTile(
                        leading: Text("2."),
                        title: Text('Cadastro do paciente'),
                      ),
                      const ListTile(
                        leading: Text("3."),
                        title: Text('Classificação (5 cenários)'),
                      ),
                      const ListTile(
                        leading: Text("4."),
                        title: Text('Protocolo específico'),
                      ),
                      const ListTile(
                        leading: Text("5."),
                        title: Text('Prescrição sugerida'),
                      ),
                      const ListTile(
                        leading: Text("6."),
                        title: Text('Acompanhamento (opcional)'),
                      ),
                      const ListTile(
                        leading: Text("7."),
                        title: Text('Alta hospitalar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
