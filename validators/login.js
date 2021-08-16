const yup = require('yup');
const { queryDB } = require('../database/pool');

// Esto sirve para enviar mensajes de error en caso de que el usuario no exista o simplemente esté deshabilitado
const checkUserState = async (req, res, next) => {
    try {
        // Tiene que ser llamado después del middleware validateToken(), porque ahí se inyectan los claims del token
        const { claims } = req.body;
        const result = await queryDB('CALL USP_GET_USER_STATUS_BY_EMAIL(?)', [claims.email]);
        const { exists, active } = result[0][0];
        if (exists) {
            if (!active) {
                throw { msg: `El usuario ${claims.email} se encuentra inhabilitado`, statusCode: 403 };
            }
        } else {
            throw { msg: `El usuario ${claims.email} no está registrado`, statusCode: 404 };
        }
        next();
    } catch (error) {
        console.error(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    checkUserState
}