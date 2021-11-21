const { queryDB } = require('../../database/pool');
const { generateTemplate } = require('../../utils/template-creator');
const stream = require('stream');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const { uploadResultRequest } = require('../../utils/functions');

const filterServices = async (req, res) => {
    const { sort, range, filter } = req.query;
    //console.log('sort', sort);
    //console.log('range', range);
    //console.log('filter', filter);

    const filterObj = JSON.parse(filter);
    //const rangeObj = JSON.parse(range);

    let query;
    let params = [];

    if (filterObj.ids) {
        // Esto indica que la búsqueda es un getManyByIds
        query = 'CALL ASP_GET_MANY_ORDER_SERVICES_BY_IDS(?)';
        params = JSON.stringify(filterObj.ids);
    } else {
        // Filtros normales
        query = 'CALL ASP_GET_ORDER_SERVICES()';
    }

    try {
        const servicesRes = await queryDB(query, params);
        const services = servicesRes[0];
        res.json({ data: services, total: services.length > 0 ? services[0].total : 0 });
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    filterServices
}