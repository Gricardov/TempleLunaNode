const { Router } = require("express");
const {
  getEvent,
  getEvents,
  postEvent,
  putEvent,
  deleteEvent,
} = require("../controller/event");

const router = Router();

router.get("/", getEvents);
router.get("/:alias", getEvent);
router.post("/", postEvent);
router.put("/:id", putEvent);
router.delete("/:id", deleteEvent);

module.exports = router;



