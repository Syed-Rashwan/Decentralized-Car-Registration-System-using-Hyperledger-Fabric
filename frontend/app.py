from flask import Flask, render_template, request, jsonify

import requests
import os

app = Flask(__name__)

BACKEND_URL = os.environ.get('BACKEND_URL', 'http://localhost:4000')

@app.route('/')
def index():
    return render_template('index.html')

# -- Register a car --
@app.route('/register', methods=['POST'])
def register():
    try:
        car_id = request.form['car_id']
        model = request.form['model']
        owner = request.form['owner']
        data = {'carId': car_id, 'model': model, 'owner': owner}
        response = requests.post(f'{BACKEND_URL}/register', json=data)
        response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
        message = response.json()['message']
        return render_template('index.html', message=message)
    except requests.exceptions.RequestException as e:
        return render_template('index.html', message=f"Error: Could not connect to backend - {e}")
    except (KeyError, ValueError) as e:
        return render_template('index.html', message=f"Error: Invalid data received from backend - {e}")
    except Exception as e:
        return render_template('index.html', message=f"Error: An unexpected error occurred - {e}")

# -- View cars --
@app.route('/cars')
def cars():
    try:
        response = requests.get(f'{BACKEND_URL}/cars')
        response.raise_for_status()
        cars = response.json()['result']
        return render_template('cars.html', cars=cars)
    except requests.exceptions.RequestException as e:
        return render_template('cars.html', error=f"Error: Could not connect to backend - {e}")
    except (KeyError, ValueError) as e:
        return render_template('cars.html', error=f"Error: Invalid data received from backend - {e}")
    except Exception as e:
        return render_template('cars.html', error=f"Error: An unexpected error occurred - {e}")

# -- View a specific car --
@app.route('/car/<id>')
def car(id):
    try:
        response = requests.get(f'{BACKEND_URL}/car/{id}')
        response.raise_for_status()
        car = response.json()['result']
        return render_template('car.html', car=car)
    except requests.exceptions.RequestException as e:
        return render_template('car.html', error=f"Error: Could not connect to backend - {e}")
    except (KeyError, ValueError) as e:
        return render_template('car.html', error=f"Error: Invalid data received from backend - {e}")
    except Exception as e:
        return render_template('car.html', error=f"Error: An unexpected error occurred - {e}")

if __name__ == '__main__':
    app.run(debug=True)
