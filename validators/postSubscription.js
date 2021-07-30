const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    userId: yup.number().min(1).max(100000000).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200).when('userId', {
        is: null,
        then: yup.string().required('El email es requerido'),
    }).nullable(),
    names: yup.string().trim().min(1).max(200).when('userId', {
        is: null,
        then: yup.string().required('El nombre es requerido'),
    }).nullable(),
    courses: yup.boolean().nullable(),
    magazine: yup.boolean().nullable(),
    novelties: yup.boolean().nullable()
});

const defValues = (data) => {
    return {
        userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        names: isNullOrUndefined(data.names) ? null : data.names.trim(),
        email: isNullOrUndefined(data.email) ? null : data.email.trim(),
        courses: isNullOrUndefined(data.courses) ? null : Boolean(data.courses),
        magazine: isNullOrUndefined(data.magazine) ? null : Boolean(data.magazine),
        novelties: isNullOrUndefined(data.novelties) ? null : Boolean(data.novelties)
    }
}

module.exports = {
    schema,
    defValues
}