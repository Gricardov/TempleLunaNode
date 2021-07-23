const { Router } = require("express");
const {
  getEvent,
  getEvents,
  postEvent,
  putEvent,
  deleteEvent,
} = require("../controller/event");
const { getEventsSchemaQuery, getEventsDefaultsQuery } = require('../validators/eventSchema');
const validateResourceMW = require('../validators/validateResource');

const router = Router();

router.get("/", validateResourceMW('query', getEventsSchemaQuery, getEventsDefaultsQuery), getEvents); // Validates req.query
router.get("/:alias", getEvent);
router.post("/", postEvent);
router.put("/:id", putEvent);
router.delete("/:id", deleteEvent);

module.exports = router;



