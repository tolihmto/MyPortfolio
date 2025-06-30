import os
from flask import Blueprint, request, send_from_directory, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from app.extensions import db
from app.models import Image
from app.utils import response

bp = Blueprint("images", __name__, url_prefix="/images")

UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")

@bp.route("/upload", methods=["POST"])
@jwt_required()
def upload_image():
    if 'image' not in request.files:
        return response(False, "Aucun fichier envoyé", code=400)

    file = request.files['image']
    if file.filename == '':
        return response(False, "Nom de fichier vide", code=400)

    filename = secure_filename(file.filename)
    user_id = int(get_jwt_identity())

    # 🔧 Créer le dossier s'il n'existe pas
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)

    save_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(save_path)

    image = Image(filename=filename, user_id=user_id)
    db.session.add(image)
    db.session.commit()

    return response(True, "Image uploadée", {"filename": filename})


@bp.route("/my", methods=["GET"])
@jwt_required()
def get_my_images():
    user_id = int(get_jwt_identity())
    images = Image.query.filter_by(user_id=user_id).all()
    return response(True, "Images récupérées", [img.filename for img in images])

@bp.route("/get/<filename>", methods=["GET"])
def get_image(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@bp.route("/delete/<filename>", methods=["DELETE"])
@jwt_required()
def delete_image(filename):
    user_id = int(get_jwt_identity())

    image = Image.query.filter_by(filename=filename, user_id=user_id).first()
    if not image:
        return response(False, "Image non trouvée ou non autorisée", code=404)

    # Supprimer le fichier du disque si présent
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    if os.path.exists(filepath):
        os.remove(filepath)

    # Supprimer de la base de données
    db.session.delete(image)
    db.session.commit()

    return response(True, "Image supprimée")
