# 📸 Flutter Portfolio - Galerie connectée

Une application Flutter multi-plateforme (mobile & desktop) permettant :
- l'inscription et la connexion d'utilisateurs,
- l'importation et l'affichage d’images personnelles via une API Flask sécurisée,
- la gestion de compte (modification e-mail / mot de passe, suppression),
- le stockage sécurisé des jetons avec `flutter_secure_storage`.

---

## 🚀 Fonctionnalités

✅ Authentification (inscription, connexion, déconnexion)  
✅ Galerie personnelle avec affichage des images  
✅ Importation d’images (`FilePicker`)  
✅ Suppression d’images  
✅ Gestion de compte utilisateur  
✅ Persistance de session via un token JWT  
✅ Navigation fluide entre les écrans

---

## 🛠️ Stack technique

### Frontend
- `Flutter`
- `flutter_secure_storage`
- `file_picker`
- `http`

### Backend (API REST)
- `Flask`
- `Flask-JWT-Extended`
- `SQLAlchemy`
- `SQLite`

---

## 🔧 Installation

### 🖥️ Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # ou venv\Scripts\activate sous Windows
pip install -r requirements.txt
flask run
```

### 📱 Frontend

```bash
cd frontend
flutter pub get
flutter run -d windows  # ou android, ios, web selon votre plateforme
```

### 🔐 Configuration

Assure-toi que l’URL de l’API (http://localhost:5000) est bien configurée dans api_service.dart :

```dart
static const String baseUrl = "http://localhost:5000";
```

### 📷 Aperçu

<blockquote class="imgur-embed-pub" lang="en" data-id="a/aqMr3Hs"  ><a href="//imgur.com/a/aqMr3Hs">Mon Portfolio</a></blockquote>

### 🧑‍💻 Auteur

* Thomas Lihoreau
* 📧 thomas.lihoreau@epitech.eu
* 💼 Projet personnel EPITECH / Portfolio

