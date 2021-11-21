const fs = require('fs');
const nodemailer = require('nodemailer');
const http = require('http');
const moment = require('moment');
const { getRandomWhatsappAssistantName, toSentence, cleanPhoneForWhatsapp } = require('../utils/functions');

require('custom-env').env();

// Contiene el transportador para los emails
const transporter = nodemailer.createTransport({
    //service: 'gmail',
    host: 'smtp.zoho.com',
    port: 465,
    pool: true,
    maxConnections: 20,
    secure: true,
    auth: {
        user: process.env.TEMP_Z_USER,
        pass: process.env.TEMP_Z_KEY
    }
});

const getTemplate = async (fileName) => {
    return new Promise((resolve, reject) => {
        fs.readFile(__dirname + '/../templates/' + fileName, async (err, data) => {
            if (err) {
                reject(err);
            }
            resolve(data);
        });
    });
}

const sendMail = async (mail) => {
    return new Promise((resolve, reject) => {
        transporter.sendMail(mail, function (error, info) {
            if (error) {
                reject(error);
            } else {
                console.log('Correo enviado: ' + info.response);
                resolve(info);
            }
        });

    })
}

const sendWhatsapp = async (number, message) => {
    return new Promise((resolve, reject) => {
        const data = new TextEncoder().encode(
            JSON.stringify({ number, message })
        );

        const options = {
            hostname: 'localhost',
            port: 8082,
            path: '/whatsapp/send',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        };

        const req = http.request(options, res => {
            console.log(`statusCode: ${res.statusCode}`);
            res.on('data', d => {
                process.stdout.write(d);
            });
            resolve(res);
        });

        req.on('error', error => {
            console.error(error);
            reject(error);
        });

        req.write(data);
        req.end();
    })
}

const logNotificationResult = (email, promiseAllSettledResults) => {
    console.log(`${moment().format('DD/MM/YYYY HH:mm')} - Estado de la notificación al usuario ${email}: ${promiseAllSettledResults.filter(r => r.status === 'fulfilled').length} de ${promiseAllSettledResults.length} operaciones correctas`, promiseAllSettledResults)
};

// Notifica cuando un pedido está terminado
exports.notifyOrderDone = async (receiver, order) => {
    try {
        const mailTemplate = await getTemplate('order-done-template.html');

        const { titleWork, id, serviceId, version, clientPhone, clientAppId, workerUserId } = order;
        const { clientNames, clientEmail } = receiver;

        let subject = '';
        let nounArticle = ''; // Esto sirve para ponerle un artículo al servicio
        let nounService = ''; // Esto sirve para escribirlo en el mensaje

        switch (serviceId) {
            case 'CRITICA':
                subject = '¡Tu crítica Temple Luna está lista!';
                nounArticle = 'la';
                nounService = 'crítica';
                break;
            case 'DISENO':
                subject = '¡Tu diseño Temple Luna está listo!';
                nounArticle = 'el';
                nounService = 'diseño';
                break;
            case 'ESCUCHA':
                // En teoría, no debería entrar aquí
                subject = '¡Tu pedido de escucha ha sido tomado!'
                nounArticle = 'la';
                nounService = 'escucha';
                break;
        }

        let linkTo = `${process.env.PRODUCTION_URL_FRONT}pedido/${id}`;
        let altText = `Hola ${toSentence(clientNames.split(' ')[0])}.\nTu trabajo final puede ser encontrado aquí:\n${linkTo}\nTe esperamos en la mejor comunidad literaria del mundo: ${process.env.URL_GROUP_FB}\nEquipo Temple Luna.`;
        let htmlText = mailTemplate.toString()
            .replace(/{{name}}/g, toSentence(clientNames.split(' ')[0]))
            .replace(/{{mainText}}/g, subject)
            .replace(/{{workTitle}}/g, "\"" + toSentence(titleWork) + "\"")
            .replace(/{{secondaryText}}/g, 'Recuerda dejar un comentario. Esperamos que te guste.')
            .replace(/{{serviceId}}/g, serviceId)
            .replace(/{{version}}/g, version)
            .replace(/{{orderHref}}/g, linkTo);

        const mailOptions = {
            from: `"${process.env.TEMP_Z_SENDER}" <${process.env.TEMP_Z_USER}>`,
            to: clientEmail,
            subject,
            text: altText,
            html: htmlText
        };

        const promises = [
            sendMail(mailOptions) // Envía correo
        ];

        // Si tiene whatsapp, lo agrego a las promesas para enviarle un mensaje
        if (clientAppId.trim() === 'WSP') {
            // Remuevo los espacio en blanco y el signo "+" del teléfono
            const cleanPhone = cleanPhoneForWhatsapp(clientPhone);
            promises.push(sendWhatsapp(cleanPhone,
                `Hola ${toSentence(clientNames.split(' ')[0])}, qué tal? 🤗\nTe escribe ${getRandomWhatsappAssistantName()}, asistenta de Temple Luna ☺️. Acabamos de terminar con ${nounArticle} ${nounService} de tu obra *"${toSentence(titleWork)}"*.\nUn favor, cuando termines de verla, nos puedes dejar comentarios y compartir para que más personas nos conozcan? 🥰 Te agradeceria mucho mucho si ayudas a difundir este bonito proyecto.\n\nAquí puedes ver ${nounArticle} ${nounService}: ${linkTo}\n\nEsta personita desarrolló tu ${nounService}, aquí te dejo su perfil para que le puedas agradecer y reacciones a sus demás trabajos:\nhttps://templeluna.app/perfil/${workerUserId}\n\nY por supuesto, te invito a esta bonita comunidad ☺️ aquí organizamos eventos, publicamos revistas propias y damos servicios. Es más, ya te estamos esperando:\n\nGrupo de facebook: ${process.env.URL_GROUP_FB}\n\nPágina web: ${process.env.PRODUCTION_URL_FRONT}`));
            // Trato humano para generar interacción y compromiso con los comentarixs
        }

        const results = await Promise.allSettled(promises);

        logNotificationResult(clientEmail, results);

        return true;

    } catch (error) {
        console.log(error);
        return false;
    }
}

// Notifica cuando un colaborador recibe un comentario en uno de los pedidos que ha realizado
exports.notifyCommentOnOrder = async (receiver, order, comment) => {
    try {
        const mailTemplate = await getTemplate('order-done-template.html');

        const { titleWork, id, serviceId, version } = order;
        const { workerFName, workerContactEmail, workerPhone, workerAppId } = receiver;

        let subject = '';
        let nounArticle = ''; // Esto sirve para ponerle un artículo al servicio
        let nounService = ''; // Esto sirve para escribirlo en el mensaje

        switch (serviceId) {
            case 'CRITICA':
                subject = '¡Has recibido un comentario en tu crítica!';
                nounArticle = 'la';
                nounService = 'crítica';
                break;
            case 'DISENO':
                subject = '¡Has recibido un comentario en tu diseño!';
                nounArticle = 'el';
                nounService = 'diseño';
                break;
            // En teoría, nunca debería entrar a ESCUCHA
            case 'ESCUCHA':
                subject = '¡Has recibido un comentario en tu servicio de escucha!';
                nounArticle = 'la';
                nounService = 'escucha';
                break;
        }

        let linkTo = `${process.env.PRODUCTION_URL_FRONT}pedido/${id}`;
        let altText = `Hola ${toSentence(workerFName.split(' ')[0])}.\nTu trabajo en la obra "${titleWork}" ha recibido un comentario. Machuca aquí para verlo: \n${linkTo}\nEquipo Temple Luna.`;
        let htmlText = mailTemplate.toString()
            .replace(/{{name}}/g, toSentence(workerFName.split(' ')[0]))
            .replace(/{{mainText}}/g, subject)
            .replace(/{{workTitle}}/g, "\"" + toSentence(titleWork) + "\"")
            .replace(/{{secondaryText}}/g, 'Gracias por ser parte.')
            .replace(/{{serviceId}}/g, serviceId)
            .replace(/{{version}}/g, version)
            .replace(/{{orderHref}}/g, linkTo);

        const mailOptions = {
            from: `"${process.env.TEMP_Z_SENDER}" <${process.env.TEMP_Z_USER}>`,
            to: workerContactEmail,
            subject,
            text: altText,
            html: htmlText
        };

        const promises = [
            sendMail(mailOptions) // Envía correo
        ];

        // Si tiene whatsapp, lo agrego a las promesas para enviarle un mensaje
        if (workerPhone && workerAppId?.trim() === 'WSP') {
            // Remuevo los espacio en blanco y el signo "+" del teléfono
            const cleanPhone = cleanPhoneForWhatsapp(workerPhone);
            promises.push(sendWhatsapp(cleanPhone,
                `Hola ${toSentence(workerFName.split(' ')[0])} 🤗.\nTe escribe ${getRandomWhatsappAssistantName()}, asistenta de Temple Luna ☺️. Acabas de recibir un comentario en ${nounArticle} ${nounService} que hiciste de *"${toSentence(titleWork)}"*.\n\nAquí puedes verlo: ${linkTo}\n\nGracias por ser parte, eres muy importante para nosotros 🥰.`));
            // Trato humano para generar interacción y compromiso con los comentarixs
        }

        const results = await Promise.allSettled(promises);

        logNotificationResult(workerContactEmail, results);

        return true;

    } catch (error) {
        console.log(error);
        return false;
    }
}

// Notifica cuando un colaborador recibe una reacción en uno de los pedidos que ha realizado
exports.notifyReactionOnOrder = async (receiver, order, actionId) => {
    try {
        const mailTemplate = await getTemplate('order-done-template.html');

        const { titleWork, id, serviceId, version } = order;
        const { workerFName, workerContactEmail } = receiver;

        let subject = '';

        switch (actionId) {
            case 'GUSTAR':
                subject = '¡Alguien te ha dejado un corazón!';
                break;
            case 'DESCARGAR':
                subject = '¡Alguien ha descargado tu pedido!';
                break;
            default:
                return true;
        }

        let linkTo = `${process.env.PRODUCTION_URL_FRONT}pedido/${id}`;
        let altText = `Hola ${toSentence(workerFName.split(' ')[0])}.\nTu trabajo en la obra "${titleWork}" ha sido descargado. ¡Felicitaciones!\nEquipo Temple Luna.`;
        let htmlText = mailTemplate.toString()
            .replace(/{{name}}/g, toSentence(workerFName.split(' ')[0]))
            .replace(/{{mainText}}/g, subject)
            .replace(/{{workTitle}}/g, "\"" + toSentence(titleWork) + "\"")
            .replace(/{{secondaryText}}/g, '¡Felicitaciones!')
            .replace(/{{serviceId}}/g, serviceId)
            .replace(/{{version}}/g, version)
            .replace(/{{orderHref}}/g, linkTo);

        const mailOptions = {
            from: `"${process.env.TEMP_Z_SENDER}" <${process.env.TEMP_Z_USER}>`,
            to: workerContactEmail,
            subject,
            text: altText,
            html: htmlText
        };

        await sendMail(mailOptions);
        return true;

    } catch (error) {
        console.log(error);
        return false;
    }
}

// Envía una revista por suscripción
exports.notifySubscriptionMagazine = async (subscribers, magazine) => {
    try {
        const mailTemplate = await getTemplate('magazine-subscription-template.html');

        const { title, edition, alias } = magazine;

        let subject = `${title}, ed. ${edition} - Revista Temple Luna`;

        let linkTo = `${process.env.PRODUCTION_URL_FRONT}revista/${alias}`;

        const sendPromises = subscribers.map(subscriber => {
            const { name, email } = subscriber;
            let altText = `Hola ${toSentence(name)}.\nYa salió la nueva edición de la revista Temple Luna. Puedes leerla aquí:\n${linkTo}\nPara dejar comentarios, crea una cuenta. Te esperamos en la mejor comunidad literaria del mundo: ${process.env.URL_GROUP_FB}\nEquipo Temple Luna.`;
            let htmlText = mailTemplate.toString()
                .replace(/{{name}}/g, toSentence(name))
                .replace(/{{magazineTitle}}/g, title)
                .replace(/{{magazineHref}}/g, linkTo)
                .replace(/{{unsubscribeHref}}/g, linkTo);

            const mailOptions = {
                from: `"${process.env.TEMP_Z_SENDER}" <${process.env.TEMP_Z_USER}>`,
                to: email,
                subject,
                text: altText,
                html: htmlText
            };
            return sendMail(mailOptions);
        });

        const sendResults = await Promise.allSettled(sendPromises);
        console.log('Resultados de envío', sendResults);
        return sendResults;

    } catch (error) {
        console.log(error);
        return false;
    }
}

/*exports.sendEmail = async (templateFileName = 'order-template.html', receiver, receiverName, type = 'ORDER_DONE', extraData) => {

    try {
        if (!receiver) {
            return;
        }

        const mailTemplate = await getTemplate(templateFileName);

        let subject = 'Test email';
        let linkTo = 'https://templeluna.app';
        let joinLink = process.env.URL_GROUP_FB;
        let altText = 'This is a test mail';
        let htmlText = 'This is a test mail';

        switch (type) {
            case 'ORDER_DONE':
                {
                    const { titleWork, id, serviceId } = extraData;
                    switch (serviceId) {
                        case 'CRITICA':
                            subject = '¡Tu crítica Temple Luna está lista!';
                            break;
                        case 'DISENO':
                            subject = '¡Tu diseño Temple Luna está listo!';
                            break;
                        case 'ESCUCHA':
                            subject = '¡Tu pedido de escucha ha sido tomado!'
                            break;
                    }
                    linkTo = `${process.env.PRODUCTION_URL_FRONT}pedido/${id}?t=${encodeURIComponent(titleWork)}&templated=true`;
                    altText = `Hola ${receiverName}.\nTu trabajo final puede ser encontrado aquí:\n${linkTo}\nTe esperamos en la mejor comunidad literaria del mundo: ${joinLink}\nEquipo Temple Luna.`;
                    htmlText = mailTemplate.toString()
                        .replace(/{{title}}/g, subject)
                        .replace(/{{bodyText}}/g, `¡Hola, ${receiverName}!<br/>Uno de nuestros artistas ha tomado tu pedido. No olvides recomendarnos, eso nos ayuda mucho`)
                        .replace(/{{linkto}}/g, linkTo);
                }
                break;

            case 'FEEDBACK_GIVEN':
                {
                    const { titleWork, id } = extraData;

                    subject = '¡Has recibido un comentario!';
                    linkTo = `${process.env.PRODUCTION_URL_FRONT}dashboard/?viewFeedback=${id}`;
                    altText = `Hola ${receiverName}.\nTu trabajo en la obra "${titleWork}" ha recibido un comentario. Leelo en tu cuenta o a través de este link:\n${linkTo}\nNo olvides que te queremos.\nEquipo Temple Luna.`;
                    htmlText = mailTemplate.toString()
                        .replace(/{{title}}/g, subject)
                        .replace(/{{bodyText}}/g, `¡Hola, ${receiverName}!<br/>Tu trabajo en la obra "${titleWork}" ha recibido un comentario ¡Felicitaciones!. Leelo en tu cuenta o desde aquí:`)
                        .replace(/{{linkto}}/g, linkTo);
                }
                break;

            case 'LIKE_GIVEN':
                {
                    const { titleWork } = extraData;

                    subject = '¡Has recibido un corazón!';
                    linkTo = `${process.env.PRODUCTION_URL_FRONT}dashboard/`;
                    altText = `Hola ${receiverName}.\nTu trabajo en la obra "${titleWork}" ha recibido un corazón. Míralo desde tu cuenta aquí:\n${linkTo}\nNo olvides que te queremos.\nEquipo Temple Luna.`;
                    htmlText = mailTemplate.toString()
                        .replace(/{{title}}/g, subject)
                        .replace(/{{bodyText}}/g, `¡Hola, ${receiverName}!<br/>Tu trabajo en la obra "${titleWork}" ha recibido un corazón ¡Felicitaciones!. Leelo en tu cuenta desde aquí:`)
                        .replace(/{{linkto}}/g, linkTo);
                }
                break;
            case 'MAGAZINE_SUBSCRIPTION':
                {
                    const { name, magazineTitle, magazineHref, unsubscribeHref } = extraData;

                    subject = `${magazineTitle} - Revista Temple Luna`;
                    linkTo = `${process.env.PRODUCTION_URL_FRONT}dashboard/`;
                    altText = `Hola ${receiverName}.\nTu trabajo en la obra "${titleWork}" ha recibido un corazón. Míralo desde tu cuenta aquí:\n${linkTo}\nNo olvides que te queremos.\nEquipo Temple Luna.`;
                    htmlText = mailTemplate.toString()
                        .replace(/{{title}}/g, subject)
                        .replace(/{{bodyText}}/g, `¡Hola, ${receiverName}!<br/>Tu trabajo en la obra "${titleWork}" ha recibido un corazón ¡Felicitaciones!. Leelo en tu cuenta desde aquí:`)
                        .replace(/{{linkto}}/g, linkTo);
                }
                break;
        }

        const mailOptions = {
            from: `"${process.env.TEMP_Z_SENDER}" <${process.env.TEMP_Z_USER}>`,
            to: receiver,
            subject,
            text: altText,
            html: htmlText
        };

        return transporter.sendMail(mailOptions, function (error, info) {
            if (error) {
                console.log(error);
                throw new Error(error);
            } else {
                console.log('Correo enviado: ' + info.response);
            }
        });
    } catch (error) {
        console.log(error);
        return;
    }

}*/