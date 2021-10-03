const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    actionId: yup.string().min(1).max(50).required(),
    userId: yup.number().min(1).max(100000000).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200),
    orderId: yup.number().min(1).max(100000000).nullable(),
    magazineId: yup.number().min(1).max(100000000).nullable(),
    active: yup.boolean().nullable(),
    socialNetworkName: yup.string().trim().min(1).max(50).nullable()
});

const defValues = (data) => {
    return {
        actionId: data.actionId.trim(),
        userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        email: isNullOrUndefined(data.email) ? null : data.email.trim(),
        orderId: isNullOrUndefined(data.orderId) ? null : Number(data.orderId),
        magazineId: isNullOrUndefined(data.magazineId) ? null : Number(data.magazineId),
        active: isNullOrUndefined(data.active) ? true : data.active, // De forma predeterminada, la acción queda activa
        socialNetworkName: isNullOrUndefined(data.socialNetworkName) ? null : data.socialNetworkName.trim()
    }
}

module.exports = {
    schema,
    defValues
}