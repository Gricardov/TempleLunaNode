const dotenv = require("dotenv");
const Server = require("./models/server");

// Configuración dotenv
dotenv.config();

const server = new Server();

server.listen();