const orders = require("./orders");
const services = require("./orderServices");
const statuses = require("./orderStatuses");

module.exports = {
    ...orders,
    ...services,
    ...statuses
}