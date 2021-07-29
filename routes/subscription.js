const { Router } = require("express");
const { postSubscription } = require("../controller/subscription");
const { validateField, postSubscription: postSubscriptionVal } = require('../validators');
const router = Router();

router.post("/", [
  validateField('body', postSubscriptionVal),
], postSubscription);

module.exports = router;
