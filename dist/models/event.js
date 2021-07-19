"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const sequelize_1 = require("sequelize");
const connections_1 = __importDefault(require("../database/connections"));
const schema = {
    id: {
        type: sequelize_1.DataTypes.UUID,
        defaultValue: sequelize_1.DataTypes.UUIDV4,
        primaryKey: true,
    },
    name: {
        type: sequelize_1.DataTypes.STRING,
    },
    urlBg: {
        type: sequelize_1.DataTypes.BOOLEAN,
    },
    urlPresentation: {
        type: sequelize_1.DataTypes.STRING,
    },
    requisites: {
        type: sequelize_1.DataTypes.JSON,
        get: function () {
            return JSON.parse(this.getDataValue("requisites"));
        },
        set: function (value) {
            this.setDataValue("requisites", JSON.stringify(value));
        },
    },
    objectives: {
        type: sequelize_1.DataTypes.JSON,
        get: function () {
            return JSON.parse(this.getDataValue("objectives"));
        },
        set: function (value) {
            this.setDataValue("objectives", JSON.stringify(value));
        },
    },
    benefits: {
        type: sequelize_1.DataTypes.JSON,
        get: function () {
            return JSON.parse(this.getDataValue("benefits"));
        },
        set: function (value) {
            this.setDataValue("benefits", JSON.stringify(value));
        },
    },
    topics: {
        type: sequelize_1.DataTypes.JSON,
        get: function () {
            return JSON.parse(this.getDataValue("topics"));
        },
        set: function (value) {
            this.setDataValue("topics", JSON.stringify(value));
        },
    },
    price: {
        type: sequelize_1.DataTypes.DOUBLE,
    },
    currency: {
        type: sequelize_1.DataTypes.STRING,
    },
    platform: {
        type: sequelize_1.DataTypes.STRING,
    },
    title: {
        type: sequelize_1.DataTypes.STRING,
    },
    description: {
        type: sequelize_1.DataTypes.STRING,
    },
    paymentLink: {
        type: sequelize_1.DataTypes.STRING,
    },
    paymentMethod: {
        type: sequelize_1.DataTypes.STRING,
    },
    paymentFacilities: {
        type: sequelize_1.DataTypes.STRING,
    },
    condition: {
        type: sequelize_1.DataTypes.STRING,
    },
    timezoneText: {
        type: sequelize_1.DataTypes.STRING,
    },
    whatsappGroup: {
        type: sequelize_1.DataTypes.STRING,
    },
    extraData: {
        type: sequelize_1.DataTypes.JSON,
        get: function () {
            return JSON.parse(this.getDataValue("extraInfo"));
        },
        set: function (value) {
            this.setDataValue("extraInfo", JSON.stringify(value));
        },
    },
    alias: {
        type: sequelize_1.DataTypes.STRING,
    },
};
const Event = connections_1.default.define("events", schema, {
    tableName: "events",
});
exports.default = Event;
module.exports = schema;
//# sourceMappingURL=event.js.map