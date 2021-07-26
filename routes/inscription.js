const { Router } = require("express");
const {
  postInscription,
} = require("../controller/inscription");

const {
  validateField,
  postInscription: postInscriptionVal
} = require('../validators');
const router = Router();

router.post("/", [
  validateField('body', postInscriptionVal),
  postInscriptionVal.isEnrolled
], postInscription);

module.exports = router;
