const { Router } = require("express");
const { filterServices } = require("../../controller/admin");
const { hasRole } = require("../../validators/validateRole");
const router = Router();

// 
router.get("/order-services", [
  //hasRole(['ADMIN'])
  // validateField('query', getCommentsVal)
], filterServices);


/*router.post("/", [
  //validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', postCommentVal)
], postComment);*/

module.exports = router;