const { Router } = require("express");
const { postRegister, isRegistered } = require("../controller/register");
const { validateField, postRegister: postRegisterVal, getIsUserRegistered: getIsUserRegisteredVal } = require('../validators');

const router = Router();

// Aquí vamos a registrar al usuario
router.post("/", [
    validateField('body', postRegisterVal),
    postRegisterVal.isRegistered
], postRegister);

router.get('/isRegistered/', [
    validateField('query', getIsUserRegisteredVal),
], isRegistered);

module.exports = router;
