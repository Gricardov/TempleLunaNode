const { Router } = require("express");
const { getOrders, getOrdersTotal, postOrder } = require("../controller/order");
const {
  postOrder: postOrderVal,
  getOrders: getOrdersVal,
  getOrdersTotal: getOrdersTotalVal,
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

router.post("/totals", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersTotalVal),
], getOrdersTotal);

router.post("/", [
  validateField('body', postOrderVal),
], postOrder);

module.exports = router;
