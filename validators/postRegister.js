const yup = require('yup');
const { queryDB } = require('../database/pool');
const { eachWordtoSentence } = require('../utils/functions');

const schema = yup.object({
    fName: yup.string().trim().min(2).max(200).required('El nombre es requerido'),
    lName: yup.string().trim().min(2).max(200).required('El apellido es requerido'),
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200).required('El email es requerido'),
    password: yup.string().trim().min(8).max(50).matches(/.*[0-9].*/, 'La contraseña debe contener por lo menos un número').required('La contraseña es requerida')
});

const defValues = (data) => {
    return {
        fName: eachWordtoSentence(data.fName.trim()),
        lName: eachWordtoSentence(data.lName.trim()),
        email: data.email.trim().toLowerCase(),
        password: data.password.trim()
    }
}

const isRegistered = async (req, res, next) => {
    try {
        // Debe ser llamado después de validar el correo
        const { email } = req.body;
        const result = await queryDB('CALL USP_GET_USER_STATUS_BY_EMAIL(?)', [email]);
        const { exists } = result[0][0];
        if (exists) {
            throw { msg: `El usuario ${email} ya está registrado`, statusCode: 404 };
        }
        next();
    } catch (error) {
        console.error(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    schema,
    defValues,
    isRegistered
}