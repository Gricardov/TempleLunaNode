const validateField = require('./validate');
const getEvent = require('./getEvent');
const getEvents = require('./getEvents');
const postInscription = require('./postInscription');
const postSubscription = require('./postSubscription');
const postStatistic = require('./postStatistic');
const postOrder = require('./postOrder');
const developOrder = require('./developOrder');
const getOrders = require('./getOrders');
const getOrder = require('./getOrder');
const takeReturnOrder = require('./takeReturnOrder');
const getOrdersTotal = require('./getOrdersTotals');
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
const getServicesByEditorial = require('./getServicesByEditorial');
const getServicesByEditorialMember = require('./getServicesByEditorialMember');

module.exports = {
    validateField,
    getEvent,
    getEvents,
    postInscription,
    postSubscription,
    postStatistic,
    postOrder,
    developOrder,
    getOrders,
    getOrder,
    takeReturnOrder,
    getOrdersTotal,
    getIsEnrolled,
    getMembersByEditorialService,
    getMagazines,
    getMagazine,
    getComments,
    postToken,
    validateToken,
    login,
    postRegister,
    getIsUserRegistered,
    getServicesByEditorial,
    getServicesByEditorialMember
}