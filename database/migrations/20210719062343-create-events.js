'use strict';

const { schema } = require('../models/event');
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();
    try {
      await queryInterface.createTable('events', { ...schema }, { transaction });
      await queryInterface.addIndex('events', ['alias'], { unique: true, transaction })
      await transaction.commit();
    } catch (error) {
      console.log(error)
      await transaction.rollback();
    }
  },
  down: (queryInterface, Sequelize) => {
    return queryInterface.dropTable('events');
  }
};
