const { queryDB } = require('../database/pool');

const getMagazine = async (req, res) => {
    const { alias } = req.params;
    try {
        const magRes = await queryDB('CALL USP_GET_MAGAZINE_BY_ALIAS(?)', [alias]); // Evento
        const magazine = magRes[0][0]; // El primero es por las estadísticas; el segundo, por que solo quiero un resultado
        if (magazine) {
            res.json(magazine);
        } else {
            throw { msg: 'Revista no encontrada', statusCode: 404 };
        }
    } catch (error) {
        console.log(error);
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
}

const getMagazinesByYear = async (req, res) => {
    const { year } = req.query;
    try {
        const magRes = await queryDB('CALL USP_GET_MAGAZINES_BY_YEAR(?)', [year]);
        res.json(magRes[0]);
    } catch (error) {
        console.log(error)
        res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
    }
};

module.exports = {
    getMagazine,
    getMagazinesByYear
}