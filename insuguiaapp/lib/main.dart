import 'package:flutter/material.dart';
// Importa as duas telas que vamos usar nas rotas
import 'screens/login_screen.dart';
import 'screens/cadastro_medico_screen.dart';

// Imports necessários para o SQLite em Desktop
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

// 1. Marque a função main() como 'async'
void main() async {
  // 2. Garante que a "ponte" do Flutter esteja pronta
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Bloco de inicialização do FFI para Desktop (Windows, Linux, macOS)
  //    (Certifique-se de ter 'sqflite_common_ffi' no seu pubspec.yaml)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      // Inicializa o FFI
      sqfliteFfiInit();
      // Define a factory do banco de dados para a versão FFI
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      // Se algo der errado aqui, veremos no console.
      debugPrint("Erro ao inicializar o FFI do sqflite: $e");
    }
  }

  // 4. Executa o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove o banner "Debug"
      title: 'InsuGuia',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),

      // Usar rotas nomeadas é uma prática melhor que 'home:'
      // para permitir a navegação entre telas.
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroMedicoScreen(),
      },
    );
  }
}
