const yup = require('yup');

const schema = yup.object({
    idtoken: yup.string().min(1).max(5000).required()
});

const defValues = (data) => {
    return {
        idtoken: data.idtoken.trim()
    }
}

module.exports = {
    schema,
    defValues
}