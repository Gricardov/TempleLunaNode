const { queryDB } = require('../database/pool');
const moment = require('moment');

const expirationDays = 7;

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

const getOrder = async (req, res) => {

  const { orderId } = req.body;

  try {
    const orderRes = await queryDB('CALL USP_GET_ORDER(?)', [orderId]);
    res.json(orderRes[0][0]);
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

const takeOrder = async (req, res) => {

  const { orderId, claims } = req.body;

  try {
    const takenAt = moment.utc().format('YYYY-MM-DD HH:mm:ss');
    const orderRes = await queryDB('CALL USP_TAKE_ORDER(?,?,?,?)', [orderId, claims.userId, takenAt, expirationDays]);
    if (orderRes.affectedRows) {
      // Obtengo el pedido actualizado
      const newOrderRes = await queryDB('CALL USP_GET_ORDER(?)', [orderId]);
      res.json({ ok: 'ok', updatedOrder: newOrderRes[0][0] });
    } else {
      throw { msg: 'Ocurrió un error al tomar el pedido', statusCode: 500 };
    }
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const returnOrder = async (req, res) => {

  const { orderId, claims } = req.body;

  // Para restaurarlo al estado original
  let originalStatus = 'DISPONIBLE';

  try {
    const oldOrderRes = await queryDB('CALL USP_GET_ORDER(?)', [orderId]);
    const oldOrder = oldOrderRes[0][0];

    if (!oldOrder) {
      throw { msg: 'No se encontró el pedido. Intenta nuevamente', statusCode: 500 };
    }

    // Si el pedido es de tipo ESCUCHA, su estado original ha sido "SOLICITADO"
    if (oldOrder.serviceId == 'ESCUCHA') {
      originalStatus = 'SOLICITADO';
    }

    // Paso el userId, porque valida si el que renuncia a su pedido es el mismo que quien lo ha tomado
    const orderRes = await queryDB('CALL USP_RETURN_ORDER(?,?,?)', [orderId, originalStatus, claims.userId]);
    if (orderRes.affectedRows) {
      // Obtengo el pedido actualizado
      const newOrderRes = await queryDB('CALL USP_GET_ORDER(?)', [orderId]);
      res.json({ ok: 'ok', updatedOrder: newOrderRes[0][0] });
    } else {
      throw { msg: 'Ocurrió un error al devolver el pedido. Intenta nuevamente', statusCode: 500 };
    }
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

module.exports = {
  getOrders,
  getOrder,
  postOrder,
  takeOrder,
  getOrdersTotal,
  returnOrder
}