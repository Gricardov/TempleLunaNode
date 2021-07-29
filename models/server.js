const express = require('express');
const cors = require('cors');
const userRoutes = require("../routes/user");
const eventRoutes = require("../routes/event");
const inscriptionRoutes = require("../routes/inscription");
const subscriptionRoutes = require("../routes/subscription");
const statisticRoutes = require("../routes/statistic");
const orderRoutes = require("../routes/order");
const { testConnectionDB } = require('../database/pool');

class Server {
    constructor() {
        this.app = express();
        this.port = process.env.PORT;
        this.apiPaths = {
            user: '/api/users',
            event: '/api/events',
            inscription: '/api/inscriptions',
            subscription: '/api/subscriptions',
            statistic: '/api/statistics',
            order: '/api/orders'
        };

        // Conexión
        this.connectDB();

        // Middlewares
        this.middlewares();

        // Rutas
        this.routes();
    }

    middlewares() {
        //CORS
        this.app.use(cors());

        // Lectura y parseo del body
        this.app.use(express.json());

        // Rutas
        this.app.use(express.static('public'));
    }

    routes() {
        this.app.use(this.apiPaths.user, userRoutes);
        this.app.use(this.apiPaths.event, eventRoutes);
        this.app.use(this.apiPaths.inscription, inscriptionRoutes);
        this.app.use(this.apiPaths.subscription, subscriptionRoutes);
        this.app.use(this.apiPaths.statistic, statisticRoutes);
        this.app.use(this.apiPaths.order, orderRoutes);
    }

    async connectDB() {
        try {
            await testConnectionDB();
            console.log('Conectado a bd!');
        } catch (error) {
            console.log(error);
        }
    }

    listen() {
        this.app.listen(this.port, () => {
            console.log('Listening on ' + this.port);
        })
    }
}

module.exports = Server;