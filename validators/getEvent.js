const yup = require('yup');

const schema = yup.object({
    alias: yup.string().trim().min(1).max(200).required('No se ha introducido un alias para el evento')
});

const defValues = (data) => {
    return {
        alias: data.alias.trim()
    }
}

module.exports = {
    schema,
    defValues
}