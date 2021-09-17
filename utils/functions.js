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

const getLinesOfText = (text, font, fontSize, maxWidth) => {
    let linesOfText = [];
    var paragraphs = text.split('\n');
    for (let index = 0; index < paragraphs.length; index++) {
        var paragraph = paragraphs[index];
        if (font.widthOfTextAtSize(paragraph, fontSize) > maxWidth) {
            var words = paragraph.split(' ');
            var newParagraph = [];
            var i = 0;
            newParagraph[i] = [];
            for (let k = 0; k < words.length; k++) {
                var word = words[k];
                newParagraph[i].push(word);
                if (font.widthOfTextAtSize(newParagraph[i].join(' '), fontSize) > maxWidth) {
                    newParagraph[i].splice(-1);
                    i = i + 1;
                    newParagraph[i] = [];
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

module.exports = {
    isNullOrUndefined,
    toSentence,
    eachWordtoSentence,
    generateQRFile,
    getLinesOfText,
    getDateText,
    uploadResultRequest
}
