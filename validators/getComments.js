const yup = require('yup');
const moment = require('moment');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    magazineAlias: yup.string().trim().min(1).max(200).required(),
    limit: yup.number().min(1).max(50),
    lastDate: yup.string().trim().min(1).max(50).test('momentValid', 'No es una fecha válida', date => !date || moment(date).isValid()) // Recordar que este campo es timestamp, por lo cuál no es necesario especificar un formato.
});

const defValues = (data) => {
    return {
        magazineAlias: data.magazineAlias.trim(),
        limit: isNullOrUndefined(data.limit) ? 5 : Number(data.limit),
        lastDate: isNullOrUndefined(data.lastDate) ? null : data.lastDate.trim()
    }
}

module.exports = {
    schema,
    defValues
}