const yup = require('yup');

const schema = yup.object({
    email: yup.string().trim().email('Ingresa un correo válido').min(5).max(200).required('El correo es requerido')
});

const defValues = (data) => {
    return {
        email: data.email.trim()
    }
}

module.exports = {
    schema,
    defValues
}