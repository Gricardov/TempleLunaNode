const yup = require('yup');
const { isNullOrUndefined } = require('../utils/functions');

const schema = yup.object({
    id: yup.number().min(1).max(100000000).required('El id del pedido es requerido'),
    urlImg: yup.string().trim().min(1).max(500).nullable(),
    INTENCION: yup.string().trim().min(10).max(5000).nullable(),
    ENGANCHE: yup.string().trim().min(10).max(5000).nullable(),
    ORTOGRAFIA: yup.string().trim().min(10).max(5000).nullable(),
    CONSEJO: yup.string().trim().min(10).max(5000).nullable()
});

const defValues = (data) => {
    return {
        id: Number(data.id),
        urlImg: isNullOrUndefined(data.urlImg) ? null : data.urlImg.trim(),
        INTENCION: isNullOrUndefined(data.INTENCION) ? null : data.INTENCION.trim(),
        ENGANCHE: isNullOrUndefined(data.ENGANCHE) ? null : data.ENGANCHE.trim(),
        ORTOGRAFIA: isNullOrUndefined(data.ORTOGRAFIA) ? null : data.ORTOGRAFIA.trim(),
        CONSEJO: isNullOrUndefined(data.CONSEJO) ? null : data.CONSEJO.trim()
    }
}

module.exports = {
    schema,
    defValues
}