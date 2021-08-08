const { Router } = require("express");
const { getMagazinesByYear, getMagazine } = require("../controller/magazine");
const { validateField, getMagazines: getMagazinesVal, getMagazine: getMagazineVal } = require('../validators');
const router = Router();

router.get("/", [
  validateField('query', getMagazinesVal)
], getMagazinesByYear);

router.get("/:alias", [
  validateField('params', getMagazineVal)
], getMagazine);

module.exports = router;