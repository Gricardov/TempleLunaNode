const { queryDB } = require('../database/pool');
const { notifyReactionOnOrder } = require('../mail/sender');

const postStatisticWithToken = async (req, res) => {
  const { actionId, claims, email, orderId, magazineId, active, socialNetworkName } = req.body;
  const userId = claims.userId;
  try {
    const statisticRes = await queryDB('CALL USP_ADD_STATISTICS(?,?,?,?,?,?,?)', [userId, email, socialNetworkName, orderId, magazineId, actionId, active]);
    if (statisticRes.affectedRows) {
      res.json({ ok: 'ok' });
      // Si se trata de un pedido, se debe notificar por correo al trabajador y solo si es una reacción activa (Dar like, no quitar like)
      if (orderId && active) {
        const affectedOrderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, null]);
        const affectedOrder = affectedOrderRes[0][0];
        // Siempre y cuando el comentario no sea del mismo que lo atendió jaja
        if (userId !== Number(affectedOrder.workerUserId)) {
          notifyReactionOnOrder(affectedOrder, affectedOrder, actionId);
        }
      }
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
      // Si se trata de un pedido, se debe notificar por correo al trabajador y solo si es una reacción activa (Dar like, no quitar like)
      if (orderId && active) {
        const affectedOrderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, null]);
        const affectedOrder = affectedOrderRes[0][0];
        notifyReactionOnOrder(affectedOrder, affectedOrder, actionId);
      }
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