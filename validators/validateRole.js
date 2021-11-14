const yup = require('yup');
const { queryDB } = require('../database/pool');

// Esto sirve para ver qué rol tiene el usuario
const hasRole = (allowedRoles = []) => async (req, res, next) => {
    try {
        const { claims } = req.body;
        const result = await queryDB('CALL USP_GET_PRIVATE_USER_BY_EMAIL(?)', [claims.email]);
        const { roleId } = result[0][0];
        if (allowedRoles.includes(roleId)) {
            next();
        } else {
            throw { msg: 'Rol incompatible para esta operación', statusCode: 403 };
        }
    } catch (error) {
        console.error(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    hasRole
}