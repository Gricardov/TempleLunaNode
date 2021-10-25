const { queryDB } = require('../database/pool');
const { generateTemplate } = require('../utils/template-creator');
const stream = require('stream');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const { uploadResultRequest } = require('../utils/functions');
const { notifyOrderDone } = require('../mail/sender');

const expirationDays = 7;

const getOrdersByEditorialWithToken = async (req, res) => {

  const { editorialId, statusId, serviceId, subserviceId, lastDate, limit, claims } = req.body;

  try {
    const workerUserId = claims.userId;

    const [orderRes, totalsRes] = await Promise.all([
      queryDB('CALL USP_GET_PRIVATE_ORDERS_BY_EDITORIAL_ID(?,?,?,?,?,?,?,?)', [editorialId, statusId, serviceId, subserviceId, workerUserId, lastDate, null, limit]),
      queryDB('CALL USP_GET_ORDER_STATUS_PRIVATE_TOTALS_BY_EDITORIAL_ID(?,?,?)', [editorialId, serviceId, workerUserId])
    ]);

    const orders = orderRes[0];
    const totals = totalsRes[0][0];

    res.json({ orders, totals });
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getOrdersWithToken = async (req, res) => {
  const { userId: workerUserId, serviceId, subserviceId, lastDate, limit, claims } = req.body;

  try {

    let profileStatement = 'CALL USP_GET_ALL_PUBLIC_ORDERS_BY_WORKER_USER_ID(?,?,?,?,?)';

    // Si el perfil solicitado tiene como dueño al solicitante, que obtenga su perfil PRIVADO. Caso contrario, perfil PÚBLICO
    if (claims.userId == workerUserId) {
      profileStatement = 'CALL USP_GET_ALL_PRIVATE_ORDERS_BY_WORKER_USER_ID(?,?,?,?,?)';
    }

    const ordersRes = await queryDB(profileStatement, [serviceId, subserviceId, workerUserId, lastDate, limit]);

    const orders = ordersRes[0];

    res.json(orders);

  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getOrdersWithoutToken = async (req, res) => {

  const { userId: workerUserId, serviceId, subserviceId, lastDate, limit } = req.body;

  try {
    const ordersRes = await queryDB('CALL USP_GET_ALL_PUBLIC_ORDERS_BY_WORKER_USER_ID(?,?,?,?,?)', [serviceId, subserviceId, workerUserId, lastDate, limit]);

    const orders = ordersRes[0];

    res.json(orders);
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getOrderWithToken = async (req, res) => {

  const { orderId, claims } = req.body;

  try {

    // Obtengo el pedido privado
    let orderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, claims.userId]);

    let order = orderRes[0][0];

    if (order) {

      // Si el pedido solicitado está tomado por el solicitante, que devuelva los datos privados
      if (claims.userId == order.workerUserId) {
        res.json(order);
      } else {
        // Caso contrario, el solicitante solo debe tener acceso público
        orderRes = await queryDB('CALL USP_GET_PUBLIC_ORDER(?)', [orderId]);
        order = orderRes[0][0];
        res.json(order);
      }

    } else {
      throw { msg: 'Pedido no encontrado', statusCode: 404 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getOrderWithoutToken = async (req, res) => {

  const { orderId } = req.body;

  try {
    const orderRes = await queryDB('CALL USP_GET_PUBLIC_ORDER(?)', [orderId]);
    const order = orderRes[0][0];
    if (order) {
      res.json(order);
    } else {
      throw { msg: 'Pedido no encontrado', statusCode: 404 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getOrdersTotals = async (req, res) => {

  const { editorialId, serviceId, claims } = req.body;
  try {
    // El workerUserId está en de los claims del JWT
    // Cuando el estado es DISPONIBLE, aún no tiene asignado un workerUserId. Esa validación se hace en el procedimiento
    const workerUserId = claims.userId;
    const totalsRes = await queryDB('CALL USP_GET_ORDER_STATUS_PRIVATE_TOTALS_BY_EDITORIAL_ID(?,?,?)', [editorialId, serviceId, workerUserId]);
    res.json(totalsRes[0][0]);
  } catch (error) {
    console.log(error);
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
    const orderRes = await queryDB('CALL USP_CREATE_ORDER(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [userId, email, names, age, phone, app, workerUserId, editorialId, serviceId, subserviceId, status, title, link, pseudonym, synopsis, details, intention, phrase, notify, urlImgData, priority, extraData, publicLink, process.env.ORDER_VERSION]);
    if (orderRes.affectedRows) {
      res.json({ ok: 'ok' });
    } else {
      throw { msg: 'Error al crear el pedido. Intente nuevamente', statusCode: 500 };
    }
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const developOrder = async (req, res) => {

  const { id, urlImg, INTENCION, ENGANCHE, ORTOGRAFIA, CONSEJO, claims } = req.body;

  try {
    // Primero, obtengo el pedido para saber como procesarlo
    const orderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [id, null]);
    const order = orderRes[0][0];

    // Verifico si es el mismo usuario quien lo va a pasar como HECHO
    if (order.workerUserId == claims.userId) {
      let url;
      let fileBuffer;

      switch (order.serviceId) {
        case 'CRITICA':
          fileBuffer = await generateTemplate(order.serviceId, { id: order.workerUserId, fName: order.workerFName, lName: order.workerLName, contactEmail: order.workerContactEmail, networks: order.workerNetworks }, { ...order, intention: INTENCION, hook: ENGANCHE, ortography: ORTOGRAFIA, advice: CONSEJO });
          url = await uploadResultRequest(fileBuffer, 'solicitud-critica', uuidv4());
          await queryDB('CALL USP_SET_ORDER_DONE(?,?)', [order.id, url]);
          break;
        case 'DISENO':
          url = urlImg;
          await queryDB('CALL USP_SET_ORDER_DONE(?,?)', [order.id, urlImg]);
          break;
        case 'ESCUCHA':
          await queryDB('CALL USP_SET_ORDER_DONE(?,?)', [order.id, null]);
          break;
      }
      res.json({ url });

      // Solo se notifican como terminados los pedidos que no son ESCUCHA
      if (order.serviceId !== 'ESCUCHA') {
        notifyOrderDone({ clientNames: order.clientNames.split(' ')[0], clientEmail: order.clientEmail }, order);
      }

    } else {
      throw { msg: 'El usuario que va a procesar el pedido no es el mismo de quien lo tomó', statusCode: 401 };
    }
  } catch (error) {
    console.log(error);
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
      const newOrderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, null]);
      res.json({ ok: 'ok', updatedOrder: newOrderRes[0][0] });
    } else {
      throw { msg: 'Ocurrió un error al tomar el pedido', statusCode: 500 };
    }
  } catch (error) {
    console.log(error)
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

// TODO: Esto se puede simplificar para que la verifiación del quien la tomó se realiza en esta mismo función
const returnOrder = async (req, res) => {

  const { orderId, claims } = req.body;

  // Para restaurarlo al estado original
  let originalStatus = 'DISPONIBLE';

  try {
    const oldOrderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, null]);
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
      const newOrderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, null]);
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
  getOrdersByEditorialWithToken,
  getOrdersWithToken,
  getOrdersWithoutToken,
  getOrderWithToken,
  getOrderWithoutToken,
  postOrder,
  developOrder,
  takeOrder,
  getOrdersTotals,
  returnOrder
}