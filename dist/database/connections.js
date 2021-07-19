"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
const sequelize_1 = require("sequelize");
const config_1 = __importDefault(require("../config/config"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const { username, password, database, host } = config_1.default[(_a = process.env.NODE_ENV) === null || _a === void 0 ? void 0 : _a.trim()];
const db = new sequelize_1.Sequelize(database, username, password, {
    host: host,
    dialect: "mysql",
    // logging: false
});
exports.default = db;
//# sourceMappingURL=connections.js.map