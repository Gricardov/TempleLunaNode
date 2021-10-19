const { queryDB } = require('../database/pool');
const { generateRequestTemplate } = require('../utils/template-generator');
const stream = require('stream');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const { uploadResultRequest } = require('../utils/functions');
const { notifyOrderDone, notifySubscriptionMagazine } = require('../mail/sender');

const sendTestOrderTemplate = async (req, res) => {
  try {
    const order = req.body;

    const testClient = { clientNames: 'Prueba', clientEmail: 'gricardov@gmail.com' };
    const testOrder = { titleWork: 'Título de prueba', id: 'id de prueba', serviceId: 'CRITICA' }

    // Send test email
    await notifyOrderDone(testClient, testOrder);

    res.json({ ok: 'ok' });

  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

const sendTestMagazineTemplate = async (req, res) => {
  try {
    const order = req.body;

    const subscribers = [{ name: 'Prueba', email: 'gricardov@gmail.com' }, { name: 'Sorgalim', email: 'oct967777777@gmail.com' }];
    const magazine = { title: 'Revista de prueba', edition: '1', alias: 'REVISTA-DE-PRUEBAS' }

    // Send test email
    await notifySubscriptionMagazine(subscribers, magazine);

    res.json({ ok: 'ok' });
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

module.exports = {
  sendTestOrderTemplate,
  sendTestMagazineTemplate
}