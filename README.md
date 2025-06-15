# Decentralized Car Registration MVP

## Overview
This project is a Minimum Viable Product (MVP) for a decentralized car registry system built using Hyperledger Fabric, Node.js, and Flask.

- **Blockchain (Fabric)**: One organization (Org1) with a peer and CA. Chaincode `carcontract` supports:
  - `registerCar(carId, model, owner)`
  - `queryAllCars()`
  - `getCar(carId)`

- **Backend API (Node.js)**:
  - `POST /register` → calls `registerCar`
  - `GET /cars` → calls `queryAllCars`
  - `GET /car/:id` → calls `getCar`

- **Frontend UI (Flask)**:
  - Form to register a car.
  - List all cars.
  - View car by ID.

## Prerequisites
- Docker and Docker Compose
- Node.js (v14+)
- Python 3.7+
- pip

## Setup and Run

### 1. Start Fabric Network
Navigate to `fabric-network` directory and run:
```bash
./network.sh
```
This will start the Fabric network and deploy the chaincode.

### 2. Start Backend API
Navigate to `backend` directory and run:
```bash
npm install
node app.js
```
Backend API will start on `http://localhost:4000`.

### 3. Start Frontend UI
Navigate to `frontend` directory and run:
```bash
pip install -r requirements.txt
python app.py
```
Frontend UI will start on `http://localhost:5000`.

## Usage
- Use the frontend UI to register cars, view all registered cars, and view car details by ID.
- The frontend communicates with the backend API, which interacts with the Fabric blockchain.

## Project Structure
car-registry-mvp/
├── README.md                    # Complete setup instructions
├── fabric-network/              # Blockchain network
│   ├── chaincode/carcontract/   # Smart contract
│   │   ├── carcontract.js       # Main contract logic
│   │   └── package.json         # Dependencies
│   ├── crypto-config.yaml       # Certificate configuration
│   ├── configtx.yaml           # Channel configuration
├── docker-compose.yaml     # Container orchestration
│   └── connection-org1.json     # Network connection profile
├── backend/                     # Node.js API server
│   ├── app.js                   # Main server with Fabric integration
│   ├── package.json             # Dependencies
│   └── enrollAdmin.js           # Admin enrollment
└── frontend/                    # Flask web application
    ├── app.py                   # Main Flask application
    ├── requirements.txt         # Python dependencies
    ├── templates/               # HTML templates
    │   ├── index.html           # Car registration form
    │   ├── cars.html           # List all cars
    │   └── car_detail.html      # Individual car view
    └── static/css/style.css     # Styling

## Notes
- This is an MVP for demonstration purposes.
- For production use, consider security, error handling, and scalability improvements.

## Author
- Rashwan Syed
- rashwanuzaib2002@gmail.com

