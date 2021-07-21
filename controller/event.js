const { queryDB } = require('../database/pool');

const getEvents = async (req = Request, res = Response) => {
  const { limit = "5", order = "startDate", desc = "1" } = req.query;
  try {
    const limitAux = parseInt(limit);
    const descAux = parseInt(desc);
    const result = await queryDB('SELECT * FROM events WHERE id = ?', ['0000000001']);
    res.json({ result });
  } catch (err) {
    res.status(500).json({ msg: 'error' });
  }

  /*const events = await Event.findAll({
    //order: [[order, descAux ? "DESC" : "ASC"]],
    limit: limitAux,
  });*/
};

const getEvent = async (req = Request, res = Response) => {
  /*const { alias } = req.params;
  const event = await Event.findOne({
    where: {
      alias,
    },
  });
  if (event) {
    res.json(event);
  } else {
    res.status(404).json({
      msg: "No existe evento con ese alias",
    });
  }*/
};

const postEvent = async (req = Request, res = Response) => {
  /*const { body } = req;
  try {
    const existsAlias = await Event.findOne({
      where: {
        alias: body.alias,
      },
    });

    if (existsAlias) {
      return res.status(400).json({
        msg: "Ya existe un evento con ese alias",
      });
    }

    const event = Event.build(body);
    await event.save();
    res.json(event);
  } catch (error) {
    console.log(error);
    res.status(404).json({
      msg: "Hable con el administrador",
    });
  }*/
};

const putEvent = async (req = Request, res = Response) => {
  /*const { id } = req.params;
  const { body } = req;
  try {
    const event = await Event.findByPk(id);
    if (!event) {
      return res.status(404).json({
        msg: "No existe un evento con ese id",
      });
    }
    await event.update(body);
    res.json(event);
  } catch (error) {
    console.log(error);
    res.status(404).json({
      msg: "Hable con el administrador",
    });
  }*/
};

const deleteEvent = async (req = Request, res = Response) => {
  /*const { id } = req.params;

  const event = await Event.findByPk(id);
  if (!event) {
    return res.status(404).json({
      msg: "No existe un evento con ese id",
    });
  }

  // Eliminación física
  //await user.destroy();

  // Eliminación lógica
  await event.update({ status: false });

  res.json(event);*/
};


module.exports = {
  getEvents,
  getEvent,
  putEvent,
  postEvent,
  deleteEvent
}