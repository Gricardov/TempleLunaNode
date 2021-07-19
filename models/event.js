const { DataTypes } = require("sequelize");
const db = require("../database/connections");

const schema = {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
  },
  urlBg: {
    type: DataTypes.BOOLEAN,
  },
  urlPresentation: {
    type: DataTypes.STRING,
  },
  requisites: {
    type: DataTypes.JSON,
    get: function () {
      return JSON.parse(this.getDataValue("requisites"));
    },
    set: function (value) {
      this.setDataValue("requisites", JSON.stringify(value));
    },
  },
  objectives: {
    type: DataTypes.JSON,
    get: function () {
      return JSON.parse(this.getDataValue("objectives"));
    },
    set: function (value) {
      this.setDataValue("objectives", JSON.stringify(value));
    },
  },
  benefits: {
    type: DataTypes.JSON,
    get: function () {
      return JSON.parse(this.getDataValue("benefits"));
    },
    set: function (value) {
      this.setDataValue("benefits", JSON.stringify(value));
    },
  },
  topics: {
    type: DataTypes.JSON,
    get: function () {
      return JSON.parse(this.getDataValue("topics"));
    },
    set: function (value) {
      this.setDataValue("topics", JSON.stringify(value));
    },
  },
  price: {
    type: DataTypes.DOUBLE,
  },
  currency: {
    type: DataTypes.STRING,
  },
  platform: {
    type: DataTypes.STRING,
  },
  title: {
    type: DataTypes.STRING,
  },
  description: {
    type: DataTypes.STRING,
  },
  paymentLink: {
    type: DataTypes.STRING,
  },
  paymentMethod: {
    type: DataTypes.STRING,
  },
  paymentFacilities: {
    type: DataTypes.STRING,
  },
  condition: {
    type: DataTypes.STRING,
  },
  timezoneText: {
    type: DataTypes.STRING,
  },
  whatsappGroup: {
    type: DataTypes.STRING,
  },
  extraData: {
    type: DataTypes.JSON,
    get: function () {
      return JSON.parse(this.getDataValue("extraInfo"));
    },
    set: function (value) {
      this.setDataValue("extraInfo", JSON.stringify(value));
    },
  },
  alias: {
    type: DataTypes.STRING,
  },
};

const Event = db.define("events", schema, {
  tableName: "events",
});

module.exports = Event;
