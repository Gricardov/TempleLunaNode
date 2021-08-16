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

module.exports = {
    isNullOrUndefined,
    toSentence,
    eachWordtoSentence
}
