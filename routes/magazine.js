const { Router } = require("express");
const { getMagazinesByYear, getMagazineWithoutToken,getMagazineWithToken } = require("../controller/magazine");
const { validateField, getMagazines: getMagazinesVal, getMagazine: getMagazineVal, validateToken } = require('../validators');
const router = Router();

router.get("/", [
  validateField('query', getMagazinesVal)
], getMagazinesByYear);

router.get("/:alias", [
  validateField('params', getMagazineVal)
], getMagazineWithoutToken);

router.post("/:alias", [
  validateToken(), // Verifica si el token es válido
  validateField('params', getMagazineVal)
], getMagazineWithToken);

module.exports = router;