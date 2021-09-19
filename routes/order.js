const { Router } = require("express");
const {
  getOrdersWithToken,
  getOrdersWithoutToken,
  getOrderWithToken,
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

// Obtiene un pedido según id. Requiere token. Puede devolver un pedido PÚBLICO o PRIVADO
router.post("/getOne", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrderVal),
], getOrderWithToken);

// Obtiene pedidos según filtros. Requiere token. Puede devolver pedidos PÚBLICOS o PRIVADOS
router.post("/filter", [
  validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersVal),
], getOrdersWithToken);

// Obtiene pedidos según filtros. No requiere token. Solo puede devolver pedidos PÚBLICOS
router.post("/filterWithoutToken", [
  validateField('body', getOrdersVal),
], getOrdersWithoutToken);

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
