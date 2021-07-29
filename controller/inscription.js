const { queryDB } = require('../database/pool');

const postInscription = async (req, res) => {
  const { eventId, userId, names, age, phone, app, email, urlImgData, notify } = req.body;
  try {
    const inscriptionRes = await queryDB('CALL USP_INSERT_INSCRIPTION(?,?,?,?,?,?,?,?,?,?)', [eventId, userId, names, age, phone, app, email, notify, urlImgData, null]);
    if (inscriptionRes.affectedRows) {
      res.json({ ok: 'ok' });
    } else {
      throw { msg: 'Error de inserción. Intente nuevamente', statusCode: 500 };
    }
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const isEnrolled = async (req, res, next) => {
  try {
    const { eventId, userId, email } = req.query;
    const result = await queryDB('CALL USP_EXISTS_IN_INSCRIPTION(?,?,?)', [eventId, userId, email]);
    const exists = result[0][0].exists;
    res.json({ exists });
  } catch (error) {
    console.error(error);
    res.status(400).json({ msg: 'Error al verificar la inscripción' });
  }
}

module.exports = {
  postInscription,
  isEnrolled
}