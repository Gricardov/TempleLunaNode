const { queryDB } = require('../database/pool');

const postStatisticWithToken = async (req, res) => {
  const { actionId, claims, email, orderId, magazineId, active, socialNetworkName } = req.body;
  try {
    const statisticRes = await queryDB('CALL USP_ADD_STATISTICS(?,?,?,?,?,?,?)', [claims.userId, email, socialNetworkName, orderId, magazineId, actionId, active]);
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

const postStatisticWithoutToken = async (req, res) => {
  const { actionId, email, orderId, magazineId, active, socialNetworkName } = req.body;
  try {
    const statisticRes = await queryDB('CALL USP_ADD_STATISTICS(?,?,?,?,?,?,?)', [null, email, socialNetworkName, orderId, magazineId, actionId, active]);
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
  postStatisticWithToken,
  postStatisticWithoutToken
}