const { queryDB } = require('../database/pool');
const { v4: uuidv4 } = require('uuid');
const admin = require("firebase-admin");

const postRegister = async (req, res) => {

  const { fName, lName, email, password } = req.body;

  try {
    // Uso el correo para generar un followName genérico del usuario. Ejemplo: gricardov-asdyb238dby823
    const followName = fName.toLowerCase().split(' ')[0] + '-' + uuidv4().replace(/-/g, '');
    const userRes = await queryDB('CALL USP_REGISTER_USER(?,?,?,?)', [fName, lName, email, followName]);
    if (userRes.affectedRows) {
      // El usuario se insertó en la bd, ahora lo inserto en firebase
      await admin.auth().createUser({
        email,
        emailVerified: false,
        password,
        disabled: false,
      });
      res.json({ ok: 'ok' });
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const isRegistered = async (req, res) => {
  const { email } = req.query;
  try {
    const result = await queryDB('CALL USP_GET_USER_STATUS_BY_EMAIL(?)', [email]);
    const { exists } = result[0][0];
    res.json({ registered: exists });
  } catch (error) {
    console.error(error);
    res.status(400).json({ msg: 'Error al verificar el registro' });
  }
}

module.exports = {
  postRegister,
  isRegistered
}