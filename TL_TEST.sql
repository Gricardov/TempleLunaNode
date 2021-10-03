-- SET SQL_SAFE_UPDATES=0;

-- DROP DATABASE TL_TEST;

SET GLOBAL time_zone = '+00:00';
SET time_zone='+00:00';

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
  birthday DATETIME NULL,  
  phone VARCHAR(50) NULL,
  appId VARCHAR(50) NULL,
  pseudonym VARCHAR(200) NULL,
  followName VARCHAR(200) NOT NULL,
  numFollowers INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numComments INT NOT NULL DEFAULT 0, -- BY TRIGGER
  urlProfileImg VARCHAR(500) NULL DEFAULT NULL,  
  occupation VARCHAR(500) NULL DEFAULT NULL,
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
  occupation VARCHAR(500) NULL,
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
  subserviceId VARCHAR(50) NULL,
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
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE SERVICES_BY_USER
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
ADD FOREIGN KEY (subserviceId) REFERENCES SUBSERVICES(id);

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
  subserviceId VARCHAR(50) NULL,
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
ADD CONSTRAINT SERVICES_BY_EDITORIAL_UNIQUE_SERVICE_SUBSERVICE UNIQUE (serviceId, subserviceId),
ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
ADD FOREIGN KEY (subserviceId) REFERENCES SUBSERVICES(id);

-- Roles de los miembros de una editorial (Ejemplo: Admin, colaborador)
CREATE TABLE EDITORIAL_MEMBER_ROLES (
	id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Miembros de una editorial (Quién pertenece a qué editorial)
CREATE TABLE EDITORIAL_MEMBERS (
  userId INT(10) ZEROFILL UNSIGNED NOT NULL,
  editorialId INT(10) ZEROFILL UNSIGNED NOT NULL,
  roleId VARCHAR(50) NOT NULL,
  availability VARCHAR(200) NULL,
  extraData JSON NULL,
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE EDITORIAL_MEMBERS
ADD PRIMARY KEY (userId, editorialId),
ADD FOREIGN KEY (userId) REFERENCES USERS(id),
ADD FOREIGN KEY (roleId) REFERENCES EDITORIAL_MEMBER_ROLES(id),
ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id);

-- Los servicios que cada miembro (X miembro puede hacer Diseño; otro, Críticas)
CREATE TABLE EDITORIAL_MEMBER_SERVICES (
    userId INT(10) ZEROFILL UNSIGNED NOT NULL,
    editorialId INT(10) ZEROFILL UNSIGNED NOT NULL,
	serviceId VARCHAR(50) NOT NULL,
    subserviceId VARCHAR(50) NULL,
    description VARCHAR(50) NOT NULL, -- Ejm: Diseñador(a), Crítico(a), etc
    active BOOLEAN NOT NULL DEFAULT 1
);

ALTER TABLE EDITORIAL_MEMBER_SERVICES
ADD FOREIGN KEY (userId, editorialId) REFERENCES EDITORIAL_MEMBERS(userId, editorialId),
ADD FOREIGN KEY (serviceId) REFERENCES SERVICES(id),
ADD FOREIGN KEY (subserviceId) REFERENCES SUBSERVICES(id);

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
  workerUserId INT(10) ZEROFILL UNSIGNED NULL, -- Adquiere valor cuando se hace una petición directa al usuario o cuando lo toma desde su editorial. En este último caso, el campo editorialId también adquiere el id de la editorial
  takenAt DATETIME NULL,
  expiresAt DATETIME NULL,
  prevWorkerUserId INT(10) ZEROFILL UNSIGNED NULL, -- El id de la persona que tomó el pedido inmediatamente anterior
  editorialId INT(10) ZEROFILL UNSIGNED NULL, -- Solo adquiere un valor cuando se hace la petición a una editorial
  serviceId VARCHAR(50) NOT NULL,
  subserviceId VARCHAR(50) NULL,
  statusId VARCHAR(50) NOT NULL DEFAULT 'DISPONIBLE',
  price DOUBLE NULL DEFAULT 0,
  currency VARCHAR(50) NULL DEFAULT 'USD',
  titleWork VARCHAR(200) NULL,
  linkWork VARCHAR(2000) NULL,
  pseudonym VARCHAR(200) NULL,
  synopsis VARCHAR(500) NULL,
  details VARCHAR(500) NULL,
  intention VARCHAR(500) NULL,
  mainPhrase VARCHAR(200) NULL,  
  observations VARCHAR(500) NULL,
  notify BOOLEAN NULL DEFAULT NULL,
  imgUrlData JSON NULL DEFAULT '[]',
  priority VARCHAR(50) NULL,
  extraData JSON NULL DEFAULT '[]',
  publicLink BOOLEAN NULL DEFAULT 1, -- Esto define si el link a la obra puede quedar público en el portafolio del autor
  resultUrl VARCHAR(2000) NULL DEFAULT NULL,
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numComments INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numViews INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numDownloads INT NOT NULL DEFAULT 0, -- BY TRIGGER
  public BOOLEAN NOT NULL DEFAULT 1,
  version VARCHAR(100) NOT NULL DEFAULT '2.2',
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
  ADD FOREIGN KEY (subserviceId) REFERENCES SUBSERVICES(id),
  ADD FOREIGN KEY (statusId) REFERENCES ORDER_STATUS(id);

-- Revista
CREATE TABLE MAGAZINES (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  urlPortrait VARCHAR(500) NOT NULL,
  displayUrl VARCHAR(500) NOT NULL, -- Este link contiene el documento optimizado para renderizar en el navegador sin descargarlo
  url VARCHAR(500) NOT NULL, -- Este link contiene el documento original para ser descargado
  numPag INT NOT NULL,
  edition INT NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL,
  editorialId INT(10) ZEROFILL UNSIGNED NULL, -- Solo adquiere un valor cuando se hace la petición a una editorial
  numHearts INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numComments INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numViews INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numDownloads INT NOT NULL DEFAULT 0, -- BY TRIGGER
  numSubscribers INT NOT NULL DEFAULT 0, -- BY TRIGGER
  alias VARCHAR(200) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  
);

ALTER TABLE MAGAZINES
ADD CONSTRAINT MAGAZINES_UNIQUE_ALIAS UNIQUE (alias),
ADD FOREIGN KEY (editorialId) REFERENCES EDITORIALS(id);

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

-- Acción de cada usuario en una revista o pedido, etc (Ejemplo: X usuario dio un corazón en Z revista)
CREATE TABLE ACTIONS_BY_USER_ON_ITEM (
  id INT(10) ZEROFILL UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  userId INT(10) ZEROFILL UNSIGNED NULL,
  email VARCHAR(200) NULL,
  socialNetwork VARCHAR(50) NULL,
  orderId INT(10) ZEROFILL UNSIGNED NULL,
  magazineId INT(10) ZEROFILL UNSIGNED NULL,
  actionId VARCHAR(50) NOT NULL,
  active BOOLEAN NOT NULL DEFAULT 1,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE ACTIONS_BY_USER_ON_ITEM
  ADD FOREIGN KEY (userId) REFERENCES USERS(id),
  ADD FOREIGN KEY (orderId) REFERENCES ORDERS(id),
  ADD FOREIGN KEY (magazineId) REFERENCES MAGAZINES(id),
  ADD FOREIGN KEY (actionId) REFERENCES ACTIONS_ON_ITEM(id);

-- Los tigres

-- Esto se activa en cada inserción a la tabla INSCRIPTIONS y revisa si el usuario quiere ser notificado para la revista (Registra en la tabla SUBSCRIBERS)
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

-- Esto se activa en cada inserción a la tabla ORDERS y revisa si el usuario quiere ser notificado para la revista (Registra en la tabla SUBSCRIBERS)
DELIMITER //
CREATE TRIGGER UTR_CHECK_NOTIFY_SUBSCRIBER_FOR_ORDER
AFTER INSERT
   ON ORDERS FOR EACH ROW
BEGIN
	IF NEW.notify IS NOT NULL THEN    
		IF EXISTS (SELECT id FROM SUBSCRIBERS WHERE userId = NEW.clientUserId OR email = NEW.clientEmail) THEN
			UPDATE SUBSCRIBERS SET novelties = NEW.notify WHERE userId = NEW.clientUserId OR email = NEW.clientEmail;		
		ELSE
			INSERT INTO SUBSCRIBERS VALUES (DEFAULT, NEW.clientUserId, NULL, NULL, NEW.notify, NEW.clientNames, NEW.clientEmail, 1, DEFAULT, DEFAULT);
		END IF;
	END IF;
END; //
DELIMITER ;

-- Esto se activa en cada inserción a la tabla COMMENTS y actualiza el número de comentarios en USERS, ORDER o MAGAZINE. No registra en la tabla ACTIONS_BY_USER_ON_ITEM porque sería tener mucha redundancia
DELIMITER //
CREATE TRIGGER UTR_UPDATE_COMMENTS_STATISTICS
AFTER INSERT
   ON COMMENTS FOR EACH ROW
BEGIN
	IF NEW.orderId IS NOT NULL THEN
		UPDATE ORDERS SET numComments = numComments + 1 WHERE id = NEW.orderId; -- Actualizo las estadísticas de comentarios del pedido
        UPDATE USERS SET numComments = numComments + 1 WHERE id = (SELECT workerUserId FROM ORDERS WHERE id = NEW.orderId); -- Actualizo las estadísticas de comentarios del perfil
	ELSEIF NEW.magazineId IS NOT NULL THEN
		UPDATE MAGAZINES SET numComments = numComments + 1 WHERE id = NEW.magazineId; -- Actualizo las estadísticas de la revista
	END IF;
END; //
DELIMITER ;

-- Esto se activa en cada inserción a la tabla ACTIONS_BY_USER_ON_ITEM y actualiza el número de corazones en USERS, ORDER o MAGAZINE. TODO quitar el tipo de SUSCRIPCION para que ya no redunde
DELIMITER //
CREATE TRIGGER UTR_UPDATE_ACTIONS_BY_USER_ON_ITEM_ON_INSERT
AFTER INSERT
   ON ACTIONS_BY_USER_ON_ITEM FOR EACH ROW
BEGIN
	IF NEW.orderId IS NOT NULL THEN
		-- Es una inserción y se supone que el primer pedido siempre es activo
        IF NEW.active = 1 THEN
			-- Verifico qué acción se ha realizado (Dar like, suscribirse, etc)
			CASE NEW.actionId
				WHEN 'GUSTAR' THEN
				BEGIN
					UPDATE ORDERS SET numHearts = numHearts + 1 WHERE id = NEW.orderId; -- Actualizo las estadísticas de los corazones del pedido
					UPDATE USERS SET numHearts = numHearts + 1 WHERE id = (SELECT workerUserId FROM ORDERS WHERE id = NEW.orderId); -- Actualizo las estadísticas de los corazones del usuario
				END;
                WHEN 'VER' THEN
                BEGIN
					UPDATE ORDERS SET numViews = numViews + 1 WHERE id = NEW.orderId; -- Actualizo las estadísticas de los corazones del pedido
				END;
                WHEN 'DESCARGAR' THEN
                BEGIN
					UPDATE ORDERS SET numDownloads = numDownloads + 1 WHERE id = NEW.orderId; -- Actualizo las estadísticas de los corazones del pedido
				END;
			END CASE;            
        END IF;
	ELSEIF NEW.magazineId IS NOT NULL THEN
		-- Es una inserción y se supone que el primer pedido siempre es activo
        IF NEW.active = 1 THEN
			-- Verifico qué acción se ha realizado (Dar like, suscribirse, etc)
			CASE NEW.actionId
				WHEN 'GUSTAR' THEN
				BEGIN
					UPDATE MAGAZINES SET numHearts = numHearts + 1 WHERE id = NEW.magazineId; -- Actualizo las estadísticas de los corazones de la revista
				END;
                WHEN 'VER' THEN
                BEGIN
					UPDATE MAGAZINES SET numViews = numViews + 1 WHERE id = NEW.magazineId; -- Actualizo las estadísticas de las vistas de la revista
				END;
                WHEN 'DESCARGAR' THEN
                BEGIN
					UPDATE MAGAZINES SET numDownloads = numDownloads + 1 WHERE id = NEW.magazineId; -- Actualizo las estadísticas de las descargas de la revista
				END;
                WHEN 'SUSCRIBIR' THEN
                BEGIN
					UPDATE MAGAZINES SET numSubscribers = numSubscribers + 1 WHERE id = NEW.magazineId; -- Actualizo las estadísticas de los suscriptores de la revista
				END;
			END CASE;     
        END IF;
	END IF;
END; //
DELIMITER ;

-- Esto se activa en cada actualización a la tabla ACTIONS_BY_USER_ON_ITEM y actualiza el número de corazones en USERS, ORDER o MAGAZINE. TODO quitar el tipo de SUSCRIPCION para que ya no redunde
DELIMITER //
CREATE TRIGGER UTR_UPDATE_ACTIONS_BY_USER_ON_ITEM_ON_UPDATE
AFTER UPDATE
   ON ACTIONS_BY_USER_ON_ITEM FOR EACH ROW
BEGIN
	-- Verfico si el campo active ha cambiado. Solo ahí se deben actualizar las estadísticas
	IF NEW.active != OLD.active THEN
		-- El pedido ha cambiado
		IF OLD.orderId IS NOT NULL THEN
        BEGIN
			-- Declaro si el valor va a aumentar o va a disminuir
			DECLARE SUM_VALUE_ORDER INT;
			
			IF NEW.active = 1 THEN
				SET SUM_VALUE_ORDER = 1;
			ELSE
				SET SUM_VALUE_ORDER = -1;
			END IF;
			
			-- Verifico qué acción se ha realizado (Dar like, suscribirse, etc)
			CASE NEW.actionId
				WHEN 'GUSTAR' THEN
					BEGIN
						UPDATE ORDERS SET numHearts = numHearts + SUM_VALUE_ORDER WHERE id = NEW.orderId; -- Actualizo las estadísticas de los corazones del pedido
						UPDATE USERS SET numHearts = numHearts + SUM_VALUE_ORDER WHERE id = (SELECT workerUserId FROM ORDERS WHERE id = NEW.orderId); -- Actualizo las estadísticas de los corazones del usuario
					END;
				WHEN 'VER' THEN
					BEGIN
						UPDATE ORDERS SET numViews = numViews + SUM_VALUE_ORDER WHERE id = NEW.orderId; -- Actualizo las estadísticas de los corazones del pedido
					END;
				WHEN 'DESCARGAR' THEN
					BEGIN
						UPDATE ORDERS SET numDownloads = numDownloads + SUM_VALUE_ORDER WHERE id = NEW.orderId; -- Actualizo las estadísticas de los corazones del pedido
					END;
			END CASE;			
        END;
                
        
                
        -- La revista ha cambiado
		ELSEIF OLD.magazineId IS NOT NULL THEN
        BEGIN
			-- Declaro si el valor va a aumentar o va a disminuir
			DECLARE SUM_VALUE_MAGAZINE INT;
			
			IF NEW.active = 1 THEN
				SET SUM_VALUE_MAGAZINE = 1;
			ELSE
				SET SUM_VALUE_MAGAZINE = -1;
			END IF;
            
            -- Verifico qué acción se ha realizado (Dar like, suscribirse, etc)
			CASE NEW.actionId
				WHEN 'GUSTAR' THEN
					BEGIN
						UPDATE MAGAZINES SET numHearts = numHearts + SUM_VALUE_MAGAZINE WHERE id = NEW.magazineId; -- Actualizo las estadísticas de los corazones de la revista
					END;
				WHEN 'VER' THEN
					BEGIN
						UPDATE MAGAZINES SET numViews = numViews + SUM_VALUE_MAGAZINE WHERE id = NEW.magazineId; -- Actualizo las estadísticas de las vistas de la revista
					END;
				WHEN 'DESCARGAR' THEN
					BEGIN
						UPDATE MAGAZINES SET numDownloads = numDownloads + SUM_VALUE_MAGAZINE WHERE id = NEW.magazineId; -- Actualizo las estadísticas de las descargas de la revista
					END;
				WHEN 'SUSCRIBIR' THEN
					BEGIN
						UPDATE MAGAZINES SET numSubscribers = numSubscribers + SUM_VALUE_MAGAZINE WHERE id = NEW.magazineId; -- Actualizo las estadísticas de los suscriptores de la revista
					END;
			END CASE;
        END;
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
('COLAB','Colaborador(a) de editorial');
/*('CRITICO','Crítico'),
('DISEÑADOR','Diseñador'),
('CORRECTOR','Corrector'),
('ESCUCHADOR','Escuchador'),
('PRODUCTOR-BTRAILER','Productor de booktrailer');*/

INSERT INTO ORDER_STATUS VALUES
('DISPONIBLE','Disponible'),
('TOMADO','Tomado'),
('ANULADO','Anulado'),
('HECHO','Hecho'),
('SOLICITADO','Solicitado'); -- Esto se refiere a un pedido (tabla ORDERS) donde se puede elegir quien quieres que lo atienda (workerUserId adquiere un valor)

INSERT INTO COMMENT_STATUS VALUES
('REVISION','En revisión'),
('APROBADO','Aprobado'),
('RECHAZADO','Rechazado');

INSERT INTO ACTIONS_ON_ITEM VALUES
('VER','Visualizar'),
('GUSTAR','Dar like'),
('COMPARTIR','Compartir'),
('DESCARGAR','Descargar'),
('SUSCRIBIR','Suscribir');

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
DEFAULT
),

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
'gricardov@gmail.com',
1,
'gricardov@templeluna.app',
'Giovanni',
'Ricardo',
'1995-04-20',
'+51999999999',
'WSP',
'Corazón de melón',
'corazondemelon',
DEFAULT,
DEFAULT,
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Flindo.jpg?alt=media&token=177bb113-efb9-4e15-9291-743a525a2420',
DEFAULT,
DEFAULT,
'["https://www.facebook.com/", "https://www.instagram.com/", "https://www.wattpad.com/story/262132830?utm_medium=link&utm_source=android&utm_content=story_info"]',
'ADMIN',
DEFAULT,
DEFAULT,
DEFAULT
),

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
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Flindo.jpg?alt=media&token=177bb113-efb9-4e15-9291-743a525a2420',
DEFAULT,
DEFAULT,
'["https://www.facebook.com/", "https://www.instagram.com/"]',
'BASIC',
DEFAULT,
DEFAULT,
DEFAULT
),

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
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fsayrih.jpg?alt=media&token=6a770c21-f3c9-475b-ae03-8423f1876c45',
DEFAULT,
DEFAULT,
'["https://www.facebook.com/", "https://www.instagram.com/"]',
'BASIC',
DEFAULT,
DEFAULT,
DEFAULT
),

(DEFAULT,
'maricucha@gmail.com',
1,
'contactomaricucha@gmail.com',
'Mari',
'Cucha',
'1995-03-03',
'+569999999',
'WSP',
'La maricucha',
'marucha',
DEFAULT,
DEFAULT,
DEFAULT,
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fsayrih.jpg?alt=media&token=6a770c21-f3c9-475b-ae03-8423f1876c45',
DEFAULT,
DEFAULT,
'["https://www.facebook.com/", "https://www.instagram.com/"]',
'BASIC',
DEFAULT,
DEFAULT,
DEFAULT
);

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

-- Servicios por editorial
INSERT INTO SERVICES_BY_EDITORIAL VALUES
(DEFAULT,
1,
'CRITICA',
NULL,
DEFAULT,
'Servicio de críticas',
'Descripción del servicio',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
),

(DEFAULT,
1,
'DISENO',
NULL,
DEFAULT,
'Servicio de diseño',
'Descripción del servicio',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
),

(DEFAULT,
1,
'DISENO',
'BAN',
DEFAULT,
'Servicio de diseño',
'Descripción del servicio',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
),

(DEFAULT,
1,
'DISENO',
'POR',
DEFAULT,
'Servicio de diseño',
'Descripción del servicio',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
),

(DEFAULT,
1,
'ESCUCHA',
NULL,
DEFAULT,
'Servicio de escucha',
'Descripción del servicio',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
0,
0,
DEFAULT,
NULL,
DEFAULT,
DEFAULT
);

-- Miembros de una editorial
INSERT INTO EDITORIAL_MEMBERS VALUES
(1,
1, -- Temple Luna
'ADMIN',
'Disponible sábados y domingos',
DEFAULT,
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(3,
1, -- Temple Luna
'COLAB',
'Disponible solo sábados',
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT
);

-- Servicios por miembros de editorial
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(1,
1,
'CRITICA',
NULL,
'Crítico(a)',
DEFAULT
),

(1,
1,
'DISENO',
NULL,
'Diseñador(a)',
DEFAULT
),

(1,
1,
'DISENO',
'BAN',
'Diseñador(a) de banners',
DEFAULT
),

(1,
1,
'ESCUCHA',
NULL,
'Escuchador(a) aficionada',
DEFAULT
),

(3,
1,
'ESCUCHA',
NULL,
'Escuchador(a)',
DEFAULT
);

-- Servicios por usuario
INSERT INTO SERVICES_BY_USER VALUES
(DEFAULT,
2,
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
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
2,
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
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
2,
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
DEFAULT, -- activo
DEFAULT,
DEFAULT
);

-- Revistas
INSERT INTO MAGAZINES VALUES 
(DEFAULT,
'Individualismo en pandemia',
'https://assets.entrepreneur.com/content/3x4/600/1624551191-ent21-julyaug-cover.jpg?width=400',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Famor-en-tiempos-de-pandemia-vol-1_compressed.pdf?alt=media&token=e588c669-4edd-4d24-865b-3e55512e1b59',
18,
1,
2,
2020,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'INDIVIDUALISMO-EN-PANDEMIA-2020-1-123456789',
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
'Hablando piedras',
'https://m.media-amazon.com/images/I/51FhT+gJCLL._AC_SY445_.jpg',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Famor-en-tiempos-de-pandemia-vol-1_compressed.pdf?alt=media&token=e588c669-4edd-4d24-865b-3e55512e1b59',
15,
1,
3,
2020,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'HABLANDO-PIEDRAS-2020-1-123456789',
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
'Amor en tiempos de pandemia',
'https://images-na.ssl-images-amazon.com/images/I/91-NnXIFTTL.jpg',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Fsilabo-angular.pdf?alt=media&token=ef600a92-58cd-4949-9d33-ef2b33853d07',
20,
1,
7,
2021,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'AMOR-EN-TIEMPOS-DE-PANDEMIA-2021-1-123456789',
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
'Burrocracias: Cuando la mitad del país es bruta',
'https://cdn.www.gob.pe/uploads/document/file/1780193/standard_Elecciones-Generales-800x450.jpg.jpg',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Famor-en-tiempos-de-pandemia-vol-1_compressed.pdf?alt=media&token=e588c669-4edd-4d24-865b-3e55512e1b59',
22,
1,
8,
2021,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'BURROCRACIAS-CUANDO-LA-MITAD-DEL-PAIS-ES-BRUTA-2021-1-123456789',
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
'Identificaciones disidentes',
'https://www.paho.org/sites/default/files/styles/flexslider_full/public/2020-02/coronavirus-creativeneko-shutterstock-com.jpg?h=111de37a&itok=azilfE4h',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Famor-en-tiempos-de-pandemia-vol-1_compressed.pdf?alt=media&token=e588c669-4edd-4d24-865b-3e55512e1b59',
22,
1,
9,
2021,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'IDENTIFICACIONES-DISIDENTES-2021-1-123456789',
DEFAULT, -- activo
DEFAULT,
DEFAULT
),

(DEFAULT,
'El mundo de cabeza',
'https://i2.wp.com/ecuadortoday.media/wp-content/uploads/2020/03/Captura-de-Pantalla-2020-03-14-a-las-13.03.36.jpg?fit=524%2C346&ssl=1',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Famor-en-tiempos-de-pandemia-vol-1_compressed.pdf?alt=media&token=e588c669-4edd-4d24-865b-3e55512e1b59',
5,
1,
10,
2021,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'EL-MUNDO-DE-CABEZA-2021-1-123456789',
DEFAULT, -- activo
DEFAULT,
DEFAULT
);

-- Comentarios para la revista
INSERT INTO COMMENTS VALUES
(DEFAULT,
1,
NULL,
3,
'Este es mi primer comentario de prueba',
NULL,
'APROBADO',
'2021-08-07T16:06:54.000Z',
'2021-08-07T16:06:54.000Z'
),

(DEFAULT,
2,
NULL,
3,
'Excelente revista, yo la amo',
NULL,
'APROBADO',
'2021-08-07T16:07:54.000Z',
'2021-08-07T16:07:54.000Z'
),

(DEFAULT,
2,
NULL,
3,
'Esta es la mejor muestra de que cuando se quiere se puede',
NULL,
'APROBADO',
'2021-08-07T16:08:54.000Z',
'2021-08-07T16:08:54.000Z'
),

(DEFAULT,
3,
NULL,
3,
'Este es mi primer comentario de prueba',
NULL,
'APROBADO',
'2021-08-07T16:09:54.000Z',
'2021-08-07T16:09:54.000Z'
),

(DEFAULT,
3,
NULL,
3,
'Si me ayudan, yo promociono su revista en instagram',
NULL,
'APROBADO',
'2021-08-07T16:10:54.000Z',
'2021-08-07T16:10:54.000Z'
),

(DEFAULT,
1,
NULL,
3,
'Cómo puedo suscrirme?',
NULL,
'APROBADO',
'2021-08-07T16:11:54.000Z',
'2021-08-07T16:11:54.000Z'
),

(DEFAULT,
1,
NULL,
3,
'Son geniales',
NULL,
'APROBADO',
'2021-08-07T16:12:54.000Z',
'2021-08-07T16:12:54.000Z'
),

(DEFAULT,
1,
NULL,
3,
'Giovani, eres my crush',
NULL,
'APROBADO',
'2021-08-07T16:13:54.000Z',
'2021-08-07T16:13:54.000Z'
);

-- Procedimientos

-- Obtiene la data privada estrictamente necesaria de un usuario si se encuentra activo
DROP PROCEDURE IF EXISTS USP_GET_PRIVATE_USER_BY_EMAIL;
DELIMITER //
CREATE PROCEDURE USP_GET_PRIVATE_USER_BY_EMAIL (P_EMAIL VARCHAR(200))
BEGIN
	SELECT id, email, emailVerified, fName, lName, followName, urlProfileImg, roleId FROM USERS WHERE email = P_EMAIL AND active = 1;
END; //
DELIMITER ;

-- Obtiene la data privada de un perfil
DROP PROCEDURE IF EXISTS USP_GET_PRIVATE_PROFILE_BY_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_PRIVATE_PROFILE_BY_ID (P_USER_ID INT)
BEGIN
	SELECT id, email, emailVerified, contactEmail, fName, lName, birthday, phone, appId, pseudonym, followName, numFollowers, numComments, numHearts, urlProfileImg, occupation, about, networks, roleId, createdAt FROM USERS WHERE id = P_USER_ID AND active = 1;
END; //
DELIMITER ;

-- Obtiene la data pública de un perfil
DROP PROCEDURE IF EXISTS USP_GET_PUBLIC_PROFILE_BY_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_PUBLIC_PROFILE_BY_ID (P_USER_ID INT)
BEGIN
	SELECT id, contactEmail, fName, lName, followName, numFollowers, numComments, numHearts, urlProfileImg, about, networks, createdAt FROM USERS WHERE id = P_USER_ID AND active = 1;
END; //
DELIMITER ;

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

SELECT 
    E.id,
    E.name,
    E.urlBg,
    E.price,
    E.currency,
    E.platform,
    E.title,
    E.about,
    E.timezoneText,
    E.alias,
    ED.from,
    ED.until,
    ED.weekly
FROM
    EVENTS E
        JOIN
    EVENT_DATES ED ON E.id = ED.eventId
WHERE
    ED.from < V_LAST_DATE AND ED.active = 1
        AND E.active = 1
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
DROP PROCEDURE IF EXISTS USP_GET_DATES_BY_EVENT_ALIAS;
DELIMITER //
CREATE PROCEDURE USP_GET_DATES_BY_EVENT_ALIAS (P_ALIAS VARCHAR(200))
BEGIN
SELECT ED.from, ED.until, ED.weekly
FROM EVENT_DATES ED
JOIN EVENTS E
ON E.id = ED.eventId
WHERE E.alias=P_ALIAS AND E.active = 1 AND ED.active = 1;
END; //
DELIMITER ;

-- Obtiene los instructores de los eventos
DROP PROCEDURE IF EXISTS USP_GET_INSTRUCTORS_BY_EVENT_ALIAS;
DELIMITER //
CREATE PROCEDURE USP_GET_INSTRUCTORS_BY_EVENT_ALIAS (P_ALIAS VARCHAR(200))
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

-- Para insertar las estadísticas SI ES QUE NO HAY UNA IGUAL. Caso contrario, que solo la actualice
DROP PROCEDURE IF EXISTS USP_ADD_STATISTICS;
DELIMITER //
CREATE PROCEDURE USP_ADD_STATISTICS (P_USER_ID INT(10), P_EMAIL VARCHAR(200), P_SOCIAL_NETWORK_NAME VARCHAR(50), P_ORDER_ID INT(10), P_MAGAZINE_ID INT(10), P_ACTION_ID VARCHAR(50), P_ACTIVE BOOLEAN)
BEGIN
	DECLARE STATISTIC_ID INT;
        
    SELECT id INTO STATISTIC_ID FROM ACTIONS_BY_USER_ON_ITEM WHERE userId <=> P_USER_ID AND email <=> P_EMAIL AND orderId <=> P_ORDER_ID AND magazineId <=> P_MAGAZINE_ID AND actionId <=> P_ACTION_ID LIMIT 1;
    
    IF STATISTIC_ID IS NOT NULL THEN
		BEGIN
			-- El único campo permitido para actualizarse tiene que ser active, para saber si esa reacción se quitó o se activo. Esto se hace para asegurarse de que cada acción es única
            UPDATE ACTIONS_BY_USER_ON_ITEM SET active = P_ACTIVE WHERE id = STATISTIC_ID;
        END;
	ELSE
		BEGIN
			-- Insertar nuevo. La primera estadística de cada tipo, se supone que siempre tiene el estado active por DEFAULT, por eso no se pasa aquí
			INSERT INTO ACTIONS_BY_USER_ON_ITEM VALUES (DEFAULT, P_USER_ID, P_EMAIL, P_SOCIAL_NETWORK_NAME, P_ORDER_ID, P_MAGAZINE_ID, P_ACTION_ID, DEFAULT, DEFAULT, DEFAULT);    
        END;
    END IF;
	
END; //
DELIMITER ;

-- Para insertar un pedido. La creación no requiere todos los campos de la tabla
DROP PROCEDURE IF EXISTS USP_CREATE_ORDER;
DELIMITER //
CREATE PROCEDURE USP_CREATE_ORDER (P_CLIENT_USER_ID INT(10), P_CLIENT_EMAIL VARCHAR(200), P_CLIENT_NAMES VARCHAR(200), P_CLIENT_AGE TINYINT, P_CLIENT_PHONE VARCHAR(50), P_CLIENT_APP VARCHAR(50), P_WORKER_ID INT(10),  P_EDITORIAL_ID INT(10), P_SERVICE_ID VARCHAR(50), P_SUBSERVICE_ID VARCHAR(50), P_STATUS_ID VARCHAR(50), P_TITLE_WORK VARCHAR(200), P_LINK_WORK VARCHAR(500), P_PSEUDONYM VARCHAR(200), P_SYNOPSIS VARCHAR(500), P_DETAILS VARCHAR(500), P_INTENTION VARCHAR(500), P_MAIN_PHRASE VARCHAR(200), P_NOTIFY BOOLEAN, P_IMG_URL_DATA JSON, P_PRIORITY VARCHAR(50), P_EXTRA_DATA JSON, P_PUBLIC_RESULT BOOLEAN, P_VERSION VARCHAR(100))
BEGIN
	INSERT INTO ORDERS VALUES (DEFAULT, P_CLIENT_USER_ID, P_CLIENT_EMAIL, P_CLIENT_NAMES, P_CLIENT_AGE, P_CLIENT_PHONE, P_CLIENT_APP, P_WORKER_ID, NULL, NULL, NULL, P_EDITORIAL_ID, P_SERVICE_ID, P_SUBSERVICE_ID, P_STATUS_ID, NULL, NULL, P_TITLE_WORK, P_LINK_WORK, P_PSEUDONYM, P_SYNOPSIS, P_DETAILS, P_INTENTION, P_MAIN_PHRASE, NULL, P_NOTIFY, P_IMG_URL_DATA, P_PRIORITY, P_EXTRA_DATA, P_PUBLIC_RESULT, NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, P_VERSION, DEFAULT, DEFAULT);    
END; //
DELIMITER ;

-- Para obtener a las personas que dan X servicio de Z editorial
DROP PROCEDURE IF EXISTS USP_GET_MEMBERS_BY_EDITORIAL_SERVICE;
DELIMITER //
CREATE PROCEDURE USP_GET_MEMBERS_BY_EDITORIAL_SERVICE (P_EDITORIAL_ID INT, P_SERVICE_ID VARCHAR(50))
BEGIN
SELECT EMS.userId as 'id', CONCAT(U.fName, " ", U.lName) as 'name', U.urlProfileImg as 'imgUrl', EMS.description, EM.availability FROM EDITORIAL_MEMBER_SERVICES EMS
JOIN EDITORIAL_MEMBERS EM
ON EM.userId = EMS.userId
AND EM.editorialId = EMS.editorialId
JOIN USERS U
ON U.id = EMS.userId
WHERE EMS.editorialId = P_EDITORIAL_ID
AND EMS.serviceId = P_SERVICE_ID
GROUP BY EMS.userId; -- Para que este campo sea único, porque hay campos como serviceId que tienen subServices null y not null, y ahí se pueden repetir los resultados
END; //
DELIMITER ;

-- Para obtener las revistas por año
DROP PROCEDURE IF EXISTS USP_GET_MAGAZINES_BY_YEAR;
DELIMITER //
CREATE PROCEDURE USP_GET_MAGAZINES_BY_YEAR (P_YEAR INT)
BEGIN
	SELECT M.id, M.title, M.urlPortrait, M.numPag, M.edition, M.year, M.numHearts, M.numComments, M.numViews, M.numDownloads, M.numSubscribers, M.alias, E.id as editorialId, E.name as editorialName, E.bgColor as editorialBgColor, E.networks as editorialNetworks
    FROM MAGAZINES M
    JOIN EDITORIALS E
    ON M.editorialId = E.id
    WHERE M.active = 1 AND M.year = P_YEAR ORDER BY M.createdAt DESC;
END; //
DELIMITER ;

-- Para obtener una revista por alias. El parámetros P_USER_ID_FOR_ACTION puede ser null y solo sirve para ver si dicho usuario ha dejado una reacción en la revista (tabla ACTIONS_BY_USER_ON_ITEM)
DROP PROCEDURE IF EXISTS USP_GET_MAGAZINE_BY_ALIAS;
DELIMITER //
CREATE PROCEDURE USP_GET_MAGAZINE_BY_ALIAS (P_ALIAS VARCHAR(200), P_USER_ID_FOR_ACTION INT)
BEGIN
	DECLARE V_USER_ID_FOR_ACTION INT;
		IF (P_USER_ID_FOR_ACTION IS NULL) THEN
			BEGIN
				SET V_USER_ID_FOR_ACTION = NULL;
			END;
		ELSE
			BEGIN
				SET V_USER_ID_FOR_ACTION = P_USER_ID_FOR_ACTION;
			END;
	END IF;

	SELECT
    M.id,
    M.title,
    M.urlPortrait,
    M.displayUrl,
    M.url,
    M.numPag,
    M.edition,
    M.year,
    M.numHearts,
    M.numComments,
    M.numViews,
    M.numDownloads,
    M.numSubscribers,
    M.alias,
    E.id as editorialId,
    E.name as editorialName,
    E.bgColor as editorialBgColor,
    E.networks as editorialNetworks,
      -- Para verificar si ha dado una reacción de corazón
    CASE
		WHEN V_USER_ID_FOR_ACTION IS NULL THEN
			NULL
		ELSE
			(SELECT EXISTS ( SELECT ABU.userId FROM ACTIONS_BY_USER_ON_ITEM ABU JOIN MAGAZINES M ON ABU.magazineId = M.id WHERE M.alias = P_ALIAS AND ABU.active = 1 AND ABU.actionId = 'GUSTAR'))
	END as hasGivenLove
    FROM MAGAZINES M
    JOIN EDITORIALS E
    ON M.editorialId = E.id
    WHERE M.active = 1 AND M.alias = P_ALIAS;
END; //
DELIMITER ;

-- Para obtener comentarios de una revista, según su id. Esto sirve cuando el id no está disponible o no es bonito pasarlo. Por ejemplo, al postear un comentario y usar esos mismos datos para obtenerlos actualizados
DROP PROCEDURE IF EXISTS USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ID (P_MAGAZINE_ID INT, P_LIMIT INT, P_LAST_TIMESTAMP TIMESTAMP)
BEGIN
DECLARE V_LAST_TIMESTAMP TIMESTAMP;
	IF (P_LAST_TIMESTAMP IS NULL) THEN
		BEGIN
			SET V_LAST_TIMESTAMP = TIMESTAMPADD(HOUR, 1, (SELECT MAX(C.createdAt) FROM COMMENTS C));
		END;
	ELSE
		BEGIN
			SET V_LAST_TIMESTAMP = P_LAST_TIMESTAMP;    
		END;
END IF;

SELECT C.id, C.userId, CONCAT(U.fName, ' ', U.lName) as names, U.urlProfileImg as urlImg, C.content, C.createdAt FROM COMMENTS C
JOIN MAGAZINES M
ON C.magazineId = M.id
JOIN USERS U
ON U.id = C.userId
WHERE C.statusId = 'APROBADO' AND M.id = P_MAGAZINE_ID AND C.createdAt < V_LAST_TIMESTAMP
ORDER BY C.createdAt DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Para obtener comentarios de una revista, según su alias. Dado que se obtienen los más actuales primero, el parámetro P_LAST_TIMESTAMP debe obtener los más antiguos que le siguen. Esto se usa para obtener la revista con una URL
DROP PROCEDURE IF EXISTS USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ALIAS;
DELIMITER //
CREATE PROCEDURE USP_GET_OLDER_COMMENTS_BY_MAGAZINE_ALIAS (P_ALIAS VARCHAR(200), P_LIMIT INT, P_LAST_TIMESTAMP TIMESTAMP)
BEGIN
DECLARE V_LAST_TIMESTAMP TIMESTAMP;
	IF (P_LAST_TIMESTAMP IS NULL) THEN
		BEGIN
			SET V_LAST_TIMESTAMP = TIMESTAMPADD(HOUR, 1, (SELECT MAX(C.createdAt) FROM COMMENTS C));
		END;
	ELSE
		BEGIN
			SET V_LAST_TIMESTAMP = P_LAST_TIMESTAMP;    
		END;
END IF;

SELECT C.id, C.userId, CONCAT(U.fName, ' ', U.lName) as names, U.urlProfileImg as urlImg, C.content, C.createdAt FROM COMMENTS C
JOIN MAGAZINES M
ON C.magazineId = M.id
JOIN USERS U
ON U.id = C.userId
WHERE C.statusId = 'APROBADO' AND M.alias = P_ALIAS AND C.createdAt < V_LAST_TIMESTAMP
ORDER BY C.createdAt DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Para obtener comentarios de un pedido, según su id. Dado que se obtienen los más actuales primero, el parámetro P_LAST_TIMESTAMP debe obtener los más antiguos que le siguen
DROP PROCEDURE IF EXISTS USP_GET_OLDER_COMMENTS_BY_ORDER_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_OLDER_COMMENTS_BY_ORDER_ID (P_ORDER_ID INT, P_LIMIT INT, P_LAST_TIMESTAMP TIMESTAMP)
BEGIN
DECLARE V_LAST_TIMESTAMP TIMESTAMP;
	IF (P_LAST_TIMESTAMP IS NULL) THEN
		BEGIN
			SET V_LAST_TIMESTAMP = TIMESTAMPADD(HOUR, 1, (SELECT MAX(C.createdAt) FROM COMMENTS C));
		END;
	ELSE
		BEGIN
			SET V_LAST_TIMESTAMP = P_LAST_TIMESTAMP;    
		END;
END IF;

SELECT C.id, C.userId, CONCAT(U.fName, ' ', U.lName) as names, U.urlProfileImg as urlImg, C.content, C.createdAt FROM COMMENTS C
JOIN ORDERS O
ON O.id = C.orderId
JOIN USERS U
ON U.id = C.userId
WHERE C.statusId = 'APROBADO' AND O.id = P_ORDER_ID AND C.createdAt < V_LAST_TIMESTAMP
ORDER BY C.createdAt DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Postea un comentario
DROP PROCEDURE IF EXISTS USP_POST_COMMENT;
DELIMITER //
CREATE PROCEDURE USP_POST_COMMENT (P_USER_ID INT, P_ORDER_ID INT, P_MAGAZINE_ID INT, P_CONTENT VARCHAR(1000))
BEGIN
	INSERT INTO COMMENTS VALUES (DEFAULT, P_USER_ID, P_ORDER_ID, P_MAGAZINE_ID, P_CONTENT, NULL, 'APROBADO', DEFAULT, DEFAULT);
END; //
DELIMITER ;

-- Verifica 1) si el usuario existe, y 2) si el usuario está activo o ha sido inhabilitado; ambos por email. Esto sirve para validar el login y enviar mensajes de error dependiendo si el usuario está inhabilitado o si no existe.
DROP PROCEDURE IF EXISTS USP_GET_USER_STATUS_BY_EMAIL;
DELIMITER //
CREATE PROCEDURE USP_GET_USER_STATUS_BY_EMAIL (P_EMAIL VARCHAR(200))
BEGIN
SELECT
	EXISTS ( SELECT id FROM USERS WHERE email = P_EMAIL ) AS 'exists',
	EXISTS ( SELECT id FROM USERS WHERE email = P_EMAIL AND active = 1 ) AS 'active'; 
END; //
DELIMITER ;

-- Registro un usuario
DROP PROCEDURE IF EXISTS USP_REGISTER_USER;
DELIMITER //
CREATE PROCEDURE USP_REGISTER_USER (P_FNAME VARCHAR(200), P_LNAME VARCHAR(200), P_EMAIL VARCHAR(200), P_FOLLOW_NAME VARCHAR(200))
BEGIN
	INSERT INTO USERS VALUES (DEFAULT, P_EMAIL, 0, NULL, P_FNAME, P_LNAME, NULL, NULL, NULL, NULL, P_FOLLOW_NAME, DEFAULT, DEFAULT, DEFAULT, NULL, NULL, NULL, DEFAULT, 'BASIC', 1, DEFAULT, DEFAULT);
END; //
DELIMITER ;

-- Obtiene los servicios de una editorial. El segundo parámetro es para incluir o excluir subservicios
DROP PROCEDURE IF EXISTS USP_GET_EDITORIAL_SERVICES;
DELIMITER //
CREATE PROCEDURE USP_GET_EDITORIAL_SERVICES (P_EDITORIAL_ID INT, P_INCLUDE_SUBSERVICES BOOLEAN)
BEGIN
	SELECT SBE.serviceId, SBE.subserviceId, S.name, SBE.urlBg
    FROM SERVICES_BY_EDITORIAL SBE
    JOIN SERVICES S
    ON S.id = SBE.serviceId
    LEFT JOIN SUBSERVICES SS -- Left join porque debo traer todos los servicios, tengan o no un subservicio
    ON SS.id = SBE.subserviceId
    WHERE SBE.editorialId <=> P_EDITORIAL_ID
    AND (
		CASE
			WHEN P_INCLUDE_SUBSERVICES = 0 THEN
				SBE.subserviceId IS NULL
			ELSE TRUE
		END
        );   
END; //
DELIMITER ;

-- Obtiene los servicios que el miembro de una editorial brinda (Ejemplo: X miembro hace críticas y diseños)
DROP PROCEDURE IF EXISTS USP_GET_EDITORIAL_SERVICES_BY_EDITORIAL_MEMBER;
DELIMITER //
CREATE PROCEDURE USP_GET_EDITORIAL_SERVICES_BY_EDITORIAL_MEMBER (P_USER_ID INT, P_EDITORIAL_ID INT, P_INCLUDE_SUBSERVICES BOOLEAN)
BEGIN
	SELECT EMS.serviceId, EMS.subserviceId, S.name as 'serviceName', S.name as 'subserviceName', SBE.urlBg
    FROM EDITORIAL_MEMBER_SERVICES EMS
    JOIN SERVICES S
    ON S.id = EMS.serviceId
    LEFT JOIN SUBSERVICES SS -- Left join porque debo traer todos los servicios, tengan o no un subservicio
    ON SS.id = EMS.subserviceId
	JOIN SERVICES_BY_EDITORIAL SBE -- Solo para asegurarnos de que la editorial tiene habilitado ese servicio
    ON SBE.editorialId = EMS.editorialId AND SBE.serviceId = EMS.serviceId
    JOIN EDITORIAL_MEMBERS EM -- Solo para asegurarnos de que la editorial tiene a ese miembro registrado
    ON EMS.userId = EM.userId    
	WHERE
		EMS.userId = P_USER_ID
		AND EMS.editorialId <=> P_EDITORIAL_ID
        AND EM.active = 1 -- El miembro de la editorial está activo
        AND (
			CASE
				WHEN P_INCLUDE_SUBSERVICES = 0 THEN
					EMS.subserviceId IS NULL
				ELSE TRUE
			END
			)
	GROUP BY EMS.editorialId, EMS.serviceId, EMS.subserviceId;    
END; //
DELIMITER ;

-- Obtiene TODOS los servicios que un usuario brinda, ya sea dentro de una editorial o por si mismo
DROP PROCEDURE IF EXISTS USP_GET_ALL_SERVICES_BY_USER;
DELIMITER //
CREATE PROCEDURE USP_GET_ALL_SERVICES_BY_USER (P_USER_ID INT, P_INCLUDE_SUBSERVICES BOOLEAN)
BEGIN
	SELECT EMS.serviceId, EMS.subserviceId, S.name as 'serviceName', S.name as 'subserviceName' -- Representa los servicios que un miembro ofrece dentro de una editorial
    FROM EDITORIAL_MEMBER_SERVICES EMS
    JOIN SERVICES S
    ON S.id = EMS.serviceId
    LEFT JOIN SUBSERVICES SS -- Left join porque debo traer todos los servicios, tengan o no un subservicio
    ON SS.id = EMS.subserviceId
	WHERE
		EMS.userId = P_USER_ID
        AND (
			CASE
				WHEN P_INCLUDE_SUBSERVICES = 0 THEN
					EMS.subserviceId IS NULL
				ELSE TRUE
			END
			)
	GROUP BY EMS.editorialId, EMS.serviceId, EMS.subserviceId
    UNION -- Uno con los resultados de esta tabla, que representa los servicios por usuario (no requieren editorial)
    SELECT SBY.serviceId, SBY.subserviceId, S.name as 'serviceName', S.name as 'subserviceName'
    FROM SERVICES_BY_USER SBY
    JOIN SERVICES S
    ON S.id = SBY.serviceId
    LEFT JOIN SUBSERVICES SS -- Left join porque debo traer todos los servicios, tengan o no un subservicio
    ON SS.id = SBY.subserviceId
    WHERE
		SBY.userId = P_USER_ID
        AND (
			CASE
				WHEN P_INCLUDE_SUBSERVICES = 0 THEN
					SBY.subserviceId IS NULL
				ELSE TRUE
			END
			);	
END; //
DELIMITER ;

-- Obtiene los pedidos PRIVADOS por editorial: Estado (disponible, tomado, listo), servicio (crítica, diseño, etc), subservicio (nullable), usuario (nullable, esto si ha sido tomado por él), por última fecha (nullable, para el scroll infinito) y si es público o no
DROP PROCEDURE IF EXISTS USP_GET_PRIVATE_ORDERS_BY_EDITORIAL_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_PRIVATE_ORDERS_BY_EDITORIAL_ID (P_EDITORIAL_ID INT, P_STATUS_ID VARCHAR(50), P_SERVICE_ID VARCHAR(50), P_SUBSERVICE_ID VARCHAR(50), P_WORKER_USER_ID INT, P_LAST_TIMESTAMP TIMESTAMP, P_PUBLIC BOOLEAN, P_LIMIT INT)
BEGIN
DECLARE V_LAST_TIMESTAMP TIMESTAMP;
	IF (P_LAST_TIMESTAMP IS NULL) THEN
		BEGIN
			SET V_LAST_TIMESTAMP = TIMESTAMPADD(HOUR, 1, (SELECT MAX(O.createdAt) FROM ORDERS O));
		END;
	ELSE
		BEGIN
			SET V_LAST_TIMESTAMP = P_LAST_TIMESTAMP;    
		END;
END IF;

SELECT
	O.id,
	O.clientUserId, -- Si clientUserId es nulo, significa que los datos están en la tabla actual. Caso contrario, debo consultarlo desde la tabla USERS. TODO: Cambiar el email por contactEmail del usuario
	CASE WHEN O.clientUserId IS NULL THEN O.clientEmail ELSE (SELECT email FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientEmail,
	CASE WHEN O.clientUserId IS NULL THEN O.clientNames ELSE (SELECT CONCAT(fName, " ", lName) FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientNames,
	CASE WHEN O.clientUserId IS NULL THEN O.clientPhone ELSE (SELECT phone FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientPhone,
	CASE WHEN O.clientUserId IS NULL THEN O.clientAppId ELSE (SELECT appId FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientAppId,
	O.workerUserId,
	U.fName as 'workerFName',
    U.lName as 'workerLName',
    U.networks as 'workerNetworks',
    U.contactEmail as 'workerContactEmail',
    U.urlProfileImg as 'workerUrlProfileImg',
	O.serviceId,
	O.subserviceId,
	O.statusId,
	O.titleWork,
	O.linkWork,
	O.pseudonym,
	O.synopsis,
	O.details,
	O.intention,
	O.mainPhrase,
	O.imgUrlData,
	O.priority,
	O.extraData,
	O.resultUrl,
	O.numHearts,
	O.numComments,
	O.numViews,
    O.numDownloads,
    O.takenAt,
    O.publicLink,
    O.public,
    O.version,
    O.expiresAt,
	O.createdAt
FROM ORDERS O
JOIN SERVICES_BY_EDITORIAL SBE -- Solo para asegurarnos de que la editorial tiene habilitado ese servicio
ON SBE.editorialId = O.editorialId AND SBE.serviceId = O.serviceId
JOIN EDITORIAL_MEMBERS EM -- Solo para asegurarnos de que la editorial tiene a ese miembro registrado
ON EM.userId = P_WORKER_USER_ID
LEFT JOIN `USERS` U -- Para que traiga todo, así los campos sean NULL
ON U.id = O.workerUserId
WHERE O.editorialId <=> P_EDITORIAL_ID
AND O.statusId = P_STATUS_ID
AND O.createdAt < V_LAST_TIMESTAMP
AND O.serviceId = P_SERVICE_ID
AND (
	CASE
		WHEN P_SUBSERVICE_ID IS NULL THEN -- Si esto es nulo, significa que no debe filtrar por este campo. Es indiferente
			TRUE
		ELSE O.subserviceId <=> P_SUBSERVICE_ID
	END
	)
AND (
	CASE
		WHEN P_PUBLIC IS NULL THEN -- Si esto es nulo, significa que no debe filtrar por este campo. Es indiferente
			TRUE
		ELSE O.public = P_PUBLIC
	END
	)
AND (
	CASE
		WHEN O.statusId = 'DISPONIBLE' THEN -- Por regla de negocio, si el estado de un pedido es DISPONIBLE, es porque aún no tiene un workerUserId asignado. Por lo tanto, no se debe validar en ese caso
			TRUE
		ELSE O.workerUserId = P_WORKER_USER_ID
	END
	)
GROUP BY O.id -- Que los ids no se repitan
ORDER BY O.createdAt DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Obtiene todos los datos PÚBLICOS de los pedidos según usuario y servicio. Esto sirve para verlos en un perfil ajeno
DROP PROCEDURE IF EXISTS USP_GET_ALL_PUBLIC_ORDERS_BY_WORKER_USER_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_ALL_PUBLIC_ORDERS_BY_WORKER_USER_ID (P_SERVICE_ID VARCHAR(50), P_SUBSERVICE_ID VARCHAR(50), P_WORKER_USER_ID INT, P_LAST_TIMESTAMP TIMESTAMP, P_LIMIT INT)
BEGIN
DECLARE V_LAST_TIMESTAMP TIMESTAMP;
	IF (P_LAST_TIMESTAMP IS NULL) THEN
		BEGIN
			SET V_LAST_TIMESTAMP = TIMESTAMPADD(HOUR, 1, (SELECT MAX(O.createdAt) FROM ORDERS O));
		END;
	ELSE
		BEGIN
			SET V_LAST_TIMESTAMP = P_LAST_TIMESTAMP;    
		END;
END IF;

SELECT
	O.id,
	CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.clientUserId
	END as clientUserId,
	O.workerUserId,
	U.fName as 'workerFName',
    U.lName as 'workerLName',
    U.networks as 'workerNetworks',
    U.contactEmail as 'workerContactEmail',
    U.urlProfileImg as 'workerUrlProfileImg',
	O.serviceId,
	O.subserviceId,
	O.titleWork,
    O.editorialId,
    CASE
		WHEN O.public != 1 THEN ''  -- Si está privado, no se puede ver públicamente
        ELSE E.name
	END as editorialName,
    CASE
		WHEN O.public != 1 THEN ''  -- Si está privado, no se puede ver públicamente
        ELSE E.bgColor
	END as editorialBgColor,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numHearts
	END as numHearts,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numComments
	END as numComments,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numViews
	END as numViews,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numDownloads
	END as numDownloads,
	CASE
		WHEN O.public != 1 THEN ''
		ELSE O.resultUrl
	END as resultUrl, -- Solo se va a mostrar el link públicamente si el solicitante lo ha elegido así
    CASE
		WHEN O.public = 1 AND O.publicLink = 1 THEN O.linkWork
		ELSE ''
	END as linkWork, -- Solo se va a mostrar el link públicamente si el solicitante lo ha elegido así
    O.publicLink,
    O.public, -- Esto significa que no se puede acceder a ningún dato crítico públicamente, solo al título
    O.version
FROM ORDERS O
LEFT JOIN `USERS` U -- Para que traiga todo, así los campos sean NULL
ON U.id = O.workerUserId
LEFT JOIN EDITORIALS E -- Para que traiga todo, así la editorial sea NULL
ON E.id = O.editorialId
WHERE O.statusId = 'HECHO'
AND U.id = P_WORKER_USER_ID
AND O.createdAt < V_LAST_TIMESTAMP
AND O.serviceId = P_SERVICE_ID
AND (
	CASE
		WHEN P_SUBSERVICE_ID IS NULL THEN -- Si esto es nulo, significa que no debe filtrar por este campo. Es indiferente
			TRUE
		ELSE O.subserviceId <=> P_SUBSERVICE_ID
	END
	)
GROUP BY O.id -- Que los ids no se repitan
ORDER BY O.createdAt DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Obtiene todos los datos PRIVADOS de los pedidos según usuario y servicio. Esto sirve para verlos en el perfil propio
DROP PROCEDURE IF EXISTS USP_GET_ALL_PRIVATE_ORDERS_BY_WORKER_USER_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_ALL_PRIVATE_ORDERS_BY_WORKER_USER_ID (P_SERVICE_ID VARCHAR(50), P_SUBSERVICE_ID VARCHAR(50), P_WORKER_USER_ID INT, P_LAST_TIMESTAMP TIMESTAMP, P_LIMIT INT)
BEGIN
DECLARE V_LAST_TIMESTAMP TIMESTAMP;
	IF (P_LAST_TIMESTAMP IS NULL) THEN
		BEGIN
			SET V_LAST_TIMESTAMP = TIMESTAMPADD(HOUR, 1, (SELECT MAX(O.createdAt) FROM ORDERS O));
		END;
	ELSE
		BEGIN
			SET V_LAST_TIMESTAMP = P_LAST_TIMESTAMP;    
		END;
END IF;

SELECT
	O.id,
	O.clientUserId, -- Si clientUserId es nulo, significa que los datos están en la tabla actual. Caso contrario, debo consultarlo desde la tabla USERS. TODO: Cambiar el email por contactEmail del usuario
	CASE WHEN O.clientUserId IS NULL THEN O.clientEmail ELSE (SELECT email FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientEmail,
	CASE WHEN O.clientUserId IS NULL THEN O.clientNames ELSE (SELECT CONCAT(fName, " ", lName) FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientNames,
	CASE WHEN O.clientUserId IS NULL THEN O.clientPhone ELSE (SELECT phone FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientPhone,
	CASE WHEN O.clientUserId IS NULL THEN O.clientAppId ELSE (SELECT appId FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientAppId,
	O.workerUserId,
	U.fName as 'workerFName',
    U.lName as 'workerLName',
    U.networks as 'workerNetworks',
    U.contactEmail as 'workerContactEmail',
    U.urlProfileImg as 'workerUrlProfileImg',
	O.serviceId,
	O.subserviceId,
	O.statusId,
	O.titleWork,
	O.linkWork,
	O.pseudonym,
	O.synopsis,
	-- O.details,
	O.intention,
	O.mainPhrase,
	O.imgUrlData,
	O.priority,
	O.extraData,
	O.resultUrl,
    O.editorialId,
    E.name as 'editorialName',
    E.bgColor as 'editorialBgColor',
	O.numHearts,
	O.numComments,
	O.numViews,
    numDownloads,
    O.takenAt,
	O.public,
    O.version,
    O.expiresAt,
	O.createdAt
FROM ORDERS O
LEFT JOIN `USERS` U -- Para que traiga todo, así los campos sean NULL
ON U.id = O.workerUserId
LEFT JOIN EDITORIALS E -- Para que traiga todo, así la editorial sea NULL
ON E.id = O.editorialId
WHERE O.statusId = 'HECHO'
AND U.id = P_WORKER_USER_ID
AND O.createdAt < V_LAST_TIMESTAMP
AND O.serviceId = P_SERVICE_ID
AND (
	CASE
		WHEN P_SUBSERVICE_ID IS NULL THEN -- Si esto es nulo, significa que no debe filtrar por este campo. Es indiferente
			TRUE
		ELSE O.subserviceId <=> P_SUBSERVICE_ID
	END
	)
GROUP BY O.id -- Que los ids no se repitan
ORDER BY O.createdAt DESC
LIMIT P_LIMIT;
END; //
DELIMITER ;

-- Obtiene los totales PRIVADOS de cada estado de los pedidos por editorial y workerUserId. Ejemplo: X usuario, para críticas tiene (DISPONIBLE: 3, TOMADO: 2, HECHO: 5). Se usa en las estadísticas del dashboard
DROP PROCEDURE IF EXISTS USP_GET_ORDER_STATUS_PRIVATE_TOTALS_BY_EDITORIAL_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_ORDER_STATUS_PRIVATE_TOTALS_BY_EDITORIAL_ID (P_EDITORIAL_ID INT, P_SERVICE_ID VARCHAR(50), P_WORKER_USER_ID INT)
BEGIN
SELECT
	(SELECT COUNT(id) FROM ORDERS WHERE statusId = 'DISPONIBLE' AND editorialId <=> P_EDITORIAL_ID AND serviceId = P_SERVICE_ID) AS 'DISPONIBLE',
	(SELECT COUNT(id) FROM ORDERS WHERE statusId = 'ANULADO' AND editorialId <=> P_EDITORIAL_ID AND serviceId = P_SERVICE_ID AND workerUserId <=> P_WORKER_USER_ID) AS 'ANULADO',
    (SELECT COUNT(id) FROM ORDERS WHERE statusId = 'HECHO' AND editorialId <=> P_EDITORIAL_ID AND serviceId = P_SERVICE_ID AND workerUserId <=> P_WORKER_USER_ID) AS 'HECHO',
    (SELECT COUNT(id) FROM ORDERS WHERE statusId = 'SOLICITADO' AND editorialId <=> P_EDITORIAL_ID AND serviceId = P_SERVICE_ID AND workerUserId <=> P_WORKER_USER_ID) AS 'SOLICITADO',
    (SELECT COUNT(id) FROM ORDERS WHERE statusId = 'TOMADO' AND editorialId <=> P_EDITORIAL_ID AND serviceId = P_SERVICE_ID AND workerUserId <=> P_WORKER_USER_ID) AS 'TOMADO';
END; //
DELIMITER ;

-- Obtiene los totales PÚBLICOS de cada estado de los pedidos por usuario. Se usa para las estadísticas de los pedidos en perfil ajeno o propio
DROP PROCEDURE IF EXISTS USP_GET_ORDER_STATUS_PUBLIC_TOTALS_BY_WORKER_USER_ID;
DELIMITER //
CREATE PROCEDURE USP_GET_ORDER_STATUS_PUBLIC_TOTALS_BY_WORKER_USER_ID (P_SERVICE_ID VARCHAR(50), P_WORKER_USER_ID INT)
BEGIN
SELECT
    (SELECT COUNT(id) FROM ORDERS WHERE statusId = 'HECHO' AND serviceId = P_SERVICE_ID AND workerUserId <=> P_WORKER_USER_ID) AS 'HECHO';
END; //
DELIMITER ;

-- Toma un pedido (TODO: Agregar más validaciones para verificar que ese usuario pertenece a la editorial, está activo y ofrece ese servicio)
DROP PROCEDURE IF EXISTS USP_TAKE_ORDER;
DELIMITER //
CREATE PROCEDURE USP_TAKE_ORDER (P_ORDER_ID INT, P_USER_ID INT, P_TAKEN_AT DATETIME, P_EXP_DAYS INT)
BEGIN
	DECLARE V_EXPIRES_AT DATETIME;
    SET V_EXPIRES_AT = DATE_ADD(P_TAKEN_AT, INTERVAL P_EXP_DAYS DAY);
	UPDATE ORDERS SET workerUserId = P_USER_ID, statusId = 'TOMADO', takenAt = P_TAKEN_AT, expiresAt = V_EXPIRES_AT WHERE id = P_ORDER_ID AND (statusId = 'DISPONIBLE' OR statusId = 'SOLICITADO');
END; //
DELIMITER ;

-- Devuelve un pedido. Valida si el userId pasado como parámetro corresponde con el mismo que lo ha tomado. Además, devuelve al statusId original pasado como parámetro
DROP PROCEDURE IF EXISTS USP_RETURN_ORDER;
DELIMITER //
CREATE PROCEDURE USP_RETURN_ORDER (P_ORDER_ID INT, P_ORIGINAL_STATUS_ID VARCHAR(50), P_USER_ID INT)
BEGIN
	UPDATE ORDERS SET workerUserId = NULL, statusId = P_ORIGINAL_STATUS_ID, prevWorkerUserId = workerUserId WHERE id = P_ORDER_ID AND statusId = 'TOMADO' AND workerUserId = P_USER_ID;
END; //
DELIMITER ;

-- Obtiene los datos PRIVADOS de un pedido. Esto es para verlo en un dashboard o ver los detalles en el perfil propio. El parámetros P_USER_ID_FOR_ACTION puede ser null y solo sirve para ver si dicho usuario ha dejado una reacción en el pedido (tabla ACTIONS_BY_USER_ON_ITEM)
DROP PROCEDURE IF EXISTS USP_GET_PRIVATE_ORDER;
DELIMITER //
CREATE PROCEDURE USP_GET_PRIVATE_ORDER (P_ORDER_ID INT, P_USER_ID_FOR_ACTION INT)
BEGIN
DECLARE V_USER_ID_FOR_ACTION INT;
	IF (P_USER_ID_FOR_ACTION IS NULL) THEN
		BEGIN
			SET V_USER_ID_FOR_ACTION = NULL;
		END;
	ELSE
		BEGIN
			SET V_USER_ID_FOR_ACTION = P_USER_ID_FOR_ACTION;
		END;
END IF;

SELECT
	O.id,
	O.clientUserId, -- Si clientUserId es nulo, significa que los datos están en la tabla actual. Caso contrario, debo consultarlo desde la tabla USERS. TODO: Cambiar el email por contactEmail del usuario (ACTIONS_BY_USER_ON_ITEM)
	CASE WHEN O.clientUserId IS NULL THEN O.clientEmail ELSE (SELECT email FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientEmail,
	CASE WHEN O.clientUserId IS NULL THEN O.clientNames ELSE (SELECT CONCAT(fName, " ", lName) FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientNames,
	CASE WHEN O.clientUserId IS NULL THEN O.clientPhone ELSE (SELECT phone FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientPhone,
	CASE WHEN O.clientUserId IS NULL THEN O.clientAppId ELSE (SELECT appId FROM USERS WHERE id = O.clientUserId LIMIT 1) END as clientAppId,
    -- Para verificar si ha dado una reacción de corazón
    CASE WHEN V_USER_ID_FOR_ACTION IS NULL THEN NULL ELSE (SELECT EXISTS ( SELECT userId FROM ACTIONS_BY_USER_ON_ITEM WHERE orderId = P_ORDER_ID AND active = 1 AND actionId = 'GUSTAR')) END as hasGivenLove,
	O.workerUserId,
    U.fName as 'workerFName',
    U.lName as 'workerLName',
    U.networks as 'workerNetworks',
    U.contactEmail as 'workerContactEmail',
    U.urlProfileImg as 'workerUrlProfileImg',
	O.serviceId,
	O.subserviceId,
	O.statusId,
	O.titleWork,
	O.linkWork,
	O.pseudonym,
	O.synopsis,
	O.details,
	O.intention,
	O.mainPhrase,
	O.imgUrlData,
	O.priority,
	O.extraData,
	O.resultUrl,
	O.numHearts,
	O.numComments,
	O.numViews,
    O.numDownloads,
    O.takenAt,
    O.version,
    O.expiresAt,
	O.createdAt
FROM ORDERS O
LEFT JOIN `USERS` U
ON U.id = O.workerUserId
LEFT JOIN EDITORIALS E -- Para que traiga todo, así la editorial sea NULL, dado que los pedidos pueden ser independientes de una editorial
ON E.id = O.editorialId
WHERE O.id = P_ORDER_ID;
END; //
DELIMITER ;

-- Obtiene los datos PÚBLICOS de un pedido. Esto es para ver el pedido de un perfil ajeno
DROP PROCEDURE IF EXISTS USP_GET_PUBLIC_ORDER;
DELIMITER //
CREATE PROCEDURE USP_GET_PUBLIC_ORDER (P_ORDER_ID INT)
BEGIN
SELECT
	O.id,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.clientUserId
	END as clientUserId,
	O.workerUserId,
	U.fName as 'workerFName',
    U.lName as 'workerLName',
    U.networks as 'workerNetworks',
    U.contactEmail as 'workerContactEmail',
    U.urlProfileImg as 'workerUrlProfileImg',
    O.serviceId,
	O.subserviceId,
	O.titleWork,
    O.editorialId,
    CASE
		WHEN O.public != 1 THEN ''  -- Si está privado, no se puede ver públicamente
        ELSE E.name
	END as editorialName,
    CASE
		WHEN O.public != 1 THEN ''  -- Si está privado, no se puede ver públicamente
        ELSE E.bgColor
	END as editorialBgColor,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numHearts
	END as numHearts,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numComments
	END as numComments,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numViews
	END as numViews,
    CASE
		WHEN O.public != 1 THEN NULL  -- Si está privado, no se puede ver públicamente
        ELSE O.numDownloads
	END as numDownloads,
	CASE
		WHEN O.public != 1 THEN ''
		ELSE O.resultUrl
	END as resultUrl, -- Solo se va a mostrar el link públicamente si el solicitante lo ha elegido así
    CASE
		WHEN O.public = 1 AND O.publicLink = 1 THEN O.linkWork
		ELSE ''
	END as linkWork, -- Solo se va a mostrar el link públicamente si el solicitante lo ha elegido así
    O.publicLink,
    O.public, -- Esto significa que no se puede acceder a ningún dato crítico públicamente, solo al título
    O.version
FROM ORDERS O
LEFT JOIN `USERS` U
ON U.id = O.workerUserId
LEFT JOIN EDITORIALS E -- Para que traiga todo, así la editorial sea NULL, dado que los pedidos pueden ser independientes de una editorial
ON E.id = O.editorialId
WHERE O.id = P_ORDER_ID;
END; //
DELIMITER ;

-- Establece un pedido como HECHO
DROP PROCEDURE IF EXISTS USP_SET_ORDER_DONE;
DELIMITER //
CREATE PROCEDURE USP_SET_ORDER_DONE (P_ORDER_ID INT, P_RESULT_URL VARCHAR(2000))
BEGIN
	UPDATE ORDERS SET statusId = 'HECHO', resultUrl = P_RESULT_URL WHERE statusId = 'TOMADO' AND id = P_ORDER_ID;
END; //
DELIMITER ;

-- select*from users;
-- SELECT*FROM ORDERS WHERE statusId = 'DISPONIBLE' AND EDITORIALID = 1 AND SERVICEID = 'DISENO' AND SUBSERVICEID IS NULL
-- UPDATE ORDERS SET workerUserID = null, statusId = 'DISPONIBLE' WHERE id = 1;
-- call USP_GET_ORDER_STATUS_TOTALS (1, 'DISENO', 1);
-- SELECT*FROM ORDERS;
-- SELECT*FROM ORDER_STATUS;
-- select*from event_dates;
-- Ejemplos
-- CALL USP_ORDERS (1,'DISPONIBLE','DISENO',NULL,1,NULL,NULL,5);
-- CALL USP_GET_ORDER_STATUS_TOTALS(1,'ESCUCHA',NULL,1)
-- select*from orders where serviceid='CRITICA'
-- CALL USP_GET_ORDERS (1,'DISPONIBLE','CRITICA',NULL,1,NULL,NULL,5);
-- CALL USP_GET_ORDERS (1, 'DISPONIBLE', 'ESCUCHA', NULL, 1, NULL, NULL, 5);
-- SELECT*FROM ORDERS WHERE subserviceId <=> null;
-- CALL USP_GET_EDITORIAL_SERVICES_BY_EDITORIAL_MEMBER (2, 1, 0);
-- SELECT*FROM EDITORIAL_MEMBERS;
-- SELECT*FROM EDITORIAL_MEMBER_SERVICES;
-- SELECT*FROM SERVICES_BY_EDITORIAL;
-- select*from services;
-- select*from services_by_editorial;
-- CALL USP_GET_EDITORIAL_SERVICES(1,1);
-- CALL USP_GET_COMMENTS_BY_MAGAZINE_ALIAS('AMOR-EN-TIEMPOS-DE-PANDEMIA-2021-1-123456789',1,NULL);
-- CALL USP_GET_MAGAZINE_BY_ALIAS('AMOR-EN-TIEMPOS-DE-PANDEMIA-2021-1-123456789');
-- CALL USP_GET_MAGAZINES_BY_YEAR(2020);
-- CALL USP_CREATE_ORDER (NULL, NULL, 'Mila', 54, '987654321', 'WSP', 2, NULL, 1, 'CRITICA', NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, 'NORMAL', '{"modality":"LMD"}', NULL);
-- CALL USP_GET_MEMBERS_BY_EDITORIAL_SERVICE (1,'DISENO')
-- call usp_add_statistics (NULL, 'gricardov@gmail.com','FACEBOOK',NULL,NULL,'VER');
-- call USP_EXISTS_IN_INSCRIPTION(1 null, 'corazon@gmail.com');
-- CALL USP_SUBSCRIBE(NULL, 'Mila','g,ricardov@gmail.com',NULL, TRUE, NULL);
-- UPDATE MAGAZINES SET numComments = 23, numHearts = 12 where id = 2;
-- select * from comments where createdAt > '2021-08-07T16:05:56.000Z';
-- call USP_GET_USER_STATUS_BY_EMAIL('gricardov@gmail.com');
-- update orders set takenAt = '2021-09-02 05:31:02' expiresAt = '2021-09-05 05:31:02' where id = 1;
-- update users set active = 0 where email = 'gricardov@gmail.com';
SELECT*FROM EDITORIAL_MEMBER_SERVICES;
SELECT*FROM COMMENTS;
SELECT*FROM MAGAZINES;
SELECT*FROM EDITORIAL_MEMBER_SERVICES;
select*from services_by_editorial;
select*from actions_on_item;
SELECT*FROM ACTIONS_BY_USER_ON_ITEM;
select*from editorials;
select*from services;
select*from subservices;
select*from actions_by_user_on_item;
SELECT*FROM SUBSCRIBERS;
select*from event_dates;
SELECT*FROM USERS;
SELECT*FROM INSCRIPTIONS;
SELECT*FROM ORDERS;
select*from order_status;
select*from subscribers;
SELECT*FROM EVENTS;

-- USE TL_TEST;

-- update orders set expiresAt = '2021-08-31 23:40:52' where id = 1;
-- update orders set expiresAt = '2021-09-05 20:50:52' where id = 2;

-- INSERT INTO events VALUES (DEFAULT,'Evento 1',DEFAULT,'https://www.youtube.com/watch?v=cD2bQH8-pos&t=424s&ab_channel=Ra%C3%BAlValverde',DEFAULT,'["Objetivo1", "Objetivo2"]','["Beneficio1", "Beneficio2"]','["Tema1","Tema2"]',0,NULL,DEFAULT,DEFAULT,DEFAULT,DEFAULT,'Título del evento','Cuéntame que es de tu vida y trataré de quererte todavía',DEFAULT,DEFAULT,'[{"name":"Obras llevadas al teatro","link":{"name":"Leer aquí","href":"https://www.google.com"}}]','GRAN-TEXTO-GUION-TEXTO-Y-NOVELA-CCADENA-1',DEFAULT,DEFAULT,DEFAULT);

-- INSERT INTO EVENT_DATES VALUES (DEFAULT, 0000000001,NOW(),NOW(),DEFAULT,DEFAULT, DEFAULT, DEFAULT);