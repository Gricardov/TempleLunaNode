const { Router } = require("express");
const { postInscription, isEnrolled } = require("../controller/inscription");
const { validateField, postInscription: postInscriptionVal, getIsEnrolled: getIsEnrolledVal } = require('../validators');
const router = Router();

router.post("/", [
  validateField('body', postInscriptionVal),
  postInscriptionVal.isEnrolled
], postInscription);

router.get('/isEnrolled/', [
  validateField('query', getIsEnrolledVal),
], isEnrolled);

module.exports = router;
