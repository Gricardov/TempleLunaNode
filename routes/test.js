const { Router } = require("express");
const {
  sendTestMagazineTemplate,
  sendTestOrderTemplate
} = require("../controller/test");

const {
  validateField,
  validateToken
} = require('../validators');

const router = Router();

// Envía por correo un pedido de prueba
router.post("/order", [
  //validateToken(), // Verifica si el token es válido
  //validateField('body', getOrderVal),
], sendTestOrderTemplate);

// Envía por correo revistas de prueba
router.post("/magazine", [
  //validateToken(), // Verifica si el token es válido
  //validateField('body', getOrderVal),
], sendTestMagazineTemplate);

module.exports = router;
