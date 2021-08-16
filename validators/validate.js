const validateField = (resourceName, { schema, defValues }) => async (req, res, next) => {
    try {
        const resource = req[resourceName];
        await schema.validate(resource);
        req[resourceName] = defValues(resource);
        next();
    } catch (e) {
        console.error(e);
        res.status(400).json({ msg: 'Error de validación' });
    }
};

module.exports = validateField;