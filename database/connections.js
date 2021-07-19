const { Sequelize } = require("sequelize");
const config = require("../config/config");
const dotenv = require("dotenv");
dotenv.config();

const { username, password, database, host } =
  config[process.env.NODE_ENV?.trim()];

const db = new Sequelize(database, username, password, {
  host: host,
  dialect: "mysql",
  // logging: false
});

module.exports = db;
