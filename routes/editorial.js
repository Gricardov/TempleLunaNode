const { Router } = require("express");
const { getMembersByEditorialService, getServicesByEditorialId, getServicesByEditorialMember } = require("../controller/editorial");
const {
  getMembersByEditorialService: getMembersByEditorialServiceVal,
  getServicesByEditorial: getServicesByEditorialVal,
  getServicesByEditorialMember: getServicesByEditorialMemberVal,
  postToken: postTokenVal,
  validateField,
  validateToken
} = require('../validators');

const router = Router();

router.get("/:editorialId/services/:serviceId/members", [ // Por ejemplo, para saber quienes dan el servicio de escucha
  validateField('params', getMembersByEditorialServiceVal)
], getMembersByEditorialService);

router.get("/:editorialId/members/me/services", [ // Va "me" porque ese campo se extrae del JWT
  //validateField('headers', postTokenVal), // Comprueba si el token existe y tiene el formato correcto
  validateToken(), // Verifica si el token es válido
  validateField('params', getServicesByEditorialMemberVal)
], getServicesByEditorialMember);

router.get("/:editorialId/services", [
  validateField('params', getServicesByEditorialVal)
], getServicesByEditorialId);

module.exports = router;