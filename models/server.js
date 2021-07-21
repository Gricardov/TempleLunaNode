const express = require('express');
const cors = require('cors');
const userRoutes = require("../routes/user");
const eventRoutes = require("../routes/event");
const { testConnectionDB } = require('../database/pool');

class Server {
    constructor() {
        this.app = express();
        this.port = process.env.PORT;
        this.apiPaths = {
            user: '/api/users',
            events: '/api/events'
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
        this.app.use(this.apiPaths.events, eventRoutes);
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