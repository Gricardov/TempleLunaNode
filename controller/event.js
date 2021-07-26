const { queryDB } = require('../database/pool');

const getEvents = async (req = Request, res = Response) => {
  const { limit, lastDate } = req.query;
  try {
    const eventsRes = await queryDB('CALL USP_GET_LATEST_EVENTS(?,?)', [limit, lastDate]);
    const instructorsPromises = eventsRes[0].map(event => queryDB('CALL USP_GET_INSTRUCTORS_BY_EVENT(?)', [event.alias]));
    const instructorsResArray = await Promise.all(instructorsPromises);
    instructorsResArray.map((res, i) => eventsRes[0][i].instructors = res[0]);
    res.json(eventsRes[0]);
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const getEvent = async (req = Request, res = Response) => {
  const { alias } = req.params;
  try {
    const promises = [
      queryDB('CALL USP_GET_EVENT_BY_ALIAS(?)', [alias]), // Evento
      queryDB('CALL USP_GET_DATES_BY_EVENT(?)', [alias]), // Fechas del evento
      queryDB('CALL USP_GET_INSTRUCTORS_BY_EVENT(?)', [alias]) // Instructores del evento
    ];
    const results = await Promise.all(promises);
    const event = results[0][0][0]; // El primero es por la promesa; el segundo, por el resultado con estadísticas; el tercero, los resultados
    if (event) {
      event.dates = results[1][0];
      event.instructors = results[2][0];
      res.json(event);
    } else {
      throw { msg: 'Evento no encontrado', statusCode: 404 };
    }
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
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