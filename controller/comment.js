const { queryDB } = require('../database/pool');

// Recordar que los comentarios siempre se muestran desde los más nuevos a los más antiguos
const getOlderCommentsByMagazineAlias = async (req, res) => {
    const { magazineAlias, limit, lastDate } = req.query;
    try {
        const comRes = await queryDB('CALL USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ALIAS(?,?,?)', [magazineAlias, limit, lastDate]);
        res.json(comRes[0]);
    } catch (error) {
        console.log(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

module.exports = {
    getOlderCommentsByMagazineAlias
}