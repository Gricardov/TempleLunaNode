const { Router } = require("express");
const { filterOrders, getOrderById, updateOrder } = require("../../controller/admin");
const { hasRole } = require("../../validators/validateRole");
const router = Router();

router.get("/orders/:id", [
  //hasRole(['ADMIN'])
  // validateField('query', getCommentsVal)
], getOrderById);
// 
router.get("/orders", [
  //hasRole(['ADMIN'])
  // validateField('query', getCommentsVal)
], filterOrders);

router.put("/orders/:id", [
  //hasRole(['ADMIN'])
  // validateField('query', getCommentsVal)
], updateOrder);

/*router.post("/", [
  //validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', postCommentVal)
], postComment);*/

module.exports = router;