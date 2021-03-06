const { queryDB } = require('../database/pool');
const { notifyCommentOnOrder } = require('../notifier/sender');
const { isNullOrUndefined } = require('../utils/functions');

// Reutilizable, para decidir qué tipo de comentarios se deben obtener.
// La revista se puede obtener por ALIAS o por ID (segundo parámetro)
const switchAndGetComments = async (orderId, { alias: magazineAlias, id: magazineId }, limit, lastDate) => {
    if (!isNullOrUndefined(orderId)) {
        return (await queryDB('CALL USP_GET_OLDER_COMMENTS_BY_ORDER_ID(?,?,?)', [orderId, limit, lastDate]))[0];
    } else if (!isNullOrUndefined(magazineAlias)) {
        return (await queryDB('CALL USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ALIAS(?,?,?)', [magazineAlias, limit, lastDate]))[0];
    } else if (!isNullOrUndefined(magazineId)) {
        return (await queryDB('CALL USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ID(?,?,?)', [magazineId, limit, lastDate]))[0];
    } else {
        // En teoría, nunca debería llegar aquí porque tiene middlewares que validan antes
        throw { msg: 'Un id no ha sido especificado', statusCode: 500 };
    }
}

// Recordar que los comentarios siempre se muestran desde los más nuevos a los más antiguos
const getOlderComments = async (req, res) => {
    const { orderId, magazineAlias, limit, lastDate } = req.query;
    try {
        const comRes = await switchAndGetComments(orderId, { alias: magazineAlias }, limit, lastDate);
        res.json(comRes);
    } catch (error) {
        console.log(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

const postComment = async (req, res) => {
    const { magazineId, orderId, comment, claims } = req.body;
    try {
        const userId = claims.userId;
        const comRes = await queryDB('CALL USP_POST_COMMENT(?,?,?,?)', [userId, orderId, magazineId, comment]);
        const inserted = comRes[0][0];
        if (inserted) {
            res.json(inserted);
            // Si se trata de un pedido, se debe notificar por correo al trabajador
            if (orderId) {
                const affectedOrderRes = await queryDB('CALL USP_GET_PRIVATE_ORDER(?,?)', [orderId, null]);
                const affectedOrder = affectedOrderRes[0][0];
                // Siempre y cuando el comentario no sea del mismo que lo atendió jaja
                if (userId !== Number(affectedOrder.workerUserId)) {
                    notifyCommentOnOrder(affectedOrder, affectedOrder, comment);
                }
            }
        } else {
            throw { msg: 'Error al crear el comentario. Intente nuevamente', statusCode: 500 };
        }
    } catch (error) {
        console.log(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    getOlderComments,
    postComment
}