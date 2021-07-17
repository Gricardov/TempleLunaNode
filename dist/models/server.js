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
const express_1 = __importDefault(require("express"));
const user_1 = __importDefault(require("../routes/user"));
const cors_1 = __importDefault(require("cors"));
const connections_1 = __importDefault(require("../database/connections"));
class Server {
    constructor() {
        this.apiPaths = {
            user: "/api/user",
        };
        this.app = express_1.default();
        this.port = process.env.PORT || "8000";
        // Conectar a bd
        this.connectDB();
        // Middlewares
        this.middlewares();
        // Rutas
        this.routes();
    }
    connectDB() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield connections_1.default.authenticate();
                console.log("Conectado a bd");
            }
            catch (error) {
                throw new Error(error);
            }
        });
    }
    middlewares() {
        //CORS
        this.app.use(cors_1.default());
        // Lectura y parseo del body
        this.app.use(express_1.default.json());
        // Rutas
        this.app.use(express_1.default.static("public"));
    }
    routes() {
        this.app.use(this.apiPaths.user, user_1.default);
    }
    listen() {
        this.app.listen(this.port, () => {
            console.log("Escuchando en puerto " + this.port);
        });
    }
}
exports.default = Server;
//# sourceMappingURL=server.js.map