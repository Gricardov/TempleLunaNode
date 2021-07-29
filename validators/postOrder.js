const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    editorialId: yup.number().min(1).max(10).required('El id de la editorial es requerido'),
    serviceId: yup.string().trim().max(10).required('El id de servicio es requerido'),
    subserviceId: yup.string().trim().max(10).nullable(),
    userId: yup.number().min(1).max(10).nullable(),
    age: yup.number().min(10).max(99).when('userId', {
        is: null,
        then: yup.number().required('La edad es requerida')
    }).nullable(),
    app: yup.string().trim().min(1).max(50).when('userId', {
        is: null,
        then: yup.string().required('La app es requerida'),
    }).nullable(),
    names: yup.string().trim().min(1).max(200).when('userId', {
        is: null,
        then: yup.string().required('El nombre es requerido'),
    }).nullable(),
    phone: yup.string().trim().matches(/^[0-9\-\+]{9,15}$/, 'El teléfono no es válido').when('userId', {
        is: null,
        then: yup.string().required('El teléfono es requerido'),
    }).nullable(),
    intention: yup.string().trim().min(1).max(500).nullable(),
    details: yup.string().trim().min(1).max(500).nullable(),
    urlImgData: yup.array().of(yup.object().shape({
        urlImg: yup.string().min(1).max(500).strict().required(),
        createdAt: yup.string().min(1).max(500).strict().required(),
        observation: yup.string().min(1).max(500).strict()
    })).nullable(),
    link: yup.string().trim().min(1).max(500).nullable(),
    title: yup.string().trim().min(1).max(500).nullable(),
    notify: yup.string().trim().min(1).max(10).nullable(),
    phrase: yup.string().trim().min(1).max(200).nullable(),
    publicLink: yup.string().trim().min(1).max(500).nullable(),
    extraData: yup.mixed().nullable(),
    critiqueTopics: yup.array().of(yup.string().min(1).max(50).strict().required()).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(100).nullable(),
    synopsis: yup.string().trim().min(1).max(500).nullable(),
    priority: yup.string().trim().min(1).max(50).nullable(),
    workerUserId: yup.number().min(1).max(10).required('El id del trabajador es requerido')
});

const defValues = (data) => {
    return {
        actionId: data.actionId.trim(),
        /*userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        email: isNullOrUndefined(data.email) ? null : data.email.trim(),
        orderId: isNullOrUndefined(data.courses) ? null : Number(data.courses),
        magazineId: isNullOrUndefined(data.magazine) ? null : Number(data.magazine),
        socialNetworkName: isNullOrUndefined(data.socialNetworkName) ? null : data.socialNetworkName.trim()*/
    }
}

module.exports = {
    schema,
    defValues
}