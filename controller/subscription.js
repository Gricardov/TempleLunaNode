const { queryDB } = require('../database/pool');

const postSubscription = async (req, res) => {
  const { userId, email, names, courses, magazine, novelties } = req.body;
  try {
    const inscriptionRes = await queryDB('CALL USP_SUBSCRIBE(?,?,?,?,?,?)', [userId, courses, magazine, novelties, names, email]);
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

module.exports = {
  postSubscription
}