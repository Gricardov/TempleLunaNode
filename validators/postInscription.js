const yup = require('yup');
const { queryDB } = require('../database/pool');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    eventId: yup.number().min(1).max(100000000).required('El id de evento es requerido'),
    userId: yup.number().min(1).max(100000000).nullable(),
    names: yup.string().trim().min(2).max(200).when('userId', {
        is: null,
        then: yup.string().required('El nombre es requerido'),
    }).nullable(),
    age: yup.number().min(10).max(99).when('userId', {
        is: null,
        then: yup.number().required('La edad es requerida')
    }).nullable(),
    phone: yup.string().trim().matches(/^[0-9\-\+]{9,15}$/, 'El teléfono no es válido').when('userId', {
        is: null,
        then: yup.string().required('El teléfono es requerido'),
    }).nullable(),
    app: yup.string().trim().min(1).max(50).when('userId', {
        is: null,
        then: yup.string().required('La app es requerida'),
    }).nullable(),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200).when('userId', {
        is: null,
        then: yup.string().required('El email es requerido'),
    }).nullable(),
    urlImgData: yup.array().of(yup.object().shape({
        urlImg: yup.string().min(1).max(500).strict().required(),
        createdAt: yup.string().min(1).max(500).strict().required(),
        observation: yup.string().min(1).max(500).strict()
    })).nullable(),
    notify: yup.boolean().nullable()
});

const defValues = (data) => {
    return {
        eventId: Number(data.eventId),
        userId: isNullOrUndefined(data.userId) ? null : Number(data.userId),
        names: isNullOrUndefined(data.names) ? null : data.names.trim(),
        age: isNullOrUndefined(data.age) ? null : Number(data.age),
        phone: isNullOrUndefined(data.phone) ? null : data.phone.trim(),
        app: isNullOrUndefined(data.app) ? null : data.app.trim(),
        email: isNullOrUndefined(data.email) ? null : data.email.trim(),
        urlImgData: isNullOrUndefined(data.urlImgData) ? null : JSON.stringify(data.urlImgData),
        notify: isNullOrUndefined(data.notify) ? null : Boolean(data.notify)
    }
}

const isEnrolled = async (req, res, next) => {
    try {
        const { eventId, userId, email } = req.body;
        const result = await queryDB('CALL USP_EXISTS_IN_INSCRIPTION(?,?,?)', [eventId, userId, email]);
        const exists = result[0][0].exists;
        if (exists) {
            throw { msg: `El usuario ${userId}, ${email} ya se encuentra inscrito al evento ${eventId}`, statusCode: 412 };
        } else {
            next();
        }
    } catch (error) {
        console.error(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    schema,
    defValues,
    isEnrolled
}