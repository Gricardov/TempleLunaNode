'use strict';
module.exports = {
    up: (queryInterface, Sequelize) => {
        return queryInterface.createTable('events', {
            id: {
                type: Sequelize.UUID,
                defaultValue: Sequelize.UUIDV4,
                primaryKey: true,
            },
            name: {
                type: Sequelize.STRING,
            },
            urlBg: {
                type: Sequelize.BOOLEAN,
            },
            urlPresentation: {
                type: Sequelize.STRING,
            },
            requisites: {
                type: Sequelize.JSON,
                get: function () {
                    return JSON.parse(this.getDataValue("requisites"));
                },
                set: function (value) {
                    this.setDataValue("requisites", JSON.stringify(value));
                },
            },
            objectives: {
                type: Sequelize.JSON,
                get: function () {
                    return JSON.parse(this.getDataValue("objectives"));
                },
                set: function (value) {
                    this.setDataValue("objectives", JSON.stringify(value));
                },
            },
            benefits: {
                type: Sequelize.JSON,
                get: function () {
                    return JSON.parse(this.getDataValue("benefits"));
                },
                set: function (value) {
                    this.setDataValue("benefits", JSON.stringify(value));
                },
            },
            topics: {
                type: Sequelize.JSON,
                get: function () {
                    return JSON.parse(this.getDataValue("topics"));
                },
                set: function (value) {
                    this.setDataValue("topics", JSON.stringify(value));
                },
            },
            price: {
                type: Sequelize.DOUBLE,
            },
            currency: {
                type: Sequelize.STRING,
            },
            platform: {
                type: Sequelize.STRING,
            },
            title: {
                type: Sequelize.STRING,
            },
            description: {
                type: Sequelize.STRING,
            },
            paymentLink: {
                type: Sequelize.STRING,
            },
            paymentMethod: {
                type: Sequelize.STRING,
            },
            paymentFacilities: {
                type: Sequelize.STRING,
            },
            condition: {
                type: Sequelize.STRING,
            },
            timezoneText: {
                type: Sequelize.STRING,
            },
            whatsappGroup: {
                type: Sequelize.STRING,
            },
            extraData: {
                type: Sequelize.JSON,
                get: function () {
                    return JSON.parse(this.getDataValue("extraInfo"));
                },
                set: function (value) {
                    this.setDataValue("extraInfo", JSON.stringify(value));
                },
            },
            alias: {
                type: Sequelize.STRING,
            },
        });
    },
    down: (queryInterface, Sequelize) => {
        return queryInterface.dropTable('events');
    }
};
//# sourceMappingURL=20210719062343-create-events.js.map