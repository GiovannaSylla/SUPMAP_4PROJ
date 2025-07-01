import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Center(
        child: auth.user == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email : ${auth.user?.email ?? "inconnu"}'),
            const SizedBox(height: 10),
            Text('Rôle : ${auth.role ?? "chargement..."}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                auth.logout();
                Navigator.pop(context);
              },
              child: const Text('Déconnexion'),
            )
          ],
        ),
      ),
    );
  }
}