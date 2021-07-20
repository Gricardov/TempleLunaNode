const { DataTypes } = require("sequelize");
const db = require("../connection");

const schema = {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  urlBg: {
    type: DataTypes.STRING,
    defaultValue: 'https://images.pexels.com/photos/4240602/pexels-photo-4240602.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'
  },
  urlPresentation: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  requisites: {
    type: DataTypes.JSON,
    defaultValue: [],
    get: function () {
      return JSON.parse(this.getDataValue("requisites"));
    },
    set: function (value) {
      this.setDataValue("requisites", JSON.stringify(value));
    },
  },
  objectives: {
    type: DataTypes.JSON,
    defaultValue: [],
    allowNull: false,
    get: function () {
      return JSON.parse(this.getDataValue("objectives"));
    },
    set: function (value) {
      this.setDataValue("objectives", JSON.stringify(value));
    },
  },
  benefits: {
    type: DataTypes.JSON,
    defaultValue: [],
    allowNull: false,
    get: function () {
      return JSON.parse(this.getDataValue("benefits"));
    },
    set: function (value) {
      this.setDataValue("benefits", JSON.stringify(value));
    },
  },
  topics: {
    type: DataTypes.JSON,
    defaultValue: [],
    allowNull: false,
    get: function () {
      return JSON.parse(this.getDataValue("topics"));
    },
    set: function (value) {
      this.setDataValue("topics", JSON.stringify(value));
    },
  },
  price: {
    type: DataTypes.DOUBLE,
    defaultValue: 0
  },
  currency: {
    type: DataTypes.STRING(100),
    defaultValue: ''
  },
  platform: {
    type: DataTypes.STRING(100),
    defaultValue: '',
    allowNull: false
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.STRING(2000),
    allowNull: false
  },
  paymentLink: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  paymentMethod: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  paymentFacilities: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  condition: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  timezoneText: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  whatsappGroup: {
    type: DataTypes.STRING,
    defaultValue: ''
  },
  extraData: {
    type: DataTypes.JSON,
    defaultValue: [],
    get: function () {
      return JSON.parse(this.getDataValue("extraData"));
    },
    set: function (value) {
      this.setDataValue("extraData", JSON.stringify(value));
    },
  },
  alias: {
    type: DataTypes.STRING,
    allowNull: false
  },
  createdAt: DataTypes.DATE,
  updatedAt: DataTypes.DATE,
};

const Event = db.define("event", schema, { tableName: "events", });

module.exports = {
  schema,
  Event
};
