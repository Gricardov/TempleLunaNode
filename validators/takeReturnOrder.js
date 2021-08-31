const yup = require('yup');

const schema = yup.object({
    orderId: yup.number().min(1).max(100000000).required('El id del pedido es requerido')
})

const defValues = (data) => {
    return {
        orderId: Number(data.orderId)
    }
}

module.exports = {
    schema,
    defValues
}