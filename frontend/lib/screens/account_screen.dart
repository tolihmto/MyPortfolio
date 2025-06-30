import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/secure_storage.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String result = '';

  void _updateEmail() async {
    final token = await SecureStorage.readToken();
    if (token == null) return;
    final res = await ApiService.updateEmail(emailController.text.trim(), token);
    setState(() => result = res);
  }

  void _updatePassword() async {
    final token = await SecureStorage.readToken();
    if (token == null) return;
    final res = await ApiService.updatePassword(passwordController.text, token);
    setState(() => result = res);
  }

  void _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      final token = await SecureStorage.readToken();
      if (token == null) return;
      final res = await ApiService.deleteAccount(token);
      await SecureStorage.deleteToken();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gérer mon compte")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Nouvel email"),
            ),
            ElevatedButton(
              onPressed: _updateEmail,
              child: const Text("Mettre à jour l’email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _updatePassword,
              child: const Text("Mettre à jour le mot de passe"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _deleteAccount,
              child: const Text("Supprimer mon compte", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            if (result.isNotEmpty)
              Text(
                result,
                style: TextStyle(
                  color: result.toLowerCase().contains('succès') ? Colors.green : Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
