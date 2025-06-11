'use strict';

const { Contract } = require('fabric-contract-api');

class CarContract extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const cars = [
            {
                model: 'Toyota',
                owner: 'Shresta'
            },
            {
                model: 'Honda',
                owner: 'Vidya'
            }
        ];

        for (let i = 0; i < cars.length; i++) {
            await ctx.stub.putState('CAR' + i, Buffer.from(JSON.stringify(cars[i])));
            console.info('Added <--> ', cars[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async registerCar(ctx, carId, model, owner) {
        console.info('============= START : Register Car ===========');

        const car = {
            model,
            owner,
            docType: 'car'
        };

        await ctx.stub.putState(carId, Buffer.from(JSON.stringify(car)));
        console.info('============= END : Register Car ===========');
    }

    async queryAllCars(ctx) {
        console.info('============= START : Query All Cars ===========');
        const startKey = '';
        const endKey = '';
        const allResults = [];
        
        for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: key, Record: record });
        }
        console.info('============= END : Query All Cars ===========');
        return JSON.stringify(allResults);
    }

    async getCar(ctx, carId) {
        console.info('============= START : Get Car ===========');
        const carAsBytes = await ctx.stub.getState(carId);
        if (!carAsBytes || carAsBytes.length === 0) {
            throw new Error(`${carId} does not exist`);
        }
        console.info('============= END : Get Car ===========');
        return carAsBytes.toString();
    }

    async changeCarOwner(ctx, carId, newOwner) {
        console.info('============= START : Change Car Owner ===========');

        const carAsBytes = await ctx.stub.getState(carId);
        if (!carAsBytes || carAsBytes.length === 0) {
            throw new Error(`${carId} does not exist`);
        }
        const car = JSON.parse(carAsBytes.toString());
        car.owner = newOwner;

        await ctx.stub.putState(carId, Buffer.from(JSON.stringify(car)));
        console.info('============= END : Change Car Owner ===========');
    }
}

module.exports = CarContract;
