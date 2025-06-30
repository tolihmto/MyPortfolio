import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'secure_storage.dart'; // Corrigé : on importe ici ta classe SecureStorage

class ApiService {
  static const String baseUrl = "http://localhost:5000";

  // Authentification
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["data"]?["access_token"];

      if (token == null || token.isEmpty) {
        throw Exception("Token manquant dans la réponse du serveur.");
      }

      return {
        "success": true,
        "token": token,
      };
    } else {
      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": data["message"] ?? "Erreur inconnue",
      };
    }
  }


  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {"success": true, "token": data["access_token"]};
    } else {
      final message = jsonDecode(response.body)["message"] ?? "Erreur d'inscription";
      return {"success": false, "message": message};
    }
  }

  // Récupérer les images
  static Future<List<String>> getUserImages() async {
    final token = await SecureStorage.readToken();

    final response = await http.get(
      Uri.parse("$baseUrl/images/my"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic>? images = json["data"];
      if (images == null) {
        throw Exception("Liste d'images absente dans la réponse");
      }
      return List<String>.from(images);
    } else {
      throw Exception("Erreur lors du chargement des images");
    }
  }


  // Upload d'image
  static Future<String> uploadImage(PlatformFile file, String token) async {
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/images/upload"));
    request.headers["Authorization"] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath("image", file.path!));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json["data"] != null && json["data"]["filename"] != null) {
        return json["data"]["filename"];
      } else {
        throw Exception("Réponse invalide du serveur (pas de 'filename')");
      }
    } else {
      throw Exception("Erreur lors de l'upload : ${response.body}");
    }
  }


  // Suppression d'une image
  static Future<String> deleteImage(String filename, String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/images/delete/$filename"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return "Image supprimée avec succès.";
    } else {
      final message = jsonDecode(response.body)["message"] ?? "Erreur";
      return "Erreur lors de la suppression : $message";
    }
  }

  // Mise à jour de l'email
  static Future<String> updateEmail(String email, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/users/update_email"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return "Email mis à jour.";
    } else {
      final message = jsonDecode(response.body)["message"] ?? "Erreur";
      return "Erreur email : $message";
    }
  }

  // Mise à jour du mot de passe
  static Future<String> updatePassword(String password, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/users/update_password"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"password": password}),
    );

    if (response.statusCode == 200) {
      return "Mot de passe mis à jour.";
    } else {
      final message = jsonDecode(response.body)["message"] ?? "Erreur";
      return "Erreur mot de passe : $message";
    }
  }

  // Suppression du compte
  static Future<String> deleteAccount(String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/users/delete"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return "Compte supprimé.";
    } else {
      final message = jsonDecode(response.body)["message"] ?? "Erreur";
      return "Erreur suppression : $message";
    }
  }
}
