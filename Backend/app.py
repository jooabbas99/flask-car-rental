from flask import Flask,request,jsonify
import mysql.connector


app = Flask(__name__)

mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  password="root",
   database="car_rental"
)

@app.route("/customers/")
def get_all_customers():
    sql = 'SELECT * FROM customer;'
    mycursor = mydb.cursor()  
    mycursor.execute(sql)
    myresult = mycursor.fetchall()
    return myresult

@app.route('/customer/<int:cid>', methods=['GET'])
def get_customer(cid):
    try:
        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM customer WHERE cid=%s", (cid,))

        myresult = mycursor.fetchone()

        if myresult:
            return jsonify({"customer": myresult}), 200
        else:
            return jsonify({"message": "Customer not found"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/customer/<int:cid>', methods=['PUT'])
def update_customer(cid):
    try:
        data = request.get_json()
        cid = data['cid']
        name = data['name']
        email = data['email']
        ssn = data['ssn']
        mycursor = mydb.cursor()
        mycursor.execute("UPDATE customer SET cname=%s, email=%s ,ssn=%s WHERE cid=%s", (name, email,ssn, cid))
        mydb.commit()
        return jsonify({"message": "Customer updated successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/customer/<int:cid>', methods=['DELETE'])
def delete_customer(cid):
    try:
        mycursor = mydb.cursor()
        mycursor.execute("DELETE FROM customer WHERE cid=%s", (cid,))
        mysql.connection.commit()
        cur.close()

        return jsonify({"message": "Customer deleted successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500