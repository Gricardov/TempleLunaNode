'use strict';
module.exports = {
    up: (queryInterface, Sequelize) => {
        return queryInterface.createTable('events', {
            name: Sequelize.DataTypes.STRING,
            isBetaMember: {
                type: Sequelize.DataTypes.BOOLEAN,
                defaultValue: false,
                allowNull: false
            }
        });
    },
    down: (queryInterface, Sequelize) => {
        return queryInterface.dropTable('events');
    }
};
//# sourceMappingURL=20210719062343-create-event.js.map