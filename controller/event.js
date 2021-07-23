const { queryDB } = require('../database/pool');

const getEvents = async (req = Request, res = Response) => {
  const { limit } = req.query;
  try {
    const eventsRes = await queryDB('CALL USP_GET_LATEST_EVENTS(?,?)', [limit, null]);
    const instructorsPromises = eventsRes[0].map(event => queryDB('CALL USP_GET_INSTRUCTORS_BY_EVENT(?)', [event.id]));
    const instructorsResArray = await Promise.all(instructorsPromises);
    instructorsResArray.map((res, i) => eventsRes[0][i].instructors = res[0]);
    res.json(eventsRes[0]);
  } catch (err) {
    res.status(500).json({ msg: 'Error de servidor' });
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