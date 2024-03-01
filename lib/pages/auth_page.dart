import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utcapp/pages/login_page.dart'; // Importa la página de inicio de sesión
import 'home_page.dart'; // Importa la página de inicio

class AuthPage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const AuthPage({Key? key}); // Corrige la definición del constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Stream para detectar cambios en el estado de autenticación
        builder: (context, snapshot) {
          // Si hay datos en el snapshot, significa que el usuario está autenticado
          if (snapshot.hasData) {
            return HomePage(); // Retorna la página principal
          } else {
            return LoginPage(); // Si no hay datos en el snapshot, el usuario no está autenticado, devuelve la página de inicio de sesión
          }
        },
      ),
    );
  }
}
