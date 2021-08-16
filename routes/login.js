const { Router } = require("express");
const { postLogin } = require("../controller/login");
const { validateField, validateToken, postToken: postTokenVal, login: loginVal } = require('../validators');

const router = Router();

// Aquí vamos a obtener el usuario si el token es correcto
router.post("/", [
    validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
    validateToken(true), // Verifica si el token es válido y que pase por alto la validación si el usuario está activo en la bd o no, dado que se determinará ahí mismo
    loginVal.checkUserState // Verifica si el usuario existe y está habilitado en la bd
], postLogin);

module.exports = router;
