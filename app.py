from flask import Flask, session, render_template, redirect, request, json
from models import db, connect_db, Product

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:password@localhost/ga_ppe_sqlalchemy'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ECHO'] = True

connect_db(app)
db.create_all()

# db.engine.execute('INSERT INTO Products (id, name_color, name_type) VALUES ("WHMSK","white","mask"),("BLMSK","blue","mask"),("RDMSK","red","mask"),("GRMSK","green","mask"),("WHRES","white","respirator"),("YLRES","yellow","respirator"),("ORRES","orange","repirator"),("CLSHD","clear","shield"),("GRGOG","green","goggles"),("ORGOG","orange","goggles"),("WHGOG","white","goggles"),("BKGOG","black","goggles"),("BLSHC","blue","shoe cover"),("BLHOD","blue","hood"),("BLGWN","blue","gown"),("GRSHC","green","shoe cover"),("GRHOD","green","hood"),("GRGWN","green","gown"),("GYSHC","grey","shoe cover"),("GYHOD","grey","hood"),("GYGWN","grey","gown"),("WHSHC","white","shoe cover"),("WHHOD","white","hood"),("WHGWN","white","gown"),("BKSTE","black","stethoscope"),("WHSTE","white","stethoscope"),("SISTE","silver","stethoscope"),("BKGLO","black","gloves"),("WHGLO","white","gloves"),("GRGLO","green","gloves");')


@app.route('/')
def show_all_products():
    product_list = Product.query.all()
    length = len(product_list)

    return render_template('show_all_product.html', product_list=product_list, length=length)



