"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteEvent = exports.putEvent = exports.postEvent = exports.getEvent = exports.getEvents = void 0;
const event_1 = __importDefault(require("../models/event"));
const getEvents = (req = Request, res = Response) => __awaiter(void 0, void 0, void 0, function* () {
    const { limit = "5", order = "startDate", desc = "1" } = req.query;
    try {
        const limitAux = parseInt(limit);
        const descAux = parseInt(desc);
        const events = yield event_1.default.findAll({
            //order: [[order, descAux ? "DESC" : "ASC"]],
            limit: limitAux,
        });
        res.json({ events });
    }
    catch (error) {
        console.log(error);
        res.status(500).json({
            msg: "Parámetros inválidos",
        });
    }
});
exports.getEvents = getEvents;
const getEvent = (req = Request, res = Response) => __awaiter(void 0, void 0, void 0, function* () {
    const { alias } = req.params;
    const event = yield event_1.default.findOne({
        where: {
            alias,
        },
    });
    if (event) {
        res.json(event);
    }
    else {
        res.status(404).json({
            msg: "No existe evento con ese alias",
        });
    }
});
exports.getEvent = getEvent;
const postEvent = (req = Request, res = Response) => __awaiter(void 0, void 0, void 0, function* () {
    const { body } = req;
    try {
        const existsAlias = yield event_1.default.findOne({
            where: {
                alias: body.alias,
            },
        });
        if (existsAlias) {
            return res.status(400).json({
                msg: "Ya existe un evento con ese alias",
            });
        }
        const event = event_1.default.build(body);
        yield event.save();
        res.json(event);
    }
    catch (error) {
        console.log(error);
        res.status(404).json({
            msg: "Hable con el administrador",
        });
    }
});
exports.postEvent = postEvent;
const putEvent = (req = Request, res = Response) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    const { body } = req;
    try {
        const event = yield event_1.default.findByPk(id);
        if (!event) {
            return res.status(404).json({
                msg: "No existe un evento con ese id",
            });
        }
        yield event.update(body);
        res.json(event);
    }
    catch (error) {
        console.log(error);
        res.status(404).json({
            msg: "Hable con el administrador",
        });
    }
});
exports.putEvent = putEvent;
const deleteEvent = (req = Request, res = Response) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    const event = yield event_1.default.findByPk(id);
    if (!event) {
        return res.status(404).json({
            msg: "No existe un evento con ese id",
        });
    }
    // Eliminación física
    //await user.destroy();
    // Eliminación lógica
    yield event.update({ status: false });
    res.json(event);
});
exports.deleteEvent = deleteEvent;
//# sourceMappingURL=event.js.map