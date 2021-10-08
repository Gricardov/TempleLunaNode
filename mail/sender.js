const fs = require('fs');
const nodemailer = require('nodemailer');
const mailTemplate = fs.readFileSync(__dirname + '/../templates/mail.html');
require('custom-env').env();

exports.sendEmail = (receiver, receiverName, type = 'REQUEST_DONE', extraData) => {

    try {
        if (!receiver) {
            return;
        }
        
        const transporter = nodemailer.createTransport({
            //service: 'gmail',
            host: 'smtp.zoho.com',
            port: 465,
            secure: true,
            auth: {
                user: process.env.TEMP_Z_USER,
                pass: process.env.TEMP_Z_KEY
            }
        });

        let subject = 'Test email';
        let linkTo = 'https://templeluna.app';
        let joinLink = process.env.URL_GROUP_FB;
        let altText = 'This is a test mail';
        let htmlText = 'This is a test mail';

        switch (type) {
            case 'REQUEST_DONE':
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

}