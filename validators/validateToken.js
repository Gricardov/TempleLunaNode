const admin = require("firebase-admin");

const validateToken = (ignoreUserEnabled) => async (req, res, next) => {
    const idtoken = req.header('idtoken');
    
    try {
        const claims = await admin.auth().verifyIdToken(idtoken);

        // Si me logueo por primera vez, el sistema verifica si estoy logueado e introduce el campo enabled. El login, por lo tanto, debe ignorar esta validación
        if (!ignoreUserEnabled) {
            if (!claims.enabled) {
                throw { msg: 'Usuario inhabilitado', statusCode: 403 };
            }
        }
        // Inserto los claims en el body        
        req.body.claims = claims;
        next();
    } catch (error) {
        console.log(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = validateToken;