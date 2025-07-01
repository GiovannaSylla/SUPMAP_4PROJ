import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: auth.isLoggedIn
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () async {
            try {
              await auth.login();
              await auth.fetchUserRole(); // ✅ rôle depuis backend

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } catch (_) {}
          },
          child: const Text('Se connecter avec Auth0'),
        ),
      ),
    );
  }
}