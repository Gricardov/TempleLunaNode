const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    actionId: yup.string().min(1).max(50).required(),
    userId: yup.number().min(1).max(100000000).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200).when('userId', {
        is: null,
        then: yup.string().required('El email es requerido'),
    }).nullable(),
    orderId: yup.number().min(1).max(100000000).nullable(),
    magazineId: yup.number().min(1).max(100000000).nullable(),
    socialNetworkName: yup.string().trim().min(1).max(50).nullable()
});

const defValues = (data) => {
    return {
        actionId: data.actionId.trim(),
        userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        email: isNullOrUndefined(data.email) ? null : data.email.trim(),
        orderId: isNullOrUndefined(data.courses) ? null : Number(data.courses),
        magazineId: isNullOrUndefined(data.magazine) ? null : Number(data.magazine),
        socialNetworkName: isNullOrUndefined(data.socialNetworkName) ? null : data.socialNetworkName.trim()
    }
}

module.exports = {
    schema,
    defValues
}