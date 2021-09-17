const { Router } = require("express");
const {
  getOrders,
  getOrder,
  getOrdersTotal,
  postOrder,
  takeOrder,
  returnOrder,
  developOrder
} = require("../controller/order");

const {
  postOrder: postOrderVal,
  getOrders: getOrdersVal,
  getOrder: getOrderVal,
  getOrdersTotal: getOrdersTotalVal,
  takeReturnOrder: takeReturnOrderVal,
  developOrder: developOrderVal,
  postToken: postTokenVal,
  validateField,
  validateToken
} = require('../validators');

const router = Router();

// Obtiene un pedido según id (privado)
router.post("/getOne", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrderVal),
], getOrder);

// Obtiene pedidos según filtros
router.post("/filter", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersVal),
], getOrders);

// Obtiene los totales de los pedidos
router.post("/totals", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersTotalVal),
], getOrdersTotal);

// Toma un pedido
router.post("/take", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', takeReturnOrderVal),
], takeOrder);

// Renuncia a un pedido
router.post("/return", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', takeReturnOrderVal),
], returnOrder);

// Entrega un pedido
router.post("/develop", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', developOrderVal),
], developOrder);

// Agrega un pedido
router.post("/", [
  validateField('body', postOrderVal),
], postOrder);

module.exports = router;
