const { queryDB } = require('../../database/pool');
const { generateTemplate } = require('../../utils/template-creator');
const stream = require('stream');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const { uploadResultRequest } = require('../../utils/functions');

const filtersForEdit = ['DISPONIBLE', 'ANULADO']; // Filtros para elegir en el dropdown al momento de editar un pedido desde admin

const filterStatuses = async (req, res) => {
    const { sort, range, filter } = req.query;
    //console.log('sort', sort);
    //console.log('range', range);
    //console.log('filter', filter);

    const { ids, filterFor } = JSON.parse(filter);

    //const rangeObj = JSON.parse(range);

    let query;
    let params = [];

    if (ids) {
        // Esto indica que la búsqueda es un getManyByIds
        query = 'CALL ASP_GET_MANY_ORDER_STATUSES_BY_IDS(?)';
        params = JSON.stringify(ids);
    } else {
        // Filtros normales
        query = 'CALL ASP_GET_ORDER_STATUSES()';
    }

    try {
        const servicesRes = await queryDB(query, params);
        let services = servicesRes[0];

        // Al editar o crear el pedido, el dropdown puede mostrar más o menos opciones
        switch (filterFor) {
            case 'EDITION':
                services = services.filter(service => filtersForEdit.includes(service.id));
                break;
        }

        res.json({ data: services, total: services.length > 0 ? services[0].total : 0 });
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    filterStatuses
}