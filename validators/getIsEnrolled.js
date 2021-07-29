const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    eventId: yup.number().min(1).max(10).required('El id de evento es requerido'),
    userId: yup.number().min(1).max(10).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(100).when('userId', {
        is: null,
        then: yup.string().required('El correo es requerido'),
    }).nullable(),
});

const defValues = (data) => {
    return {
        eventId: Number(data.eventId),
        userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        email: isNullOrUndefined(data.email) ? null : data.email.trim()
    }
}

module.exports = {
    schema,
    defValues
}