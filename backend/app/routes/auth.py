from flask import Blueprint, request
from app.models import User
from app.extensions import db
from flask_jwt_extended import create_access_token
from app.utils import response

bp = Blueprint("auth", __name__, url_prefix="/auth")

@bp.route("/register", methods=["POST"])
def register():
    email = request.json.get("email")
    password = request.json.get("password")
    if not email or not password:
        return response(False, "Email et mot de passe requis", code=400)

    if User.query.filter_by(email=email).first():
        return response(False, "Utilisateur déjà existant", code=409)

    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()

    return response(True, "Inscription réussie", {"email": user.email})

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()

    if not user or not user.check_password(password):
        return response(False, "Identifiants invalides", code=401)

    access_token = create_access_token(identity=str(user.id))
    return response(True, "Connexion réussie", {"access_token": access_token})
