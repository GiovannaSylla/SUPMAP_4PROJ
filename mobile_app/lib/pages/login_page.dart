import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        // Redirection dès que l'utilisateur est connecté
        if (auth.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/map');
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Connexion')),
          body: Center(
            child: auth.isLoggedIn
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                try {
                  print("Connexion via AuthService...");
                  await auth.login();
                } catch (e) {
                  print("Erreur de connexion : $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur Auth0 : $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Se connecter avec Auth0'),
            ),
          ),
        );
      },
    );
  }
}