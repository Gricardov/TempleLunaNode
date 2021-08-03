const { Router } = require("express");
const { getMembersByEditorialService } = require("../controller/editorial");
const { validateField, getMembersByEditorialService: getMembersByEditorialServiceVal } = require('../validators');
const router = Router();

router.get("/:editorialId/services/:serviceId/members", [
  validateField('params', getMembersByEditorialServiceVal)
], getMembersByEditorialService);

module.exports = router;