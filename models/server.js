const express = require('express');
const cors = require('cors');
const {
    loginRoutes,
    userRoutes,
    eventRoutes,
    inscriptionRoutes,
    subscriptionRoutes,
    statisticRoutes,
    orderRoutes,
    editorialRoutes,
    magazineRoutes,
    commentRoutes
} = require("../routes");
const admin = require("firebase-admin");
const serviceAccount = require("../firebase-admin-key.json");
const { testConnectionDB } = require('../database/pool');

class Server {
    constructor() {
        this.app = express();
        this.port = process.env.PORT;
        this.apiPaths = {
            login: '/api/login',
            user: '/api/users',
            event: '/api/events',
            inscription: '/api/inscriptions',
            subscription: '/api/subscriptions',
            statistic: '/api/statistics',
            order: '/api/orders',
            editorial: '/api/editorials',
            magazine: '/api/magazines',
            comment: '/api/comments'
        };

        // Firebase
        this.firebase();

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
        this.app.use(this.apiPaths.login, loginRoutes);
        this.app.use(this.apiPaths.user, userRoutes);
        this.app.use(this.apiPaths.event, eventRoutes);
        this.app.use(this.apiPaths.inscription, inscriptionRoutes);
        this.app.use(this.apiPaths.subscription, subscriptionRoutes);
        this.app.use(this.apiPaths.statistic, statisticRoutes);
        this.app.use(this.apiPaths.order, orderRoutes);
        this.app.use(this.apiPaths.editorial, editorialRoutes);
        this.app.use(this.apiPaths.magazine, magazineRoutes);
        this.app.use(this.apiPaths.comment, commentRoutes);        
    }

    async firebase() {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
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