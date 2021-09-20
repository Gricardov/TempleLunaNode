const yup = require('yup');
const moment = require('moment');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    userId: yup.number().min(1).max(100000000).required('El id del usuario es requerido'),
    //servicesIds: yup.array().of(yup.string().min(1).max(100)).nullable(), // Esto sirve para traer las estadísticas de varios servicios al mismo tiempo
    serviceId: yup.string().trim().max(50).required('El id de servicio es requerido'),
    subserviceId: yup.string().trim().max(50).nullable(),
    lastDate: yup.string().trim().min(1).max(50).test('momentValid', 'No es una fecha válida', date => !date || moment(date).isValid()).nullable(), // Recordar que este campo es timestamp, por lo cuál no es necesario especificar un formato.
    limit: yup.number().min(1).max(10).nullable()
});

const defValues = (data) => {
    return {
        userId: Number(data.userId),
        //servicesIds: isNullOrUndefined(data.servicesIds) ? [] : data.servicesIds,
        serviceId: data.serviceId.trim(),
        subserviceId: isNullOrUndefined(data.subserviceId) ? null : data.subserviceId.trim(),
        lastDate: isNullOrUndefined(data.lastDate) ? null : data.lastDate.trim(),
        limit: isNullOrUndefined(data.limit) ? 5 : Number(data.limit)
    }
}

module.exports = {
    schema,
    defValues
}