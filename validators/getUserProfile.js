const yup = require('yup');

const schema = yup.object({
    userId: yup.number().min(1).max(100000000).required('El id del usuario es requerido')
});

const defValues = (data) => {
    return {
        userId: Number(data.userId)
    }
}

module.exports = {
    schema,
    defValues
}