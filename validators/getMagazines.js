const yup = require('yup');

const schema = yup.object({
    year: yup.number().min(2000).max(99999).required()
});

const defValues = (data) => {
    return {
        year: Number(data.year),
    }
}

module.exports = {
    schema,
    defValues
}