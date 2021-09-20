const yup = require('yup');
const moment = require('moment');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    editorialId: yup.number().min(1).max(100000000).required('El id de la editorial es requerido'),
    statusId: yup.string().trim().max(50).required('El id de estado es requerido'),
    serviceId: yup.string().trim().max(50).required('El id de servicio es requerido'),
    subserviceId: yup.string().trim().max(50).nullable(),
    //workerUserId: yup.number().min(1).max(100000000).nullable(),
    lastDate: yup.string().trim().min(1).max(50).test('momentValid', 'No es una fecha válida', date => !date || moment(date).isValid()).nullable(), // Recordar que este campo es timestamp, por lo cuál no es necesario especificar un formato.
    limit: yup.number().min(1).max(10).nullable()
});

const defValues = (data) => {
    return {
        editorialId: Number(data.editorialId),
        statusId: data.statusId.trim(),
        serviceId: data.serviceId.trim(),
        subserviceId: isNullOrUndefined(data.subserviceId) ? null : data.subserviceId.trim(),
        //workerUserId: isNullOrUndefined(data.workerUserId) ? null : Number(data.workerUserId),
        lastDate: isNullOrUndefined(data.lastDate) ? null : data.lastDate.trim(),
        limit: isNullOrUndefined(data.limit) ? 5 : Number(data.limit)
    }
}

module.exports = {
    schema,
    defValues
}