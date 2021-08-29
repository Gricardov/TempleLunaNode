const { queryDB } = require('../database/pool');

const getOrders = async (req, res) => {

  const { editorialId, statusId, serviceId, subserviceId, lastDate, limit, claims } = req.body;
  
  try {
    // El workerUserId está en de los claims del JWT
    // Cuando el estado es DISPONIBLE, aún no tiene asignado un workerUserId. Esa validación es hace en el procedimiento
    const workerUserId = claims.userId;
    const orderRes = await queryDB('CALL USP_GET_ORDERS(?,?,?,?,?,?,?,?)', [editorialId, statusId, serviceId, subserviceId, workerUserId, lastDate, null, limit]);
    res.json(orderRes[0]);
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getOrdersTotal = async (req, res) => {

  const { editorialId, serviceId, claims } = req.body;
  try {
    // El workerUserId está en de los claims del JWT
    // Cuando el estado es DISPONIBLE, aún no tiene asignado un workerUserId. Esa validación es hace en el procedimiento
    const workerUserId = claims.userId;
    const orderRes = await queryDB('CALL USP_GET_ORDER_STATUS_TOTALS(?,?,?)', [editorialId, serviceId, workerUserId]);
    res.json(orderRes[0][0]);
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const postOrder = async (req, res) => {

  const { editorialId, serviceId, subserviceId, userId, age, app, names, phone, intention, details, urlImgData, link, title, notify, phrase, pseudonym, publicLink, extraData, email, synopsis, priority, workerUserId } = req.body;

  let status = 'DISPONIBLE';

  // Si se ha seleccionado el workerUserId de antemano, quiere decir que el pedido está en estado SOLICITADO
  if (workerUserId) {
    status = 'SOLICITADO';
  }

  try {
    const orderRes = await queryDB('CALL USP_CREATE_ORDER(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [userId, email, names, age, phone, app, workerUserId, editorialId, serviceId, subserviceId, status, title, link, pseudonym, synopsis, details, intention, phrase, notify, urlImgData, priority, extraData, publicLink]);
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
  postOrder,
  getOrdersTotal
}