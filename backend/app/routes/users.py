from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db
from app.models import User
from app.utils import response

bp = Blueprint("users", __name__, url_prefix="/users")

@bp.route("/me", methods=["GET"])
@jwt_required()
def get_profile():
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    return response(True, "Profil récupéré", {"email": user.email})

@bp.route("/update_email", methods=["PUT"])
@jwt_required()
def update_email():
    new_email = request.json.get("email")
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    if not new_email:
        return response(False, "Nouvel email manquant", code=400)
    user.email = new_email
    db.session.commit()
    return response(True, "Email mis à jour", {"email": user.email})

@bp.route("/update_password", methods=["PUT"])
@jwt_required()
def update_password():
    new_password = request.json.get("password")
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    if not new_password:
        return response(False, "Nouveau mot de passe manquant", code=400)
    user.set_password(new_password)
    db.session.commit()
    return response(True, "Mot de passe mis à jour")

@bp.route("/delete", methods=["DELETE"])
@jwt_required()
def delete_user():
    user_id = int(get_jwt_identity())
    user = User.query.get(user_id)
    db.session.delete(user)
    db.session.commit()
    return response(True, "Utilisateur supprimé")
