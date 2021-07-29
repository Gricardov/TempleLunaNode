const { Router } = require("express");
const { postStatistic } = require("../controller/statistic");
const { validateField, postStatistic: postStatisticVal } = require('../validators');
const router = Router();

router.post("/", [
  validateField('body', postStatisticVal),
], postStatistic);

module.exports = router;
