-- SET SQL_SAFE_UPDATES=0;

-- DROP DATABASE TL_TEST;
CREATE DATABASE IF NOT EXISTS TL_TEST;

USE TL_TEST;

-- Tablas

-- Apps de contacto (Ejemplo: Whatsapp, Telegram o línea directa)
CREATE TABLE IF NOT EXISTS CONTACT_APPS (
  id VARCHAR(50) NOT NULL PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

-- Eventos
CREATE TABLE IF NOT EXISTS EVENTS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(500) NOT NULL,
  urlBg VARCHAR(500) NOT NULL DEFAULT 'https://images.pexels.com/photos/4240602/pexels-photo-4240602.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
  urlPresentation VARCHAR(500) NOT NULL DEFAULT '',
  requisites JSON NOT NULL DEFAULT '[]',
  objectives JSON NOT NULL DEFAULT '[]',
  benefits JSON NOT NULL DEFAULT '[]',
  topics JSON NOT NULL DEFAULT '[]',
  price DOUBLE NOT NULL DEFAULT 0,
  currency VARCHAR(50) NULL DEFAULT 'USD',
  platform VARCHAR(100) NOT NULL DEFAULT 'Google Meets',
  paymentLink VARCHAR(500) NULL DEFAULT '',
  paymentMethod VARCHAR(500) NULL DEFAULT '',
  paymentFacilities VARCHAR(500) NULL DEFAULT '',
  title VARCHAR(500) NOT NULL,
  about VARCHAR(1000) NOT NULL,
  `condition` VARCHAR(500) NULL DEFAULT '',
  timezoneText VARCHAR(200) NULL DEFAULT '',
  recordings JSON NULL DEFAULT '[]',
  extraData JSON NULL DEFAULT '[]',
  alias VARCHAR(200) NOT NULL,
  whatsappGroup VARCHAR(500) NULL DEFAULT '',
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE EVENTS
ADD CONSTRAINT EVENTS_UNIQUE_ALIAS UNIQUE (alias);

-- Fechas de los eventos (Un evento puede tener varias fechas en las que se lleva a cabo. Se crea una tabla aparte para facilitar los queries)
CREATE TABLE IF NOT EXISTS EVENT_DATES (
	id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    eventId INT(10) ZEROFILL UNSIGNED NOT NULL ,
    `from` DATETIME NOT NULL,
	`until` DATETIME NOT NULL,
	weekly BOOLEAN NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT 1,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE EVENT_DATES
ADD FOREIGN KEY (eventId) REFERENCES EVENTS(id);

-- Roles de los usuarios (Ejemplo: admin, moderador, colaborador)
CREATE TABLE USER_ROLES (
	id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Usuarios. Más adelante debemos guardar una tabla con sus preferencias (Más lector, escritor, etc)
CREATE TABLE USERS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(200) NOT NULL,
  emailVerified BOOLEAN NOT NULL DEFAULT 0,
  contactEmail VARCHAR(200) NULL,
  fName VARCHAR(200) NOT NULL,
  lName VARCHAR(200) NOT NULL,
  birthday DATETIME NOT NULL,  
  phone VARCHAR(50) NULL,
  appId VARCHAR(50) NOT NULL,
  pseudonym VARCHAR(200) NULL,
  followName VARCHAR(200) NOT NULL,
  numFollowers INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  urlProfileImg VARCHAR(500) NULL DEFAULT NULL,  
  occupation VARCHAR(200) NULL DEFAULT NULL,
  about VARCHAR(1000) NULL DEFAULT NULL,
  networks JSON NOT NULL DEFAULT '[]',
  roleId VARCHAR(50) NOT NULL DEFAULT 'BASIC',
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE USERS
ADD CONSTRAINT USERS_UNIQUE_FOLLOWNAME UNIQUE (followName),
ADD CONSTRAINT USERS_UNIQUE_EMAIL UNIQUE (email),
ADD FOREIGN KEY (appId) REFERENCES CONTACT_APPS(id),
ADD FOREIGN KEY (roleId) REFERENCES USER_ROLES(id),
ADD UNIQUE INDEX USERS_FOLLOWNAME_INDEX (followName);

/*-- Roles por usuario (Un usuario puede ser admin, moderador, colaborador)
CREATE TABLE ROLES_BY_USER (
	userId INT(10) ZEROFILL UNSIGNED NOT NULL,
    roleId VARCHAR(50) NOT NULL,
	createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE ROLES_BY_USER
ADD PRIMARY KEY (userId, roleId),
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (roleId) REFERENCES USER_ROLES(id);*/

-- Inscripciones a los eventos
CREATE TABLE INSCRIPTIONS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  eventId INT(10) ZEROFILL UNSIGNED NOT NULL ,
  userId INT(10) ZEROFILL UNSIGNED NULL,
  names VARCHAR(200) NULL,
  age TINYINT NULL,
  phone VARCHAR(50) NULL,
  appId VARCHAR(50) NULL,
  email VARCHAR(200) NULL,
  notify BOOLEAN NULL DEFAULT NULL, -- Esto solo sirve para activar el trigger y guardar el valor con el que se inscribió. El valor actualizado siempre está en la tabla SUBSCRIBERS (novelties)
  paymentData JSON NULL DEFAULT '[]',
  extraData JSON NULL DEFAULT '{}',
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE INSCRIPTIONS
ADD CONSTRAINT INSCRIPTIONS_UNIQUE_USER_ID_BY_EVENT_ID UNIQUE (eventId, userId),
ADD CONSTRAINT INSCRIPTIONS_UNIQUE_EMAIL_BY_EVENT_ID UNIQUE (eventId, email),
ADD FOREIGN KEY (appId) REFERENCES CONTACT_APPS(id),
ADD FOREIGN KEY (eventId) REFERENCES EVENTS(id),
ADD FOREIGN KEY (userId) REFERENCES USERS(id);

-- Instructores por eventos (Ejemplo: Profesor X dirige Z evento)
CREATE TABLE INSTRUCTORS_BY_EVENT (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  eventId INT(10) ZEROFILL UNSIGNED NOT NULL ,
  userId INT(10) ZEROFILL UNSIGNED NULL,
  fName VARCHAR(200) NULL,
  lName VARCHAR(200) NULL,
  birthday DATETIME NULL, 
  phone VARCHAR(50) NULL,
  appId VARCHAR(50) NULL,
  email VARCHAR(200) NULL,
  urlProfileImg VARCHAR(500) NULL DEFAULT NULL,
  occupation VARCHAR(200) NULL,
  about VARCHAR(1000) NULL,
  networks JSON NULL DEFAULT '[]',
  extraData JSON NULL DEFAULT '{}',
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE INSTRUCTORS_BY_EVENT
ADD FOREIGN KEY (eventId) REFERENCES EVENTS(id),
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (appId) REFERENCES CONTACT_APPS(id);

-- Servicios (Ejemplo: Diseño, críticas, booktrailers)
CREATE TABLE SERVICES (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL  
);

-- Sub servicios (Por ejemplo, el servicio de diseños tiene portadas, banners)
CREATE TABLE SUBSERVICES (
  id VARCHAR(50) NOT NULL,
  serviceId VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL  
);

ALTER TABLE SUBSERVICES
ADD PRIMARY KEY (id, serviceId),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id);

-- Servicios por usuario (Ejemplo: Críticas, diseños, booktrailers + sus respectivas condiciones)
CREATE TABLE SERVICES_BY_USER (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  userId INT(10) ZEROFILL UNSIGNED NOT NULL,
  serviceId VARCHAR(50) NOT NULL,
  subServiceId VARCHAR(50) NULL,
  urlBg VARCHAR(500) NULL DEFAULT 'https://images.pexels.com/photos/4240602/pexels-photo-4240602.jpeg?',
  title VARCHAR(500) NULL,
  about VARCHAR(500) NULL,
  benefits JSON NULL DEFAULT '[]',  
  requisites JSON NULL DEFAULT '[]',
  aboutMePolicy VARCHAR(500) NULL DEFAULT '',
  pricePolicy VARCHAR(500) NULL DEFAULT '',
  contributePolicy VARCHAR(500) NULL DEFAULT '',
  timePolicy VARCHAR(500) NULL DEFAULT '',
  minPrice DOUBLE NOT NULL DEFAULT 0,
  maxPrice DOUBLE NOT NULL DEFAULT 0,
  currency VARCHAR(50) NULL DEFAULT 'USD',
  extraData JSON NULL DEFAULT '[]',
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE SERVICES_BY_USER
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
ADD FOREIGN KEY (subServiceId) REFERENCES SUBSERVICES(id);

-- Editoriales
CREATE TABLE EDITORIALS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  about VARCHAR(1000) NOT NULL,
  followName VARCHAR(200) NOT NULL,  
  phone VARCHAR(50) NOT NULL,
  appId VARCHAR(50) NOT NULL,
  email VARCHAR(200) NOT NULL,
  numFollowers INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  urlProfileImg VARCHAR(500) NULL DEFAULT NULL,
  bgColor VARCHAR(10) NULL DEFAULT NULL,
  networks JSON NOT NULL DEFAULT '[]',
  acceptsMembers BOOLEAN NOT NULL DEFAULT 1,
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE EDITORIALS
ADD CONSTRAINT EDITORIALS_UNIQUE_FOLLOWNAME UNIQUE (followName),
ADD CONSTRAINT EDITORIALS_UNIQUE_EMAIL UNIQUE (email),
ADD FOREIGN KEY (appId) REFERENCES CONTACT_APPS(id),
ADD UNIQUE INDEX EDITORIALS_FOLLOWNAME_INDEX (followName);

-- Servicios por editorial (Ejemplo: Críticas, diseños, booktrailers + sus respectivas condiciones)
CREATE TABLE SERVICES_BY_EDITORIAL (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  editorialId INT(10) ZEROFILL UNSIGNED NOT NULL,
  serviceId VARCHAR(50) NOT NULL,
  subServiceId VARCHAR(50) NULL,
  urlBg VARCHAR(500) NULL DEFAULT 'https://images.pexels.com/photos/4240602/pexels-photo-4240602.jpeg?',
  title VARCHAR(500) NOT NULL,
  about VARCHAR(500) NOT NULL,
  benefits JSON NOT NULL DEFAULT '[]',  
  requisites JSON NOT NULL DEFAULT '[]',
  teamPolicy VARCHAR(500) NOT NULL DEFAULT '',
  pricePolicy VARCHAR(500) NOT NULL DEFAULT '',
  contributePolicy VARCHAR(500) NOT NULL DEFAULT '',
  volunteerPolicy VARCHAR(500) NOT NULL DEFAULT '',
  timePolicy VARCHAR(500) NOT NULL DEFAULT '',
  minPrice DOUBLE NOT NULL DEFAULT 0,
  maxPrice DOUBLE NOT NULL DEFAULT 0,
  currency VARCHAR(50) NULL DEFAULT 'USD',
  extraData JSON NULL DEFAULT '[]',
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE SERVICES_BY_EDITORIAL
ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
ADD FOREIGN KEY (subServiceId) REFERENCES SUBSERVICES(id);

-- Miembros de una editorial (Quién pertenece a qué editorial)
CREATE TABLE EDITORIAL_MEMBERS (
  userId INT(10) ZEROFILL UNSIGNED NOT NULL,
  editorialId INT(10) ZEROFILL UNSIGNED NOT NULL,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE EDITORIAL_MEMBERS
ADD PRIMARY KEY (userId, editorialId),
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id);

-- Roles de los miembros de una editorial (Ejemplo: Fundador, diseñador, crítico)
CREATE TABLE EDITORIAL_MEMBER_ROLES (
	id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Roles por miembros de una editorial (Un miembro de editorial puede ser fundador, diseñador, crítico, escuchador, etc)
CREATE TABLE ROLES_BY_EDITORIAL_MEMBERS (
	userId INT(10) ZEROFILL UNSIGNED NOT NULL,
	editorialId INT(10) ZEROFILL UNSIGNED NOT NULL,
    roleId VARCHAR(50) NOT NULL
);

ALTER TABLE ROLES_BY_EDITORIAL_MEMBERS
ADD PRIMARY KEY (userId, editorialId, roleId),
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id),
ADD FOREIGN KEY (roleId) REFERENCES EDITORIAL_MEMBER_ROLES(id);

-- Permisos que tiene cada rol dentro de una editorial. (Ejemplo: El diseñador de una editorial solo puede atender los servicios de diseño; el crítico, solo puede atender los servicios de críticas)
CREATE TABLE EDITORIAL_MEMBER_ROLES_SERVICES (
	roleId VARCHAR(50) PRIMARY KEY,
	serviceId VARCHAR(50) NOT NULL,
    subServiceId VARCHAR(50) NULL
);

ALTER TABLE EDITORIAL_MEMBER_ROLES_SERVICES
ADD FOREIGN KEY (roleId) REFERENCES EDITORIAL_MEMBER_ROLES(id),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
ADD FOREIGN KEY (subServiceId) REFERENCES SUBSERVICES(id);

-- Estados de un pedido (Ejemplo: DISPONIBLE, TOMADO, ANULADO, HECHO)
CREATE TABLE ORDER_STATUS (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL  
);

-- Pedidos de un servicio, hacia una persona o editorial. (Ejemplo, una persona pide una crítica a una editorial). Uno debe registrarse si quiere hacer pedidos directos.
CREATE TABLE ORDERS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  clientUserId INT(10) ZEROFILL UNSIGNED NULL, -- En caso sea un usuario registrado, los otros campos clientXXX ya no son necesarios
  clientEmail VARCHAR(200) NULL,
  clientNames VARCHAR(200) NULL,  
  clientAge TINYINT NULL,
  clientPhone VARCHAR(50) NULL,
  clientAppId VARCHAR(50) NULL,  
  workerUserId INT(10) ZEROFILL UNSIGNED NULL,  -- Adquiere valor cuando se hace una petición directa al usuario o cuando lo toma desde su editorial. En este último caso, el campo editorialId también adquiere el id de la editorial.
  editorialId INT(10) ZEROFILL UNSIGNED NULL,-- Solo adquiere un valor cuando se hace la petición a una editorial
  serviceId VARCHAR(50) NOT NULL,
  subServiceId VARCHAR(50) NULL,
  statusId VARCHAR(50) NOT NULL,
  price DOUBLE NULL DEFAULT 0,
  currency VARCHAR(50) NULL DEFAULT 'USD',
  titleWork VARCHAR(200) NULL,
  linkWork VARCHAR(500) NULL,
  pseudonym VARCHAR(200) NULL,
  synopsis VARCHAR(500) NULL,
  details VARCHAR(500) NULL,
  intention VARCHAR(500) NULL,
  mainPhrase VARCHAR(200) NULL,  
  critiqueTopics JSON NULL DEFAULT '[]',
  observations VARCHAR(500) NULL,
  notify BOOLEAN NULL DEFAULT NULL,
  imgUrlData JSON NULL DEFAULT '[]',
  priority VARCHAR(50) NULL,
  extraData JSON NULL DEFAULT '[]',
  publicResult BOOLEAN NOT NULL DEFAULT 1, -- Esto define si el link a la obra puede quedar público en el portafolio del autor
  resultUrl VARCHAR(500) NULL DEFAULT NULL,
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numComments INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numViews INT NOT NULL DEFAULT 0, -- BY TRIGGER
  public BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE ORDERS
  ADD UNIQUE INDEX ORDERS_CREATED_AT_INDEX(createdAt),
  ADD FOREIGN KEY (clientUserId) REFERENCES USERS(id),
  ADD FOREIGN KEY (clientAppId) REFERENCES CONTACT_APPS(id),
  ADD FOREIGN KEY (workerUserId) REFERENCES USERS(id),
  ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id),
  ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
  ADD FOREIGN KEY (subServiceId) REFERENCES SUBSERVICES(id),
  ADD FOREIGN KEY (statusId) REFERENCES ORDER_STATUS(id);

-- Revista
CREATE TABLE MAGAZINES (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  urlPortrait VARCHAR(500) NOT NULL,
  url VARCHAR(500) NOT NULL,
  numPag INT NOT NULL,
  edition INT NOT NULL,
  year INT NOT NULL,
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numComments INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numViews INT NOT NULL DEFAULT 0, -- BY TRIGGER
  alias VARCHAR(200) NOT NULL
);

ALTER TABLE MAGAZINES
ADD CONSTRAINT MAGAZINES_UNIQUE_ALIAS UNIQUE (alias);

-- Estados de un comentario (Ejemplo: En revisión, aprobado, rechazado)
CREATE TABLE COMMENT_STATUS (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL  
);

-- Comentarios de un pedido o una revista
CREATE TABLE COMMENTS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  userId INT(10) ZEROFILL UNSIGNED NULL,
  orderId INT(10) ZEROFILL UNSIGNED NULL,
  magazineId INT(10) ZEROFILL UNSIGNED NULL,
  content VARCHAR(1000) NOT NULL,
  observations VARCHAR(500) NULL,
  statusId VARCHAR(50) NOT NULL,  
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE COMMENTS
  ADD FOREIGN KEY (userId) REFERENCES USERS(id),
  ADD FOREIGN KEY (orderId) REFERENCES ORDERS(id),
  ADD FOREIGN KEY (magazineId) REFERENCES MAGAZINES(id),
  ADD FOREIGN KEY (statusId) REFERENCES COMMENT_STATUS(id);

-- Suscriptores
CREATE TABLE SUBSCRIBERS (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  userId INT(10) ZEROFILL UNSIGNED NULL,
  courses BOOLEAN NULL,
  magazine BOOLEAN NULL,
  novelties BOOLEAN NULL,
  names VARCHAR(200) NULL,
  email VARCHAR(200) NULL,
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE SUBSCRIBERS
  ADD CONSTRAINT SUBSCRIBERS_UNIQUE_EMAIL UNIQUE (email),
  ADD CONSTRAINT SUBSCRIBERS_UNIQUE_USER_ID UNIQUE (userId),
  ADD FOREIGN KEY (userId) REFERENCES USERS(id);

-- Acciones como ver, dar corazón, etc
CREATE TABLE ACTIONS_ON_ITEM (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL  
);

-- Accion de cada usuario en una revista o pedido, etc (Ejemplo: X usuario dio un corazón en Z revista)
CREATE TABLE ACTIONS_BY_USER_ON_ITEM (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  userId INT(10) ZEROFILL UNSIGNED NULL,
  email VARCHAR(200) NULL,
  socialNetwork VARCHAR(50) NULL,
  orderId INT(10) ZEROFILL UNSIGNED NULL,
  magazineId INT(10) ZEROFILL UNSIGNED NULL,
  actionId VARCHAR(50) NOT NULL,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE ACTIONS_BY_USER_ON_ITEM
  ADD FOREIGN KEY (userId) REFERENCES USERS(id),
  ADD FOREIGN KEY (orderId) REFERENCES ORDERS(id),
  ADD FOREIGN KEY (magazineId) REFERENCES MAGAZINES(id),
  ADD FOREIGN KEY (actionId) REFERENCES ACTIONS_ON_ITEM(id);

-- Los tigres
DELIMITER //
CREATE TRIGGER UTR_CHECK_NOTIFY_SUBSCRIBER_FOR_INSCRIPTION
AFTER INSERT
   ON INSCRIPTIONS FOR EACH ROW
BEGIN
	IF NEW.notify IS NOT NULL THEN    
		IF EXISTS (SELECT id FROM SUBSCRIBERS WHERE userId = NEW.userId OR email = NEW.email) THEN
			UPDATE SUBSCRIBERS SET novelties = NEW.notify WHERE userId = NEW.userId OR email = NEW.email;		
		ELSE
			INSERT INTO SUBSCRIBERS VALUES (DEFAULT, NEW.userId, NULL, NULL, NEW.notify, NEW.names, NEW.email, 1, DEFAULT, DEFAULT);
		END IF;
	END IF;
END; //
DELIMITER ;

-- Inserciones

-- Inserciones maestras

INSERT INTO CONTACT_APPS VALUES
('WSP','Whatsapp'),
('TLG','Telegram'),
('SIG','Signal'),
('OAPP','Otra app');

INSERT INTO USER_ROLES VALUES
('FOUNDER','Fundador'), -- Solo para el creador
('ADMIN','Administrador'), -- Para los que tienen privilegios de hacer cambios en la plataforma
('MOD','Moderador'), -- Para los que aprueban contenidos
('COLAB','Colaborador'), -- Para los que dan servicios
('CREATOR','Creador de contenidos'), -- Para los que crean sus contenidos como blogs
('BASIC','Básico'); -- Todos

INSERT INTO SERVICES VALUES
('CRITICA','Crítica'),
('DISENO','Diseño'),
('CORRECCION','Corrección'),
('ESCUCHA','Escucha'),
('BTRAILER','Booktrailer');

INSERT INTO SUBSERVICES VALUES
('POR', 'DISENO','Portada'),
('BAN','DISENO','Banner para redes');

INSERT INTO EDITORIAL_MEMBER_ROLES VALUES
('ADMIN','Administrador'),
('CRITICO','Crítico'),
('DISEÑADOR','Diseñador'),
('CORRECTOR','Corrector'),
('ESCUCHADOR','Escuchador'),
('PRODUCTOR-BTRAILER','Productor de booktrailer');

INSERT INTO ORDER_STATUS VALUES
('DISPONIBLE','Disponible'),
('TOMADO','Tomado'),
('ANULADO','Anulado'),
('HECHO','Hecho');

INSERT INTO COMMENT_STATUS VALUES
('REVISION','En revisión'),
('APROBADO','Aprobado'),
('RECHAZADO','Rechazado');

INSERT INTO ACTIONS_ON_ITEM VALUES
('VER','Visualizar'),
('GUSTAR','Dar like'),
('COMPARTIR','Compartir'),
('DESCARGAR','Descargar');

-- Inserciones no maestras

-- Eventos
INSERT INTO EVENTS VALUES
(DEFAULT,
'Aprende a construir tu libro desde cero',
'https://images.pexels.com/photos/6383219/pexels-photo-6383219.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
'https://www.youtube.com/watch?v=cD2bQH8-pos&t=424s&ab_channel=Ra%C3%BAlValverde',
'["Requisito 1", "Requisito 2", "Requisito 3"]',
'["Objetivo 1", "Objetivo 2"]',
'["Beneficio 1","Beneficio 2"]',
'["Tema 1", "Tema 2", "Tema 3"]',
0,
NULL,
'Zoom',
NULL,
NULL,
NULL,
'Este es el encabezado del evento',
'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry"s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book',
'10 inscritos como mínimo',
NULL,
'[{"name":"Introducción al curso","url":"https://www.youtube.com/watch?v=c70NJVO9jtE&ab_channel=M%C3%9ASICAVARIADALBA","resources":[]},{"name":"Creando la historia","url":"https://www.youtube.com/watch?v=6nemwgJZCc8&ab_channel=Pat%C3%A9deFu%C3%A1","resources":[]}]',
'[{"name":"Obras llevadas al teatro","link":{"name":"Leer aquí","href":"https://www.google.com"}}]',
'APRENDE-A-CREAR-TU-LIBRO-DESDE-CERO-AMASCARITA-1-2021',
'https://chat.whatsapp.com/FW4fmEli2WsATci5RYU2nI',
DEFAULT,
DEFAULT,
DEFAULT);

INSERT INTO EVENTS VALUES
(DEFAULT,
'Aprende a crear tu historial desde cero',
'https://images.pexels.com/photos/6383219/pexels-photo-6383219.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
DEFAULT,
'["Requisito 1", "Requisito 2", "Requisito 3", "Requisito 4"]',
'["Objetivo 1", "Objetivo 2", "Objetivo 3"]',
'["Beneficio 1"]',
'["Tema 1", "Tema 2" ,"Tema 3"]',
20,
'USD',
'Zoom',
'https://paypal.me/gricardov',
'Bitcoin',
'Estas son las facilidades de pago',
'Este es el encabezado del evento',
'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry"s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book',
'10 inscritos como mínimo',
NULL,
'[{"name":"Introducción al taller","url":"https://www.youtube.com/watch?v=c70NJVO9jtE&ab_channel=M%C3%9ASICAVARIADALBA","resources":[]},{"name":"Creando la pupusa","url":"https://www.youtube.com/watch?v=6nemwgJZCc8&ab_channel=Pat%C3%A9deFu%C3%A1","resources":[]}]',
'[{"name":"Obras llevadas al teatro","link":{"name":"Leer aquí","href":"https://www.google.com"}}]',
'APRENDE-A-CREAR-TU-EDITORIAL-AMASCARITA-1-2021',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT);

-- Fechas de los eventos
INSERT INTO EVENT_DATES VALUES
(DEFAULT, 0000000001, DATE_ADD(NOW(), INTERVAL 10 DAY), DATE_ADD(NOW(), INTERVAL 11 DAY), 1, DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 0000000001, DATE_ADD(NOW(), INTERVAL 13 DAY), DATE_ADD(NOW(), INTERVAL 14 DAY), 0, DEFAULT, DEFAULT, DEFAULT),
(DEFAULT, 0000000002, DATE_ADD(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 2 HOUR), 1, DEFAULT, DEFAULT, DEFAULT);

-- Usuarios
INSERT INTO USERS VALUES
(DEFAULT,
'corazon@gmail.com',
1,
'contacto@gmail.com',
'Alyoh',
'Mascarita',
'1995-04-20',
'+51999999999',
'WSP',
'Alyoh Mascarita',
'alyohmascarita',
DEFAULT,
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Flindo.jpg?alt=media&token=177bb113-efb9-4e15-9291-743a525a2420',
DEFAULT,
DEFAULT,
'["https://www.facebook.com/", "https://www.instagram.com/"]',
'BASIC',
DEFAULT,
DEFAULT,
DEFAULT);

INSERT INTO USERS VALUES
(DEFAULT,
'pilyy@gmail.com',
1,
'contactopilyy@gmail.com',
'Pilyy',
'Hernandez',
'1992-04-01',
'+529999999',
'TLG',
'Pilyy Hernandez',
'pilyyhernandez',
DEFAULT,
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fsayrih.jpg?alt=media&token=6a770c21-f3c9-475b-ae03-8423f1876c45',
DEFAULT,
DEFAULT,
'["https://www.facebook.com/", "https://www.instagram.com/"]',
'BASIC',
DEFAULT,
DEFAULT,
DEFAULT);

/*-- Roles por usuario
INSERT INTO ROLES_BY_USER VALUES
(1,'BASIC',DEFAULT,DEFAULT),
(1,'ADMIN',DEFAULT,DEFAULT),
(2,'BASIC',DEFAULT,DEFAULT),
(2,'COLAB',DEFAULT,DEFAULT),
(2,'MOD',DEFAULT,DEFAULT);*/

-- Inscripciones
INSERT INTO INSCRIPTIONS VALUES
(DEFAULT, 0000000001, 0000000001, NULL, NULL, NULL, 'WSP', NULL, DEFAULT, NULL, NULL, 1, DEFAULT, DEFAULT),
(DEFAULT, 0000000001, NULL, 'Tipito Enojado', 26, '+519999999', 'TLG', 'tipitoenojada@gmail.com', 1, NULL, NULL, 1, DEFAULT, DEFAULT);

-- Instructores por evento
INSERT INTO INSTRUCTORS_BY_EVENT VALUES
(DEFAULT, 2, 1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Soy escritor y poeta amateur',NULL,NULL,NULL,DEFAULT,DEFAULT),
(DEFAULT,1,NULL,'Cosme','Fulanito',NOW(),'+519999999','TLG','cosme@gmail.com', 'https://i.ytimg.com/vi/xnoummdS3DA/maxresdefault.jpg','Escritor y poeta','Lo siento nene vas a morir. Me quitaste lo que más quería y volverá conmigo, volverá algún día.','["https://www.facebook.com"]',NULL,DEFAULT,DEFAULT);

-- Servicios por usuario
INSERT INTO SERVICES_BY_USER VALUES
(DEFAULT,
0000000002,
'CRITICA',
NULL,
DEFAULT,
'Servicio de críticas',
'Este es mi servicio',
'["Beneficio 1"]',
'["Requisito 1", "Requisito 2"]',
'Política de sobre mí',
'Política de precios',
'Política de contribución',
'Política de tiempo',
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
);

INSERT INTO SERVICES_BY_USER VALUES
(DEFAULT,
0000000002,
'DISENO',
NULL,
DEFAULT,
'Servicio de diseños',
'Este es mi diseño',
'["Beneficio 1"]',
'["Requisito 1", "Requisito 2"]',
'Política sobre mí',
'Política de precios',
'Política de contribución',
'Política de tiempo',
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
);

INSERT INTO SERVICES_BY_USER VALUES
(DEFAULT,
0000000002,
'DISENO',
'BAN',
DEFAULT,
'Servicio de diseños',
'Este es mi diseño',
'["Beneficio 1"]',
'["Requisito 1", "Requisito 2"]',
'Política sobre mí',
'Política de precios',
'Política de contribución',
'Política de tiempo',
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
);
select*from editorials;
-- Editoriales
INSERT INTO EDITORIALS VALUES
(1,
'Editorial Temple Luna',
'Somos Temple Luna, la editorial de los artistas',
'templeluna',
'+5212721588788',
'WSP',
'contacto@templeluna.app',
DEFAULT,
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/editorial%2FGrupo%20195.svg?alt=media&token=782e36a5-a88b-4a52-aa9e-5d13e22ed396',
'#1A1A1A',
'["https://www.facebook.com/templeluna", "https://www.instagram.com/templelunaeditorial"]',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT
);

-- Procedimientos

-- Obtiene los eventos más cercanos a iniciar
DROP PROCEDURE IF EXISTS USP_GET_LATEST_EVENTS;
DELIMITER //
CREATE PROCEDURE USP_GET_LATEST_EVENTS (P_LIMIT INT, P_LAST_DATE DATETIME)
BEGIN
DECLARE V_LAST_DATE DATETIME;
IF (P_LAST_DATE IS NULL) THEN
BEGIN
	SET V_LAST_DATE = DATE_ADD((SELECT MAX(ED.from) FROM EVENT_DATES ED), INTERVAL 1 HOUR);
END;
ELSE
BEGIN
	SET V_LAST_DATE = P_LAST_DATE;    
END;
END IF;

SELECT E.id, E.name, E.urlBg, E.price, E.currency, E.platform, E.title, E.about, E.timezoneText, E.alias, ED.from, ED.until, ED.weekly
FROM EVENTS E
JOIN EVENT_DATES ED
ON E.id = ED.eventId
WHERE ED.from < V_LAST_DATE AND ED.active = 1 AND E.active = 1
GROUP BY E.id
ORDER BY ED.from DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Obtiene los eventos
DROP PROCEDURE IF EXISTS USP_GET_EVENT_BY_ALIAS;
DELIMITER //
CREATE PROCEDURE USP_GET_EVENT_BY_ALIAS (P_ALIAS VARCHAR(200))
BEGIN
SELECT E.id, E.name, E.urlBg, E.urlPresentation, E.requisites, E.objectives, E.benefits, E.topics, E.price, E.currency, E.platform, E.paymentLink, E.paymentMethod, E.paymentFacilities, E.recordings, E.title, E.about, E.condition, E.timezoneText, E.whatsappGroup, E.alias, E.extraData
FROM EVENTS E
WHERE E.alias = P_ALIAS AND E.active = 1
LIMIT 1;
END; //
DELIMITER ;

-- Obtiene las fechas de los eventos
DROP PROCEDURE IF EXISTS USP_GET_DATES_BY_EVENT;
DELIMITER //
CREATE PROCEDURE USP_GET_DATES_BY_EVENT (P_ALIAS VARCHAR(200))
BEGIN
SELECT ED.from, ED.until, ED.weekly
FROM EVENT_DATES ED
JOIN EVENTS E
ON E.id = ED.eventId
WHERE E.alias=P_ALIAS AND E.active = 1 AND ED.active = 1;
END; //
DELIMITER ;

-- Obtiene los instructores de los eventos
DROP PROCEDURE IF EXISTS USP_GET_INSTRUCTORS_BY_EVENT;
DELIMITER //
CREATE PROCEDURE USP_GET_INSTRUCTORS_BY_EVENT (P_ALIAS VARCHAR(200))
BEGIN
SELECT -- Si userId es nulo, significa que los datos están en la tabla actual. Caso contrario, debo consultarlo desde la tabla USERS
IBE.userId,
CASE WHEN IBE.userId IS NULL THEN IBE.fName ELSE (SELECT fName FROM USERS WHERE id = IBE.userId LIMIT 1) END as fName,
CASE WHEN IBE.userId IS NULL THEN IBE.lName ELSE (SELECT lName FROM USERS WHERE id = IBE.userId LIMIT 1) END as lName,
CASE WHEN IBE.userId IS NULL THEN IBE.urlProfileImg ELSE (SELECT urlProfileImg FROM USERS WHERE id = IBE.userId LIMIT 1) END as urlProfileImg,
CASE WHEN IBE.userId IS NULL THEN IBE.occupation ELSE (SELECT occupation FROM USERS WHERE id = IBE.userId LIMIT 1) END as occupation,
CASE WHEN IBE.userId IS NULL THEN IBE.about ELSE (SELECT about FROM USERS WHERE id = IBE.userId LIMIT 1) END as about,
CASE WHEN IBE.userId IS NULL THEN IBE.networks ELSE (SELECT networks FROM USERS WHERE id = IBE.userId LIMIT 1) END as networks
FROM INSTRUCTORS_BY_EVENT IBE
JOIN EVENTS E
ON E.id = IBE.eventId
WHERE E.alias = P_ALIAS;
END; //
DELIMITER ;

-- Registra inscripción a un evento
DROP PROCEDURE IF EXISTS USP_INSERT_INSCRIPTION;
DELIMITER //
CREATE PROCEDURE USP_INSERT_INSCRIPTION (P_EVENT_ID INT(10), P_USER_ID INT(10), P_NAMES VARCHAR(200), P_AGE TINYINT, P_PHONE VARCHAR(50), P_APP VARCHAR(50), P_EMAIL VARCHAR(200), P_NOTIFY BOOLEAN, P_PAYMENT_DATA JSON, P_EXTRA_DATA JSON)
BEGIN
INSERT INTO INSCRIPTIONS VALUES (DEFAULT, P_EVENT_ID, P_USER_ID, P_NAMES, P_AGE, P_PHONE, P_APP, P_EMAIL, P_NOTIFY, P_PAYMENT_DATA, P_EXTRA_DATA, DEFAULT, DEFAULT, DEFAULT);
END; //
DELIMITER ;

-- Verifica si un correo ya se registró en un evento. Si se registró con userId, verifica el email en la tabla Users también
DROP PROCEDURE IF EXISTS USP_EXISTS_INSCRIPTION;
DELIMITER //
CREATE PROCEDURE USP_EXISTS_IN_INSCRIPTION (P_EVENT_ID INT(10), P_USER_ID INT(10), P_EMAIL VARCHAR(200)) -- Si paso P_USER_ID, se supone que no debo pasar el email, porque la info ya es suficiente. Viceversa con P_EMAIL
BEGIN
SELECT EXISTS (
SELECT id FROM INSCRIPTIONS WHERE eventId=P_EVENT_ID AND (email=P_EMAIL OR userId=P_USER_ID)
UNION
SELECT I.id FROM INSCRIPTIONS I
JOIN
USERS U
ON U.id = I.userId
WHERE I.eventId=P_EVENT_ID AND (U.email=P_EMAIL OR U.id=P_USER_ID)
) AS 'exists';
END; //
DELIMITER ;

-- Realiza la suscripción a un servicio
DROP PROCEDURE IF EXISTS USP_SUBSCRIBE;
DELIMITER //
CREATE PROCEDURE USP_SUBSCRIBE (P_USER_ID INT(10), P_SUB_COURSES BOOLEAN, P_SUB_MAGAZINE BOOLEAN, P_SUB_NOVELTIES BOOLEAN, P_NAMES VARCHAR(200), P_EMAIL VARCHAR(200))
BEGIN
IF EXISTS (SELECT id FROM SUBSCRIBERS WHERE userId = P_USER_ID OR email = P_EMAIL) THEN -- Si ..._COURSES, ..._MAGAZINE o ..._NOVELTIES es NULL, significa que esos valores no se deben actualizar
	IF P_SUB_COURSES IS NOT NULL THEN
		UPDATE SUBSCRIBERS SET courses = P_SUB_COURSES WHERE userId = P_USER_ID OR email = P_EMAIL;
    END IF;
    
    IF P_SUB_MAGAZINE IS NOT NULL THEN
		UPDATE SUBSCRIBERS SET magazine = P_SUB_MAGAZINE WHERE userId = P_USER_ID OR email = P_EMAIL;
    END IF;
			
	IF P_SUB_NOVELTIES IS NOT NULL THEN
		UPDATE SUBSCRIBERS SET novelties = P_SUB_NOVELTIES WHERE userId = P_USER_ID OR email = P_EMAIL;
    END IF;
ELSE
	INSERT INTO SUBSCRIBERS VALUES (DEFAULT, P_USER_ID, P_SUB_COURSES, P_SUB_MAGAZINE, P_SUB_NOVELTIES, P_NAMES, P_EMAIL, 1, DEFAULT, DEFAULT);
END IF;
END; //
DELIMITER ;

-- Para guardar las estadísticas
DROP PROCEDURE IF EXISTS USP_ADD_STATISTICS;
DELIMITER //
CREATE PROCEDURE USP_ADD_STATISTICS (P_USER_ID INT(10), P_EMAIL VARCHAR(200), P_SOCIAL_NETWORK_NAME VARCHAR(50), P_ORDER_ID INT(10), P_MAGAZINE_ID INT(10), P_ACTION_ID VARCHAR(50))
BEGIN
	INSERT INTO ACTIONS_BY_USER_ON_ITEM VALUES (DEFAULT, P_USER_ID, P_EMAIL, P_SOCIAL_NETWORK_NAME, P_ORDER_ID, P_MAGAZINE_ID, P_ACTION_ID, DEFAULT, DEFAULT);
END; //
DELIMITER ;

-- Para insertar un pedido. La creación no requiere todos los campos de la tabla
DROP PROCEDURE IF EXISTS USP_CREATE_ORDER;
DELIMITER //
CREATE PROCEDURE USP_CREATE_ORDER (P_CLIENT_USER_ID INT(10), P_CLIENT_EMAIL VARCHAR(200), P_CLIENT_NAMES VARCHAR(200), P_CLIENT_AGE TINYINT, P_CLIENT_PHONE VARCHAR(50), P_CLIENT_APP VARCHAR(50), P_WORKER_ID INT(10), P_SERVICE_ID VARCHAR(50), P_SUBSERVICE_ID VARCHAR(50), P_TITLE_WORK VARCHAR(200), P_LINK_WORK VARCHAR(500), P_PSEUDONYM VARCHAR(200), P_SYNOPSIS VARCHAR(500), P_DETAILS VARCHAR(500), P_INTENTION VARCHAR(500), P_MAIN_PHRASE VARCHAR(200), P_URL_IMG_REF VARCHAR(500), P_CRITIQUE_TOPICS JSON, P_NOTIFY BOOLEAN,  IMG_URL_DATA JSON, P_PRIORITY VARCHAR(50), P_EXTRA_DATA JSON, P_PUBLIC_RESULT BOOLEAN, P_PUBLIC BOOLEAN)
BEGIN
	INSERT INTO ORDERS VALUES (DEFAULT, P_CLIENT_USER_ID, P_CLIENT_EMAIL, P_CLIENT_NAMES, P_CLIENT_AGE, P_CLIENT_PHONE, P_CLIENT_APP, P_WORKER_ID, NULL, P_SERVICE_ID, P_SUBSERVICE_ID, 'DISPONIBLE', NULL, NULL, P_TITLE_WORK, P_LINK_WORK, P_PSEUDONYM, P_SYNOPSIS, P_DETAILS, P_INTENTION, P_MAIN_PHRASE, P_CRITIQUE_TOPICS, NULL, P_NOTIFY, IMG_URL_DATA, P_PRIORITY, P_EXTRA_DATA, P_PUBLIC_RESULT, NULL, DEFAULT, DEFAULT, DEFAULT, P_PUBLIC, DEFAULT, DEFAULT);    
END; //
DELIMITER ;
select*from orders;
-- Ejemplos
-- call usp_add_statistics (NULL, 'gricardov@gmail.com','FACEBOOK',NULL,NULL,'VER');
-- call USP_EXISTS_IN_INSCRIPTION(1, null, 'corazon@gmail.com');
 -- CALL USP_SUBSCRIBE(NULL, 'Mila','gricardov@gmail.com',NULL, TRUE, NULL);
SELECT*FROM ACTIONS_BY_USER_ON_ITEM;
select*from editorials;
select*from services;
select*from subservices;
SELECT*FROM ORDERS;
select*from actions_by_user_on_item;
SELECT*FROM SUBSCRIBERS;
select*from event_dates;
SELECT*FROM USERS;
SELECT*FROM INSCRIPTIONS;

SELECT*FROM EVENTS;
-- INSERT INTO events VALUES (DEFAULT,'Evento 1',DEFAULT,'https://www.youtube.com/watch?v=cD2bQH8-pos&t=424s&ab_channel=Ra%C3%BAlValverde',DEFAULT,'["Objetivo1", "Objetivo2"]','["Beneficio1", "Beneficio2"]','["Tema1","Tema2"]',0,NULL,DEFAULT,DEFAULT,DEFAULT,DEFAULT,'Título del evento','Cuéntame que es de tu vida y trataré de quererte todavía',DEFAULT,DEFAULT,'[{"name":"Obras llevadas al teatro","link":{"name":"Leer aquí","href":"https://www.google.com"}}]','GRAN-TEXTO-GUION-TEXTO-Y-NOVELA-CCADENA-1',DEFAULT,DEFAULT,DEFAULT);

-- INSERT INTO EVENT_DATES VALUES (DEFAULT, 0000000001,NOW(),NOW(),DEFAULT,DEFAULT, DEFAULT, DEFAULT);