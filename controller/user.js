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
  getUsers,
  putUser,
  postUser,
  deleteUser
}