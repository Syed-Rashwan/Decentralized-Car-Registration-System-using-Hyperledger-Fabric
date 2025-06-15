const express = require('express');
const bodyParser = require('body-parser');
const carRegistryController = require('./car-registry-controller');
const userController = require('./user-controller');

const app = express();
const port = 4000;

app.use(bodyParser.json());

app.post('/register', carRegistryController.registerCar);
app.get('/cars', carRegistryController.queryAllCars);
app.get('/car/:id', carRegistryController.getCar);

app.post('/user/register', userController.registerUser);
app.post('/user/login', userController.loginUser);

app.listen(port, () => {
  console.log(`Backend API listening on port ${port}`);
});
