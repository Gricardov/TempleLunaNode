const dotenv = require("dotenv");
const Server = require("./models/server.js");

// Configuración dotenv
dotenv.config();

const server = new Server();

server.listen();