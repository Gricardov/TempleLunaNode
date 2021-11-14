const express = require('express');
const cors = require('cors');
const { EventEmitter } = require("events");
const {
    loginRoutes,
    registerRoutes,
    userRoutes,
    eventRoutes,
    inscriptionRoutes,
    subscriptionRoutes,
    statisticRoutes,
    orderRoutes,
    editorialRoutes,
    magazineRoutes,
    commentRoutes,
    adminRoutes,
    testRoutes
} = require("../routes");
const admin = require("firebase-admin");
const serviceAccount = require("../firebase-admin-key.json");
const { testConnectionDB } = require('../database/pool');
require('custom-env').env();

class Server {
    constructor() {
        this.app = express();
        this.mailEventEmitter = new EventEmitter();
        this.port = process.env.HOST_PORT;
        this.apiPaths = {
            login: '/api/login',
            register: '/api/register',
            user: '/api/users',
            event: '/api/events',
            inscription: '/api/inscriptions',
            subscription: '/api/subscriptions',
            statistic: '/api/statistics',
            order: '/api/orders',
            editorial: '/api/editorials',
            magazine: '/api/magazines',
            comment: '/api/comments',
            service: '/api/services',
            test:'/api/test',
            admin:'/api/admin'
        };

        // Firebase
        this.firebase();

        // Conexión a la bd
        this.connectDB();

        // Middlewares
        this.middlewares();

        // Eventos
        this.eventEmitters();

        // Rutas
        this.routes();
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
        this.app.use(this.apiPaths.register, registerRoutes);
        this.app.use(this.apiPaths.user, userRoutes);
        this.app.use(this.apiPaths.event, eventRoutes);
        this.app.use(this.apiPaths.inscription, inscriptionRoutes);
        this.app.use(this.apiPaths.subscription, subscriptionRoutes);
        this.app.use(this.apiPaths.statistic, statisticRoutes);
        this.app.use(this.apiPaths.order, orderRoutes);
        this.app.use(this.apiPaths.editorial, editorialRoutes);
        this.app.use(this.apiPaths.magazine, magazineRoutes);
        this.app.use(this.apiPaths.comment, commentRoutes);
        this.app.use(this.apiPaths.admin, adminRoutes);
        this.app.use(this.apiPaths.test, testRoutes);
    }

    eventEmitters() {
        /*this.app.set('mailEventEmitter', this.mailEventEmitter);
        this.app.get('mailEventEmitter').on('mailEventEmitter', () => {
            console.log('an event occurred!');
          });*/
    }

    listen() {
        this.app.listen(this.port, () => {
            console.log('Listening on ' + this.port);
        })
    }
}

module.exports = Server;