import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/secure_storage.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool isUploading = false;
  String? resultMessage;

  Future<void> _uploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final token = await SecureStorage.readToken();
    if (token == null) {
      setState(() => resultMessage = "Erreur : token non trouvé");
      return;
    }

    setState(() => isUploading = true);

    final response = await ApiService.uploadImage(result.files.single, token);

    setState(() {
      resultMessage = "Image '$response' importée avec succès.";
      isUploading = false;
    });
  }

  bool _isSuccessMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains("succès") || lower.contains("réussite");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Importer une image")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: isUploading ? null : _uploadImage,
              icon: const Icon(Icons.upload_file),
              label: const Text("Choisir une image"),
            ),
            const SizedBox(height: 20),
            if (isUploading) ...[
              const CircularProgressIndicator(),
            ] else if (resultMessage != null) ...[
              Text(
                resultMessage!,
                style: TextStyle(
                  color: _isSuccessMessage(resultMessage!) ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Retour à la galerie"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
