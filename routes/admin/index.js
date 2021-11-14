const { Router } = require("express");

const router = Router();

const orders = require("./orders");
const services = require("./orderServices");
const statuses = require("./orderStatuses");

router.use(orders);
router.use(services);
router.use(statuses);

module.exports = router;