const { Router } = require("express");
const { getUser, getUsers, postUser, putUser, deleteUser } = require("../controller/user");
const { validateField, validateToken, postToken: postTokenVal } = require('../validators');

const router = Router();

router.get("/", getUsers);

router.get("/:id", getUser);

// Aquí vamos a obtener el usuario si el token es correcto
router.post("/", [
    validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
    validateToken() // Verifica si el token es válido    
], postUser);

router.put("/:id", putUser);

router.delete("/:id", deleteUser);

module.exports = router;
