const axios = require('axios');

const BASE_URL = 'http://localhost:4000';

async function testRegisterCar() {
    try {
        const response = await axios.post(`${BASE_URL}/register`, {
            carId: 'CAR123',
            model: 'Tesla Model S',
            owner: 'Alice'
        });
        console.log('Register Car:', response.data);
    } catch (error) {
        console.error('Register Car Error:', error.response ? error.response.data : error.message);
    }
}

async function testGetAllCars() {
    try {
        const response = await axios.get(`${BASE_URL}/cars`);
        console.log('Get All Cars:', response.data);
    } catch (error) {
        console.error('Get All Cars Error:', error.response ? error.response.data : error.message);
    }
}

async function testGetCarById(carId) {
    try {
        const response = await axios.get(`${BASE_URL}/car/${carId}`);
        console.log(`Get Car ${carId}:`, response.data);
    } catch (error) {
        console.error(`Get Car ${carId} Error:`, error.response ? error.response.data : error.message);
    }
}

async function runTests() {
    await testRegisterCar();
    await testGetAllCars();
    await testGetCarById('CAR123');
    await testGetCarById('NON_EXISTENT_CAR');
}

runTests();
