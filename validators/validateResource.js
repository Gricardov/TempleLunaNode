const validateResourceMW = (resourceName, schema, getDefaults) => async (req, res, next) => {
    try {
        const resource = req[resourceName];
        // throws an error if not valid
        await schema.validate(resource);
        req[resourceName] = getDefaults(resource);
        next();
    } catch (e) {
        console.error(e);
        res.status(400).json({ msg: 'Error de validación' });
    }
};

module.exports = validateResourceMW;