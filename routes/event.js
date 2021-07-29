const { Router } = require("express");
const { getEvent, getEvents, postEvent, putEvent, deleteEvent } = require("../controller/event");
const { validateField, getEvent: getEventVal, getEvents: getEventsVal } = require('../validators');
const router = Router();

router.get("/", [
  validateField('query', getEventsVal)
], getEvents);
router.get("/:alias", [
  validateField('params', getEventVal)
], getEvent);
router.post("/", postEvent);
router.put("/:id", putEvent);
router.delete("/:id", deleteEvent);

module.exports = router;



