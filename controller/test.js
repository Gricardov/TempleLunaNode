const { queryDB } = require('../database/pool');
const { generateTemplate } = require('../utils/template-creator');
const stream = require('stream');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const { uploadResultRequest } = require('../utils/functions');
const { notifyOrderDone, notifySubscriptionMagazine } = require('../notifier/sender');

// Generate test pdf order
const generateTestPdfOrder = async (req, res) => {
  try {
    const { orderId = 1, artistId = 1, urlImg = '', titleWork = 'Título de prueba', serviceId = 'CRITICA', fName = 'Alyoh', lName = 'Mascarita', contactEmail = 'prueba@prueba.com', networks = ['https://facebook.com', 'https://templeluna.app'], intention = 'INTENTION', hook = 'HOOK', ortography = 'ORTOGRAPHY', advice = 'ADVICE' } = req.body;

    const fileBuffer = await generateTemplate(serviceId, { id: artistId, fName, lName, contactEmail, networks }, { id: orderId, titleWork, intention, hook, ortography, advice });
    var bufferStream = new stream.PassThrough();
    bufferStream.end(Buffer.from(fileBuffer));
    bufferStream.pipe(res);
  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

// Send test email
const sendTestOrderEmail = async (req, res) => {
  try {
    const order = req.body;

    const testClient = { clientNames: 'Prueba', clientEmail: 'gricardov@gmail.com' };
    const testOrder = { workerUserId: '000001', resultUrl: 'https://templeluna.app', titleWork: 'Título de prueba', id: 'id de prueba', serviceId: 'DISENO', clientPhone: '+51927153346', clientAppId: 'WSP' };

    const ok = await notifyOrderDone(testClient, testOrder);

    if (ok) {
      res.json({ ok: 'ok' });
    } else {
      res.json({ error: 'Error' });
    }

  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
};

// Send test magazine
const sendTestMagazineEmail = async (req, res) => {
  try {
    const order = req.body;

    const subscribers = [{ name: 'Prueba', email: 'gricardov@gmail.com' }, { name: 'Sorgalim', email: 'oct967777777@gmail.com' }];
    const magazine = { title: 'Revista de prueba', edition: '1', alias: 'REVISTA-DE-PRUEBAS' }

    // Send test email
    const res = await notifySubscriptionMagazine(subscribers, magazine);

    if (res) {
      res.json({ ok: 'ok' });
    } else {
      res.json({ error: 'Error' });
    }

  } catch (error) {
    console.log(error);
    res.status((error && error.statusCode) || 500).json({ msg: (error && error.msg) || 'Error de servidor' });
  }
}

module.exports = {
  generateTestPdfOrder,
  sendTestMagazineEmail,
  sendTestOrderEmail
}