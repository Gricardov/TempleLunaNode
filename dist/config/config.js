"use strict";
const dotenv = require("dotenv");
dotenv.config();
module.exports = {
    development: {
        username: process.env.D_USER,
        password: process.env.D_PASS,
        database: process.env.D_DB,
        host: process.env.D_HOST,
        dialect: "mysql",
    },
    production: {
        username: process.env.P_USER,
        password: process.env.P_PASS,
        database: process.env.P_DB,
        host: process.env.P_HOST,
        dialect: "mysql",
    },
};
//# sourceMappingURL=config.js.map