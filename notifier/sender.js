const fs = require('fs');
const nodemailer = require('nodemailer');
// const mailTemplate = fs.readFileSync(__dirname + '/../templates/mail.html');
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

// Notifica cuando un pedido está terminado
exports.notifyOrderDone = async (receiver, order) => {
    try {
        const mailTemplate = await getTemplate('order-done-template.html');

        const { titleWork, id, serviceId, version } = order;
        const { clientNames, clientEmail } = receiver;

        let subject = '';

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

        let linkTo = `${process.env.PRODUCTION_URL_FRONT}pedido/${id}`;
        let altText = `Hola ${clientNames}.\nTu trabajo final puede ser encontrado aquí:\n${linkTo}\nTe esperamos en la mejor comunidad literaria del mundo: ${process.env.URL_GROUP_FB}\nEquipo Temple Luna.`;
        let htmlText = mailTemplate.toString()
            .replace(/{{name}}/g, clientNames)
            .replace(/{{mainText}}/g, subject)
            .replace(/{{workTitle}}/g, "\"" + titleWork + "\"")
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

        await sendMail(mailOptions);
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
        const { workerFName, workerContactEmail } = receiver;

        let subject = '';

        switch (serviceId) {
            case 'CRITICA':
                subject = '¡Has recibido un comentario en tu crítica!';
                break;
            case 'DISENO':
                subject = '¡Has recibido un comentario en tu diseño!';
                break;
            // En teoría, nunca debería entrar a ESCUCHA
            case 'ESCUCHA':
                subject = '¡Has recibido un comentario en tu servicio de escucha!';
                break;
        }

        let linkTo = `${process.env.PRODUCTION_URL_FRONT}pedido/${id}`;
        let altText = `Hola ${workerFName}.\nTu trabajo en la obra "${titleWork}" ha recibido un comentario. Machuca aquí para verlo: \n${linkTo}\nEquipo Temple Luna.`;
        let htmlText = mailTemplate.toString()
            .replace(/{{name}}/g, workerFName)
            .replace(/{{mainText}}/g, subject)
            .replace(/{{workTitle}}/g, "\"" + titleWork + "\"")
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

        await sendMail(mailOptions);
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
        let altText = `Hola ${workerFName}.\nTu trabajo en la obra "${titleWork}" ha sido descargado. ¡Felicitaciones!\nEquipo Temple Luna.`;
        let htmlText = mailTemplate.toString()
            .replace(/{{name}}/g, workerFName)
            .replace(/{{mainText}}/g, subject)
            .replace(/{{workTitle}}/g, "\"" + titleWork + "\"")
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
            let altText = `Hola ${name}.\nYa salió la nueva edición de la revista Temple Luna. Puedes leerla aquí:\n${linkTo}\nPara dejar comentarios, crea una cuenta. Te esperamos en la mejor comunidad literaria del mundo: ${process.env.URL_GROUP_FB}\nEquipo Temple Luna.`;
            let htmlText = mailTemplate.toString()
                .replace(/{{name}}/g, name)
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