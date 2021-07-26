const yup = require('yup');
const moment = require('moment');

const schema = yup.object({
    limit: yup.number().min(1).max(50),
    lastDate: yup.string().trim().min(1).max(50)
});

const defValues = (data) => {
    return {
        limit: data.limit ? parseInt(data.limit) : 5,
        lastDate: data.lastDate ? data.lastDate.split('_')[0] + ' ' + data.lastDate.split('_')[1] : null // El servidor siempre va a recibir en formato UTC
    }
}

module.exports = {
    schema,
    defValues
}