const { queryDB } = require('../database/pool');
const admin = require("firebase-admin");

const postLogin = async (req, res) => {
  const { claims } = req.body; // El middleware validateToken inserta los claims del JWT en el body

  // Primero, verifico si el usuario está activo en mi bd
  try {
    const userRes = await queryDB('CALL USP_GET_PRIVATE_USER_BY_EMAIL(?)', [claims.email]);
    const user = userRes[0][0];
    if (user) {
      // Si el usuario existe, le habilito el JWT y devuelvo su data. Caso contrario, no le servirá su token
      await admin.auth().setCustomUserClaims(claims.sub, {
        enabled: true
      });
      res.json(user);
    } else {
      throw { msg: 'Usuario inexistente o deshabilitado', statusCode: 500 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};


module.exports = {
  postLogin
}