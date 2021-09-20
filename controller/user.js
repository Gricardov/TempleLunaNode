const { queryDB } = require('../database/pool');

const getUsers = async (req, res) => {
  res.json({});
};

const getUser = async (req, res) => {
  /*const { id } = req.params;
  const user = await User.findByPk(id);
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({
      msg: "No existe usuario con ese id",
    });
  }*/
};

const getUserProfileWithToken = async (req, res) => {
  const { claims } = req.body;
  const { userId } = req.params;
  try {

    let profileStatement = 'CALL USP_GET_PUBLIC_PROFILE_BY_ID(?)';

    // Si el perfil solicitado tiene como dueño al solicitante, que obtenga su perfil PRIVADO. Caso contrario, perfil PÚBLICO
    if (claims.userId == userId) {
      profileStatement = 'CALL USP_GET_PRIVATE_PROFILE_BY_ID(?)';
    }

    const [profileRes, servicesRes] = await Promise.all([
      queryDB(profileStatement, [userId]),
      queryDB('CALL USP_GET_ALL_SERVICES_BY_USER(?,?)', [userId, false])
    ]);

    const profile = profileRes[0][0];

    if (profile) {

      let services = servicesRes[0];

      // Obtengo las estadísticas por cada uno de los servicios de los pedidos
      const totalsRes = await Promise.all(services.map(service => queryDB('CALL USP_GET_ORDER_STATUS_PUBLIC_TOTALS_BY_WORKER_USER_ID(?,?)', [service.serviceId, userId])));

      // Agrego las estadísticas a cada servicio
      services = totalsRes.map((total, index) => ({ total: total[0][0].HECHO, ...services[index] }));

      res.json({ profile, services });
    } else {
      throw { msg: 'Perfil inexistente o deshabilitado', statusCode: 404 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const getUserProfileWithoutToken = async (req, res) => {
  const { userId } = req.params;
  try {
    const [profileRes, servicesRes] = await Promise.all([
      queryDB('CALL USP_GET_PUBLIC_PROFILE_BY_ID(?)', [userId]),
      queryDB('CALL USP_GET_ALL_SERVICES_BY_USER(?,?)', [userId, false])
    ]);

    const profile = profileRes[0][0];

    if (profile) {

      let services = servicesRes[0];

      // Obtengo las estadísticas por cada uno de los servicios de los pedidos
      const totalsRes = await Promise.all(services.map(service => queryDB('CALL USP_GET_ORDER_STATUS_PUBLIC_TOTALS_BY_WORKER_USER_ID(?,?)', [service.serviceId, userId])));

      // Agrego las estadísticas a cada servicio
      services = totalsRes.map((total, index) => ({ total: total[0][0].HECHO, ...services[index] }));

      res.json({ profile, services });
    } else {
      throw { msg: 'Perfil inexistente o deshabilitado', statusCode: 404 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

const postUser = async (req, res) => {
  const { claims } = req.body; // El middleware validateToken inserta los claims del JWT en el body
  try {
    const userRes = await queryDB('CALL USP_GET_PRIVATE_USER_BY_EMAIL(?)', [claims.email]);
    const user = userRes[0][0];
    if (user) {
      res.json(user);
    } else {
      throw { msg: 'Usuario inexistente o deshabilitado', statusCode: 404 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const putUser = async (req, res) => {
  /*const { id } = req.params;
  const { body } = req;
  try {
    const user = await User.findByPk(id);
    if (!user) {
      return res.status(404).json({
        msg: "No existe un usuario con ese id",
      });
    }
    await user.update(body);
    res.json(user);
  } catch (error) {
    console.log(error);
    res.status(404).json({
      msg: "Hable con el administrador",
    });
  }*/
};

const deleteUser = async (req, res) => {
  /*const { id } = req.params;

  const user = await User.findByPk(id);
  if (!user) {
    return res.status(404).json({
      msg: "No existe un usuario con ese id",
    });
  }

  // Eliminación física
  //await user.destroy();

  // Eliminación lógica
  await user.update({ status: false });

  res.json(user);*/
};

module.exports = {
  getUser,
  getUserProfileWithToken,
  getUserProfileWithoutToken,
  getUsers,
  putUser,
  postUser,
  deleteUser
}