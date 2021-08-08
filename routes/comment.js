const { Router } = require("express");
const { getOlderCommentsByMagazineAlias } = require("../controller/comment");
const { validateField, getComments: getCommentsVal } = require('../validators');
const router = Router();

router.get("/", [
  validateField('query', getCommentsVal)
], getOlderCommentsByMagazineAlias);

module.exports = router;