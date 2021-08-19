const yup = require('yup');
const allowedServices = ["ESCUCHA"];

const schema = yup.object({
    editorialId: yup.number().min(1).max(100000000).required('El id de la editorial es requerido'),
    serviceId: yup.string().trim().min(1).max(50).required('El id del servicio es obligatorio').test('allowedService', 'El servicio no está permitido', value => allowedServices.includes(value))
});

const defValues = (data) => {
    return {
        editorialId: Number(data.editorialId),
        serviceId: data.serviceId.trim()
    }
}

module.exports = {
    schema,
    defValues
}