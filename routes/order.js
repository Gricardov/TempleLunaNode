const { Router } = require("express");
const { getOrders, postOrder } = require("../controller/order");
const {
  postOrder: postOrderVal,
  getOrders: getOrdersVal,
  postToken: postTokenVal,
  validateField,
  validateToken
} = require('../validators');
const router = Router();

router.post("/filter", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersVal),
], getOrders);

router.post("/", [
  validateField('body', postOrderVal),
], postOrder);

module.exports = router;
