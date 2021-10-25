const { Router } = require("express");
const {
  sendTestMagazineEmail,
  sendTestOrderEmail,
  generateTestPdfOrder
} = require("../controller/test");

const {
  validateField,
  validateToken
} = require('../validators');

const router = Router();

// Envía por correo un pedido de prueba
router.post("/order/mail", [
  //validateToken(), // Verifica si el token es válido
  //validateField('body', getOrderVal),
], sendTestOrderEmail);

// Envía por correo revistas de prueba
router.post("/magazine/mail", [
  //validateToken(), // Verifica si el token es válido
  //validateField('body', getOrderVal),
], sendTestMagazineEmail);

// Genera un pdf de pedido de prueba
router.post("/order/template", [
], generateTestPdfOrder);

module.exports = router;
