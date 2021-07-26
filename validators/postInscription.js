const yup = require('yup');
const { queryDB } = require('../database/pool');

const schema = yup.object({
    eventId: yup.number().min(1).max(10).required('El id de evento es requerido'),
    userId: yup.number().min(1).max(10).nullable(),
    names: yup.string().trim().min(1).max(200).when('userId', {
        is: null,
        then: yup.string().required(),
    }),
    age: yup.number().min(10).max(99).when('userId', {
        is: null,
        then: yup.number().required()
    }),
    phone: yup.string().trim().matches(/^[0-9\-\+]{9,15}$/, 'El teléfono no es válido').when('userId', {
        is: null,
        then: yup.string().required(),
    }),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(100).when('userId', {
        is: null,
        then: yup.string().required(),
    })
});

const defValues = (data) => {
    return {
        eventId: Number(data.eventId),
        userId: data.userId == null ? null : Number(data.userId),
        names: data.userId == null ? data.names : null,
        age: data.userId == null ? Number(data.age) : null,
        phone: data.userId == null ? data.phone : null,
        email: data.userId == null ? data.email : null,
    }
}

const isEnrolled = async (req, res, next) => {
    try {
        const { eventId, userId, email } = req.body;
        const result = await queryDB('CALL USP_EXISTS_IN_INSCRIPTION(?,?,?)', [eventId, userId, email]);
        const exists = result[0][0].exists;
        if (exists) {
            throw `El usuario ${userId}, ${email} ya se encuentra inscrito al evento ${eventId}`;
        } else {
            next();
        }
    } catch (error) {
        console.error(error);
        res.status(400).json({ msg: 'El usuario ya está registrado al evento' });
    }
}

module.exports = {
    schema,
    defValues,
    isEnrolled
}