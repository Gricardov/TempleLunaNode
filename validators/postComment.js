const yup = require('yup');
const { eachWordtoSentence, isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    orderId: yup.number().min(1).max(100000000).nullable(),
    magazineId: yup.number().min(1).max(100000000).nullable(),
    comment: yup.string().trim().min(2).max(1000).required(),
    limit: yup.number().min(1).max(10), // Para obtener una lista de comentarios como resultado
}).test(
    'at-least-order-or-comment',
    'Debes especificar un id de pedido o un id de revista',
    value => value.orderId || value.magazineId
);

const defValues = (data) => {
    return {
        orderId: isNullOrUndefined(data.orderId) ? null : Number(data.orderId),
        magazineId: isNullOrUndefined(data.magazineId) ? null : Number(data.magazineId),
        comment: data.comment.trim(),
        limit: isNullOrUndefined(data.limit) ? 5 : Number(data.limit)
    }
}

module.exports = {
    schema,
    defValues
}