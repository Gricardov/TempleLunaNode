const { Router } = require("express");
const {
  getOrdersByEditorialWithToken,
  getOrdersWithToken,
  getOrdersWithoutToken,
  getOrderWithToken,
  getOrdersTotals,
  postOrder,
  takeOrder,
  returnOrder,
  developOrder
} = require("../controller/order");

const {
  postOrder: postOrderVal,
  getOrdersByEditorial: getOrdersByEditorialVal,
  getOrdersByUser: getOrdersByUserVal,
  getOrder: getOrderVal,
  getOrdersTotal: getOrdersTotalVal,
  takeReturnOrder: takeReturnOrderVal,
  developOrder: developOrderVal,
  postToken: postTokenVal,
  validateField,
  validateToken
} = require('../validators');

const router = Router();

// Obtiene un pedido PRIVADO según id. Sirve para que un trabajdor pueda ver todos los detalles de un pedido y requiere token
router.post("/getOne", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrderVal),
], getOrderWithToken);

// Agregar getOneWithoutToken

// Obtiene pedidos PRIVADOS según una editorial y demás filtros. Sirve para el dashboard de pedidos y requiere token
router.post("/filter", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersByEditorialVal),
], getOrdersByEditorialWithToken);

// Agregar /filterWithoutToken

// Obtiene pedidos PRIVADOS o PÚBLICOS dependiendo del solicitante. Se usa para ver los pedidos de un perfil. Requiere token.
router.post("/all", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersByUserVal),
], getOrdersWithToken);

// Obtiene pedidos PÚBLICOS según usuario y servicios. Sirve para obtener datos públicos de los pedidos en un perfil ajeno. No requiere token
router.post("/allWithoutToken", [
  validateField('body', getOrdersByUserVal),
], getOrdersWithoutToken);

// Obtiene los totales de los pedidos
router.post("/totals", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersTotalVal),
], getOrdersTotals);

// Agregar /totalsWithoutToken

// Toma un pedido
router.post("/take", [
  validateToken(), // Verifica si el token es válido
  validateField('body', takeReturnOrderVal),
], takeOrder);

// Renuncia a un pedido
router.post("/return", [
  validateToken(), // Verifica si el token es válido
  validateField('body', takeReturnOrderVal),
], returnOrder);

// Entrega un pedido
router.post("/develop", [
  validateToken(), // Verifica si el token es válido
  validateField('body', developOrderVal),
], developOrder);

// Agrega un pedido
router.post("/", [
  validateField('body', postOrderVal),
], postOrder);

module.exports = router;
