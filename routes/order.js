const { Router } = require("express");
const { postOrder } = require("../controller/order");
const { validateField, postOrder: postOrderVal } = require('../validators');
const router = Router();

router.post("/", [
  validateField('body', postOrderVal),
], postOrder);

module.exports = router;
