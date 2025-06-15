from flask import Flask, render_template, request, jsonify, session, redirect, url_for

import requests
import os

app = Flask(__name__)
app.secret_key = 'your_secret_key_here'  # Replace with a secure secret key

BACKEND_URL = os.environ.get('BACKEND_URL', 'http://localhost:4000')

@app.route('/')
def index():
    if 'username' not in session:
        return redirect(url_for('login'))
    return render_template('index.html', username=session['username'])

# -- Register a car --
@app.route('/register', methods=['POST'])
def register():
    if 'username' not in session:
        return redirect(url_for('login'))
    try:
        car_id = request.form['car_id']
        model = request.form['model']
        owner = request.form['owner']
        data = {'carId': car_id, 'model': model, 'owner': owner}
        headers = {'Content-Type': 'application/json'}
        response = requests.post(f'{BACKEND_URL}/register', json=data, headers=headers)
        response.raise_for_status()
        message = response.json()['message']
        return render_template('index.html', message=message, username=session['username'])
    except requests.exceptions.RequestException as e:
        return render_template('index.html', message=f"Error: Could not connect to backend - {e}", username=session['username'])
    except (KeyError, ValueError) as e:
        return render_template('index.html', message=f"Error: Invalid data received from backend - {e}", username=session['username'])
    except Exception as e:
        return render_template('index.html', message=f"Error: An unexpected error occurred - {e}", username=session['username'])

# -- View cars --
@app.route('/cars')
def cars():
    if 'username' not in session:
        return redirect(url_for('login'))
    try:
        response = requests.get(f'{BACKEND_URL}/cars')
        response.raise_for_status()
        cars = response.json()['result']
        return render_template('cars.html', cars=cars, username=session['username'])
    except requests.exceptions.RequestException as e:
        return render_template('cars.html', error=f"Error: Could not connect to backend - {e}", username=session['username'])
    except (KeyError, ValueError) as e:
        return render_template('cars.html', error=f"Error: Invalid data received from backend - {e}", username=session['username'])
    except Exception as e:
        return render_template('cars.html', error=f"Error: An unexpected error occurred - {e}", username=session['username'])

# -- View a specific car --
@app.route('/car/<id>')
def car(id):
    if 'username' not in session:
        return redirect(url_for('login'))
    try:
        response = requests.get(f'{BACKEND_URL}/car/{id}')
        response.raise_for_status()
        car = response.json()['result']
        return render_template('car.html', car=car, username=session['username'])
    except requests.exceptions.RequestException as e:
        return render_template('car.html', error=f"Error: Could not connect to backend - {e}", username=session['username'])
    except (KeyError, ValueError) as e:
        return render_template('car.html', error=f"Error: Invalid data received from backend - {e}", username=session['username'])
    except Exception as e:
        return render_template('car.html', error=f"Error: An unexpected error occurred - {e}", username=session['username'])

# -- User login --
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        data = {'username': username}
        try:
            response = requests.post(f'{BACKEND_URL}/user/login', json=data)
            response.raise_for_status()
            session['username'] = username
            return redirect(url_for('index'))
        except requests.exceptions.RequestException as e:
            error = f"Login failed: {e}"
            return render_template('login.html', error=error)
    return render_template('login.html')

# -- User registration --
@app.route('/register_user', methods=['GET', 'POST'])
def register_user():
    if request.method == 'POST':
        username = request.form['username']
        data = {'username': username}
        try:
            response = requests.post(f'{BACKEND_URL}/user/register', json=data)
            response.raise_for_status()
            message = response.json()['message']
            return render_template('register.html', message=message)
        except requests.exceptions.RequestException as e:
            error = f"Registration failed: {e}"
            return render_template('register.html', error=error)
    return render_template('register.html')

# -- User logout --
@app.route('/logout')
def logout():
    session.pop('username', None)
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True)
