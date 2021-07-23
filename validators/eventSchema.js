const yup = require('yup');

const getEventsSchemaQuery = yup.object({
    limit: yup.number().min(1).max(50)
});

const getEventsDefaultsQuery = (data) => {
    return {
        limit: data.limit ? parseInt(data.limit) : 5

    }
}

module.exports = {
    getEventsSchemaQuery,
    getEventsDefaultsQuery
};