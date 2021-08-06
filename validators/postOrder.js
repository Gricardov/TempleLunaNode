const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const allowedServicesIds = ['ESCUCHA', 'DISENO', 'CRITICA'];

const schema = yup.object({
    editorialId: yup.number().min(1).max(100000000).required('El id de la editorial es requerido'),
    serviceId: yup.string().trim().max(50).test('isServiceIdAllowed', 'El servicio solicitado no está habilitado', serviceId => allowedServicesIds.includes(serviceId)).required('El id de servicio es requerido'),
    subserviceId: yup.string().trim().max(50).nullable(),
    userId: yup.number().min(1).max(100000000).nullable(),
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
    details: yup.string().trim().max(500).nullable(), // Puede estar vacío
    urlImgData: yup.array().of(yup.object().shape({
        urlImg: yup.string().min(1).max(500).strict().required(),
        createdAt: yup.string().min(1).max(500).strict().required(),
        observation: yup.string().min(1).max(500).strict()
    })).nullable(),
    link: yup.string().trim().min(1).max(500).nullable(),
    title: yup.string().trim().min(1).max(200).nullable(),
    notify: yup.boolean().nullable(),
    phrase: yup.string().trim().max(200).nullable(), // Puede estar vacío
    pseudonym: yup.string().trim().max(200).nullable(),
    publicLink: yup.boolean().nullable(),
    extraData: yup.mixed().nullable(),
    //critiqueTopics: yup.array().of(yup.string().min(1).max(50).strict().required()).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200).nullable(),
    synopsis: yup.string().trim().min(1).max(500).nullable(),
    //priority: yup.string().trim().min(1).max(50).nullable(),
    priority: yup.string().trim().min(1).max(50).when('serviceId', (serviceId, schema) => serviceId != 'ESCUCHA' ? schema.test('isNullOrUndefined', 'Este servicio no permite elegir una prioridad', val => isNullOrUndefined(val)) : schema).nullable(), // Solo los servicios habilitados pueden especificar una prioridad. Por ejemplo, servicio de ESCUCHA
    workerUserId: yup.number().min(1).max(100000000).when('serviceId', (serviceId, schema) => serviceId != 'ESCUCHA' ? schema.test('isNullOrUndefined', 'Este servicio no permite elegir un id de colaborador', val => isNullOrUndefined(val)) : schema).nullable() // Verifico que solo los servicios habilitados acepten valores de workerUserId
});

const defValues = (data) => {
    return {
        editorialId: Number(data.editorialId),
        serviceId: data.serviceId.trim(),
        subserviceId: isNullOrUndefined(data.subserviceId) ? null : data.subserviceId.trim(),
        userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        age: isNullOrUndefined(data.age) ? null : Number(data.age),
        app: isNullOrUndefined(data.app) ? null : data.app.trim(),
        names: isNullOrUndefined(data.names) ? null : data.names.trim(),
        phone: isNullOrUndefined(data.phone) ? null : data.phone.trim(),
        intention: isNullOrUndefined(data.intention) ? null : data.intention.trim(),
        details: isNullOrUndefined(data.details) ? null : data.details.trim(),
        urlImgData: isNullOrUndefined(data.urlImgData) ? null : JSON.stringify(data.urlImgData),
        link: isNullOrUndefined(data.link) ? null : data.link.trim(),
        title: isNullOrUndefined(data.title) ? null : data.title.trim(),
        notify: isNullOrUndefined(data.notify) ? null : Boolean(data.notify),
        phrase: isNullOrUndefined(data.phrase) ? null : data.phrase.trim(),
        pseudonym: isNullOrUndefined(data.pseudonym) ? null : data.pseudonym.trim(),
        publicLink: isNullOrUndefined(data.publicLink) ? null : Boolean(data.publicLink),
        extraData: isNullOrUndefined(data.extraData) ? null : JSON.stringify(data.extraData),
        email: isNullOrUndefined(data.email) ? null : data.email.trim(),
        synopsis: isNullOrUndefined(data.synopsis) ? null : data.synopsis.trim(),
        priority: isNullOrUndefined(data.priority) ? null : data.priority.trim(),
        workerUserId: isNullOrUndefined(data.workerUserId) ? null : Number(data.workerUserId)
    }
}

module.exports = {
    schema,
    defValues
}