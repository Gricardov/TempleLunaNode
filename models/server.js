const express = require("express");
const userRoutes = require("../routes/user");
const eventRoutes = require("../routes/event");
const cors = require("cors");
const db = require("../database/connections");

class Server {
  app;
  port;
  apiPaths = {
    user: "/api/user",
    event: "/api/event",
  };

  constructor() {
    this.app = express();
    this.port = process.env.PORT || "8000";

    // Conectar a bd
    this.connectDB();

    // Middlewares
    this.middlewares();

    // Rutas
    this.routes();
  }

  async connectDB() {
    try {
      await db.authenticate();
      console.log("Conectado a bd");
    } catch (error) {
      throw new Error(error);
    }
  }

  middlewares() {
    //CORS
    this.app.use(cors());

    // Lectura y parseo del body
    this.app.use(express.json());

    // Rutas
    this.app.use(express.static("public"));
  }
  routes() {
    this.app.use(this.apiPaths.user, userRoutes);
    this.app.use(this.apiPaths.event, eventRoutes);
  }
  listen() {
    this.app.listen(this.port, () => {
      console.log("Escuchando en puerto " + this.port);
    });
  }
}

module.exports = Server;