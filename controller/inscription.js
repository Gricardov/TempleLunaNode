const { queryDB } = require('../database/pool');
const { isEnrolled } = require('../validators/postInscription');

const postInscription = async (req, res) => {
  const { eventId, userId, names, age, phone, email } = req.body;
  //console.log(eventId)
  try {
    /* const inscriptionRes = await queryDB('CALL USP_INSERT_INSCRIPTION(?,?,?,?,?,?,?)', [1, null, 'Camilo sesto', 24, '+519999999', 'gr@gmail.com', null]);
     //const inscriptionRes = await queryDB('CALL USP_INSERT_INSCRIPTION(?,?,?,?,?,?,?)', [1, 1, null, null, null, null, null]);
     if (inscriptionRes.affectedRows) {
       res.json({ ok: 'ok' });
     } else {
       throw { msg: 'Error de inserción. Intente nuevamente', statusCode: 500 };
     }*/
    res.json({ ok: 'ok' })
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

module.exports = {
  postInscription
}