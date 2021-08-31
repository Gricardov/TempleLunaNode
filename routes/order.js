const { Router } = require("express");
const { getOrders, getOrdersTotal, postOrder, takeOrder, returnOrder } = require("../controller/order");
const {
  postOrder: postOrderVal,
  getOrders: getOrdersVal,
  getOrdersTotal: getOrdersTotalVal,
  takeReturnOrder: takeReturnOrderVal,
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

router.post("/take", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', takeReturnOrderVal),
], takeOrder);

router.post("/return", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', takeReturnOrderVal),
], returnOrder);

router.post("/", [
  validateField('body', postOrderVal),
], postOrder);

module.exports = router;
