const User = require("../models/user");

const getUsers = async (req, res) => {
  const users = await User.findAll();
  res.json({ users });
};

const getUser = async (req, res) => {
  const { id } = req.params;
  const user = await User.findByPk(id);
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({
      msg: "No existe usuario con ese id",
    });
  }
};

const postUser = async (req, res) => {
  const { body } = req;
  try {
    const existeEmail = await User.findOne({
      where: {
        email: body.email,
      },
    });

    if (existeEmail) {
      return res.status(400).json({
        msg: "Ya existe un usuario con ese email",
      });
    }

    const user = User.build(body);
    await user.save();
    res.json(user);
  } catch (error) {
    console.log(error);
    res.status(404).json({
      msg: "Hable con el administrador",
    });
  }
};

const putUser = async (req, res) => {
  const { id } = req.params;
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
  }
};

const deleteUser = async (req, res) => {
  const { id } = req.params;

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

  res.json(user);
};

module.exports = {
  getUser,
  getUsers,
  putUser,
  postUser,
  deleteUser
}