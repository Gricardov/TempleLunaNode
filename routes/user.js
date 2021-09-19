const { Router } = require("express");
const { getUser, getUserProfileWithToken,getUserProfileWithoutToken, getUsers, postUser, putUser, deleteUser } = require("../controller/user");
const { validateField, validateToken, getUserProfile: getUserProfileVal, postToken: postTokenVal } = require('../validators');

const router = Router();

router.get("/", getUsers);

router.get("/:userId", getUser);

// Requiere un token, puede devolver un perfil PÚBLICO o PRIVADO, dependiendo del solicitante
router.post("/:userId/profile", [
    //validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
    validateToken(), // Verifica si el token es válido
    validateField('params', getUserProfileVal)
], getUserProfileWithToken);

// No requiere un token, siempre devuelve un perfil PÚBLICO
router.get("/:userId/profile", [
    validateField('params', getUserProfileVal)
], getUserProfileWithoutToken);

// Aquí vamos a obtener el usuario si el token es correcto
router.post("/", [
    //validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
    validateToken() // Verifica si el token es válido    
], postUser);

router.put("/:userId", putUser);

router.delete("/:userId", deleteUser);

module.exports = router;
