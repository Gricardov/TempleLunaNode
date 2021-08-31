const yup = require('yup');
const moment = require('moment');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    limit: yup.number().min(1).max(50),
    lastDate: yup.string().trim().min(1).max(50).test('momentValid', 'No es una fecha válida', date => !date || moment(date, 'YYYY-MM-DD_HH:mm:ss', true).isValid())
});

const defValues = (data) => {
    return {
        limit: isNullOrUndefined(data.limit) ? 5 : Number(data.limit),
        lastDate: isNullOrUndefined(data.lastDate) ? null : data.lastDate.trim().split('_')[0] + ' ' + data.lastDate.trim().split('_')[1] // El servidor siempre va a recibir en formato UTC. Hora y fecha están separados por un guión bajo.
    }
}

module.exports = {
    schema,
    defValues
}