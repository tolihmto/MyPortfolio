import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/secure_storage.dart';
import '../main.dart'; // pour accéder à routeObserver

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with RouteAware {
  List<String> images = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadImages();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Rechargement quand on revient sur la galerie depuis Upload
    _loadImages();
  }

  Future<void> _loadImages() async {
    final token = await SecureStorage.readToken();
    final result = await ApiService.getUserImages();
    setState(() {
      images = result;
      isLoading = false;
    });
  }

  void _logout() async {
    await SecureStorage.deleteToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _deleteImage(String filename) async {
    final token = await SecureStorage.readToken();
    final result = await ApiService.deleteImage(filename, token!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma galerie"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/upload'),
            icon: const Icon(Icons.upload),
            tooltip: "Importer une image",
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/account'),
            icon: const Icon(Icons.settings),
            tooltip: "Mon compte",
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Se déconnecter",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
              ? const Center(child: Text("Aucune image à afficher."))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final filename = images[index];
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            "${ApiService.baseUrl}/images/get/$filename",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            color: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                              tooltip: "Supprimer l'image",
                              onPressed: () => _deleteImage(filename),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
