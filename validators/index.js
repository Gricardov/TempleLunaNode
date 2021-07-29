const validateField = require('./validate');
const getEvent = require('./getEvent');
const getEvents = require('./getEvents');
const postInscription = require('./postInscription');
const postSubscription = require('./postSubscription');
const postStatistic = require('./postStatistic');
const postOrder = require('./postOrder');
const getIsEnrolled = require('./getIsEnrolled');

module.exports = {
    validateField,
    getEvent,
    getEvents,
    postInscription,
    postSubscription,
    postStatistic,
    postOrder,
    getIsEnrolled
}