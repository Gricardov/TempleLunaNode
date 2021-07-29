const { queryDB } = require('../database/pool');

const postStatistic = async (req, res) => {
  const { actionId, userId, email, orderId, magazineId, socialNetworkName } = req.body;
  try {
    const statisticRes = await queryDB('CALL USP_ADD_STATISTICS(?,?,?,?,?,?)', [userId, email, socialNetworkName, orderId, magazineId, actionId]);
    if (statisticRes.affectedRows) {
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
  postStatistic
}