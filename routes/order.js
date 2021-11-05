const { Router } = require("express");
const {
  getOrdersByEditorialWithToken,
  getOrdersWithToken,
  getOrdersWithoutToken,
  getOrderWithToken,
  getOrderWithoutToken,
  getRandomOrders,
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

// Obtiene los datos PRIVADOS O PÚBLICOS de un pedido según id. Sirve para que un trabajdor pueda ver todos los detalles de un pedido, ya sea en su perfil o en su dashboard, o un pedido en ajeno. Requiere token
router.post("/getOne", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrderVal),
], getOrderWithToken);

// Obtiene los datos PÚBLICOS de un pedido según id. Sirve para ver la información pública de un pedido en un perfil
router.post("/getOneWithoutToken", [
  validateField('body', getOrderVal),
], getOrderWithoutToken);

// Obtiene los datos PRIVADOS de pedidos según una editorial y demás filtros. Sirve para el dashboard de pedidos y requiere token
router.post("/filter", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersByEditorialVal),
], getOrdersByEditorialWithToken);

// Obtiene pedidos al azar. Se usa para la pantalla de home
router.get("/random", [
], getRandomOrders);

// Agregar /filterWithoutToken

// Obtiene los datos PRIVADOS o PÚBLICOS de un pedido dependiendo del solicitante. Se usa para ver los pedidos de un perfil. Requiere token.
router.post("/all", [
  validateToken(), // Verifica si el token es válido
  validateField('body', getOrdersByUserVal),
], getOrdersWithToken);

// Obtiene los datos PÚBLICOS de un pedido según usuario y servicios. Sirve para obtener datos públicos de los pedidos en un perfil ajeno. No requiere token
router.post("/allWithoutToken", [
  validateField('body', getOrdersByUserVal),
], getOrdersWithoutToken);

// Obtiene los datos PRIVADOS de los totales por pedido. Se usa en las estadísticas del dashboard
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
