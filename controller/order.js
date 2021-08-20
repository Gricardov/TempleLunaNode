const { queryDB } = require('../database/pool');

const getOrders = async (req, res) => {
  const { editorialId, statusId, serviceId, subserviceId, workerUserId, lastDate, limit } = req.body;
  try {
    const orderRes = await queryDB('CALL USP_GET_ORDERS(?,?,?,?,?,?,?,?)', [editorialId, statusId, serviceId, subserviceId, null, lastDate, null, limit]);
    res.json(orderRes[0]);
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const postOrder = async (req, res) => {

  const { editorialId, serviceId, subserviceId, userId, age, app, names, phone, intention, details, urlImgData, link, title, notify, phrase, pseudonym, publicLink, extraData, email, synopsis, priority, workerUserId } = req.body;
  try {
    const orderRes = await queryDB('CALL USP_CREATE_ORDER(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [userId, email, names, age, phone, app, workerUserId, editorialId, serviceId, subserviceId, title, link, pseudonym, synopsis, details, intention, phrase, notify, urlImgData, priority, extraData, publicLink]);
    if (orderRes.affectedRows) {
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
  getOrders,
  postOrder
}