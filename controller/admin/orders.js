const { queryDB } = require('../../database/pool');
const { generateTemplate } = require('../../utils/template-creator');
const stream = require('stream');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const { uploadResultRequest } = require('../../utils/functions');
const { notifyOrderDone } = require('../../mail/sender');

const getOrderById = async (req, res) => {
    const { id } = req.params;
    try {
        const orderRes = await queryDB('CALL ASP_GET_ORDER(?)', [id]);

        const order = orderRes[0][0];

        res.json({ data: order });
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

const filterOrders = async (req, res) => {
    const { sort, range, filter } = req.query;

    // Para la paginación. Ejm: '[0,10]'
    const rangeObj = JSON.parse(range);
    // Para el ordenamiento. Ejm: '["id","ASC"]'. Solo puedo ordenar por id y createdAt
    const sortObj = JSON.parse(sort);
    // Para el filtro. Ejm: '{"q":"D","titleWork":"TITLE"}'. Solo puedo filtrar por id, titleWork, workerNames, statusId, serviceId, editorialId, clientNames y clientPhone
    const filterObj = JSON.parse(filter);

    try {
        // Debo hacer dos llamadas. La primera, sin pasarle los rangos de paginación para obtener el total de registros. El segundo, son los datos
        const ordersRes = await queryDB('CALL ASP_GET_ORDERS(?,?,?,?,?,?,?,?,?,?,?)', [rangeObj[0], rangeObj[1], filterObj.titleWork, filterObj.workerNames, filterObj.statusId, filterObj.serviceId, filterObj.editorialId, filterObj.clientNames, filterObj.clientPhone, sortObj[0] === "id" ? sortObj[1] : null, sortObj[0] === "createdAt" ? sortObj[1] : null]);

        const orders = ordersRes[0];

        res.json({ data: orders, total: orders[0] ? orders[0].totalForPagination : 0 });
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

const updateOrder = async (req, res) => {
    const { id } = req.params;
    const data = req.body;

    // Aquí solo debo actualizar los campos permitidos por mí: statusId (Acción para anular y reactivar), public, publicLink, titleWork, 
    const { statusId, titleWork, public, publicLink } = data;

    try {
        const orderRes = await queryDB('CALL ASP_UPDATE_ORDER(?,?,?,?,?)', [id, statusId, titleWork, public, publicLink]);
        if (orderRes.affectedRows) {
            res.json({ data });
        } else {
            throw { msg: 'Error al actualizar el pedido. Intente nuevamente', statusCode: 500 };
        }
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    getOrderById,
    filterOrders,
    updateOrder
}