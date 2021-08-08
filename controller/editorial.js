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

module.exports = {
    getMembersByEditorialService
}