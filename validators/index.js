const validateField = require('./validate');
const getEvent = require('./getEvent');
const getEvents = require('./getEvents');
const postInscription = require('./postInscription');
const postSubscription = require('./postSubscription');
const postStatistic = require('./postStatistic');
const postOrder = require('./postOrder');
const getIsEnrolled = require('./getIsEnrolled');
const getMembersByEditorialService = require('./getMembersByEditorialService');
const getMagazines = require('./getMagazines');
const getMagazine = require('./getMagazine');
const getComments = require('./getComments');
const postToken = require('./postToken');
const validateToken = require('./validateToken');
const login = require('./login');
const postRegister = require('./postRegister');
const getIsUserRegistered = require('./getIsUserRegistered');

module.exports = {
    validateField,
    getEvent,
    getEvents,
    postInscription,
    postSubscription,
    postStatistic,
    postOrder,
    getIsEnrolled,
    getMembersByEditorialService,
    getMagazines,
    getMagazine,
    getComments,
    postToken,
    validateToken,
    login,
    postRegister,
    getIsUserRegistered
}