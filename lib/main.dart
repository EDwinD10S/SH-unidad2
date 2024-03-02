import 'package:flutter/material.dart'; //importamos material.iu
import 'package:utcapp/pages/auth_page.dart'; // Importamos la página de autenticación
import 'package:firebase_core/firebase_core.dart'; // Importamos Firebase Core
import 'firebase_options.dart'; // Importa las opciones de configuración de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // GarantizaMOS que los widgets de Flutter estén inicializados
  await Firebase.initializeApp( // Inicializa Firebase
    options: DefaultFirebaseOptions.currentPlatform, // Utiliza las opciones de configuración de Firebase
  );
  runApp(const MyApp()); // Ejecuta la aplicación Flutter
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}); // Constructor constante de la clase MyApp

  @override
  Widget build(BuildContext context) {
    // Método que construye la interfaz de usuario de la aplicación
    // ignore: prefer_const_constructors
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Deshabilita el banner de depuración
      home: const AuthPage(), // Establece la página inicial como la página de autenticación
    );
  }
}  