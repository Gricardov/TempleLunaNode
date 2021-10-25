const fs = require('fs');
const fontkit = require('@pdf-lib/fontkit');
const { generateQRFile, getLinesOfText, getDateText } = require('./functions');
const { PDFDocument, rgb, StandardFonts } = require('pdf-lib');
require('custom-env').env();

const DEFAULT_BACKGROUND_COLOR = rgb(243 / 255, 241 / 255, 255 / 255);

const latoRegular = fs.readFileSync(__dirname + '/../fonts/Lato-Regular.ttf');
const latoBold = fs.readFileSync(__dirname + '/../fonts/Lato-Bold.ttf');

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

exports.generateTemplate = async (type, artist, order) => {
    try {
        let fileName = 'critique-template.pdf';

        // Por ahora, solo procesamos críticas
        if (type !== 'CRITICA') {
            return;
        }

        const pdfTemplate = await getTemplate(fileName);

        return processCritique(artist, pdfTemplate, order);
    } catch (error) {
        console.log('Error al generar PDF', error);
        throw new Error(error);
    }
}

const processCritique = async (artist, file, { id: orderId, titleWork, intention, hook, ortography, advice }) => {

    // Las coordenadas inician desde la esquina inferior izquierda

    // Documento principal
    const pdf = await PDFDocument.load(file);
    pdf.registerFontkit(fontkit);

    // Parámetros de página
    let lastCoordinates = 0;
    let lineHeight = 10;
    let marginH = 70;
    let marginV = 70;

    // Datos del artista
    const { id: artistId, fName, lName, imgUrl, contactEmail, networks = [] } = artist;

    // Fuentes

    const latoRegularEmbedded = await pdf.embedFont(latoRegular, { subset: true });
    const latoBoldEmbedded = await pdf.embedFont(latoBold, { subset: true });

    const pages = pdf.getPages();

    const { width, height } = pages[0].getSize();


    // Página 1

    // Versión
    lastCoordinates = setText(pages[0], latoRegularEmbedded, `v${process.env.ORDER_VERSION} ${process.env.ORDER_VERSION_NAME}`, 15, rgb(0, 0, 0), width, marginH, 'CENTER', 45);

    // Nombre artista
    lastCoordinates = setParagraph(pdf, pages[0], {
        text: `Crítica de\n${fName} ${lName}`,
        font: latoRegularEmbedded,
        size: 18,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'CENTER',
        lineHeight: 2,
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y + lastCoordinates.height + 180 }
    });

    // Dibujo el separador horizontal en SVG
    const lineWidth = 48;
    const lineBorderWidth = 3;
    const newY = lastCoordinates.y + lineBorderWidth + 130;
    const svgPath = `M 0,0 L ${lineWidth},0`;
    pages[0].moveTo((width - lineWidth) / 2, newY);
    pages[0].drawSvgPath(svgPath, { borderColor: rgb(0, 0, 0), borderWidth: lineBorderWidth });

    lastCoordinates.y = newY;
    lastCoordinates.height = lineBorderWidth;

    // Determino el tamaño del título en base al número de caracteres
    let titleWorkParagraphSize = 45;
    let topOffset = 220;
    if (titleWork.length > 50) {
        titleWorkParagraphSize = 30;
        topOffset = 270;
    } else if (titleWork.length > 30) {
        titleWorkParagraphSize = 40;
        topOffset = 260;
    } else if (titleWork.length > 24) {
        titleWorkParagraphSize = 45;
        topOffset = 250;
    }

    // Título de la obra
    lastCoordinates = setParagraph(pdf, pages[0], {
        text: titleWork.toUpperCase(),
        font: latoBoldEmbedded,
        size: titleWorkParagraphSize,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'CENTER',
        lineHeight: 1,
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y + lastCoordinates.height + topOffset }
    });


    // Página 2

    const page2 = pdf.addPage();

    marginH = 75;
    marginV = 100;

    // Acerca de
    lastCoordinates = setText(page2, latoBoldEmbedded, 'Acerca de', 40, rgb(0, 0, 0), width, marginH, 'LEFT', height - marginV);

    // Título de la obra
    lastCoordinates = setText(page2, latoBoldEmbedded, 'Título de la obra', 17, rgb(0, 0, 0), width, marginH, 'LEFT', lastCoordinates.y - 75);

    // Nombre obra
    lastCoordinates = setParagraph(pdf, page2, {
        text: titleWork,
        font: latoRegularEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'LEFT',
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
    });

    // Realizado por
    lastCoordinates = setText(page2, latoBoldEmbedded, 'Realizado por', 17, rgb(0, 0, 0), width, marginH, 'LEFT', lastCoordinates.y - 60);

    // Nombre artista
    lastCoordinates = setParagraph(pdf, page2, {
        text: `${fName} ${lName}`,
        font: latoRegularEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'LEFT',
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
    });

    // Título redes artista
    lastCoordinates = setText(page2, latoBoldEmbedded, 'Síguelo(a) en sus redes', 17, rgb(0, 0, 0), width, marginH, 'LEFT', lastCoordinates.y - 60);

    // Perfil de Temple Luna
    lastCoordinates = setParagraph(pdf, page2, {
        text: `${process.env.PRODUCTION_URL_FRONT}perfil/${artistId}`,
        font: latoRegularEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'LEFT',
        color: rgb(5 / 255, 99 / 255, 193 / 255),
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
    });

    // Contactos del artista (2 máximo)
    networks.slice(0, 2).map(text => {

        lastCoordinates = setParagraph(pdf, page2, {
            text: text,
            font: latoRegularEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            marginH,
            marginV,
            mode: 'LEFT',
            color: rgb(5 / 255, 99 / 255, 193 / 255),
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
        });

    });

    // Página oficial
    lastCoordinates = setText(page2, latoBoldEmbedded, 'Pide tu crítica aquí', 17, rgb(0, 0, 0), width, marginH, 'LEFT', lastCoordinates.y - 60);

    // Enlace página
    lastCoordinates = setParagraph(pdf, page2, {
        text: 'https://templeluna.app',
        font: latoRegularEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'LEFT',
        color: rgb(5 / 255, 99 / 255, 193 / 255),
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
    });

    // Título fecha
    lastCoordinates = setText(page2, latoBoldEmbedded, 'Fecha de realización', 17, rgb(0, 0, 0), width, marginH, 'LEFT', lastCoordinates.y - 60);

    // Fecha
    lastCoordinates = setText(page2, latoRegularEmbedded, getDateText(new Date()), 17, rgb(0, 0, 0), width, marginH, 'LEFT', lastCoordinates.y - 40);

    // Código QR
    const qrFile = await generateQRFile(`${process.env.PRODUCTION_URL_FRONT}pedido/${orderId}`, 70);
    const pdfImg = await pdf.embedPng(qrFile);
    lastCoordinates = setImage(page2, pdfImg, 70, 70, width - pdfImg.width - 50, 50);


    // Página 3

    // Agrego una nueva página
    const page3 = pdf.addPage();

    // Título
    lastCoordinates = setText(page3, latoBoldEmbedded, 'Crítica', 40, rgb(0, 0, 0), width, marginH, 'LEFT', height - marginV);

    if (intention) {
        // Intención
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: '¿Se entiende lo que quiero transmitir?',
            font: latoBoldEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            color: rgb(0, 0, 0),
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 75 }
        });

        // Texto transmisión
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: intention,
            font: latoRegularEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
        });
    }

    if (hook) {
        // Enganche
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: '¿Qué tanto engancha mi obra?',
            font: latoBoldEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            color: rgb(0, 0, 0),
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 75 }
        });

        // Texto enganche
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: hook,
            font: latoRegularEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
        });
    }

    if (ortography) {
        // Ortografía
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: '¿Qué tal fue mi ortografía?',
            font: latoBoldEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            color: rgb(0, 0, 0),
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 75 }
        });

        // Texto ortografía
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: ortography,
            font: latoRegularEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
        });
    }

    if (advice) {
        // Consejo
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: '¿Qué consejo me darías para mejorar?',
            font: latoBoldEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            color: rgb(0, 0, 0),
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 75 }
        });

        // Texto consejo
        lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
            text: advice,
            font: latoRegularEmbedded,
            size: 17,
            totalWidth: width,
            totalHeight: height,
            marginH,
            marginV,
            mode: 'LEFT',
            lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
        });
    }

    // Título extra 1
    lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
        text: 'Siempre recuerda que',
        font: latoBoldEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        color: rgb(0, 0, 0),
        marginH,
        marginV,
        mode: 'RIGHT',
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 75 }
    });

    // Extra 1
    lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
        text: 'Todos tenemos puntos fuertes y débiles. No te desanimes por los débiles, utiliza esa energía en mejorarlos. La vida está llena de críticas, saca lo mejor de ellas. Tú decides si esta iniciativa crece.',
        font: latoRegularEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'RIGHT',
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
    });

    // Título extra 2
    lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
        text: '¿Te gusta este servicio?',
        font: latoBoldEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        color: rgb(0, 0, 0),
        marginH,
        marginV,
        mode: 'RIGHT',
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 75 }
    });

    // Extra 2
    lastCoordinates = setParagraph(pdf, lastCoordinates.page, {
        text: 'Invita a tus amigos a pedir críticas. Déjanos comentarios, reacciones y compártenos con los botones de abajo.',
        font: latoRegularEmbedded,
        size: 17,
        totalWidth: width,
        totalHeight: height,
        marginH,
        marginV,
        mode: 'RIGHT',
        lastCoordinates: { ...lastCoordinates, y: lastCoordinates.y - 40 }
    });

    const pdfUnit8Array = await pdf.save();
    const fileBuffer = Buffer.from(pdfUnit8Array);

    return fileBuffer;

}

const setParagraph = (doc, page, { text, font, size, color = rgb(0, 0, 0), totalWidth, totalHeight, marginH, marginV, mode, lastCoordinates, lineHeight = 10 }) => {
    let fontHeight = font.heightAtSize(size);

    const setLinesOfText = (currentPage, arrayOfLines, lastCoordinates) => {
        let newPage = currentPage;
        let newCoordinates = lastCoordinates;
        // Itero cada línea de texto
        for (let index = 0; index < arrayOfLines.length; index++) {
            const text = arrayOfLines[index];
            // Verifico si esta línea sigue entrando en la página
            if (newCoordinates.y - fontHeight > marginV) {
                newCoordinates = setText(currentPage, font, text, size, color, totalWidth, marginH, mode, index ? newCoordinates.y - newCoordinates.height - lineHeight : newCoordinates.y);
            } else {
                // Si no entra, agrego una nueva página para meterla ahí
                newPage = doc.addPage();

                // Y llamo a esta misma función, recursivamente
                const newData = setLinesOfText(newPage, arrayOfLines.slice(index), { y: page.getHeight() - marginV, height: 0 });
                newPage = newData.newPage;
                newCoordinates = newData.newCoordinates;
                break;
            }
        }
        return { newPage, newCoordinates };
    }

    const arrayOfLines = getLinesOfText(text, font, size, totalWidth - (2 * marginH));
    const { newPage, newCoordinates } = setLinesOfText(page, arrayOfLines, { y: lastCoordinates.y, height: font.heightAtSize(size) });

    return { ...newCoordinates, height: fontHeight, page: newPage };
}

const setText = (page, font, text, size, color, totalWidth, marginH, mode, y) => {
    let x;
    switch (mode) {
        case 'CENTER':
            x = ((totalWidth - font.widthOfTextAtSize(text, size)) / 2);
            break;

        case 'RIGHT':
            x = totalWidth - font.widthOfTextAtSize(text, size) - marginH;
            break;

        default:
            x = marginH;
            break;
    }
    page.drawText(text, {
        x,
        y,
        size,
        font,
        color,
    });
    return { y, height: font.heightAtSize(size), page }; // Devuelve la coordenada donde se quedó
}

const setImage = (page, pdfImg, width, height, x, y) => {
    page.drawImage(pdfImg, {
        x,
        y,
        width,
        height,
    });
    return { y, height, page };
}