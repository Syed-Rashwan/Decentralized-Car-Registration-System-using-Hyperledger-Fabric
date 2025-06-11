const fabricClient = require('./fabric-client');

exports.registerCar = async (req, res) => {
  try {
    const { carId, model, owner } = req.body;
    const result = await fabricClient.registerCar(carId, model, owner);
    res.json({ message: 'Car registered successfully', result });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

exports.queryAllCars = async (req, res) => {
  try {
    const result = await fabricClient.queryAllCars();
    res.json({ result: JSON.parse(result) });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

exports.getCar = async (req, res) => {
  try {
    const carId = req.params.id;
    const result = await fabricClient.getCar(carId);
    res.json({ result: JSON.parse(result) });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};
