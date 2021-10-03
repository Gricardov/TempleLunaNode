const yup = require('yup');
const moment = require('moment');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    magazineAlias: yup.string().trim().min(1).max(200).nullable(),
    orderId: yup.number().min(1).max(100000000).nullable(),
    limit: yup.number().min(1).max(10),
    lastDate: yup.string().trim().min(1).max(50).test('momentValid', 'No es una fecha válida', date => !date || moment(date).isValid()) // Recordar que este campo es timestamp, por lo cuál no es necesario especificar un formato.
}).test(
    'at-least-order-or-magazine-alias',
    'Debes especificar un id de pedido o un alias de revista',
    value => value.magazineAlias || value.orderId
);

const defValues = (data) => {
    return {
        magazineAlias: isNullOrUndefined(data.magazineAlias) ? null : data.magazineAlias.trim(),
        orderId: isNullOrUndefined(data.orderId) ? null : Number(data.orderId),
        limit: isNullOrUndefined(data.limit) ? 5 : Number(data.limit),
        lastDate: isNullOrUndefined(data.lastDate) ? null : data.lastDate.trim()
    }
}

module.exports = {
    schema,
    defValues
}