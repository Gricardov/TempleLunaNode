const { Router } = require("express");
const {
  getUser,
  getUsers,
  postUser,
  putUser,
  deleteUser,
} = require("../controller/user");

const router = Router();

router.get("/", getUsers);
router.get("/:id", getUser);
router.post("/", postUser);
router.put("/:id", putUser);
router.delete("/:id", deleteUser);

module.exports = router;
