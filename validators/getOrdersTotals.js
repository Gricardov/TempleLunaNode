const yup = require('yup');
const moment = require('moment');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    editorialId: yup.number().min(1).max(100000000).required('El id de la editorial es requerido'),
    serviceId: yup.string().trim().max(50).required('El id de servicio es requerido'),
    subserviceId: yup.string().trim().max(50).nullable(),
});

const defValues = (data) => {
    return {
        editorialId: Number(data.editorialId),
        serviceId: data.serviceId.trim(),
        subserviceId: isNullOrUndefined(data.subserviceId) ? null : data.subserviceId.trim(),
    }
}

module.exports = {
    schema,
    defValues
}