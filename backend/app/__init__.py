from flask import Flask
from .extensions import db, jwt, cors
from .routes import auth, users, images
from config import Config

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    cors.init_app(app)
    db.init_app(app)
    jwt.init_app(app)

    app.register_blueprint(auth.bp)
    app.register_blueprint(users.bp)
    app.register_blueprint(images.bp)

    return app
