const { Router } = require("express");
const { postStatisticWithToken, postStatisticWithoutToken } = require("../controller/statistic");
const { validateField, postStatistic: postStatisticVal, validateToken } = require('../validators');
const router = Router();

router.post("/", [
  validateToken(), // Verifica si el token es válido
  validateField('body', postStatisticVal),
], postStatisticWithToken);

router.post("/postWithoutToken", [
  validateField('body', postStatisticVal),
], postStatisticWithoutToken);

module.exports = router;
