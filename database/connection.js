const { Sequelize } = require("sequelize");
const config = require("../config/config");
const dotenv = require("dotenv");
dotenv.config();

const env = process.env.NODE_ENV ? process.env.NODE_ENV.trim() : 'development';

const { username, password, database, host } = config[env];

const db = new Sequelize(database, username, password, {
  host: host,
  dialect: "mysql",
  // logging: false
});

module.exports = db;
