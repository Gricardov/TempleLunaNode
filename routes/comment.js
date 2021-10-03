const { Router } = require("express");
const { getOlderComments, postComment } = require("../controller/comment");
const { validateField, getComments: getCommentsVal, postComment: postCommentVal, validateToken } = require('../validators');
const router = Router();

router.get("/", [
  validateField('query', getCommentsVal)
], getOlderComments);

router.post("/", [
  //validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('body', postCommentVal)
], postComment);

module.exports = router;