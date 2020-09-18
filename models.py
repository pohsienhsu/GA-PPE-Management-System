from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def connect_db(app):
    db.app = app
    db.init_app(app)

class Product(db.Model):
    """Product"""
    __tablename__ = "Products"
    __table_args__ = (
        db.UniqueConstraint('name_color', 'name_type', name='unique_color_type'),
    )

    def __repr__(self):
        product = self
        return f"<Product id={product.id} name_color={product.name_color} name_type={product.name_type}>"

    id = db.Column(db.CHAR(5), primary_key=True)
    name_color = db.Column(db.String(30), nullable=False)
    name_type = db.Column(db.String(30), nullable=False)







