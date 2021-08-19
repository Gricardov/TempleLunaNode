const yup = require('yup');

const schema = yup.object({
    editorialId: yup.number().min(1).max(100000000).required('El id de la editorial es requerido')    
});

const defValues = (data) => {
    return {
        editorialId: Number(data.editorialId)
    }
}

module.exports = {
    schema,
    defValues
}