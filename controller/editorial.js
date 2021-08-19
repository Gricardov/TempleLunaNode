const { queryDB } = require('../database/pool');

const getMembersByEditorialService = async (req, res) => {
    const { editorialId, serviceId } = req.params;
    try {
        const membersRes = await queryDB('CALL USP_GET_MEMBERS_BY_EDITORIAL_SERVICE(?,?)', [editorialId, serviceId]);
        res.json(membersRes[0]);
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
};

const getServicesByEditorialId = async (req, res) => {
    const { editorialId } = req.params;
    try {
        const servicesRes = await queryDB('CALL USP_GET_EDITORIAL_SERVICES(?,?)', [editorialId, false]);
        res.json(servicesRes[0]);
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
};

const getServicesByEditorialMember = async (req, res) => {
    const { editorialId } = req.params;
    const { claims } = req.body;
    try {
        const servicesRes = await queryDB('CALL USP_GET_EDITORIAL_SERVICES_BY_EDITORIAL_MEMBER(?,?,?)', [claims.userId, editorialId, false]);
        res.json(servicesRes[0]);
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    getMembersByEditorialService,
    getServicesByEditorialId,
    getServicesByEditorialMember
}