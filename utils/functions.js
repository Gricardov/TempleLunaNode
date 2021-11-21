const QRCode = require('qrcode');
const stream = require('stream');
const moment = require('moment');
const FileType = require('file-type');
const { Storage } = require('@google-cloud/storage');
require("moment/locale/es");

const storage = new Storage({ keyFilename: "./firebase-admin-key.json" });

const configureBucketCors = async () => {
    await storage.bucket('gs://temple-luna.appspot.com').setCorsConfiguration([
        {
            maxAgeSeconds: 3600,
            method: ['GET'],
            origin: ['*'],
            responseHeader: ['*'],
        },
    ]);
}

configureBucketCors();

const isNullOrUndefined = (value) => value == null || value == undefined;

const toSentence = (text, limit) => {
    limit = !limit ? text.length : limit;
    if (text && text.length > 0) {
        return (text.substring(0, 1).toUpperCase() + text.substring(1, limit).toLowerCase()).trim();
    } else {
        return '';
    }
}

// Esto agrega una letra mayúscula al inicio de todas las palabras del texto
const eachWordtoSentence = (text) => {
    const words = text.split(' ');
    const wordsArray = words.map(word => toSentence(word));
    return wordsArray.join(' ');
}

const uploadResultRequest = async (fileBuffer, path, filename) => {
    const metadata = await FileType.fromBuffer(fileBuffer);
    const file = storage.bucket('gs://temple-luna.appspot.com').file(`${path}/${filename}.${metadata.ext}`);
    await file.save(fileBuffer, {
        gzip: true,
        metadata: {
            cacheControl: 'public, max-age=31536000',
        }
    });
    const urls = await file.getSignedUrl({
        action: 'read',
        expires: '03-09-2500',
    });
    return urls[0];
}

const streamToBuffer = stream => {
    const chunks = [];
    return new Promise((resolve, reject) => {
        stream.on('data', chunk => chunks.push(chunk));
        stream.on('error', reject);
        stream.on('end', () => resolve(Buffer.concat(chunks)));
    })
};

const generateQRFile = async (content, width = 200, errorCorrectionLevel = 'L') => {
    const qrStream = new stream.PassThrough();
    await QRCode.toFileStream(qrStream, content,
        {
            type: 'png',
            width,
            margin: 1,
            color: {
                dark: "#000",
                light: "#FFF"
            },
            errorCorrectionLevel
        }
    );
    return await streamToBuffer(qrStream);
}

const breakWordIntoArray = (word, font, fontSize, maxWidth) => {
    let brokenWordArr = [];
    const charArray = word.split(""); // Ejm: [a,b,c,d,e,f,g]
    while (charArray.length > 0) {
        // Si la cadena de caracteres sobrepasa el máximo, ve probando hasta que entre
        if (font.widthOfTextAtSize(charArray.join(""), fontSize) > maxWidth) {
            // Ve probando de mayor a menor longitud
            for (let i = charArray.length - 1; i >= 0; i--) {
                // Pruebo con esta longitud
                const tempCharArray = charArray.slice(0, i + 1);
                // Si con esta longitud se pasa, continuo probando en la siguiente iteración.
                // Caso contrario, hago splice al original y detengo la prueba actual
                if (font.widthOfTextAtSize(tempCharArray.join(""), fontSize) <= maxWidth) {
                    // Elimino la porción del original
                    const splicedPortion = charArray.splice(0, i + 1);
                    // Agrego lo que eliminé
                    brokenWordArr.push(splicedPortion.join(""));
                    // Detengo la prueba
                    break;
                }
            }
        } else {
            // Si no sobrepasa, que lo agregue
            brokenWordArr.push(charArray.join(""));
            // Limpio el arreglo para que termine el while
            charArray.splice(0, charArray.length);
        }
    }
    return brokenWordArr;
}

const getLinesOfText = (text, font, fontSize, maxWidth) => {
    let linesOfText = [];
    var paragraphs = text.split('\n');
    //console.log('par',paragraphs);
    for (let index = 0; index < paragraphs.length; index++) {
        var paragraph = paragraphs[index];
        // Si la línea de texto sobrepasa el tamaño indicado, secciona por palabras
        if (font.widthOfTextAtSize(paragraph, fontSize) > maxWidth) {
            // Primero, obtengo las palabras con separación
            var rawWords = paragraph.split(' ');

            let words = [];

            rawWords.map(rawWord => {
                // Si la palabra sobrepasa el ancho máximo, la corto en pedacitos
                if (font.widthOfTextAtSize(rawWord, fontSize) > maxWidth) {
                    words = words.concat(breakWordIntoArray(rawWord, font, fontSize, maxWidth))
                } else {
                    words.push(rawWord);
                }
            });

            var newParagraph = [];
            var i = 0;
            newParagraph[i] = [];

            for (let k = 0; k < words.length; k++) {

                var word = words[k];
                newParagraph[i].push(word);

                // Si esta línea reformulada sobrepasa el tamaño, elimina la última palabra y pásala a la siguiente línea
                if (font.widthOfTextAtSize(newParagraph[i].join(' '), fontSize) > maxWidth) {
                    // Elimina la última palabra
                    newParagraph[i].splice(-1);
                    // Muevete a la siguiente línea
                    i = i + 1;
                    // Limpiala
                    newParagraph[i] = [];
                    // Y agrégala ahí
                    newParagraph[i].push(word);
                }
            }
            paragraphs[index] = newParagraph.map(p => p.join(' '))//.join('\n');
            linesOfText = linesOfText.concat(paragraphs[index]);
        } else {
            linesOfText.push(paragraph);
        }
    }
    return linesOfText;//paragraphs.join('\n');
}

const getDateText = (date) => {
    const momentObj = moment(date);
    return toSentence(momentObj.format('D [de] MMMM [del] YYYY'));
}

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

const getRandomWhatsappAssistantName = () => {
    const whatsappAssistants = ['Milagros', 'Brenda', 'Loedrin', 'Isabel', 'Yocasta'];
    const randomIndex = getRandomInt(0, whatsappAssistants.length - 1);
    return whatsappAssistants[randomIndex];
}

// Esta función recibe un número con símbolos y espacios, y lo transforma a puros numeritos que Whatsapp puede entender
const cleanPhoneForWhatsapp = (rawPhone) => {
    return rawPhone.replace(/\s+/g, '').replace(/\+/g, '').replace(/\(/g, '').replace(/\)/g, '').replace(/\-/g, '');
}

module.exports = {
    isNullOrUndefined,
    toSentence,
    eachWordtoSentence,
    generateQRFile,
    getLinesOfText,
    getDateText,
    uploadResultRequest,
    getRandomWhatsappAssistantName,
    cleanPhoneForWhatsapp
}
