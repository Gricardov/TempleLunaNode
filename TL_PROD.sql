-- SET SQL_SAFE_UPDATES=0;

-- DROP DATABASE TL_PROD;

SET GLOBAL time_zone = '+00:00';
SET time_zone='+00:00';

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET CHARACTER_SET_SERVER = utf8mb4;
SET COLLATION_SERVER = utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS TL_PROD;

USE TL_PROD;

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
                ELSE BEGIN END;
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
                ELSE BEGIN END;
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
				ELSE BEGIN END;
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
				ELSE BEGIN END;
			END CASE;
        END;
		END IF;
    END IF;
END; //
DELIMITER ;

-- Procedimientos

-- Obtiene los suscriptores a la revista TL. Si el nombre es anónimo (TL_ANONYMOUS_HP), entonces que devuelva "artista" para que el usuario vea ese nombre
DROP PROCEDURE IF EXISTS USP_GET_MAGAZINE_SUBSCRIBERS;
DELIMITER //
CREATE PROCEDURE USP_GET_MAGAZINE_SUBSCRIBERS ()
BEGIN
SELECT
	CASE
		WHEN S.userId IS NULL THEN
			CASE
				WHEN S.names = 'TL_ANONYMOUS_HP' THEN 'artista'
			ELSE
				CONCAT(UCASE(LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(S.names, ' ', 1), ' ', -1), 1)),
				LCASE(SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(S.names, ' ', 1), ' ', -1), 2))) -- La primera letra siempre en mayúscula y las siguientes en minúscula, y solo extrae el primer nombre
			END
    ELSE
		(SELECT CONCAT(UCASE(LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(fName, ' ', 1), ' ', -1), ' ', 1), ' ', -1), 1)), 
				LCASE(SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(fName, ' ', 1), ' ', -1), ' ', 1), ' ', -1), 2))) -- La primera letra siempre en mayúscula y las siguientes en minúscula, y solo extrae el primer nombre
         FROM USERS WHERE id = S.userId LIMIT 1)
	END as name,
    S.email
FROM SUBSCRIBERS S WHERE magazine = 1;
END; //
DELIMITER ;

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
	SELECT id, contactEmail, fName, lName, followName, numFollowers, numComments, numHearts, urlProfileImg, about, networks, roleId, createdAt FROM USERS WHERE id = P_USER_ID AND active = 1;
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
    
    IF STATISTIC_ID IS NULL OR P_USER_ID IS NULL THEN -- Pregunto si P_USER_ID is null porque en el caso de estadísticas de COMPARTIR no es necesario que el usuario esté logueado (Puede ser null)
		BEGIN
			-- Insertar nuevo. La primera estadística de cada tipo, se supone que siempre tiene el estado active por DEFAULT, por eso no se pasa aquí
			INSERT INTO ACTIONS_BY_USER_ON_ITEM VALUES (DEFAULT, P_USER_ID, P_EMAIL, P_SOCIAL_NETWORK_NAME, P_ORDER_ID, P_MAGAZINE_ID, P_ACTION_ID, DEFAULT, DEFAULT, DEFAULT);
        END;
	ELSE
		BEGIN
			-- El único campo permitido para actualizarse tiene que ser active, para saber si esa reacción se quitó o se activo. Esto se hace para asegurarse de que cada acción es única
            UPDATE ACTIONS_BY_USER_ON_ITEM SET active = P_ACTIVE WHERE id = STATISTIC_ID;
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
	SELECT M.id, M.title, M.urlPortrait, M.numPag, M.edition, M.month, M.year, M.numHearts, M.numComments, M.numViews, M.numDownloads, M.numSubscribers, M.alias, E.id as editorialId, E.name as editorialName, E.bgColor as editorialBgColor, E.networks as editorialNetworks
    FROM MAGAZINES M
    JOIN EDITORIALS E
    ON M.editorialId = E.id
    WHERE M.active = 1 AND M.year = P_YEAR ORDER BY M.createdAt DESC;
END; //
DELIMITER ;

-- Para obtener una revista por alias. El parámetro P_USER_ID_FOR_ACTION puede ser null y solo sirve para ver si dicho usuario ha dejado una reacción en la revista (tabla ACTIONS_BY_USER_ON_ITEM)
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
    SELECT C.id, C.userId, CONCAT(U.fName, ' ', U.lName) as names, U.urlProfileImg as urlImg, C.content, C.createdAt FROM COMMENTS C
	JOIN USERS U
	ON U.id = C.userId
    WHERE C.id = LAST_INSERT_ID();
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

-- Obtiene datos PÚBLICOS de pedidos al azar. No obtiene ESCUCHA. Sirve para el home
DROP PROCEDURE IF EXISTS USP_GET_RANDOM_PUBLIC_ORDERS;
DELIMITER //
CREATE PROCEDURE USP_GET_RANDOM_PUBLIC_ORDERS (P_LIMIT INT)
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
LEFT JOIN `USERS` U -- Para que traiga todo, así los campos sean NULL
ON U.id = O.workerUserId
LEFT JOIN EDITORIALS E -- Para que traiga todo, así la editorial sea NULL
ON E.id = O.editorialId
WHERE O.statusId = 'HECHO'
AND O.serviceId != 'ESCUCHA'
GROUP BY O.id -- Que los ids no se repitan
ORDER BY RAND()
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
	O.statusId,
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
	O.statusId,
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

-- Inserciones para producción

-- Generales

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

INSERT INTO SERVICES_BY_EDITORIAL VALUES
(DEFAULT,1,'CRITICA',NULL,DEFAULT,'Servicio de críticas','Descripción del servicio',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0,0,DEFAULT,NULL,DEFAULT,DEFAULT),
(DEFAULT,1,'DISENO',NULL,DEFAULT,'Servicio de diseño','Descripción del servicio',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0,0,DEFAULT,NULL,DEFAULT,DEFAULT),
(DEFAULT,1,'DISENO','BAN',DEFAULT,'Servicio de diseño','Descripción del servicio',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0,0,DEFAULT,NULL,DEFAULT,DEFAULT),
(DEFAULT,1,'DISENO','POR',DEFAULT,'Servicio de diseño','Descripción del servicio',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0,0,DEFAULT,NULL,DEFAULT,DEFAULT),
(DEFAULT,1,'ESCUCHA',NULL,DEFAULT,'Servicio de escucha','Descripción del servicio',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,0,0,DEFAULT,NULL,DEFAULT,DEFAULT);

INSERT INTO USERS VALUES (1,'gricardov@gmail.com',1,'gricardov@templeluna.app','Giovanni','Ricardo',NULL,'+51999999999',NULL,'Corazón de melón','corazondemelon',DEFAULT,DEFAULT,DEFAULT,'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Flindo.jpg?alt=media&token=177bb113-efb9-4e15-9291-743a525a2420',DEFAULT,DEFAULT,'["https://www.facebook.com/gricardov/", "https://www.instagram.com/", "https://www.instagram.com/gricardov/"]','ADMIN',DEFAULT,DEFAULT,DEFAULT);

INSERT INTO EDITORIAL_MEMBERS VALUES 
(1, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(1, 1, 'ESCUCHA', NULL, 'Artista', 1);
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(1, 1, 'CRITICA', NULL, 'Artista', 1);
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(1, 1, 'DISENO', NULL, 'Artista', 1);

-- Desde firebase

INSERT INTO USERS VALUES 
(49, 'escritos.oswaldo.ortiz@gmail.com', 1, 'escritos.oswaldo.ortiz@gmail.com', 'Ángel', 'Ortiz', NULL, NULL, NULL, NULL, 'OswaldoOrtiz', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fchamo.jpg?alt=media&token=468f6551-b903-4223-b647-c5cc892039d8', DEFAULT, DEFAULT, '["instagram.com/escritos_ortiz","https://www.wattpad.com/user/oswald85"]', 'COLAB', 1, DEFAULT, DEFAULT),
(50, 'sayrabaylon41@gmail.com', 1, 'sayrabaylon41@gmail.com', 'Sayra', 'Baylon', NULL, NULL, NULL, NULL, 'SayraBaylon', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fsayrih.jpg?alt=media&token=6a770c21-f3c9-475b-ae03-8423f1876c45', DEFAULT, DEFAULT, '["https://instagram.com/sayrabaylon_2321","https://www.wattpad.com/user/SayraBaylon"]', 'COLAB', 1, DEFAULT, DEFAULT),
(51, 'irisadk94@gmail.com', 1, 'irisadk94@gmail.com', 'Erendira', 'León', NULL, NULL, NULL, NULL, 'ErendiraLeon', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Ferendira.jpg?alt=media&token=5c35bb61-131c-4d8b-a9dc-79958ed273d0', DEFAULT, DEFAULT, '["https://instagram.com/irisadk94","https://iristomandoelcontrol.blogspot.com/","http://www.tusrelatos.com/autores/pajarita-enamorada"]', 'COLAB', 1, DEFAULT, DEFAULT),
(52, 'miadurant4@gmail.com', 1, 'miadurant4@gmail.com', 'Mia', 'Victoria', NULL, NULL, NULL, NULL, 'MiaDurant4', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fmia.jpg?alt=media&token=c2da3ac5-18f4-4967-9c20-e01374e5fe03', DEFAULT, DEFAULT, '["https://instagram.com/gianna_g.durant_l.04","https://www.wattpad.com/user/Gianna04G02DL"]', 'COLAB', 1, DEFAULT, DEFAULT),
(53, 'mila_enorriz_luna@tfbnw.net', 0, 'mila_enorriz_luna@tfbnw.net', 'Nuevo', 'Usuario', NULL, NULL, NULL, NULL, 'followName53', 0, 0, 0, '', DEFAULT, DEFAULT, '[]', 'COLAB', 1, DEFAULT, DEFAULT),
(54, 'marimercado922@gmail.com', 1, 'marimercado922@gmail.com', 'Maria', 'Mercado', NULL, NULL, NULL, NULL, 'PrincesaDeFresa', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fmarim1.jpg?alt=media&token=692c003a-17cf-4825-9f76-15c3c09a0f7f', DEFAULT, DEFAULT, '["instagram.com/marimer.25","https://www.wattpad.com/user/MariMercado8"]', 'COLAB', 1, DEFAULT, DEFAULT),
(55, 'marthariveraantequera@outlook.com', 1, 'marthariveraantequera@outlook.com', 'Martha', 'Rivera', NULL, NULL, NULL, NULL, 'MarthaRivera', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fmartharivera.jpg?alt=media&token=4a0289d4-5d4b-4fd6-a288-3ae4f261cbc7', DEFAULT, DEFAULT, '["https://www.instagram.com/lrservicioseditoriales","https://www.fiverr.com/lrserviciosedit/correccion-edicion-y-maquetacion","https://linktr.ee/mlbradleyescritora"]', 'COLAB', 1, DEFAULT, DEFAULT),
(56, 'lacarodelreal@gmail.com', 1, 'lacarodelreal@gmail.com', 'Carolina', 'Morales', NULL, NULL, NULL, NULL, 'LaCaroDelReal', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fcaro.jpg?alt=media&token=329c34cd-ca44-41f1-9355-37084d0dd0e5', DEFAULT, DEFAULT, '["https://instagram.com/carodepenarol","https://www.wattpad.com/user/CaroDePearolMorales"]', 'COLAB', 1, DEFAULT, DEFAULT),
(57, 'templelunalye@gmail.com', 1, 'templelunalye@gmail.com', 'Nuevo', 'Usuario', NULL, NULL, NULL, NULL, 'followName57', 0, 0, 0, '', DEFAULT, DEFAULT, '[]', 'COLAB', 1, DEFAULT, DEFAULT),
(58, 'natalyacalderonh@gmail.com', 1, 'natalyacalderonh@gmail.com', 'Nataly', 'Calderón', NULL, NULL, NULL, NULL, 'NatalyCalderonH', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fnataly.jpg?alt=media&token=2c8c19ab-0b00-4e7f-b657-6f3ac0b0d674', DEFAULT, DEFAULT, '["https://instagram.com/soytatyautor/"]', 'COLAB', 1, DEFAULT, DEFAULT),
(59, 'siranaulavaleria@gmail.com', 1, 'siranaulavaleria@gmail.com', 'Valeria', 'Siranaula', NULL, NULL, NULL, NULL, 'ValeriaSiranaula', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fvalesina.jpg?alt=media&token=0ac8e523-972b-490f-9061-68d289f7e0f9', DEFAULT, DEFAULT, '["https://www.instagram.com/vale.designs/","https://twitter.com/ValeSiranaula"]', 'COLAB', 1, DEFAULT, DEFAULT),
(60, 'zariuxluna@gmail.com', 1, 'zariuxluna@gmail.com', 'Zariux', 'Luna', NULL, NULL, NULL, NULL, 'ZariuxLuna', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fzariux.jpg?alt=media&token=16e2777e-e149-4cd3-baaf-84600116cbdc', DEFAULT, DEFAULT, '["https://instagram.com/zariux_luna/","https://www.zariuxluna.com/","https://www.wattpad.com/user/ZariuxLuna","https://www.facebook.com/cronicasdelunita"]', 'COLAB', 1, DEFAULT, DEFAULT),
(61, 'dani.rod.2402@gmail.com', 1, 'dani.rod.2402@gmail.com', 'Daniel', 'Rodriguez', NULL, NULL, NULL, NULL, 'DanielRodriguez', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fdanielrodriguez.jpg?alt=media&token=699ebe7d-35d6-4480-8a3f-8beff3177b7b', DEFAULT, DEFAULT, '["https://www.instagram.com/Bo.ok_addicts/","https://www.facebook.com/elvisdaniel.rodriguezmorillo.3"]', 'COLAB', 1, DEFAULT, DEFAULT),
(62, 'zhazirt123@gmail.com', 1, 'zhazirt123@gmail.com', 'Zhazirt', 'Flores', NULL, NULL, NULL, NULL, 'ZhazirtFlores', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fzhazirt.jpg?alt=media&token=6b0bf0b7-1189-4cab-818a-a725d6f09d47', DEFAULT, DEFAULT, '["https://jackdreamer99.blogspot.com/","https://www.wattpad.com/user/zhazirt"]', 'COLAB', 1, DEFAULT, DEFAULT),
(63, 'zulpecristo@gmail.com', 1, 'zulpecristo@gmail.com', 'Luz', 'Cespedes', NULL, NULL, NULL, NULL, 'LuzCespedesMartinez', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fluz.jpg?alt=media&token=4314d1f6-7660-40b4-8eb6-054d7fc729d4', DEFAULT, DEFAULT, '["https://instagram.com/luzcespedesmartinez/"]', 'COLAB', 1, DEFAULT, DEFAULT),
(64, 'feelingss.023@gmail.com', 1, 'feelingss.023@gmail.com', 'Pilar', 'Melgarejo', NULL, NULL, NULL, NULL, 'Pilyy', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fcrushhh.jpg?alt=media&token=251f510a-71a5-46a3-a746-165d07f96c64', DEFAULT, DEFAULT, '["https://www.facebook.com/PiccoloScrittore26 ","https://www.wattpad.com/user/PiccolaScrittrice17","https://www.wattpad.com/user/PiccolaScrittrice23"]', 'COLAB', 1, DEFAULT, DEFAULT),
(65, 'academiatemple@gmail.com', 1, 'academiatemple@gmail.com', 'Nuevo', 'Usuario', NULL, NULL, NULL, NULL, 'followName65', 0, 0, 0, '', DEFAULT, DEFAULT, '[]', 'COLAB', 1, DEFAULT, DEFAULT),
(66, 'reds.words@outlook.es', 1, 'reds.words@outlook.es', 'Redin', 'Mendez', NULL, NULL, NULL, NULL, 'RedsLetters', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fredinmendez2.jpg?alt=media&token=c68806eb-bf73-4c3f-9a43-94a9b0c02ac5', DEFAULT, DEFAULT, '["https://www.instagram.com/reds.letters/","https://www.facebook.com/reds.letters"]', 'COLAB', 1, DEFAULT, DEFAULT),
(67, 'efrainapazabustamante@gmail.com', 1, 'efrainapazabustamante@gmail.com', 'Ricardo', 'Apaza', NULL, NULL, NULL, NULL, 'Chamo', 0, 0, 0, 'undefined', DEFAULT, DEFAULT, '["https://instagram.com/ricardoab0","https://www.wattpad.com/user/RickRock02"]', 'COLAB', 1, DEFAULT, DEFAULT),
(68, 'monica.ruiz@nauta.cu', 0, 'monica.ruiz@nauta.cu', 'Amanda', 'Torres', NULL, NULL, NULL, NULL, 'Morena', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Famanda.jpg?alt=media&token=6fed5baf-c4f9-4799-b2b9-f448d3b55b6e', DEFAULT, DEFAULT, '["https://www.wattpad.com/user/Titania2408"]', 'COLAB', 1, DEFAULT, DEFAULT);


INSERT INTO EDITORIAL_MEMBERS VALUES 
(49, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(50, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(51, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(52, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(53, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(54, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(55, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(56, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(57, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(58, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(59, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(60, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(61, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(62, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(63, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(64, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(65, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(66, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(67, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(68, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(49, 1, 'CRITICA', NULL, 'Artista', 1),
(50, 1, 'CRITICA', NULL, 'Artista', 1),
(50, 1, 'CORRECCION', NULL, 'Artista', 1),
(51, 1, 'CRITICA', NULL, 'Artista', 1),
(52, 1, 'DISENO', NULL, 'Artista', 1),
(54, 1, 'CORRECCION', NULL, 'Artista', 1),
(54, 1, 'CRITICA', NULL, 'Artista', 1),
(55, 1, 'CRITICA', NULL, 'Artista', 1),
(55, 1, 'DISENO', NULL, 'Artista', 1),
(56, 1, 'CRITICA', NULL, 'Artista', 1),
(56, 1, 'CORRECCION', NULL, 'Artista', 1),
(58, 1, 'CRITICA', NULL, 'Artista', 1),
(59, 1, 'DISENO', NULL, 'Artista', 1),
(60, 1, 'CRITICA', NULL, 'Artista', 1),
(60, 1, 'CORRECCION', NULL, 'Artista', 1),
(61, 1, 'DISENO', NULL, 'Artista', 1),
(62, 1, 'CRITICA', NULL, 'Artista', 1),
(63, 1, 'CRITICA', NULL, 'Artista', 1),
(64, 1, 'CRITICA', NULL, 'Artista', 1),
(64, 1, 'CORRECCION', NULL, 'Artista', 1),
(66, 1, 'CRITICA', NULL, 'Artista', 1),
(66, 1, 'DISENO', NULL, 'Artista', 1),
(67, 1, 'CORRECCION', NULL, 'Artista', 1),
(68, 1, 'CRITICA', NULL, 'Artista', 1);

-- Temporales para iniciar
INSERT INTO EVENTS VALUES
(1,
'Gran inauguración de Temple Luna',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/miscelanea%2FTemple%20Luna.png?alt=media&token=33f2e8c4-b35e-47d7-8435-e7965b104750',
'',
'["Amar la lectura y la escritura"]',
'["Asistir a la inauguración de la plataforma Temple Luna"]',
'["Podrás ser el primero en disfrutar los beneficios de la plataforma"]',
'["Inauguración"]',
0,
NULL,
'Google Meets',
NULL,
NULL,
NULL,
'Gran inauguración de Temple Luna',
'¡Bienvenido(a)! Asiste y podrás ser parte de la gran iniciativa Temple Luna, que busca acerca los mejores servicios a lectores y escritores',
'10 inscritos como mínimo',
NULL,
NULL,
NULL,
'GRAN-INAUGURACION-TEMPLE-LUNA-2021',
'https://chat.whatsapp.com/Gxm48ky5Ein9qwkK7FkAC7',
DEFAULT,
DEFAULT,
DEFAULT
);

INSERT INTO EVENT_DATES VALUES
(DEFAULT, 1, '2021-10-09 01:00:00','2021-10-09 02:00:00', 0, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO INSTRUCTORS_BY_EVENT VALUES
(DEFAULT, 1, 1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Creador y fundador de Temple Luna',NULL,NULL,NULL,DEFAULT,DEFAULT);

INSERT INTO MAGAZINES VALUES 
(DEFAULT,
'Amor en tiempos de pandemia',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Fpreview-revista-1.PNG?alt=media&token=1a8fcf71-afc2-4d77-b8d1-d9b58e6d7950',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FRevista-TL-1_compressed.pdf?alt=media&token=f6e957ab-0361-4913-81b8-4c8f792135fa',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FTL1JPG.pdf?alt=media&token=940b3eb9-7187-4d5d-bb6d-525b45282c7b',
22,
1,
10,
2021,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'AMOR-EN-TIEMPOS-DE-PANDEMIA-1-2021',
DEFAULT, -- activo
DEFAULT,
DEFAULT
);

-- 11/10/2021: Inserción del evento de la tertulia

INSERT INTO EVENTS VALUES
(2,
'La gran tertulia literaria',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/eventos%2Ffondo-grupo-la-tertulia.png?alt=media&token=6e44f2e4-fab6-4ec0-b8f4-cfeddf5ee29b',
'',
'["Amar la lectura y/o escritura", "Interactuar con otros miembros de la comunidad", "Participar de las reuniones semanales"]',
'["Conocer obras nuevas", "Conocer de cerca nuevos autores", "Debatir ideas literarias"]',
'["Expandir conocimientos del mundo literario por medio de la comunidad"]',
'["Los temas son variables y se proponen cada semana en el grupo"]',
0,
NULL,
'Google Meets',
NULL,
NULL,
NULL,
'La gran tertulia literaria',
'¡Bienvenido(a)! Si te interesa hablar sobre obras y amas escuchar autores nuevos, este es tu lugar. Te invitamos a este grupo de tertulia literaria. Nos unimos todos los sábados de 9pm a 11pm (Hora Colombia - Lima) para aprender y debatir. ¡Te encantará!',
'20 inscritos como mínimo',
NULL,
NULL,
NULL,
'LA-GRAN-TERTULIA-LITERARIA-WMUNIZ-2021',
'https://chat.whatsapp.com/FCU0DzPxGtw8AdoFxVRbJt',
DEFAULT,
DEFAULT,
DEFAULT
);

INSERT INTO EVENT_DATES VALUES
(DEFAULT, 2, '2021-11-14 02:00:00','2021-11-14 04:00:00', 1, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO INSTRUCTORS_BY_EVENT VALUES
(DEFAULT, 2, NULL,'Wilfrido','Muniz',NULL,NULL,NULL,NULL,'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fwilfrido3.jpg?alt=media&token=c6938927-c784-49d2-9999-cb878c20dd0d','Periodista y autor literario',NULL,NULL,NULL,DEFAULT,DEFAULT);

-- 12/10/2021: Asignación de roles de escucha a Pilar, Maria Belén y Mauro, previa agregación a la editorial para los dos últimos. Eliminación del servicio de escucha para mí (userId=1)

-- Me elimino del servicio de escucha
DELETE FROM EDITORIAL_MEMBER_SERVICES WHERE serviceId = 'ESCUCHA' AND userId = 1;

-- Actualizo los roles de Mauro y Maria Belés
UPDATE USERS SET roleId = 'COLAB' WHERE id = 71 OR id = 87;

-- Agrego a Mauro y Mía Belés a la editorial Temple Luna
INSERT INTO EDITORIAL_MEMBERS VALUES 
(71, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(87, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

-- Les asigno el rol a todos
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(71, 1, 'ESCUCHA', NULL, 'Artista', 1);
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(87, 1, 'ESCUCHA', NULL, 'Artista', 1);
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(64, 1, 'ESCUCHA', NULL, 'Artista', 1);

-- Actualizo la foto de Mia
UPDATE USERS SET urlProfileImg = 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fmia-belen.jpg?alt=media&token=529bf739-66ec-4ffa-85cc-b098fda1f675' WHERE id = 87;
UPDATE USERS SET about = 'Tec. Profesional en literatura, guión, y teatro.\nPsicóloga psiquiatría en temas:\n\n- Trastorno depresivo\n- Crisis\n- Bloqueo mental en escritores\n- Escritores en proceso, e independientes.' WHERE id = 87;

-- Actualizo la disponibilidad de Mía
UPDATE EDITORIAL_MEMBERS SET availability = 'Miércoles en toda la mañana y fines de semana de 1-4pm (Hora Colombia - Lima)' WHERE userId = 87;

-- Actualizo las redes de Pilyy
UPDATE USERS SET networks='["https://www.facebook.com/Pily.135","https://www.wattpad.com/user/PiccolaScrittrice230","https://www.wattpad.com/user/PiccolaScrittrice23"]' WHERE id = 64;

-- Inserto las suscripciones a 12-10-2021
INSERT INTO SUBSCRIBERS VALUES 
(DEFAULT, NULL, 1, 1, 1, 'Manuel Pereira ', 'manucho1024mbungb@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Luis Orozco', 'luisorozco.lde@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Sagk Bautista ', 'sacgbautista@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Eva Maria', 'eva271992@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Trisha Sanz', 'escritoraenlasmilyunalunas@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 0, 1, 1, 'Sergio A. Amaya Santamaría ', 'sergioamaysas@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'José Alberto Nápoles Torres', 'napolesjosealberto@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 0, 'Marie Chavier ', 'mariechavier13@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Fernando ', 'ferjosza21@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Mar', 'virginialezcano980@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Katherine Marin', 'namkathe99@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Isabel ', 'mariaisabelchacon9@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Yorman', 'yorm.dar@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Edgar Sánchez ', 'edgarsahdz@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jorge Berganza ', 'jorgeberganza13.com@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Francisco Alvarado', 'javatre57@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Mariel', 'losocy_857@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Benito ', 'benycamacho8@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'hector', 'hmontesc65@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 0, 0, 'Carla', 'paz303229@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ada ', 'adaescalante@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Hector Nila', 'dulcinea6607@yahoo.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Juan Carlos ', 'juankjcag@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Melina Paccini', 'melinapaccini@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Constanza antonia ', 'fritisconstanza86@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Olo Waypiler', 'oloway07@gmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Iliana', 'ilianazapico1103@gmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Sagk Bautista ', 'sacgbautista@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Roxana', 'roxycanteros@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Yarelly Ramos ', 'yarellyramosgonzalez@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Eva', 'evagiraldo33@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Kris Buendia ', 'krisbuendia.autora@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Silvia', 'bersata@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Miguel', 'msaints.fff@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Laczuly', 'laydyalejandra@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Arnoldo', 'publiccoloroionca@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Victoria ', 'Victoriavalon@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 0, 1, 1, 'Carlos Rodriguez', 'youtevi123@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Nelson', 'nelsoncarvajalgomez@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Liliana Martínez', 'liliana2068@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Paulina', 'pauline_dozar@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Pilar Cerón Durán ', 'pilarceronduran@yahoo.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'sheila', 'sheilamoya74@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Tyler', 'ty2020king@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'maria mercado ', 'marimercado922@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Solange', 'solesimon@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jhorgelis Chacón Díaz ', 'Jhorgelischacon0712@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ricardo Gustavo Espeja', 'rgespeja1950@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 0, 1, 'Christian Rios', 'christianriossifuentes@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Beatriz', 'bessi.puertas@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 0, 'Brenda Soraya Lopez', 'brendalopez070981@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Zero', 'joseyaoo123@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Veronica', 'veronica.l.vignolo@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Rosa Hernández', 'kimalezi95@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jeison Eulacio', 'yeisoneulacio28@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Nelson Gutiérrez', 'nelsongrr2018@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Daisy', 'Daisuidlv@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Iriel cuello', 'irielanahicuello@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Daniela', 'danielaandreaellesmartinez@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Brianne López Sánchez ', 'skipi0625@yahoo.com.mx', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ivelisse Esquilin', 'ivyesquilin@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 0, 'Melissa Falco', 'naypasede@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Montserrath', 'ramirezacostakarinamontserrath@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Zhazirt ', 'zhazirt123@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'DAN', 'daercimi@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ania Tamas', 'amy.tamas15@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Biosneidy Bereguete Mendoza', 'biosneidy23@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ramon Abel Salazar monreal', 'ramonabelsalazar@11gomail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Isidoro García Cruz', 'isidorogc.igc@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Karma', 'karma.libros.0103@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Celia', 'celiagarciagil25@gmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Trisha Sanz', 'escritoraenlasmilyunalunas@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Eugenia', 'eugenia.roman@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Pedro Villahermosa', 'villahermosapedro69@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Caro Morales', 'lacarodelreal@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Mauricio Vega Vivas', 'mauriciovega@prodigy.met.mx', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ayden Atwood ', 'princesa.solitaria85@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Pilarica', 'pilaricasi@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Manuel Antón Mosteiro García', 'bateledicions@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Noemí', 'noemigisbertnadal@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jairo', 'jairo.currea@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Fabián Amir Ortíz ', 'famiro14@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Rebeca Vazquez Galaviz', 'garebebi.1104@gmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Trisha Sanz', 'escritoraenlasmilyunalunas@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Cindy Caicedo ', 'cindyjohannacc@gmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Efraín', 'efrainapazabustamante@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 0, 1, 1, 'Marco Antonio Román Encinas', 'mromane@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Darío Valenzuela', 'alberto_valenzuela2001@yahoo.com.ar', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Silvia', 'chivitagon35@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Dariam', 'darvingjosuer@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Luis Rízolo', 'luisrizolo@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Julieta', 'pekemichelena@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Amanda Torres', 'monica.ruiz@nauta.cu', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Camones Rondan Yulhiño Sisley', 'Ycamonesrondan@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Marcelo', 'marcelosolis_2000@yahoo.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Alejandro Eduardo Klappenbach', 'aleklapen62@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Vanessa', 'vanessalopez21254@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Susana Zenteno Jurado', 'moralrsmorales@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Yeraldin', 'geraltaborda40@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Manuel Antón Mosteiro García', 'mamosteiro@hotmail.es', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Diana Flores ', 'dianitaflores854@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 0, 1, 1, 'Rivka', 'rivkaplotnikova28@hotmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Iliana', 'ilianazapico1103@gmail.com', 1, DEFAULT, DEFAULT),
-- (DEFAULT, NULL, 1, 1, 1, 'Joselin', 'centenojt29@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Enver Bazante', 'ggermanb@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 0, 1, 'Ruis coy', 'ruiscoy@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Andrea', 'andrealmarenco@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Danna Quiroz', 'dannapaola61863@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Sandra Jaimes', 'sandra.jaimes.celis@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Nataly', 'natalyacalderonh@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Rashel ', 'Rashelgarcia03@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Joselin', 'centenojt29@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Luis Gustavo', 'mulatillovasquezluis2@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Elena', 'elenaacaro31@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Nicole Zevallos Alarcon', 'nicole.zevallos@ucsp.edu.pe', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Juanrobertoautor ', 'juanelmanu@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Dayana ', 'anchitipandayana1@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Susana Vaca Fuentes ', 'licsue@yahoo.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jeyr', 'jackofeelins@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Marcelo León Jara', 'mleon369@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'An', 'anescribes@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Silvia Ester mamani', 'roderojas11@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 0, 1, 1, 'Manuel Silva ', 'xenophilo1@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Nelly Mendoza Sánchez ', 'enead5@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Carlos Valdés', 'Pubyco@yahoo.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Samuel Molina', 'ss97lgdlv@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Martín Madín', 'martinmadinramirez1986.7@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Angélica ', 'angelica2609@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Lucas Puentes Vilchis', 'lucas.puentes@plastiglas.com.mx', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Martín Bisio', 'mbisio@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Victoria Pikholc', 'sabrinagarlic@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'So Van de Langerberg ', 'NoVgs3697@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Alexa', 'vacationstelephone@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'josue', 'josuevalentramijac@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ernesto Lópz', 'erlovi31@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ana', 'alianita201@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Rivera', 'rdgzccs@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Alyah Fulgencio', 'fulgencioalyah2004@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Maria', 'merodriguezvalentin@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Paula', 'paulacuelli@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Karla Yazmin', 'heryourself01997@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Llany', 'Jhany0904@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Neisy Alvarez', 'alvarezneisy106@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'ID Loría', 'dianaloria08@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'MIGUEL ANGEL DURAND MELGAREJO', 'mig6209@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Myrian Silva', 'sillvamyrian9@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Fernando baena Vejarano', 'ferbaena7@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Mar', 'marcela.valdesdostres@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Santiago Vega', 'bookgamecorporation@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Ricarda Pantoja', 'laaldeademoco@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Fernanda Ramos ', 'susan_mare@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jarlin Mejía ', 'jarlinyaelm@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Guillermo Alfaro Morera ', 'alfaromorera1965@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Geovanny', 'geoalfchaconromerom@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Eliseo García Martínez', 'garciaeliseo75@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Katherin', 'katherinalvaradoespinosa@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Liliana', 'lilianadelrossoescritora@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Melody Domínguez ', 'gdmngz1828@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Yazmin venegas ', 'venegasjazz@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'José Manuel Valdez', 'jmvldz@hotmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Carlos Montaño ', 'montanocarlos@gmail.com', 1, DEFAULT, DEFAULT),
(DEFAULT, NULL, 1, 1, 1, 'Jennifer', 'jennifergarrigosmartinez1232@gmail.com', 1, DEFAULT, DEFAULT);

-- Actualizo el nombre de un suscriptor
UPDATE SUBSCRIBERS SET names = 'Alyoh', courses = 1 where id = 2;

-- Actualizo el rol de Fanni
UPDATE USERS SET roleId = 'COLAB' WHERE id = 96;

-- Agrego a Fanny a la editorial Temple Luna
INSERT INTO EDITORIAL_MEMBERS VALUES 
(96, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

-- Les asigno el rol a Fanny
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(96, 1, 'CRITICA', NULL, 'Artista', 1);

-- Actualizo el perfil de Fanny
UPDATE USERS SET about = 'Mi nombre es Fanny y soy de Argentina. La lectura en conjunto a la escritura siempre estuvieron presentes en mi vida.', phone = '+543884160540', networks = '["https://www.wattpad.com/user/MyPrincess-105","https://www.instagram.com/camposfanni/"]', urlProfileImg = 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Ffanni.jpg?alt=media&token=3097badc-ae33-471d-a865-4c4fc24e51ba' WHERE id = 96;

-- Actualizo el rol de Patty
UPDATE USERS SET roleId = 'COLAB' WHERE id = 97;

-- Agrego a Patty a la editorial Temple Luna
INSERT INTO EDITORIAL_MEMBERS VALUES 
(97, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

-- Les asigno el rol a Patty
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(97, 1, 'CRITICA', NULL, 'Artista', 1),
(97, 1, 'DISENO', NULL, 'Artista', 1);

-- Actualizo el perfil de Patty
UPDATE USERS SET about = 'Me llamo agueda, me encanta la lectura, el dibujo y la música, me gusta ayudar a los demás', phone = '', networks = '["https://www.wattpad.com/user/sofoifa","https://www.tiktok.com/@a_sofoifa_?","https://www.instagram.com/agued.ad/"]', urlProfileImg = 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fagueda.jpg?alt=media&token=ddfd847e-e150-4b22-a77d-1ae9616cf619' WHERE id = 97;

-- Inserto los nuevos subservicios
INSERT INTO SUBSERVICES VALUES
('CR', 'DISENO','Cuenta regresiva'),
('BAN-WSP','DISENO','Estado de Whatsapp'),
('BAN-FB','DISENO','Banner para Facebook'),
('BAN-INS','DISENO','Banner para Instagram'),
('BAN-WTT','DISENO','Banner para Wattpad');

-- Migro los usuarios necesarios para mostrar los pedidos de la versión anterior
INSERT INTO USERS VALUES
(102, 'mati.alkaid26@gmail.com', 1, 'mati.alkaid26@gmail.com', 'Karen', 'Heredia', NULL, NULL, NULL, NULL, 'Alkaiid', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/Alkaiid"]', 'COLAB', 1, DEFAULT, DEFAULT),
(103, 'albertowritter@gmail.com', 1, 'albertowritter@gmail.com', 'Alberto', 'Cedillo', NULL, NULL, NULL, NULL, 'followName103', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["twitter.com/AlphaPhantom6","https://www.wattpad.com/user/AlphaPhantom16"]', 'COLAB', 1, DEFAULT, DEFAULT),
(104, 'gqmafe2@gmail.com', 0, 'gqmafe2@gmail.com', 'Fernanda', 'Guerrero', NULL, NULL, NULL, NULL, 'followName104', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/deavolatil","https://www.wattpad.com/user/madredemonstruos"]', 'COLAB', 1, DEFAULT, DEFAULT),
(105, 'taisarteaga.c@gmail.com', 1, 'taisarteaga.c@gmail.com', 'Tais', 'Arteaga', NULL, NULL, NULL, NULL, 'followName105', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/.taiiiss.","https://www.wattpad.com/user/VanilleMorgan"]', 'COLAB', 1, DEFAULT, DEFAULT),
(106, 'mariafernandabutten@gmail.com', 1, 'mariafernandabutten@gmail.com', 'Maria', 'Javier', NULL, NULL, NULL, NULL, 'MariaButten', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fmariabutten.jpg?alt=media&token=8458265d-d9e0-4bdb-81ce-bf8c7e2429d5', DEFAULT, DEFAULT, '["https://instagram.com/MarafernandaB3","https://www.wattpad.com/user/MaraFernandaB"]', 'COLAB', 1, DEFAULT, DEFAULT),    
(107, 'ositalectora1@gmail.com', 1, 'ositalectora1@gmail.com', 'Fernanda', 'Aristizábal', NULL, NULL, NULL, NULL, 'followName107', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/ositalectora1"]', 'COLAB', 1, DEFAULT, DEFAULT),
(108, 'micamedina015@gmail.com', 1, 'micamedina015@gmail.com', 'Micaela', 'Medina', NULL, NULL, NULL, NULL, 'followName108', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/micam_18","https://www.wattpad.com/user/micam_018"]', 'COLAB', 1, DEFAULT, DEFAULT),
(109, 'taitomanx@gmail.com', 0, 'taitomanx@gmail.com', 'Daniel', 'Sánchez', NULL, NULL, NULL, NULL, 'followName109', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://twitter.com/danielevilps4","https://www.wattpad.com/user/Taitoman85"]', 'COLAB', 1, DEFAULT, DEFAULT),
(110, 'melanyportilla@hotmail.com', 1, 'melanyportilla@hotmail.com', 'Melanie', 'Portilla', NULL, NULL, NULL, NULL, 'followName110', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/wattpad_en_las_sombras","instagram.com/lanie_16p","https://www.wattpad.com/user/AgapiVell"]', 'COLAB', 1, DEFAULT, DEFAULT),
(111, 'viyulieth@gmail.com', 1, 'viyulieth@gmail.com', 'Viviana', 'Miranda', NULL, NULL, NULL, NULL, 'followName111', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.facebook.com/viviana.landron"]', 'COLAB', 1, DEFAULT, DEFAULT),
(112, 'marylundhautor@gmail.com', 1, 'marylundhautor@gmail.com', 'Mary', 'Lundh', NULL, NULL, NULL, NULL, 'MaryLundh', 0, 0, 0, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/perfil%2Fmarylundh.jpg?alt=media&token=ceb94b45-8c72-4c47-8b20-e3121be00fd8', DEFAULT, DEFAULT, '["https://instagram.com/marylundhautor/","https://www.wattpad.com/user/maryLundhautor"]', 'COLAB', 1, DEFAULT, DEFAULT),
(113, 'fannyamador26@gmail.com', 1, 'fannyamador26@gmail.com', 'Fanny', 'Amador', NULL, NULL, NULL, NULL, 'followName113', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/Leycar_Beltran"]', 'COLAB', 1, DEFAULT, DEFAULT),
(114, 'jenny_aline_d@hotmail.com', 1, 'jenny_aline_d@hotmail.com', 'Jennifer', 'Aline', NULL, NULL, NULL, NULL, 'JennyAline', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/Jenny_Aline"]', 'COLAB', 1, DEFAULT, DEFAULT),
(115, 'julilorenzi0508@gmail.com', 1, 'julilorenzi0508@gmail.com', 'Juli', 'Lorenzi', NULL, NULL, NULL, NULL, 'followName115', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/Julyan666"]', 'COLAB', 1, DEFAULT, DEFAULT),
(116, 'elf_morgana@hotmail.com', 1, 'elf_morgana@hotmail.com', 'Kristopher', 'Nuñez', NULL, NULL, NULL, NULL, 'Morgana', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/TristeMancebo"]', 'COLAB', 1, DEFAULT, DEFAULT),
(117, 'cccadena@gmail.com', 1, 'cccadena@gmail.com', 'Carlos', 'Cadena', NULL, NULL, NULL, NULL, 'followName117', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.facebook.com/LosDemoniosDetrasDeLaPared/","https://www.wattpad.com/user/CarlosAlbertoCadenaG","instagram.com/cccadena"]', 'COLAB', 1, DEFAULT, DEFAULT),
(118, 'andreamishelg@gmail.com', 1, 'andreamishelg@gmail.com', 'Andrea', 'Gonzáles', NULL, NULL, NULL, NULL, 'followName118', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/andreagonzalez667","https://www.wattpad.com/user/agonzalez11"]', 'COLAB', 1, DEFAULT, DEFAULT),
(119, 'abimendieta1@gmail.com', 1, 'abimendieta1@gmail.com', 'Abigail', 'Mendieta', NULL, NULL, NULL, NULL, 'followName119', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/AbigailMendieta7"]', 'COLAB', 1, DEFAULT, DEFAULT),
(120, 'isabellapanqueca28@gmail.com', 1, 'isabellapanqueca28@gmail.com', 'Isabela', 'Alvarez', NULL, NULL, NULL, NULL, 'followName120', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/marbela_alv"]', 'COLAB', 1, DEFAULT, DEFAULT),
(121, 'soeri3008@gmail.com', 1, 'soeri3008@gmail.com', 'Evelyn', 'Monreal', NULL, NULL, NULL, NULL, 'followName121', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/soeri_draw","https://www.facebook.com/soeri3008"]', 'COLAB', 1, DEFAULT, DEFAULT),
(122, 'joysostermann@gmail.com', 1, 'joysostermann@gmail.com', 'Joys', 'Ostermann', NULL, NULL, NULL, NULL, 'followName122', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/p/CNcvEMZnNu0/","https://lagrimassolitarias.blogspot.com","https://youtube.com/channel/UCgxz6ngoNmkcYYOiylJZgBQ","https://vm.tiktok.com/ZMemwWRay/"]', 'COLAB', 1, DEFAULT, DEFAULT),
(123, 'luis.hernandez3@outlook.com', 0, 'luis.hernandez3@outlook.com', 'Eduardo', 'Hernandez', NULL, NULL, NULL, NULL, 'followName123', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["http://instagram.com/todooidoalconsciente","https://www.facebook.com/champvive/"]', 'COLAB', 1, DEFAULT, DEFAULT),
(124, 'cnicoledprieto@gmail.com', 1, 'cnicoledprieto@gmail.com', 'Camila', 'Prieto', NULL, NULL, NULL, NULL, 'followName124', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["instagram.com/__.tinkywinky._/","https://www.wattpad.com/user/rarita_02"]', 'COLAB', 1, DEFAULT, DEFAULT),
(125, 'raven1994kali@gmail.com', 0, 'raven1994kali@gmail.com', 'Verónica', 'García', NULL, NULL, NULL, NULL, 'followName125', 0, 0, 0, NULL, DEFAULT, DEFAULT, '["https://www.wattpad.com/user/kaliorion"]', 'COLAB', 1, DEFAULT, DEFAULT);

-- Los asigno a la editorial y les asigno su rol dentro de ella
INSERT INTO EDITORIAL_MEMBERS VALUES 
(102, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(103, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(104, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(105, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(106, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(107, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(108, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(109, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(110, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(111, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(112, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(113, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(114, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(115, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(116, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(117, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(118, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(119, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(120, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(121, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(122, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(123, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(124, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT),
(125, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(102, 1, 'CRITICA', NULL, 'Artista', 1),
(102, 1, 'DISEÑO', NULL, 'Artista', 1),
(103, 1, 'CRITICA', NULL, 'Artista', 1),
-- (104, 1, '', NULL, 'Artista', 1),
(105, 1, 'CRITICA', NULL, 'Artista', 1),
(106, 1, 'DISENO', NULL, 'Artista', 1),
(107, 1, 'CRITICA', NULL, 'Artista', 1),
-- (108, 1, '', NULL, 'Artista', 1),
-- (109, 1, '', NULL, 'Artista', 1),
-- (110, 1, '', NULL, 'Artista', 1),
-- (111, 1, '', NULL, 'Artista', 1),
(112, 1, 'CRITICA', NULL, 'Artista', 1),
(113, 1, 'DISENO', NULL, 'Artista', 1),
(114, 1, 'CRITICA', NULL, 'Artista', 1),
(115, 1, 'CRITICA', NULL, 'Artista', 1),
(116, 1, 'CRITICA', NULL, 'Artista', 1),
(117, 1, 'DISENO', NULL, 'Artista', 1),
-- (118, 1, '', NULL, 'Artista', 1),
(119, 1, 'CRITICA', NULL, 'Artista', 1),
-- (120, 1, '', NULL, 'Artista', 1),
(121, 1, 'DISENO', NULL, 'Artista', 1),
(122, 1, 'CRITICA', NULL, 'Artista', 1),
(122, 1, 'DISENO', NULL, 'Artista', 1),
-- (123, 1, '', NULL, 'Artista', 1),
(124, 1, 'CRITICA', NULL, 'Artista', 1);
-- (125, 1, '', NULL, 'Artista', 1);

-- Migro los pedidos de la versión anterior

-- Modifico la tabla de pedidos para que acepte más caracteres
ALTER TABLE ORDERS MODIFY synopsis VARCHAR(1000) NULL;
ALTER TABLE ORDERS MODIFY details VARCHAR(1000) NULL;
ALTER TABLE ORDERS MODIFY intention VARCHAR(1000) NULL;

-- Inserto los pedidos anteriores
INSERT INTO ORDERS VALUES 
(DEFAULT, NULL, 'ayelen.afsa@gmail.com', 'Ayelen Sandoval Abreg├║', 17, '+51 926 733 004', 'WSP', 49, '2021-04-08 22:04:46', '2021-04-15 22:04:46', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Descendiente del Infierno', 'https://www.wattpad.com/story/259975147?utm_source=android&utm_medium=com.aero&utm_content=share_writing&wp_page=create&wp_uname=AyeFer27&wp_originator=6b%2BlSAUbPUE0LnZebK37rxZKNV7mRWNlrcr9C0aJ7OGP3sgXSv0bb%2FrHztSUuRD%2FDhaQ4kr1ifnk%2Frmc%2BujxykCymwMOHh6ofIslv3V8wxCbD%2FKuzEFStTc2z%2F3AzlqG', NULL, 'Mi obra trata de la vida de Angela y como cambia todo despu├®s del asesinato de una de sus compa├▒eras', NULL, 'Deseo trasmitir miedo y suspenso a los lectores de saber quien es "La cosa" que le hace da├▒o a Angela', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5be97214-5238-44d7-8007-fd873381047d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=yhfmTEefrkBpkmiinuUmmL%2FuiMzZg%2BQv8t816WhlJwnb57%2FYY52qe4dCn7AgrrL6UXQGHKyGaXF7bh4Ue2yrUxl0iTDMJD676GCyn2VypLuZlpiC1O19VIVY0AfiGniORunogtte1dUXJWEkR2JyDv7soJjU6I1CNXqn4KnvAv0oigP9rkiMHxIM%2BRdfx236rjloelqnDLmWW2W%2FS9ve3T0b8sK2%2FXfTsPBiUyhoiq7Pu%2BR1iODSnYHpLPE1q4eAExussrIXOYGipMaiKtCoBp73nIOoFjQ1IrQGC1mlw1I9R%2Bkvk30r0aDKsRl%2FXgV8Xru7YgZ8aSK1RorIcZ60sw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-05 22:30:32', '2021-05-30 22:57:11'),
(DEFAULT, NULL, 'isabellitaalejandra@gmail.com', 'Isabelle Viden', 18, '+58 4144777632', 'WSP', 68, '2021-05-17 23:49:07', '2021-05-24 23:49:07', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Conexiones oscuras', 'https://www.wattpad.com/story/231362685?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=javiqntpray&wp_originator=j3srqvB%2FxYbnZFkZsGEh5d69uESxgvTNELuJ8Ppoqhb%2F4Zhn7AKJfjvk9wqVathmgW6yrpKBpZ3Be8iVvbniNIgaG5bRVS2eLDCxtO7QzQaBBeAxe7vXOy%2F5K3QC2reH', NULL, 'Una chica quien ha vivido todo lo que recuerda bajo mentiras y limitaciones por partes de su madre, pero al entrar en un internado, conoce personas que la acompa├▒an a descubrir el por qu├® de las actitudes de su madre para con ella. Y en ese proceso conoce y se enamora de un antagonista.', NULL, 'Misterio, suspenso y obsesi├│n, quiero que se sienta la incertidumbre de que es lo que suceder├í, y el por qu├® de la aparici├│n de ciertos personajes', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6740b33d-c139-4bed-aed5-b132b3b13107.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Ca%2Bz2rSD88o5b%2BsicP2iJVk%2BhsYDtZnTCFJbCFx8RCjmOd0qzKJQ5hSz7tsRxlxtGsXRxvugrzE%2FF2XtGI9H0gWYfXci56j3ZAVj30zCVPRd0qomEetorED9IlLtp9os%2FOfKE3yOGAtmJmBTgA1pE%2FyF%2B3bC6B2yv46%2FhSQa%2F%2B%2FBWvbYYSZQArs%2FPWFyCXW%2BjeKZEM%2F78oEa40CDxXSckUhbwOoqVIG1Vw%2FD6WjDkb%2BfpfImXn2VWSvrJkDWMgXcliOqnbGWSt3tEhprqi3nzLZ%2B79PtWXfy7vbruS%2Bk%2Bgfm0zU4tkJzyOtxQpCqaoL918GFafNqQ1c3rYl3GFy2Ig%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-12 01:12:39', '2021-06-08 00:59:51'),
(DEFAULT, NULL, 'julilorenzi0508@gmail.com', 'July', 15, '+5491154567056', 'WSP', 56, '2021-02-28 11:00:38', '2021-03-03 11:00:38', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Karpel', 'https://www.wattpad.com/story/258147150?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Julyan666&wp_originator=CEOwAKpa5KUMgyX%2BdJGrpPrqcX4%2FrtCOz7BKkRhJapHXH6OVOO%2FI5hw9i0adJDLK8tORW3gY6pqmIy0Yx561Jqj78dYodtR%2Fzuv05K8aede9wwKTjQLwax%2B4%2BEE6%2FXRe', NULL, 'Mi obra se trata de un brujo que despu├®s de un pasado bastante tr├ígico, empieza a vivir en un mundo m├ígico y fant├ístico.', NULL, 'Es una historia sencilla. Quiero que quienes la lean puedan escapar un rato del mundo real y disfruten.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/f4fd633f-c3e3-422d-88be-d89b90248ee6.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=LNtMaVqqXHVzwrBfXgMteGZb1q74mabQ0bbnuGWXk5ZsqPfTikDHf1mpk8mhV4yeO9c7iQ3e0F8VdfrLyomIJajXyK31JgUta2hk0OZ7XRLfKOnt16fI04nr0MqprVcGY5OcxnBv0ClGr50p9w5Jx7I8jg6wsFHxwi5EJT8g1R0%2FnMmC0X8i7kzFikBEbp5hGtZuXuW1pvNq0RDphpA%2FZDmK3bexNZZ0V7SFgh%2B7NkMYdB6isfDLZrJdsLaoaAOi%2Bheut180tzciOKl7LyrQfzRLEnhvMBHJHMbLUcqYWRQdM9jIYJRfoUw6hQRBZd8zYVVGprlL7mA1fGUtx0JsPw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 10:55:40', '2021-03-10 11:47:11'),
(DEFAULT, NULL, 'fernanadoalvarez78@gmail.com', 'Fernando Alvarez', 18, '+58 4241869791', 'WSP', 115, '2021-03-15 13:12:54', '2021-03-18 13:12:54', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '- ├ÿrdinem -', 'https://www.wattpad.com/1038770335?utm_source=android&utm_medium=link&utm_content=share_published&wp_page=create_on_publish&wp_uname=Diplomatico714&wp_originator=2y4bSkwjmHBdkr9%2FuCzUKF7yslwSMqtYYVS2OOW8O52LMaYrIvHKJOOzvTgCYqoFBEiIsczJQ0K1eYpq6WT3mKkJzeu1HqdtCh2kvckkKAR5F1NVHQ3frxtzQt33m0PR', NULL, 'Es una trama de ficci├│n y fantas├¡a basada en las realidades espacio-tiempo, la interdimensionalidad cu├íntica y la espiritualidad. Est├í recubierta de s├¡mbolos aleg├│ricos que permiten con profundidad poder experimentar cada referencia para con la realidad y viceversa. Involucra Acci├│n, Drama, Tragedia, Comedia, Romance, entre otros. Involucra la qu├¡mica/alquimia, cosmolog├¡a, astronom├¡a, cienciolog├¡a, espiritualismo, misticismo, entre otros.', NULL, 'Deseo atrapar al lector con la misma historia, haciendole aferraci├│n a los personajes, por su gran variedad y extensi├│n, adem├ís de generar contacto emocional fuerte por los giros y la profundidad de la misma obra.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1c06bc00-ab39-4c9d-815b-afddb7583415.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=ungr8ibHY2niH6QCIivt3MT6bX45ecRy5ZGM21WQrXOU4aKWXbC0brS3SMhNjFI8lEJIA1DHP1F3ug4yLldRWVFVWzrJUeHLlNFK7ZIdQMDLcZp4LBDqH2kc6QmGd%2B9eScoTJxQZYKbTT4a%2F4R8VPjZFKPwVzBlM8aHF70DxajW927Oezu4HjuKlXiTfkvTtplqyCH5hketXhqdNL1hnt4re1ykcfmjSYVbfT7htiU%2FjV7O99C%2FSTk5Pt3CP8Vfw2F0wXUND8GsDo7XZ%2BkKWfn8XbKRYgSuhacqvR94OtEmKeFnCyZKNMz%2F3BSujBbgZGXL2nyNEZflpGbPkvyUOTA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-11 18:53:07', '2021-03-17 17:55:45'),
(DEFAULT, NULL, 'Miosotis.2407@gmail.com', 'Loana M├®ndez', 19, '18093611339', 'WSP', 54, '2021-07-31 10:14:26', '2021-08-07 10:14:26', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El padre de mi hija', 'https://www.wattpad.com/1040263297?utm_source=ios&utm_medium=link&utm_content=share_writing&wp_page=create_writer&wp_uname=Neymar2407&wp_originator=nuGE9AOvkNxhQtVzGw%2FqDUogyzwDuXyzYWUo9DnaqP%2Bud5M5i5D0qHEsv4NAEL8lvhf2HH6XngpRPkWYHcV%2BcSxkTqPvBVChF1kfr5ahBSirJPR%2BdaGkgxxalWuy2y9I', NULL, 'El padre de mi hija, cuenta la historia de un amor inconcluso. Ella se alej de el cuando queda embarazada para no ser un impedimento para que ├®l cumpla sus sue├▒os. Cuatro a├▒os despu├®s decide regresar hacerle frente al hombre que ahora es poseedor de un imperio.', NULL, 'Deseo transmitir amor paternal de un padre aparentemente fr├¡o hacia la luz de sus ojos. Busco atrapar al lector dentro de esta historia de celos, traici├│n y desamor', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2b60e785-9da3-4ad3-b0d4-91278fcdd551.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=N6SgWcUptPNAghpG38WuaO%2B92Aw8C81blQAUtCN461C1KtUXuMYw5HenpC0Onw9apzpK44qll5%2FAjm3JV6RDNpwQvblGr%2FhV0yW7A9yrhoNILKHLJHi0h442w2MUCGpDBuHUPQ3tvL0u3ViQKP8Tt7QNrb0gi%2FFFBitJVA%2BN50FR7mDSUw1ZBKkN7%2FmoYCPvaeZuar%2BB26ubfu4j6k33tS8c60MIyT5Cfm0H%2BPb0Rt%2B9%2FK0s4y%2BkjibZcZciJDAHUF0J%2FfUGoJlYMZTyF%2Bi%2F%2BaZ8LfjSpFNhjIal2EfDB8IgqJSv2gmr2FORmq%2BFjywKgWqFRz3K9fODwG2y3yrxNg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-30 12:28:35', '2021-08-17 13:00:53'),
(DEFAULT, NULL, 'maricelberon98@gmail.com', 'Maricel', 22, '+543489345527', 'WSP', 51, '2021-05-14 12:16:01', '2021-05-21 12:16:01', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'La venganza de alma', 'https://www.wattpad.com/story/260863234?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Marr2198&wp_originator=eX5IavO2ZcRWJpeZtiMJuCQ8n%2FO4qL6l3lrKAK%2FHMvfkkouxDkWOR2S0kiPX7fZxvCDlAPkw3YthNlGF2brZM%2Bqw8KAskKVUfqORAPTyiIwyo9VEyPC%2Bkj1qk7e5l%2Bv0', NULL, 'M├¡ obra trata sobre una mujer que busca venganza por el asesinato de sus padres cuando era peque├▒a.', NULL, 'Deseo transmitir incertidumbre,suspenso, tambi├®n romance.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/327b377b-a91f-47b1-9c2d-a917a3d6e6e8.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=A%2FYfkRRbhrfyShXOxtw7HD1qWTjcjc%2B8u7c66GuqlBpMnqeC20DVp%2FskO98Q7CToVLu43n7P0X4rxAEPQnbuy4%2BvLn2rbH1%2Fv5abRHR7ZN706Qrw1eniT3%2FSrjUEUQ0yvNioRZbqcAtyj0CwWn5%2FNZQMpd5VMudBULnA0U2u9XoUGM4Rx7o6QQnndwDpArgAYMQNlgh4BxxPPP1q5aMK0opuMJvJgeNFnQZp2IRTEuRFjdA5SGHsBYjLm3REb5JmxswDXMiUZqkVfqVFNgcyIxtodVJJ%2FSf7OIYeE3l2oXte8dMMWCBk9956LnxNOMRYZbkHUtilvEwAv1mFRKzKwQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 17:36:38', '2021-05-18 21:10:21'),
(DEFAULT, NULL, 'albertowritter@gmail.com', 'Alberto Cedillo', 20, '', 'WSP', 50, '2021-03-01 16:31:18', '2021-03-04 16:31:18', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Amor Virtual', 'https://www.wattpad.com/story/254641496-amor-virtual', NULL, 'Qu├® es el amor? Las emociones humanas, sus costumbres, en fin  su estilo de vida son un completo misterio para Raquel-28 una TecnoDoll avanzada la cual desde que fue encendida no para de tener de curiosidad sobre si misma, su entorno y sobre todo sobre sus sentimientos hacia su amo Alejandro, ┬┐Qu├® me hace especial? Esta y mas preguntas se responder├ín en esta novela rom├íntica de ciencia ficci├│n llena de reflexi├│n, mesclas de emociones y momentos de humor picante.', NULL, 'deseo transmitir, diversion, romance, insertidumbre', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/bf0acbc4-7951-4692-b3f4-2c4cc9e2bdc6.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=R76V09SJ8gwp8sa%2FKhmqPPNt9hJuFrpCLI0nj5CjUc0DQCqbmpOlrRfRizC9HdJwV%2FOb7HaoVMb%2BZXu0%2B77SW5nA%2FVgS73JkdkMi7aqWMZpbxZf%2F97NxJIsmnEvP%2BTgWvl3HDPppSLKutfqczgs1blwmWiAuHPYVLGMMmUb2QVE0PLUlqrj3harOLx6vzYxaNjIxIqDAqn%2BI%2FWuXu5QCdxplTaQBnBjFFuxT96YNzAcyLzatR%2F2r60tfu3G0Q9cBWb4ZJx8gkVxFqFR3fNAyplI3vHMpHRvwbLJtue8np1N87HgKj1IqtgkWzJ1P6S5E28YqSvgxNszBHysePj0aKg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 14:32:08', '2021-03-17 23:25:24'),
(DEFAULT, NULL, 'Drbm929@gmail.com', 'Diana Bracho', 28, '+50761015811', 'WSP', 116, '2021-04-25 18:56:59', '2021-05-02 18:56:59', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Puerto seguro', 'https://www.wattpad.com/story/244039813?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Dbracho14&wp_originator=5osiybfSMm4ryjuGYAjAS%2FG90x1CDOr7DULAh4z9kKsB6JjdJ%2Bx1R4rgLVg3Rdrlhh7KV1ptokJXDBziVodtar9pFxjyFwHP%2FurGlr1ALCl1Ra5Ppdov%2FOjlfHQcxzKU', NULL, 'cuenta la historia de Ver├│nica Ferrara, quien obligada por sus padres a atender la empresa familiar  en Porto Alegre Brasil ,encuentra el amor en Fernanda, quien es una mujer adinerada pero con alma libre que no le interesa en lo m├ís m├¡nimo la opini├│n del mundo para vivir.  maldad, traici├│n, envidia,amor, desamor, accion y suspenso.', NULL, 'Romance, acci├│n   y drama', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/85810101-9c06-4c35-8977-5d77bc530c74.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=DeAstdBjLAuhBClMa5UAcSSjEif54y%2BmCGYVNx1mAZeKvhNLiJEIdZcxLnXmk27gWVPn56CDKkN5Rbm2X9mdrPQcN860RA4Y32TmW3ZP88GobU%2Fm0opE1zppwvCSQzxd6uDu1F4wJw%2Fv7r%2FaE1ltqJGkw%2FQmSYHo3lOHG1MFrkt6zdTmPJw7Ji4pDfPTapKCgUmNIu%2BBu5MaEgVBGynoL0gBlJzc91nTlB8IKT5NV%2F%2FLz7e0yeVZ57CiXGR0%2FsFyZsSrm8SRtDJ3fdw%2B0tzFZhYNJDRN0ToCy8UfOLVBsm86QV9iDBLgZnGENNbqnUjhlGwVgFGBzS3gegEsftwEGw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-29 19:54:42', '2021-04-28 18:10:57'),
(DEFAULT, NULL, 'hernandezalma1407@gmail.com', 'Alma', 17, '448 150 2376', 'WSP', 115, '2021-02-27 23:36:58', '2021-03-02 23:36:58', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '3 metros bajo tierra', 'https://www.wattpad.com/story/252573791?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=Alma_Hernande&wp_originator=WcX25TjqKz5gJmzVqXsr11GrqBAuTz5cAdyJwm8jeaoNdqgoAEVxf4WW%2FrhLgILXp28zyQ562BLUOa%2F95sVqdQrn3JyCEvlmfcUop3mBjnEKmd7JK6RZPyHo0iOwqzUg', NULL, 'De una pareja que se amaran a pesar de que esten 3 metros bajo tierra v', NULL, 'Que el amor puede durar mas alla de la muerte', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1c9c967f-a9f9-4f6e-b022-500b80732090.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=gjdGrFjUmX6WmoTUeBb8VcsYAg7NBujl6vrQ6jqeJhfI8enXvqRs%2B0V5KFBYXfBtKR3sFBMfRLUVeF%2BIKFb8O4G7NxYWxibWJYEb7qJ%2Be3zMuizBsnQL%2BZBMbSXtd2rJUV%2BPM4fzV7jLhxmMcBAC6WjsnYdHJK0s99EdQUgQtyoD7AQ9PexxQZ7uKE3ZymD5MZArxlPaJ5ds89GL6q4BsyME1vi8W%2FrjE4DI%2FionFquaiEtRoHmTKf8%2FuVD6%2BpZOwWvLhScTs8BfeqLgICDUJuFIscYjzQ40mtkbJ3S5SRv1STlgwuh98EA6lN%2B8gV7MJHphfrm1uuazgPVeLJzhPg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-26 23:50:55', '2021-02-27 23:59:30'),
(DEFAULT, NULL, 'cockita99faustino@gmail.com', 'Sof├¡a Faustino', 22, '+522461884658', 'WSP', 62, '2021-05-13 00:09:38', '2021-05-20 00:09:38', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '┬┐en d├│nde comenz├│ todo?', 'https://www.wattpad.com/story/149245081', NULL, 'Cuento con microrrelatos que hablan sobre la vida de personas que no se encuentran en sus cabales.', NULL, 'Un poco de realidad, que les cause incertidumbre y vean hasta que punto pueden llegar algunas personas.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1d5789ee-3a9b-4872-bd04-5304c5c2752a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=kHvHg283XHMcKeDPf59dolGrE%2B%2BT19AXOx2C6YyIZk4UUMu0v0Y%2Bl2Fz1utAGalvPP4%2FgWU7cOWlLzl5ExZAagOj1wb3Y%2BiXZ5dTyuFB62wss1ixuFSNXSkko9tkdRXOivMY4XMLAc3oIjzKV0N5%2BrrGIB6ZEwDiAZs8jG4QJjmYXsBRqkjq%2FDpfnqDowGxp1XV8zqMISba0DmXM9MltBMXh%2FLmQeyL2xZxuHrj3Ro%2F6IzAp8YmqCLLYivFH2LMj929HHMroSFOwyEQnD1A9qFd%2FDEgkloYtJY1mlhEAJGMUf0V%2FTKxAJOuV%2FKxA9T47NJrISOOrP00kmD4nnVytlQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 17:51:07', '2021-05-14 22:57:41'),
(DEFAULT, NULL, 'irinavargasestanga@gmail.com', 'Irina Vargas Estanga', 19, '54 9 11 6645 4149', 'WSP', 68, '2021-07-07 15:48:59', '2021-07-14 15:48:59', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'T├║ + yo= yellow', 'https://www.wattpad.com/story/235764950-t%C3%BA-%2B-yo-yellow', NULL, 'Mi obra trata de un romance dif├¡cil de concretar.   Asher e Ivelisse est├ín entrelazados por Erin, la novia de ├®l y la prima de ella. La complicidad y el universo los┬á convertir├ín en amigos cercanos, pero el amor est├í a la vuelta de la esquina. Los a├▒os correr├ín mientras el matrimonio, el desamor, la muerte y la realidad los ahoga. As├¡ mismo de una forma u otra, ellos acabar├ín por encontrarse en una encrucijada para comprender ese "algo" que sienten el uno por el otro.', NULL, 'Deseo transmitir la amistad y el desarrollo de una relaci├│n lenta, el surgimiento del amor dulce. Todo los sentimientos que padecen los personajes.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/97c04310-e363-4e9a-b8d8-b8eb319a6d05.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=mIHg6eJ5fRnbnqSDW60i0kXhYFAGpjhcywY9r2R7hUvsS0gz8pZ7u6xRRTEbzC%2FypEgBJ5zrJOhFSnqNqV0FyvBCy%2FDMwAOn70YKWuM9dZLJw7E2YmVjt%2Blcb8sRGJK9LR8UTRRaOr49uMd8IPEy1sF2j9wgFEkITKBhDGzZaj%2BiQ0xnZk8cUZDxX6fgLaxdpJKqP1YLLin1vC6nBgj5X2AGScqbF7Z0h6IKontNeXxvkxYQaCCTdpA1UFLSjAVx8V9NcVFB%2BX6iYN0bKNELZ1YxwUc2w76XHWxbls7m6TS3PnEBjObneeDseF%2Fv2WWHhdyZpQGiFqLxEKNBIluPWQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-28 17:31:20', '2021-07-19 08:49:56'),
(DEFAULT, NULL, 'julianenriquecastro@gmail.com', 'Julian Castro', 21, '3042051236', 'WSP', 67, '2021-05-07 11:54:07', '2021-05-14 11:54:07', NULL, 1, 'CORRECCION', NULL, 'HECHO', NULL, NULL, 'Order', 'https://www.wattpad.com/story/244132389-order', NULL, 'Mi obra de del genero de cienc├¡a ficci├│n con superpoderes, trata sobre la historia de diversos personajes y sobre un gran ideal de convertirse en el Order, un individuo respetando por los dioses y temido por los demonios quien est├í sobre todo y todas las cosas', NULL, NULL, '', NULL, 0, NULL, NULL, NULL, 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-correccion/6e7486b6-917b-4898-bd3d-cd5f0352a84a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=hZbZomjLLo99z8adNp0tYlf5Q2RDmD%2B6F%2FD5pMdlNTqQ51Lm%2FaUQf9MAAVjOgeYs0RCtes3beZKXPMUTI3EE1mKMQC1hhBp%2BoNBWQpdf9Mg5%2BwO12tqZZIT4LRyTGMR7VEf%2FYm1sC1bFf0mqszVOmsfQlceV%2BdpX%2B4bPVhLQVFiKKv97yq6tX7xNFXMCsp2Yxvtmd3e0p4Nfi5egpUjSn4shBcI%2FKDFUCjxoRUECGfwBTGa0crG2mdmNimqhKazyur%2FWqdb%2FzBwPlNPiW%2FPb5xxY3Z8AEQ%2F0K3AER98gLHqBlXCbBLgb5U3Ph0Q0mnjgaG5wcYVk40Nqiek8yl9HtQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-06 21:07:30', '2021-05-10 14:09:54'),
(DEFAULT, NULL, 'susanaambit@hotmail.com', 'Susana Ambit Tellechea', 27, '685877491', 'WSP', 119, '2021-02-28 01:02:26', '2021-03-03 01:02:26', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Dime que me quieres, aunque sea mentira.', 'https://www.wattpad.com/story/256494494?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=SusanaAmbit&wp_originator=WBo%2FKzJVKXwPAILNFrqigmMvgQUlM2u6agkOHPMpmuIsWAhguyGAiFGKsWGXjti8JjqD5CZ4Uv3AE58DPOZGLzAEDJb5mmiwyiNrTLKVRpDhYlQlJrju6jT0%2FoRAk6h6', NULL, 'Dos personas destinadas a no enamorarse    Nerea, lo ten├¡a todo , dinero  buena familia  y un  futuro  pr├ícticamente  marcado.  Alocada  y divertida.  Odia las relaciones y no cree en el amor.    Aron.  Cantante  y guitarrista en su tiempo  libre .  Un chico  de granja, feliz  sencillo y humilde . Que cree en el amor  y  sue├▒a con una familia.   Ella  puro fuego, el un chico  bueno  .   Dos polos opuestos , dos l├¡neas paralelas en la l├¡nea del destino , que se cruzar├ín  en un momento tan ef├¡mero y fugaz  que cambiar├í sus vidas para siempre', NULL, 'Es una novela, para los que adoramos el romanticismo  con alguna que otra parte picante. Con sus m├ís y sus menos  y con los clich├®s cambiados.  F├ícil de leer y  entretenida', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a2103390-349e-4335-aa69-a93f953dfecb.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Smk0%2FZrrXgXX4hygNhdp4N4vT5Qu%2BDpQ42habEx5aD9jyNGo7nYZr%2FSpWKOaVH%2Fs71cclJEJl%2FjumD19EQozUM%2BbZEePEk8Pxp%2BsUdiBhisOboMN%2FP%2FtmdSBgGd3k65JEPZW%2BbYWHYFg20CYtBk3vE7YlyO9PJ1uDNAxmQzZOGsLPvtrYU3Cg1eN4lDThGjZhe02c3HYzsF9sOYwt1iQ4Lhgk1sSW3PSLLOIEZMxDTPBpgh7LDVPxmhZ%2FfpG1QI37jF1v%2ByAKTmwxd5eFutRc974p7WFFA%2BfILX8Mavnm4iciLQn8kgX%2Bv6tD5%2BgaPM6Fu40c5AtqQAWQMGQmj2Oxg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 13:25:45', '2021-03-02 00:42:16'),
(DEFAULT, NULL, 'nururia28@gmail.com', 'Nuria', 21, '', 'WSP', 62, '2021-03-31 21:22:29', '2021-04-07 21:22:29', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Desesperados', 'https://www.wattpad.com/story/220193586-desesperados', NULL, 'Son 5 historias enlazadas de un grupo de 5 amigos. Principalmente trata la superaci├│n personal.', NULL, 'Superaci├│n personal. Cada uno de los protagonistas tiene que enfrentarse a diferentes problemas y sobreponerse a ellos, creciendo como personas en el proceso.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/25d9b747-10c5-429d-9496-23c96582b869.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=nZRc3Hbd3lfD%2FW1TBDwB%2FQ46YhPs4fcYfGlCsYN9yZF8hBdih9BG1iIOOX8xhwFn34oAfqoF%2BJRtrJPTnsd6RhcHOj2RTMFf4u67H5pKtBmfJr7AL8tZpyWEW6UuudWkXwOHiqXpcPxzMOWLAT0NNLavVbTyjqqFB0c5bmsLi1OJiYes4jazBI%2F9cwC6gKn%2F3FGPhWKj0Z9fah6t1fLOtyB77TZpmzZHLYXL6EaC4FOD2KYK%2BLlqMmDCVhDBFEB61Jp%2F0bZtQGV%2F1hX0ZccT3TcGnM3RM7BvTNx7FRt1rmML6J1gfwZ4pl5snjrBy1G4GN%2FIGlAvVPz4wg4uv%2BstYw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 16:35:06', '2021-03-31 21:27:26'),
(DEFAULT, NULL, 'Lauraospina1d@gmail.com', 'Laura Ospina', 23, '+573155269685', 'WSP', 116, '2021-05-20 22:56:06', '2021-05-27 22:56:06', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Mermaid', 'https://www.wattpad.com/story/185755538', NULL, 'Es una historia de amor LGBT entre un trit├│n y un ser Inmortal, quienes deben enfrentar muchas cosas en su camino.', NULL, 'El no rendirse, en el creer en el amor, en cumplir sus metas y levantarse cuando caes', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/97532963-b292-4e9b-913f-d4f49afc0767.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Tx%2B3ahhZoG5RiKMBopE%2BZ0gLExqViRg7MNUXETdWz4etnKeci3yAS0%2FaFvd2Z2qIJ81VAdKkTKiv2nlFPtbym7Y3rXL9ImAAzCHyFqFFINa9oWmxl4%2BYQNXkK5EJ2eQTZkZBZbDj45ExIuxP2B%2B%2F688w6tPzgmC9HkoxA2%2Fl8N7fT%2BrKYx8Uz3crsHoVGMhP8%2FYOGcqXM4VfkCBB6fBOZ50ZkiBbbNRNR5sRhPCEmbp7gl5phZwJU4vzyQVCIwnp2%2Fp9uVlISHkqOMXnwlU8FDnk88G58mGoMwzh2Ssnpr%2FiVSiyHuSUpw5o%2BvaI1DlaFXk7tGEgYRco82LXOEIZcA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 18:55:06', '2021-05-25 12:22:06'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51902123505', 'WSP', 113, '2021-04-19 23:07:31', '2021-04-26 23:07:31', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Ella sabe que hizo algo mal, solo no sabe c├│mo arreglarlo.', 'https://www.wattpad.com/story/266469517?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=0uSXQOPn777o%2BMQ6aNNKHkxiSB5w40s3m7Zh6Gfp08hakjRQ7138pqaHrnlxwckeHfTsxDrDHsudGUc4LXAWmWk0%2F91N%2FR38FwaY2c4S9rJAqROCPvdA4yjdU0kAEmGT', 'Efra├¡n Apaza', NULL, NULL, 'Condescendencia. Tristeza.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F315414ac-d1c2-4f58-8289-24bae842f660?alt=media&token=b03f7e57-0b21-4c49-8b09-d502549fd165","createdAt":"2021-04-17 18:13:11"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ff1dce4e6-36bb-47a6-80ea-6f94bf0d442c?alt=media&token=842a57b3-fb20-4101-9274-c783849a847e', 0, 0, 0, 0, 1, '2.2', '2021-04-17 18:13:11', '2021-04-23 18:24:50'),
(DEFAULT, NULL, 'keniadelatorre35@gmail.com', 'Kenia De La Torre', 44, '', 'WSP', 115, '2021-02-26 23:28:37', '2021-03-01 23:28:37', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'La venganza del escritor', 'https://www.wattpad.com/story/252379933?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=KeniadelaTorre5&wp_originator=I9s%2BVHsG0L%2Fscvyo%2BIFj54DAgSQTKxqEhbPNVfip8oEoHFbMmJHgL2EbGDy13wmm5zXRbOZ%2BBD3hC6BCY57AfsODxX9vhylNhQEjjTzwT%2B6nJ2o0Zd3%2BKhEp8i3Rez6f', NULL, 'Una actriz aparece muerta en su camerino y el principal sospechoso es un escritor de libretos que estaba enamorado de ella.', NULL, 'Temor, desesperanza, soledad.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/8eb8c897-1691-4892-83c5-6b2abe531e02.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=QY6CiOWd4DpJVuxgkjL%2BFEQfc9RrtNeGW5vSOTu2DB4gcQNJP40IJA9b7sOmFZjiiCzXoaGe1L6lHUS%2F5dxrv7GQdI5Uk8upbOg8hHU0NCApJ0BjYFo3X1JcvGOLh9eI3r%2BGgSYxuaeMwM91JO2BuToSTSqtkiUVAuYdxWOppSjV8NE12LrHdlf99kya6ltUKKfLZXdOcCB9FaTMD8FHrPPjIjeW5jOWTv7SNQyKsXLxJoGbajrqhBNYgQuW%2FS1x41f46nXzMHlMO3XDh1fr3pfvrMfct5VeXjDGoex%2Fvtfw7bE%2B%2Bt72%2FgIDnCFw80V3m57rSQ%2FtB4ZR2rTnb3wsWg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-26 23:02:58', '2021-02-27 10:15:04'),
(DEFAULT, NULL, 'eglez1701@gmail.com', 'EMILIANO GLZ', 18, '5561126041', 'WSP', 60, '2021-04-14 18:23:50', '2021-04-21 18:23:50', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Semper Vigilant', 'https://www.wattpad.com/story/258230946?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=EmigHolmes&wp_originator=cpA8sHZiyFS6VKy6nI%2FUL85HLJD%2BmzijYf6Ke9OSanI%2B3ealh8%2B2VRPyOIpbzpraPjnisKpUo7U61kMBejn4MCacLnFd6uOFk88buKPyiu1KHf9E0Scmwi3B6tclkkB9', NULL, 'Las historias de una cadete reci├®n graduada de la Academia y un Capit├ín veterano se cruzan, en una carrera por detener una inminente guerra civil que podr├¡a hacer caer a la Rep├║blica, y con ella acarrear la muerte de millones de personas en la galaxia conocida', NULL, 'La incertidumbre y la duda sobre si las convicciones propias son las correctas, o en realidad, eres justo lo que repudias', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/f63a72ce-3bd4-4d5e-96d6-7c52a4a0df19.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=qR4rox4jeTs2fvR4FYVx4nfXjJYCWUcBcfLbZuoc%2FXe98hlm8%2Fw4q0ZqWszh5lIU7EmHAa%2Bt2CTDbfi8DmNlvlw9KwouVJB2l%2FhH5%2BcBfBlCf%2F2NI%2B6lumxKW9fiK3T1dnCSo9NZP%2FpTTOViBjLjG%2F19Kfl6A1rbDzGn%2FTm8%2Bh2QfX%2F1M%2Bkp1GeXe5BzwiQtOrx0aKtz6uR8EzFglKuZQnAPGk8kHq%2BKRRfugTiymqDJbVrIztAy1hdcVVk8P1I0gWa0SvXF7Yo3hH7m6UktT8VarBJAUqzQN2gdkxhiNwBB%2BKGOf34tcCRwQUKudQY6V%2BisLuiiaPC0gotxygPuxQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 15:22:11', '2021-04-16 13:41:26'),
(DEFAULT, NULL, 'isabellapanqueca28@gmail.com', 'Isabela Alvarez', 17, '+584148807500', 'WSP', 115, '2021-02-27 10:17:49', '2021-03-02 10:17:49', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '┬┐Por qu├® muri├│ Morgan?', 'https://www.wattpad.com/story/241481364?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Isa_Alv&wp_originator=chmNUcxGg%2Bm%2BDH72HLWTE7NMe1Diq%2BEwIgheZc34Lo0XQyBqs7P94xa5mj7Zqmek%2BFcQTM%2BLJs7reiX9Dzug9d6wNZ0ds%2B%2FEfMqRjx4i9y1rohHHdd2dU5QisUdpIf5Y', NULL, 'Escrib├¡ esto a ra├¡z de un experiencia que tuve. Quise sacar de eso algo bueno. As├¡ que, trata sobre la vida de Morgan, solo como ocultas todo solo por simple fachada. En c├│mo puedes disfrutar de leves momentos de felicidad mientras algo malo est├í sobre ti.', NULL, 'Quisiera transmitir que no todo es lo que se ve, no todo es no bonito ni bueno, y lo m├ís importante, que la confianza es cochina.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/c1c2bac7-6f91-40f8-874f-d593c5ff3295.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=GCGuC2Rfen1g2rFx8F59GyLBvzslc6XfFt1KN61YwZUeOX1AV0W5kUyD2HkcBKQjf0BeYkxv5UIL10NuT%2FAepnadE9WDDclyXrGDgMSok1FlVWdzhIT0PrSJ59asxTaKy3hk79zz%2Bf0V9dGlOxzLqde%2B8J%2BTjnygS6NawyNUwuE8VeVYNVjTYyxhhyWMDwQhB9dkUb5G6Z4psK%2FssLG27g%2Bw3gZ2K6zm4ZeOKrBH5ArJk4Vw0yRtR0CA84gCo4P%2F50UfzVU7DdSXRrheMp4HO4WEZpaG6dwaCb5Qb2SAZx%2Fo067KI4SvmlQgVIJYtSB%2Bvg6S%2FZFGTZH4t1mVSDI84g%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-26 23:05:40', '2021-02-27 23:08:24'),
(DEFAULT, NULL, 'miosotis.2407@gmail.com', 'Loana M├®ndez', 19, '18093611339', 'WSP', 106, '2021-06-01 14:03:08', '2021-06-08 14:03:08', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Lazo que puede enredarse, estirarse o desgastarse... pero nunca romperse.', 'https://www.wattpad.com/1040263297?utm_source=ios&utm_medium=link&utm_content=share_writing&wp_page=create_writer&wp_uname=Neymar2407&wp_originator=nuGE9AOvkNxhQtVzGw%2FqDUogyzwDuXyzYWUo9DnaqP%2Bud5M5i5D0qHEsv4NAEL8lvhf2HH6XngpRPkWYHcV%2BcSxkTqPvBVChF1kfr5ahBSirJPR%2BdaGkgxxalWuy2y9I', 'Neymar2407', NULL, NULL, 'Quiero que aparezcan un padre y su hija despu├®s de ah├¡ queda a creatividad del colaborador. ┬íGracias!', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fa3e7ab80-86a5-4c36-884e-beb1d2b42c34?alt=media&token=a3899b06-e374-49f1-b3a1-a73f8b212af5', 0, 0, 0, 0, 1, '2.2', '2021-05-30 12:22:56', '2021-06-04 11:38:13'),
(DEFAULT, NULL, 'johannabrito2613@gmail.com', 'Elybell Amasta', 19, '18299328873', 'WSP', 106, '2021-06-01 20:27:36', '2021-06-08 20:27:36', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Por ahora no tengo ninguna frase', 'https://booknet.com/book/322923', 'Elybell amasta', NULL, NULL, 'Ser├¡a idea una pareja queriendo tocarse pero no pueden ya que la historia relata un amor prohibido por diferencias sociales. Tambi├®n que haya p├®talos de rosas y el titulo sea con letra plateada.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ff9491f0c-c963-4059-b9ef-d60f0ce63612?alt=media&token=77164541-d928-4bcd-bc1c-43161eba1e7b","createdAt":"2021-05-30 01:28:24"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F9918d6ea-ec6c-4bdb-a512-401637243252?alt=media&token=e88c0428-b3d9-4a4c-ace4-855ae3031712', 0, 0, 0, 0, 1, '2.2', '2021-05-30 01:28:24', '2021-06-11 21:07:03'),
(DEFAULT, NULL, 'puentehaciaelalma@gmail.com', 'Luisa Valero', 45, '+51928415440', 'WSP', 58, '2021-09-23 15:11:41', '2021-09-30 15:11:41', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, '"cobard├¡a"', 'https://www.facebook.com/2067637556825096/posts/2978151855773657/', NULL, 'Es un poema sobre un amor imposible por Cobard├¡a.', NULL, 'Sentimiento de duda e incertidumbre por razones mentales frente a lo que siente el coraz├│n.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-09-16 21:43:58', '2021-09-23 15:11:41'),
(DEFAULT, NULL, 'fannyamador26@gmail.com', 'Estefani Amador Curiel', 19, '+52 3222531321', 'WSP', 51, '2021-05-04 10:16:43', '2021-05-11 10:16:43', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Balas Perdidas ┬┐Alguien me amar├í?', 'https://www.wattpad.com/story/255519391?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Leycar_Beltran&wp_originator=QKcN2GvQClVd0p58bQUmeNXEy1d7trFOghtVfC4%2Bx3oQrVfWTo7%2B1k9m%2FBqfNJHrWUhA4%2FXinPW7NGl1wdRsWa7L6mmzi%2FhfqSUiD47aXq2xXgLkHh0ujoxlHurQNueP', NULL, 'Mi obra trata de una adolescente con problemas de depresi├│n y suicidio del cual sus padres son testigos y no hacen nada por ayudarla, ella se ve en una b├║squeda de s├¡ misma buscando a alguien que la ame.', NULL, 'Deseo transmitir todos los sentimientos que la protagonista siente, hacer reflexionar a las personas que han pasado por lo mismo que ella y que entiendan que se puede salir de ah├¡.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/543ac9f7-de56-4d92-939f-2325acb4961e.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=nFSpaHApNjIbrrQPT5vVZ0U999GXwWeX%2FTW8S9%2B2hLGjV7n7gppnPZHXxbHnMBaRGJXx346Kk9i5zniPNwQNVNpU3R5E5GudnFmpOHud2v7WphVwOgR03f85WA9gPJJ0WaPB9Dtdu%2FXd8q988BX0mSP2Rc75itZNVgnD3lhbAW71P95mn3rRFfXzvXMi%2F3PXSPyJ3NVb0Oz4vXNEviZxCM0bFLkHe9Tl8OFnvL3QE54RbNAzu3IrLTc56TxbHN5OQ1Z4FPMsgMBtjJoIAgit6hb501M9vclmxb6IfjZpjGWJunSkXHwHq02Mq5Cl9gt6GH8568ZCowVtZAwAdmBUCg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 14:09:04', '2021-05-10 19:08:48'),
(DEFAULT, NULL, 'rengel123a@gmail.com', 'Kaira Monasterio', 15, '+58126147215', 'WSP', 115, '2021-03-02 16:29:14', '2021-03-05 16:29:14', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Compru├®balo Junto a mi', 'https://www.wattpad.com/story/249450380?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=library&wp_uname=Isa_Alv&wp_originator=dnxcBUWVhAh0imRsuetQTDAAMWFU%2FzbvqbrDl9D5aOB%2BHC2H3cULFaMKY2YITNutP5dWB0r3LUKXHB8DtTyPBMPAJQpzI2orbmCLr0xkOZ%2Bv%2B0z89nxECk%2FCpuZgBw8M', NULL, 'Trata sobre una chica que lucha con sus sentimientos y lidia  con el repentino acercamiento de el chico que le gusta a su vida. Las dificultades y las emociones invaden este relato descrito por ella misma.', NULL, 'Intento transmitir lo que ella siente, la condici├│n que desarrolla y lo dif├¡cil que es para ella manejar todo lo que siente.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5acbef82-51d6-43a4-a475-905ea807b642.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=T010By2vQuXzaudxBwqcR05BXHoM%2FiBsDEqetqtwkX0u8brH9RejudHPNSWXFQXkZ5Vxnxje1Fi2M5%2FD9MOPg0z5dy91ol76AJ3dpQC6P%2BeSpZoKW5FA2TqSMFHB0uu6DDkNINUB%2FyjjsmJcjOIh91f0dOsGJsDuUypjFWxFGrzdbkbXvLELsx6ULB%2Bnrqx1D%2Bult0B6rf4VI44iXvemehVb5%2BWHS%2Bos%2B6sj5B1lcIzQJX17tTZJRj3uHYxBAm3FKZ5TROnPdTkVrwHF6H6e2y0%2FRz%2F9T%2F6j3qnT6E7D9XShAOwUMxLtYT3CjRuXon9SRmq%2BNW%2BElnWH%2BVtAvfNeTw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 15:28:10', '2021-03-02 16:41:07'),
(DEFAULT, NULL, 'luke.leis.91@gmail.com', 'Luke Leis', 29, '', 'WSP', 68, '2021-04-05 00:11:55', '2021-04-12 00:11:55', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Reunificaci├│n', 'https://www.wattpad.com/story/249111657-reunificaci%C3%B3n-episodio-i-%C3%A1strith', NULL, 'Mi obra es el inicio de un multiverso de distintas historias que demuestran como nuestros mundos estan conectados desde el big bang hasta el big crunch. Tambi├®n habla sobre los metahumanos y un sentido existencialista. Por ahora solo hay 3 episodios publicados de los 8 que tengo listos de esta entrega llamada Reunificaci├│n.', NULL, 'Quiero que haya un enfoque distinto a lo que llamamos bien o mal. Que el lector entienda el poder de la causalidad adornada a trav├®s de una dualidad destino/libertad. ┬┐Qu├® tan libres somos? ┬┐Qu├® tan importantes somos para la existencia?', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/70b4d3f7-dbdc-42e7-a365-6729dcc112bb.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=RXVmn7Yv6fPaoyu1JIavMvANjSBNsmboACtIBg9cjglHCSvaBKLvKhiRwKe%2FFK6pMtPDqCAlaZAvi998Xe5NedXD63A9wdn5gnbSEGPioGUkQODibx6lWsvoQmUpeflrK3TzUq9BB8AWs1FIBq%2FFyO%2Bro0j2ohgYiw4lTMG5KFWz1h1hzalIAPdN8iHYJiN%2BOhoShymXBuNqyCyOlYO2Y6QuDDkPkpxluvDlR%2BqWaisZr3P30x48%2FFJUR07NFNI8OlJJD%2BhBpN4MTGENNVdlmCDR%2B9Mie2k7SSSjl9m5rQFDzjVQ4hua0m90cnr5L6VDDei8iTpimxJGu%2BV29xnpFw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 23:38:45', '2021-04-09 00:01:21'),
(DEFAULT, NULL, 'Cccadena@gmail.com', 'Carlos Cadena', 41, '+52 8180204004', 'WSP', 49, '2021-03-20 14:05:25', '2021-03-20 14:05:25', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'ER├ôSTRATO', 'https://www.wattpad.com/1040308420-artilugios-del-placer-antolog%C3%ADa-de-candentes', NULL, 'Sobre las decisiones humanas, la esperanza y la locura ante una situaci├│n social.', NULL, 'La conciencia y el an├ílisis social.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/32801d0c-31f4-40c2-a3ed-73ae82a3521d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=gOwFgej4l9Hlu4LATiAEWFAc4R64EeuXpkHmWDmOg%2BBXJujb8N01g1%2FAEmcI8NQjTnU7PgiXPUp94SCu00cota9WiHzt3CC%2BxJL55QW3TU%2Baoay%2BHl79bwqvuLcezjfUeEHBZULASvdSe0KUIAnXFZOasNmznex4gCMceZfBW83k7VGjl1Pe3MpBBLYLuVK5oxSHh0Qm8ckXV38ZggS0KYGcB40v8%2BLAdDMnGt3IRbIIe6TcsjZtph6J53eaqh2rAQrxGJvcgGh2Y7uB9AGi6XSggGf4T67QhnCGmg8JP0qc5jHSO7rdVCXvXh2o%2BbwwSk8nZz%2FO1j1AnYvdnQ1Rmg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-19 21:19:50', '2021-03-22 18:35:51'),
(DEFAULT, NULL, 'soniaalexandravalderrama@hotmail.com', 'Sonia Valderrama', 23, '+573059443658', 'WSP', 122, '2021-04-13 10:18:22', '2021-04-20 10:18:22', NULL, 1, 'DISENO', 'BAN', 'HECHO', NULL, NULL, 'Mi maravillosa destrucci├│n', 'https://m.dreame.com/novel/OGRI6V2m0qGjYPzKmLbLQg==.html', 'Soniis Valderrama', NULL, NULL, 'Como el amor puede llegar a ser tan fuerte que aunque cause tu muerte, no te arrepientas de haber conocido a esa persona.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F22d1eee8-30ca-40e3-bcba-1c2cb3bf42e7?alt=media&token=19f65f47-ecd5-48e8-a95c-82f693cbaa45', 0, 0, 0, 0, 1, '2.2', '2021-04-02 07:38:19', '2021-04-19 15:25:59'),
(DEFAULT, NULL, 'diego.fvo26@gmail.com', 'Diego Vega', 25, '52 5531787872', 'WSP', 62, '2021-05-25 01:31:33', '2021-06-01 01:31:33', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Pesimismo innato', 'https://drive.google.com/file/d/1CYutLVU3Clr2zkAnA83xt2Wpl0IbVW1e/view?usp=drivesdk', NULL, 'Trato de plasmar el dolor constante y punzante de la vida. Una vida sin esperanza, esperando la muerte y contemplando el espect├ículo. Tambi├®n toc├│ temas c├│mo enfermedades mentales sin cura', NULL, 'Quiero transmitir la verdadera visi├│n de la vida, sin m├ís, s├│lo ver el caos en el que estamos parados y de los cu├íles somos protagonistas en un solo escenario', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/9cc60903-9539-4f95-813a-45f4499f8a48.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=txFHU%2FuvtqJH58J7eqwLfR0lGqXN48NlUKi8L9GUoeisCRkQL6myzPG0qsDNOlZgQY8TezddPzDD8Dp7nPsbYLuXoKWvQ1OuB32SRq3HBLTTRzNOt5g0fVQE0SKINryb%2FY%2BMs3LbmhBisGIKQ4%2Bgeoh4bGS3vQcyDIZP0RcJv4uLUmbBotgmJ5v0hGQ1nh3OzJhCDr79NF1xFMXO44sAwiZ6eSg6Ugk66tSA49uUWY%2FMnbgIcec%2Bog%2F96%2B1yiFLWBlq7u2EQSzo8nih4U0ywYz69skfRmFEGZNX7vK4m8ZIbGn%2Bnetfe1wIti4LXx%2BekDdzIP%2BCpJVsG0QqGs0AKvA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-21 23:42:35', '2021-05-25 08:00:11'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51 902123505', 'WSP', 102, '2021-04-06 14:15:25', '2021-04-13 14:15:25', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Carta sin destinatario', 'https://www.wattpad.com/story/264205171?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=ums80uZaSgqXgrNts0EyVcYcAY%2BuASqESEwcCio88yjSov1RQSpd9l8IWR7y%2BD18OItIPjE86LoGNKryw26XGeWM8yHicuzP2Km%2FVOrrd2Pf0BKqYVYQUxIKkX83tmxq', NULL, 'Trata sobre un suceso vivido sobre la p├®rdida de un hermano y el dolor que queda detr├ís de su fallecimiento y lo dif├¡cil que puede ser superado', NULL, 'Transmitir los sentimientos negativos que pueden nacer luego de una perdida y, lo que hay veces uno descubre luego de su muerte lo dif├¡cil que pudo ser vivir para esa persona o cosas que tuvo que ocultar.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/e164ebda-49e2-43ab-a6c7-d3b8d85ec13c.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=IJvOR7L%2BtJbc6koPCtrqCfoXBgw7Y%2BcjZcy%2BFcz2PJLixVAdzjq%2FyRbfwaYgWnW%2FGvkPEi010jg%2BB61ApqH8orA7tIIjbtTWCFNTh6dgLarpCUCriZC7lL0bCrg%2BiQPLo6MkJcMGpFnWcwCmT9cEqQjZQXVQaFplAX%2BDgTpzDcQQaYRYHP%2F7HUuyf%2FddMsCNLPJ5vNz3e%2BsoVJ%2BzWY%2F%2BKlBZbtDPRL0Bejr%2BR7h6ZVwPXGzb2ua1IlEX0y4PjXrbMdPosSXVy84V2mY8cZ6qJe1JoPZT0ZGvQzcoC5lqye%2FOXmtvtAgdn9ES%2Ba8NWDfX3I8BvXPhtJzJT56KtrKOig%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-30 21:42:06', '2021-04-09 11:44:02'),
(DEFAULT, NULL, 'william.sandoval2001@gmail.com', 'William Sandoval', 19, '35121486', 'WSP', 61, '2021-07-21 13:59:45', '2021-07-28 13:59:45', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Bajo la mirada se todos', 'https://www.wattpad.com/story/277439604?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=WilliamSandoval8&wp_originator=fF4ed4dNz2gBhd7gnTWL6%2Be6VWd7XhPty1LE67sh6TCHle2MfkOt9BRIofcf2AKUAejEcw30T%2FVvb%2Fd3aGlM3nvubM1bZegG37%2FJGUjG8HkaTyeT5Jf3wP3q8T4kWGvw', 'WilliamSandoval8', NULL, NULL, 'Una chica y un chico frente a una multitud', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F3235b161-490b-4480-a173-bca617cdd7c4?alt=media&token=858bfeb4-fc9a-485e-806e-8595ed60b5f6', 0, 0, 0, 0, 1, '2.2', '2021-07-14 14:25:08', '2021-07-23 09:05:42'),
(DEFAULT, NULL, 'adriora@outlook.com', 'Mick Taylor', 35, '2293431671', 'WSP', 62, '2021-03-26 13:56:13', '2021-03-26 13:56:13', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'D├¡a de niebla', 'https://www.wattpad.com/story/261451232?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=MickTaylor083&wp_originator=GECQ0VBIBGA8eDfgHGwNQ0p5Icxn%2BIhN7XkKDPpbG4EXiCx4%2B6QisKyGRY4VqGuc2mxB8BEH%2BLp2UCSqvs014fnjN%2BMLSw2i5tK5Il37XlNQQ4%2BretUZggRzEY6PqlDh', NULL, 'Un encuentro entre una pareja en el l├¡mite entre lo deseado y lo prohibido', NULL, 'Deseo vs negaci├│n', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/9b335827-4c5d-45b9-be99-67d15ee3b02b.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Qv7p7Ivxb3rpu1HXrbLj%2FYTIvO4Vibb9kXNrwRG43qKKpZu6DDSZAneWne4jdNF82ewb8zY46EglYEDzcwdfki4zsYMdOF2zQsOVPkFY%2B1DOurc3ROq6PuykUqVooRUZoUw7Y5oxLlGFeUKqrO35t9YFfM%2FovtuVtvFd1flj8Xd6n2I9HciVgwe1QmybqK1z%2FkjSRZfvIfcGP42aG%2BE7OOdvrUEpNAth6kBuxMFS9Q2Oug0Yh2WTcvDKdgYD5icFY5TSbtfIiUv5DWVBy0tc5QhwsV9n3Liwvze3h20s%2Fsd5MlQCXLNODsZltBx3wUXKyRC%2FQW5WwusJWy5OxtC40A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-24 00:16:54', '2021-03-26 14:00:41'),
(DEFAULT, NULL, 'Lauraospina1d@gmail.com', 'Laura Ospina', 23, '+573155269685', 'WSP', 58, '2021-07-07 16:10:04', '2021-07-14 16:10:04', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Taoxi├╗', 'https://www.wattpad.com/story/200011959?utm_source=ios&utm_medium=link&utm_content=story_info&wp_page=story_details&wp_uname=DetrasdeBrithany&wp_originator=aJb1EwFxPmcxUrQlg0Cr4eP0d%2BU6RIdTTF3h8gDzNYKMgfElVuusk%2Fy8uGRYvMnS8ha1p7vaud4LmHDPUZ2D2bSbB%2F5qF9StyaelZazHljzXXZ0ugTdOejYPSV%2FTv3OH', NULL, 'Se trata sobre dos almas destinadas se reencuentran cuando una de ellas reencarna.', NULL, 'Que a veces cuando el destino aun te ponga obst├ículos para no estar con esa persona, es algo inevitable, ya que es imposible evitar que dos almas gemelas se reencuentren', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/dc3b0f0b-a096-4fb3-b8cd-3941c33ac630.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=XiJjOfLZtDx8luiEJRBn6ExtPRAWOtCvq4FDYXEcHNoO%2B5nLW3sF3r339f6nc6pvTjkM4smMxYyZtjF1XqkgOU5%2FTNsxdHU75XJfeRlqoAxMYX7y%2F%2BCzsC9rboWO6JWQtFjyztKHLZUdDcwRMqmVJX0p%2FPLtY7coAPTrn%2FEv%2BiL2GUIzDQxCxlTHjkpNxAN%2F%2FlmEORN%2B1206XHJmjqMjrJ5NicOPQdC1Tnig2A5tk7JxYWDcCZq1SnZIUpU%2BnxSeZ%2Bg0%2BhnAypasre6BOn4HP8osMNc3pP%2ByC6WBGaJTtwbH95wqWfuRaDxEdAKlCVVPegL6YhMeOgfeTXQjrUkQ9g%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-19 22:09:14', '2021-07-13 10:58:23'),
(DEFAULT, NULL, 'kimberlystanmarvel@gmail.com', 'Sof├¡a Hern├índez', 16, '+52 3327831393', 'WSP', 62, '2021-03-31 01:09:22', '2021-04-07 01:09:22', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Te atrapar├®', 'https://www.wattpad.com/story/237464606?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=SofiaHernandez12345&wp_originator=x2oaw18Gjthvwu3QMahIibntY8CO4MhjyDbdcUv3numrmATp0GzXNfd0v3YDS8mjkANW1nS4FqeNpItMcukzD%2FmzGvurm8OL%2BFnPU2heRPihSuDFqI%2FRYf5ozHFh%2FGnI', NULL, 'Trata de una chica con m├║ltiple personalidad que perdi├│ a sus padres y buscara al asesino y hacer justicia', NULL, 'Deseo transmitir el dolor que sinti├│ la protagonista', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/dd1d9ad1-d127-44e2-81dc-43a7c482bd09.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=w6q%2Fe%2BOi%2ByQTXwMb1%2BZa7srMs6xdw5AcNxVE%2FJ4kuvODDUboVWaoMhoKqaAmA3lxowyp6v9%2B9dTq6VHX5lkFRjasgipmIc45UBWFDL25jlD68az%2BCsvVY%2BBEJu2nCpHJpDttu5jv5idZ2RnM0vEQvgusvwpwklRQ11KE7cXSnsM8ObgWRT7UX5TWS0thwbSLPPvxksXbiudIpccpv1AuaeGrq0n%2FyQtMh%2FQoKDNNtct409ZPHUJ2JozdyqHf5f7RhHzxjlUVt7sgXAf9GEb1bp53b4vXKzxRaZxX6PLDO7UDAkXdRGtH4pA%2FaNqHkgw2Oe%2B4cilKP6AkKf5kQ57zow%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-27 15:47:17', '2021-03-31 21:33:27'),
(DEFAULT, NULL, 'andrea.5678956@gmail.com', 'Andrea Urbina', 19, '', 'WSP', 114, '2021-03-19 16:06:19', '2021-03-19 16:06:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Lo soldados de Evan: el renacimiento de un nuevo Dios.', 'https://my.w.tt/vWxANiXXMbb', NULL, 'Mi historia trata sobre la mitolog├¡a grecorromana y sobre un secreto de estos dioses: sus soldados mortales. Soldados mortales capaces de hacer cualquier cosa por su dios. Incluso, destruir a otros dioses.', NULL, 'Deseo transmitir valent├¡a, miedo, fuerza y replanteamiento acerca de la vida. ┬┐Y si los dioses existen? ┬┐C├│mo lo tomar├¡a un mortal? ┬┐Por qu├® un Dios necesita de un mortal?', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/dca8de66-7649-48fd-8a60-57cbcb0f68b9.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=dNd%2FKxbERq%2FJleRQL4qoFAStY7DWY41HOTX5LyvqlEoiDAI%2BcO6PYQGLMo8ZDq5Ne5pM%2FzN4KK1Eg6ahXjeDbn7Mv%2F978arRtNhtceVFyUHlGFZaGI2CVd%2FmJt9YrAUK5Y1z%2FcnV57QipMO%2B%2F%2BNl4q%2FFYHF7ccNx7J7AzEmqPxxm2qnzrA%2FpdCDDCtA7Mjln60EUq1nMslCbXi0HNzBrTPMbY53yYr2iivB84YBJkFgdqHAVotTDEyMza%2BGnHxiSnnLfnMSRAqYAyGkBvb4IZ22%2BGk5P%2FniWvETpcIlX2sFqgurOnaMq%2B1aSbpClmqEWIBB0JBh4ntDkQi6hqjk5%2Fg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 14:41:13', '2021-03-23 12:21:07'),
(DEFAULT, NULL, 'bcaroyaranga@gmail.com', 'Brenda Caro', 27, '+51 902 717 018', 'WSP', 67, '2021-06-07 23:48:30', '2021-06-14 23:48:30', NULL, 1, 'CORRECCION', NULL, 'TOMADO', NULL, NULL, 'Una lucha dimensional', 'https://drive.google.com/file/d/1ZqAl6Krvs9wx-xd3OvZeOoQhEwtqVtdy/view?usp=drivesdk', NULL, 'Es un fanfic de la serie shadowhunters y s├║pernatural. Fantas├¡a.', NULL, NULL, '', NULL, 0, NULL, NULL, NULL, 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-06-07 23:27:54', '2021-06-07 23:48:30'),
(DEFAULT, NULL, 'escritos.oswaldo.ortiz@gmail.com', 'Oswaldo Ortiz', 19, '+593 991333981', 'WSP', 115, '2021-03-14 16:10:55', '2021-03-17 16:10:55', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Antolog├¡a de Represi├│n', 'https://www.wattpad.com/story/247989889?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=oswald85&wp_originator=dqIGWQTxROv9IXSLJUKCSJMVGzt%2BBCuffrOD%2Fhx5606HJBArN%2Fysc9b%2FoUv6nMIC2KhOX1CkhO0GiXqu0dhiquvCYWIzg8LlV%2BhHDmXdbiqlbz6kdmdrls43roBtMmYw', NULL, 'Sobre varias historias independientes entre s├¡ que cuentan la vida de varios personajes y las situaciones de estas, todas estas me han funcionado como un ejercicio de escritura y ahora quiero compartirles.', NULL, 'Dar a conocer mi universo literario a trav├®s de mis escritos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2459a867-5192-4b16-8507-0f51582b05b4.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=WGul3NlzNGnGMRaQOe3cMuIYeBNQX%2BBc2Sjgl4iMmuGxLX790qNNS4LHpEDFaxmQvVhJM%2FbMcv6NJFPVf%2FVUrzhQBUMDFm%2FJGFdUQWhkkH6bWYlrCPIzsphbSG6oZeuB1FmTviZ1%2BhrvjinB3E3%2BuNac%2B4SWpw8XZUL3K3LHaFkUu4OZUudHlFJq4Geenr6G34bBRK19VOs1NEE9eeKayA1KHGlg294ogXWnDQpgz6XTb1Dvk3WL%2B%2FTBNm2Blg4Ew6hcaNgAM%2FMaVbXGZ6javfAntbaycrApaQd%2FtLUGu8iDOvh3x0dSIZw7kZIZGtSVfAGMsJeLLeL8QOTRd09gPA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-13 20:31:02', '2021-03-14 17:05:13'),
(DEFAULT, NULL, 'estivenpatiohuertas@gmail.com', 'estiven antonio pati├▒o huertas', 26, '', 'WSP', 49, '2021-03-18 16:31:44', '2021-03-18 16:31:44', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'kakegurui los ultimos dias del clan momobami', 'https://www.wattpad.com/story/192970206-kakeguri-los-ultimos-dias-del-clan-momobami', NULL, 'es la historia de un hombre que lo pierde todo y nunca podr├ín recuperarlo  su tristeza se vuelve odio el odio se vuelve ira y ira en venganza los momobami sabran lo que es perderlo todo poco a poco', NULL, 'es pobrar una historia conocida pero vista un punto vista distinto y ver que aciertos y desaciertos que  tengo  y mejorar los desaciertos que tengo', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2b732a63-d9d3-466b-a495-7bb349bc9734.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=zatNwVVtQO6THepjJe6xpsCF1hcGRv2bAe2LU6HmYLddRCWQl5OltJ01usqfivlTQsVVxLgvuwEKJ%2FMha9%2BKEZbAbDT8rsadhL%2FvbuGgIpsHRDRyXbwZHkAPXV3NzuFcH4jekri8h2qLWVXNahAIDBloLPOn%2FeG1VbFlAQrdGLUf9r4cTfoMgmslcIYGpQE7TyBmQcVjWTolPlJIplptyAt0W7gcyfCfeXm0uqVU0xW2E1R%2BAuefeZX4FpDlAln8%2Fas9TnP8vqWKT00yNhCROGXjWxHeiiShw4%2Bii2tMIdO4BWrQg0jGyoPfAfxBRb8gjftyeLlYrXGL1duFV35Gyg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-07 19:27:50', '2021-03-22 08:43:01'),
(DEFAULT, NULL, 'maicoagustinherrera@gmail.com', 'Maico Herrera', 21, '+54 11 21810711', 'WSP', 51, '2021-06-22 13:50:26', '2021-06-29 13:50:26', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '24 horas', 'https://www.wattpad.com/story/234526593-24-horas', NULL, 'La obra trata sobre Mauro, un civil com├║n y corriente que, en una ma├▒ana de trabajo, ver├í que el apocalipsis zombi ha estallado, decidiendo recorrer una enorme distancia para reencontrarse con sus hijas y ponerlas a salvo.', NULL, 'El miedo del personaje a perder lo que ama, al igual que la perdida de mesura con el paso del tiempo. Asimismo, cuando ├®l pierde algo, trato de que se sienta como una perdida real.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5c7b0758-b78d-442d-825a-31f8d2765389.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=GaB87UeTKpdU5Ayqhx1FOWijagrZgVUGa7wA%2FOyPXTJIlqRYUXW0kwdcGBjN7L1t%2FIsKynoooW1vatqhRGjOIXDphSryoon9tq%2Bbgisebmmpd2VhYgsRUc6k%2FvASHNdeSH8H1pH%2FX8Dwz4vIF1OJH4CSYGCr0bv9j5i%2F1VW1nLZ%2B8UmqPxogOyG3VBVkp7tfoC8p5LE0Jc7mDDKOwQOpZ2QlQmbvTqiOhK74qIVqNwuNwDUrlHInDarT07%2FJxpN2S6z3rZCR2DF2q3DMwWU71W0ptCAPA%2BYzqP9cuJsY4JTcRy88F9LQeqDmrhUT7eY2%2FdAkirzWnYH09xPf3IJIMg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-01 13:22:33', '2021-06-29 13:11:31'),
(DEFAULT, NULL, 'fernanadoalvarez78@gmail.com', 'Fernando Alvarez', 18, '+58 4241869791', 'WSP', 102, '2021-03-28 01:06:59', '2021-03-28 01:06:59', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, '- ├ÿrdinem - "La inmensidad en cuatro palmas"', 'https://www.wattpad.com/1038770335?utm_source=android&utm_medium=link&utm_content=share_published&wp_page=create_on_publish&wp_uname=Diplomatico714&wp_originator=2y4bSkwjmHBdkr9%2FuCzUKF7yslwSMqtYYVS2OOW8O52LMaYrIvHKJOOzvTgCYqoFBEiIsczJQ0K1eYpq6WT3mKkJzeu1HqdtCh2kvckkKAR5F1NVHQ3frxtzQt33m0PR', 'Dipl├©m├ítico', NULL, NULL, 'El dise├▒o se basa en el cielo estrellado, con infinitas constelaciones y en el pie de la imagen, un suelo apenas visible. Tiene que decir "Ordinem" con cierta fuente de letra que quiero para el dise├▒o.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F6824ba0a-7872-412d-bc32-3f793dbe134c?alt=media&token=ea8b1cd7-c101-4289-9ad3-e0fb1991f8c5', 0, 0, 0, 0, 1, '2.2', '2021-03-11 18:58:44', '2021-03-29 18:17:15'),
(DEFAULT, NULL, 'marifiro.11@gmail.com', 'Maria Figueroa', 26, '51 965 070 854', 'WSP', 54, '2021-06-04 19:14:59', '2021-06-11 19:14:59', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Una memoria perdida', 'http://wattpad.com/story/77096698-una-memoria-perdida', NULL, 'Trata sobre un joven que ha perdido sus memorias y debe enfrentarse al mundo en esas condiciones, saliendo adelante mientras alguien lo persigue.', NULL, 'Quiero transmitir un poco sobre la vida y los obst├ículos que se presentan all├¡, as├¡ como el salir hacia adelante y la confianza que se tiene hacia los dem├ís.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0cec8b8f-c120-44f8-ae37-5d9c25a69293.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=VYDHkpFoUeRBkW7szwxlBgEkgGljmdHmqO6%2Bzxm%2BBGfoKBdtrAByGB%2BBESKJSXZQVHH3HQVw5hV1eMmCKIyB3d55S32NfEolq9M9tVc%2BJbjDIe64wT6g%2FGAI0xIKh4CsoOKdXCaL%2B0lAC4RruRhPSYjQZmOX8%2F39gxJKe3ZKxEd8SuKCbJV1mT9FYs6PGuxEp0Pc1xQPkW9pp98adHRbW3VoVXaJDK6FRKQm8EeSaPdGxTxrP3%2BpJpF81GfonysvJWLMw3Hmzu%2FsQ0uKQ4Ftmwo7VJkTjpBhDHneNi0yyZRTkl6viq5ugWJgjXj5S5ABvedjqO3Hb6JaPEM32iJHAQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-29 06:44:40', '2021-06-07 11:01:31'),
(DEFAULT, NULL, 'perladanielacortes@gmail.com', 'Daniela Cortes', 22, '+52 2284094017', 'WSP', 60, '2021-06-15 11:39:56', '2021-06-22 11:39:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Los secretos de la mafia', 'https://www.wattpad.com/story/267355954?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=DanielaCortesh&wp_originator=kPQd6bjRPj%2BZtFo%2BNgEcsE4alTi2GHye2Wz71SdPbtp9S%2FPM24huen4sLuZlg5Zi0k9hoO1poE6G5mwiU5aJxnvxHfvSg%2BUdeQ83eNoR6OYz9Ne4gp%2F41DrOl%2BwIx0IA', NULL, 'Dos hermanos que intentan encontrar la verdad de quienes son, quien es su familia. Pero viven envueltos en secretos y mentiras. Todo a su alrededor es falso y poco a poco se van dando cuenta, entran en una guerra de mafias... D├│nde una los proteje y otra los quiere muertos pero.... Y si no es as├¡? Si eso tambi├®n es una mentira?', NULL, 'Misterio, pero tambi├®n LEALTAD FAMILIAR, no es una historia de romance, es una historia donde lo ├║nico que importa es la familia.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5392422e-cc18-4642-8b44-9890f931d413.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=jdmeFUx3JEDUlJJrXxZLJOvvEyO2fcvzutnWTULAM1JGG21xoo3QTKa%2BJp6O4OhtCwB8C3wsquQPDRTIkPhvC%2F%2FNX896lH7AuhalR%2BqJ9wPePCncrokTN75U9AqYk8a9shMV5GRHukT7GNyqrN8NeIrrX24lcnlAkmbndciQCRe6Rc3c%2BRQB8hw6FQ7nT2cymEAplgxM2eGogDN8u96Xar8%2BBH1Ki7cLq5C9aoKJcWmGgYft9d8glD8XB1VKRhEimhAqI%2FqEXZnqR3hdvDzEjm453veWegu7HoBWkvmkOMYvDkToOONcfopOw0xEoC3Tm52%2FsdJ16Vn0CTlCM7pzBA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-31 08:34:49', '2021-06-29 14:46:43'),
(DEFAULT, NULL, 'lindariosllontop@gmail.com', 'Linda', 18, '925595246', 'WSP', 54, '2021-05-04 16:47:20', '2021-05-11 16:47:20', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Love touched my door...', 'https://www.wattpad.com/story/95663051?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=adnilrios18&wp_originator=%2BOdibVF3lCI0wh88aztAhKto%2FBc3REJpRmTbXmsriFi1rYRMkSsBj76VcYhBDRf%2F7Vb1U5yJ4wNcjKNfTqfturnhV5JG3vcxJaMDVPN8vtWqpBzVQAOmzaEg00oOuhv%2F', NULL, 'De un amor en el cual ocurre de todo para que no pase.', NULL, 'Que el amor no solo se basa en lo que uno siente, sino en lo que uno sabe.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ef762e89-9d5e-45ca-990a-59d41e337979.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=A%2FA2lW60y78ZmifK2%2FpLhHk9TVyfUimzUoqFfuF6acESHFDzn6Ft4G72HE2hqKkbHx6fMh0MgMv0NCLLewMzlmgMi7BiVtgdjjxMJ0DK2%2Frb221ux6ueDVcZoPlaJIIV6jIrDTQ6scA3pBlphMVcdXs9pwdXlRrsgU5%2FAz1Wl%2F79l1uYXs%2FJDnMxvseBHbOf9ApXwqp7VbcS2MDyXdVlyNAkKoXSJH4zCZiL52k3MuO28za3gwVsomS3KLxSeDT7cMyDWdCLW2ZagafkrY9IO43OQHDaPDdVsB%2BQC6pnjs6LgzZlZTOwouczISw4lwAG1PapwBzDUs%2FQnXKoe7nRKA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-22 17:54:30', '2021-05-05 14:15:12'),
(DEFAULT, NULL, 'emilyneu1290@gmail.com', 'Emily Neu', 27, '', 'TLG', 102, '2021-04-03 18:36:23', '2021-04-10 18:36:23', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '├ël es mi destino', 'https://www.wattpad.com/story/256644378?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Emily_Neu&wp_originator=4vJr75Sv%2BzDXQDES7UhBPktJZ2hKgV4TtvobfGnD23ZHKewqKriCL7AhLjKPCTmp5TQ%2FgRJ4jCrGOVWbmjr3Jh1TqfTRHW%2Fk9u%2Bxkeh4VUD%2BhFFKGMsq9Ny%2F38g1UrE3', NULL, 'Sobre un romance prohibido entre una joven guerrera y su emperador. ├ël debe casarse con una desconocida y ella es enlistada en el ej├®rcito, pero sus sentimientos son mucho m├ís poderosos que cualquier regla, incluso que la propia dinast├¡a.', NULL, 'Deseo transmitir incertidumbre ante la relaci├│n, rabia con las injusticias que vivir├ín los personajes y un sentimiento de enamoramiento provocado por las escenas rom├ínticas.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ce6f6cfd-5272-4a6c-9f4d-2f62795a3965.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=1tCETfYTAZNblLtLjDWMyragi5LE3vQoyZUeFoe4zsmNVjitrn82XT0lRAHyln26r1nsDqPsUG5SLR%2FO6NKguwBrxaCV9QDPQ295FOChDbCMq2w3IKFnFmiu%2Bu2rTEY5HqHSj3DfIx9pvjHtjVLAOeZ9W9%2FA1DaxxRIor5fij7Q8DV%2FvrvyB7Sr9l72pGjCFy1YAE43%2Bghu%2BCIIko5l65eXuoWglWCD%2FQ7nFwrdre3IIM%2F%2BouzqsKiXGzIp2qbfEEHMGBhfcgmpuxWY4W%2Bjf4PxmpObh%2BC6RYx7aldQ%2B3G5gv%2BLwU7i6SZyzYmDyepf0Tg6YvwAc2LvLXRGqcUKkdQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 23:09:12', '2021-04-06 15:20:23'),
(DEFAULT, NULL, 'nathalyjimena123@hotmail.com', 'Nathaly', 17, '57 3142551055', 'WSP', 60, '2021-05-06 15:00:28', '2021-05-13 15:00:28', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Impermanencia de la mente', 'https://www.wattpad.com/story/215046086-impermanencia-de-la-mente', NULL, 'Trata sobre la estad├¡a en Harvard de una presunta soci├│pata.', NULL, 'Deseo que la trama y los personajes salgan de los estereotipos que abundan en plataformas como Wattpad, destacando la fuerza y el empoderamiento femenino de una protagonista que no desea ser rescatada, y un protagonista que sale del est├índar de "chico malo".', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/292dc950-8982-4d14-bac4-02132a969fe3.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=0mk%2B0twnlS%2BMDESEr%2B5AsA9umPsePmmCHh7jXtWfzfYq%2BZ9B8wb1JpLGtHuX4HHlZe7WCsau2TOL30HhFH7xBINRr698yb7J8tylef8hmSfIePgfdkezIvYTb59wl%2FFsyyqLMIvD6sm7ZPqJaFIwEQUE5EpUrGX1ivNh64ig5KHgyD1a6el%2FOlIOdXvZtFR8iKF%2B1kZRGyJ%2BBWRD1bK3A1lMr%2BFOCQ50C6F%2BDYtZmULik9iL8SfggW%2BzzdOuKQv4mLxq7L88ELkOEITcIUXtuni5e1L%2B2XlthZRDeQYTVB73OTEVqLQA4R5hairtMgO0AUr3%2FDaj4%2FmOAmNuJU9S8w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-26 11:09:28', '2021-05-10 14:51:54'),
(DEFAULT, NULL, 'Laurentrafael12@gmail.com', 'Laurent Herrera', 20, '04266387106', 'WSP', 55, '2021-06-07 23:35:15', '2021-06-14 23:35:15', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Ojos grises: infierno', 'https://www.wattpad.com/story/255213735?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=LaurentHerrera&wp_originator=aK3t2XdPVc4vbd3CFL%2BwT42eIpe9s2RaJlkMDiXYgEYo%2BHlwSwv12NLJ%2FxfxZlWvqKgsI2%2Fb5aZMxejZthb8TcXclZY8J%2By5N%2F1PElf2%2FSRJghoKGs5Ri8eL5JwdmSi6', NULL, 'Pues, en resumen, dioses, temas religiosos, fantas├¡a, un mundo inmenso lleno de infinitas posibilidades eventos y personajes, es una fusi├│n de todas las grandes ├®pocas de la historia humana, este es solo el inicio y cuenta con pocos personajes, pero m├ís adelante sera normal ver a Lucifer discutir con Jes├║s en el propio para├¡so, Thor tendr├í concursos de pulso con H├®rcules , grandes pensadores como Platon, confusio, Buda etc, reunidos en un mismo techo y cosas as├¡', NULL, 'Solo quiero entretener un poco con lo que me sale de la cabeza y de ser posible hacer pasar un buen rato en un mismo muy imaginativo', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/b16faf35-20f9-4b0f-9043-aae479b4ef80.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=OeTO76VIA%2BNiqFyOGknb4WZxrJlXdEd%2FCdfnwmpruRN25eqFjQGvZegRoUUeN058xwywqr5y%2FRTTkmpX4L5FnqcAj0LrR53hZQ%2FB41ouShn41U1R8ZM0yY8hIArp0aypkWunJoY%2Bg6MratRU2yPrsaDOdSWQkuUhiYeUxUlhxToPXBCRjoQLK9ALEbPznQS4BI9CFmZp69H4WpYQeRgLW5XNuthcnBl52Pr2aBJ51cwgqT4uNN8uqg1l%2BKbsbSwApjFFSMV8Z1EmwORxicvZdyvzBGnLTMtWPPpk9mS5Gra%2Fn2xLJvc3bEnjGPv0DMjFw5f0SDuJMkl7YgU7AX727w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-06 18:49:59', '2021-06-12 12:51:52'),
(DEFAULT, NULL, 'miel9es@gmail.com', 'Melissa Salgado', 22, '+527226166127', 'WSP', 60, '2021-04-29 13:37:34', '2021-05-06 13:37:34', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Tren Edur', 'https://www.wattpad.com/story/198116871-tren-edur', NULL, 'Sobre que la vida es ef├¡mera, las historias familiares que desconoces y cuando te enamoras de una persona en un transporte p├║blico.', NULL, 'Deseo transmitir que aprecien los peque├▒os detalles de la vida y se atrevan tomar el tren sin importar si es el equivocado.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/f7c41347-0135-4f57-902b-1c142905ac12.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=OqntgGm9%2BKJ1ylQxyi9eFOVIk%2BTJ1Edi7LO%2Fchw19TIc6k%2FJP%2FfPBDqTAj8kdgxYA0UKPadpkWod5WnP8HIgLTTGSiMgByTPkCAk%2FVi2ezs8cC%2FvdJovNaK%2FzvuUSZK6CHep1DIFJxo02nZ%2B%2FN7umkF67jnpmJdOQ%2BUBVqI16FkXuqW1Kl%2F8jfB%2Fu%2Ba%2FCfgptQdA66JUsPzCMudc4DFb7N%2FfAOswj51sOT3Do3gl9qEe7eUrs%2BYkj4n3BWu97pALTHcWfUeYZ%2F0Wracyr3MG2R7z%2FbghqAIVt%2BsHt355I3fBziVg5tsnhCCwmPK7M4wzqhuEFGwkjgsvIjMwoseqPg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 18:29:40', '2021-05-06 14:58:23'),
(DEFAULT, NULL, 'bcaroyaranga@gmail.com', 'Brenda Caro', 27, '+51902717018', 'WSP', 67, '2021-03-30 23:38:20', '2021-04-06 23:38:20', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Amor Entre Guerra', '', 'Brenda Caro', NULL, NULL, 'Deseo trasmitir un ambiente de dolor, que tenga que ver con la guerra. Holocausto.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fe3623b27-0a30-4e07-abda-df542bfd7dbf?alt=media&token=3dd3342f-2a0c-4609-82ed-c9553042e3d7', 0, 0, 0, 0, 1, '2.2', '2021-03-04 12:53:56', '2021-03-31 00:00:00'),
(DEFAULT, NULL, 'rosimarpineda11@gmail.com', 'Rosimar Perez', 19, '+584264421783', 'WSP', 55, '2021-08-04 16:02:36', '2021-08-11 16:02:36', NULL, 1, 'DISENO', 'BAN-WTT', 'HECHO', NULL, NULL, 'Me enamore de el sabiendo que nada ser├¡a f├ícil pero d├¡ganme. c├│mo no caer en el deseo por un italian', 'https://www.wattpad.com/story/266361418?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=RosPerez995&wp_originator=gyYJVcL0WjjIMfSmlxc%2FdikW5ocBai3AbAxgT5uEsB4nqFe%2BFyyKRFn%2Bj%2FVJe2xtKbc%2BQiNrcRyYlmgv2H2iv%2FRDbCzOvfwbW5ENZM7pp1IwORIxILq1%2BOgEZt5XKHBt', '@Rosperez995', NULL, NULL, 'Quiero que aparezcan mis protagonistas lo que uso en la historia como se trata sobre mafia y armas, peligros quiz├ís que salgan ambos con armas cuid├índose las espaldas o lo puedo dejar en su imaginaci├│n', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fa69ee4fb-561c-4bb7-b0ea-631d38176646?alt=media&token=06401279-0b6c-4c1b-9c31-ee4dc34da95d', 0, 0, 0, 0, 1, '2.2', '2021-07-31 12:00:13', '2021-08-09 11:36:52'),
(DEFAULT, NULL, 'camisplit@gmail.com', 'Camila', 26, '+5493513039521', 'WSP', 68, '2021-04-10 21:15:45', '2021-04-17 21:15:45', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'La confesi├│n de Aurelio Hans', 'https://www.wattpad.com/story/263712734?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Camisplit&wp_originator=59OWJ4k85yVyRl45LNaVrcFwNC6lJQ9gQoekTY264r7t8NsFgOlq664C24MXW6W9GEN%2BtdHS83fJAs3q%2BL8ropRXTY6xIvDxl3NP3Z6DzqZyW7NiYdzI4ueXSoLMCE%2Bt', NULL, 'Trata sobre un escritor que escribe relatos de terror y utiliza una estrategia poco com├║n para crearlos.', NULL, 'Deseo trasmitir, miedo, terror, que el lector no desea pasar por esas cosas. Que el personaje les trasmita un horror dif├¡cil de explicar.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/b7b86194-4422-41c2-8a0e-5938694a3d1c.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=fs9oOFxGCQ8VnRtdJdVkVveBWRSxwbcXQSaY%2B6ExWdzZcpDTgpQFi66%2BjTwJ20ZJJlIXaE4qgK1JjtfqffNMZD%2F3og8cFpEPdzagjE14mH4C9JXiEhYGWwxla7hEM5Q%2BjVVknkT7HK0OAPL3eFIKYiR3vDbSpKoo4oPDywp8BgPfJfrXQAxsvecxfRvu5L%2FLo3EKUs2e3jRoSmRz2puDawICiDNGjtnR8lc5I1aIHS%2BVx3GHl4YM8BsU5jBBi3Sj4G8Btueyblcot7g%2FbcIZ178OHZMuUOgiEkFHBfIaRWGJi60eMq6GuGmEUmwuTIk6wR%2FTyWe8v8OwDxFRlyhECQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-08 20:22:27', '2021-04-12 01:03:15'),
(DEFAULT, NULL, 'anitamirandag@hotmail.com', 'Sujeylee', 19, '8117546378', 'WSP', 49, '2021-04-05 20:29:56', '2021-04-12 20:29:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '┬┐Qu├® le pas├│ a Dyl?', 'https://www.wattpad.com/story/82993045-%C2%BFqu%C3%A9-le-pas%C3%B3-a-dyl', NULL, 'Habla sobre la vida posterior a un secuestro. Los temas centrales es que la protagonista descubra qu├® pas├│ con su hermano y lograr superar el trauma que el rapto ocasion├│.', NULL, 'Deseo transmitir los sentimientos de la protagonista y hablar de lo que no se ve tras una v├¡ctima de secuestro.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a36ac5dd-1e2e-4b09-9add-777f6fad20eb.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=FHKl3cZUPyBZi3cN1rj22JVRQmOXOaVX%2FtUOGRkwlnLTn7xMdIoKx0USnssOxuexmpNWax8OYhx3goXBx7gsh5hBkUt0qB5JvkmNj4bT0dX3SPaL%2BMkd3cwqwtBIKc3oiwIvdurTyIH2bLLqgf7JkOjmWp5gciFYU5mNFciGh1Y%2F1SMUg5AZPaGkdFM%2B6Ke8pb8Q0%2FKpurmn8I8dvenkM24cyQusd7nRNkxcFWRoxoDDvNKVjlW2sRAXjtq5DqqiclKm2ynwUwEiHj0Z59aLe2UfUSeLZJmoxf3XjHfQd5YVA5OuAZN2TSqwyvZE%2FfDERvXRnLL7Ng6kh09cc3JC%2Fg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 17:18:58', '2021-04-09 00:34:47'),
(DEFAULT, NULL, 'mhugo2434@gmail.com', 'Hugo Mu├▒oz', 18, '+543512170168', 'WSP', 55, '2021-06-13 17:26:40', '2021-06-20 17:26:40', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'A la muerte no le gusta matar', 'https://www.wattpad.com/story/239502821-el-d%C3%ADa-en-que-la-muerte-cuid%C3%B3-de-la-vida', 'Hugo M. B.', NULL, NULL, 'Quiero transmitir el cari├▒o que puede existir entre la vida y la muerte. Aunque estos no puedan tocarse no se rechazan por un amor que se asecha en forma de amistad.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F00fd1277-b89d-40c4-8b13-5b0a66d4052b?alt=media&token=ee549826-ef4f-4cd6-bc53-a95a341d14ac', 0, 0, 0, 0, 1, '2.2', '2021-05-08 17:22:03', '2021-06-18 14:30:34'),
(DEFAULT, NULL, 'irinavargasestanga@gmail.com', 'Irina Vargas Estanga', 19, '54 9 11 6645 4149', 'WSP', 63, '2021-06-11 14:36:22', '2021-06-18 14:36:22', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'Beso de ceniza', 'https://www.wattpad.com/story/241097066-beso-de-ceniza', NULL, 'Mi obra trata de un mundo de seres mitol├│gicos con varios estigmas entre s├¡. Donde Maleon, una de las m├ís renombradas figuras de inmenso poder, est├í en preludio de su muerte. Sin embargo, cuando su ca├│tica vida acaba perjudicando al hombre que ama, se ve obligada a enfrentarse de cara a sus mayores temores.  Gavriel Koch, es un hombre com├║n que odia su vida y su trabajo hasta que un d├¡a est├® mismo termina provocando la desaparici├│n de su hermana y lo lleva a descubrir un mundo de dolor, magia y caos.', NULL, 'Deseo transmitir magia y que los personajes transmitan lo que sienten desde la alegr├¡a a la tristeza.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-05-28 17:28:01', '2021-06-11 14:36:23'),
(DEFAULT, NULL, 'kleyber.caraballo@gmail.com', 'kleyber caraballo', 21, '+584144066150', 'WSP', 120, '2021-03-18 00:45:43', '2021-03-21 00:45:43', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Relatos para no dormir.', 'https://www.wattpad.com/952582973?utm_source=android&utm_medium=link&utm_content=share_published&wp_page=create_on_publish&wp_uname=kleybercar&wp_originator=c9vI7mEnNrVNX9unnKY3u5EuqllNjd1%2FuKe9U%2BQau1D%2F6FVWpkgD0kLD%2BuW5mhVpcZIre5zMCRH8cSJVgz%2F7nqmfjbVcGHKUQpNqD4GxF2EUDxQ2moAA3ZY%2BWfGHNGMN', NULL, 'Relatos cortos paranormales', NULL, 'Miedo y suspenso conforme transcurra el relato.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4e063ea8-8b05-4c97-9c9d-cb418ccbbf28.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=U4YwShHgA58LOpZ2yQNDURF9wjIuUoyO9D3X38eA0fvoKncp%2FzT3o%2BgD01UOj50Mje7GcDfWlQeIlP3B%2BoHtD84wfMz3i0hmTT34buVoMyDwHxqfNyuLNuGXCJfe7sOlWbXfU8peRHCLIQfx1SJgMBF%2F4rZtTiu%2B6DviyCAoiOyjQbX9yu8o94eNPueeBmEqWmVG9OXC0eHsVsuSCGpnbwtACmBO2YQs7j2TgRKNReNiLXU7%2FlFn83PpSCj7DIweoGfuBZWwZMHuyRHfmev1t8XbTIVkSLoRms%2FqrSP4FdGqrBiOEWiQYHjRU3bm8I8jvhjc3IyD2FVo2mg0Zcp5EA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-17 18:28:05', '2021-03-18 13:39:14'),
(DEFAULT, NULL, 'guevaragiselle588@gmail.com', 'Giselle Bellerose', 15, '+58 04160140372', 'WSP', 120, '2021-03-18 16:04:33', '2021-03-18 16:04:33', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'MASQUE', 'https://www.wattpad.com/story/252004567?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Elle_Bellerose&wp_originator=jyp7zSU87E3Z%2FqzBcflXPV%2Fr2asbp6RPK7oyPWeDXu0oFBSsfOY6GO8edIQcLT1G0q9i78SOilLB1Q0wmOCIxSQhOWk5ZhNRfbYBiZppotwTw9i8yjFMmYX0Y1937uHD', NULL, 'MASQUE, Trata sobre un pueblo oculto entre los bosques de estados unidos, que esconde un gran secreto a trav├®s de unas m├íscaras. La protagonista llega a el pueblo como cualquier otro visitante, pero bastar├¡a una sola noche para cambiarlo todo, y descubrir que no es cualquier tipo de pueblo.  Ella se da la tarea de averig├╝ar que se esconde tras las m├íscaras para salvar a Hosbanth, el pueblo perdido, y darle a los residentes paz despu├®s de tantos a├▒os de angustia. Pero para lograrlo, debe mancharse las manos de sangre, mentir, y proteger a quienes ama, Aunque ella dude de si todos dicen la verdad. Hay muchos huecos en esta historia, nada tiene sentido, es un remolino lleno de misterio.', NULL, 'Deseo transmitir suspenso y misterio, Que a los lectores en el final de cada cap├¡tulo, les recorra el cuerpo con una fuerte intriga.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/afd6b84a-4ca8-4707-83c3-6216cff5beb6.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=I%2FjzC4Bt2Zkjm%2BXeotb8L0iB08jRNFKixF4plkg8i5%2F5KzYSAF8ItQaqJZlbJO6j5z6okB2159ZmhQpxSDcvkTGwG1sJaXEsIlyxMhCqBijV%2F%2BqXinN5eza9r5CBQGIBziuXvOgQ5eu4gwzagyi%2FqQ2iynpYBoq4WRAaPrIz4PW1OAt4DXNeWU5nps1IJ3B2wbj%2B6SNGPYYUsI9P8QGbxI%2BIYz3ovOYWnN1U1xOzuYXhwO7Y0n9zez95TKn%2FnC%2FCMTMH3IVRWXkv2c%2BrPC%2B246njymTYE8IRGxOV3j0oE%2FjkQL%2FzXDLDK8tB%2FJkitsT8hFFtHVAJtcx3mq5HMt4uog%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-18 15:57:25', '2021-03-19 18:30:30'),
(DEFAULT, NULL, 'amadorg317@gmail.com', 'Abby Amador', 16, '+50496830698', 'WSP', 113, '2021-04-09 13:15:26', '2021-04-16 13:15:26', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'La mitad de su belleza era su extra├▒a manera de pensar', 'https://www.wattpad.com/story/261259115?utm_source=android&utm_medium=com.whatsapp&utm_content=share_reading&wp_page=library&wp_uname=AbbiMejia03&wp_originator=dZvrIpCqlxNmdqvKtNZ%2F4An9PJ5RZyaIyeDNp6qIL6Z2GqAz1%2Bcs1pVy4c0YUvtdwbdqWPkAYkFEjeVSBDIsJR5fjPglJHWwH1fQg8N7t9fTfQR553mxo5agkrCrZ4%2FW', '???', NULL, NULL, 'Que apesar de estar solo y tener un coraz├│n solitario puede haber alguien quien te brinda la ayuda y te de la oportunidad de que no todo en esta vida es malo', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fd598629b-d9bf-4917-8909-0935436aaea5?alt=media&token=d29f48a0-e624-47ae-a209-9a754ac7d8f1', 0, 0, 0, 0, 1, '2.2', '2021-04-09 12:09:37', '2021-04-12 21:41:32'),
(DEFAULT, NULL, 'drakronncruz13@hotmail.com', 'Diego Cruz', 22, '+573044531141', 'WSP', 62, '2021-07-03 23:21:29', '2021-07-10 23:21:29', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '7 d├¡as', 'https://my.w.tt/eiEJcAedGbb', NULL, 'Sobre unos amigos que terminan en el purgatorio, d├│nde cada uno representa un pecado capital y es perseguido por un demonio.', NULL, 'Terror y misterios, que el lector busque que pas├│ con el personaje o descubra los secreto que dejado dentro de la obra como el nombre del demonio que los persigue.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0d1efc05-c014-4bfd-badd-c17ba300cb13.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=MEmgNy%2FRUbvaksxGeSRNSVubd%2FsB%2FoaNgsE4eChSh0ZjDE7gIsz3uct4l6VAKT8mCbjqqeubeX2ILnstABnBfrEbakSA2sOtquxKDpQVD%2BfK9ph5VPoVnEuVbZ9mIGkosKnf%2BnEnDfWwJYyDrtZYfr7nJMIgh1%2BDfwUIpKvAFexbJoZfxzn44D3QFFzsGz5zpjgfMYMAp8BFMJ4UDWVMQVdqGnn2sh%2BfOHtS6bKJSAltyVg1nN5f03JmJnpvS%2Bk66dOH7N5SR1yx2RrPLo3A4Ce3%2BQH9yesbnZ2nvhXUvdd0TEG1UWpx5W4ISs8J9Nj%2FsTd%2BMgOJigg8iLNbAvMRew%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-07 15:05:57', '2021-07-05 02:07:43'),
(DEFAULT, NULL, 'distraido@hotmail.es', 'Le├│n Arauz', 26, '84585913', 'WSP', 115, '2021-03-31 19:14:35', '2021-04-07 19:14:35', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El ├║ltimo de los dioses', 'https://www.wattpad.com/story/141518095?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=GsPhantasos&wp_originator=5uVXn0z88lYrR927euIGtdQfTyeFfhn%2Bt05gfy2YVHaTwghIeaETPTJRqF89z8e6u8B4YUyJCS2pe63qEeZQPoDTALrMpsRCdWjPWSiPorOnrjg4qAXSoUmhApp1t2c0', NULL, 'Ciencia ficcion, la reconquista del territorio humano tras la devastaci├│n causada por un mal antiguo', NULL, 'Deseo transmitir emoci├│n, duda, suspenso rabia y cari├▒o hacia los personajes', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/604e2aac-730b-40b7-bc72-fd7082bc84fb.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=arILAYyVewnbeceb1GFK9CQEsw%2BuO5jIAW9Mjp9GVRuJyna1cD3798%2F2RUTlR6ijSnAWQ%2Fo%2FFX1oAWa9Be6k1lG%2Fln%2BeLvgvrqizXlkpDcAZ9SDXBRGCT8DwrpDgJVSnnsNKcsOeGkH0BiWVkX9z%2B%2FbV4h1qOzVwBYfNMzf%2BzZB99MlrpwGOQfr%2BUVs9zTnqddA%2FEf%2FSDxfXrxbpHF%2FW9WZEFCVnuIIyY1XYBrnN3RVw0nU5ZKrzmiTVjX31Dz0VhksTGe3EoP%2FwFIT92uMCM4TMPyKcw4fQMBRs28lhMo4ELGr1GjyTyvPsEbzdaM5mCch5DlCOH0jrCDV9g46yWQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 17:41:02', '2021-04-03 15:01:22'),
(DEFAULT, NULL, 'little_dhampir17@hotmail.com', 'Annabella Giovannetti', 26, '+528113207283', 'WSP', 115, '2021-02-27 18:48:15', '2021-03-02 18:48:15', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Detr├ís del antifaz', 'https://www.wattpad.com/story/2191203-detr%C3%A1s-del-antifaz-saga-detr%C3%A1s-del-antifaz-1', NULL, 'Mi obra cuenta la historia de Kimberly, una ni├▒a hu├®rfana de madre que es vendida por su padre a un traficante. Muestra c├│mo las cosas vividas forjaron su car├ícter duro y lo mucho que le cuesta abrirse totalmente.', NULL, 'Una de las cosas que m├ís deseo transmitir es que el tr├ífico de personas es real, que las v├¡ctimas sufren no solo f├¡sicamente, sino que si llegan a escapar de ese mundo, es dif├¡cil poder insertarse en la sociedad.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4034768f-3084-496a-b9a6-e97af2017386.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=GwWvh7Xm6hf8jUeDWLGoMtW7t%2B41YS99comTxKm4F7RFOmBUEwyWGJX5nqLJFrJPGQicRPCZdgAfYAiX4IJFexWCiiS1NfVLKRdSUQ%2FK9L1EJr0dQXZdxKZL9Jf540yyKWfl1AyywJoUiwXTHl6srGkV8CDCuQ3e45U1PaRd6SzHSfmon6m%2FBneK0FgNpHcSF0em8scjQvbEXwWeAZw4nvfrVs%2BPtbAmR0bf7shpDzSQLnZwIRMgMw0zZ1g1GyIuIvNW8fOB%2BDagSYXBRQz3zFQr0cV0WwdEx0X0eLShqlW5PkU%2FiylY6WEm0nyAaE5WQTiDF1ApNsHVR4Q%2Bt1HBBg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 17:35:55', '2021-02-28 12:53:39'),
(DEFAULT, NULL, 'bsuarezluna@gmail.com', 'Bryan Miguel Su├írez Luna', 27, '+525577918932', 'WSP', 49, '2021-03-30 08:50:21', '2021-04-06 08:50:21', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Plandemeowm', 'https://www.wattpad.com/story/218211376?utm_medium=link&utm_content=story_info&utm_source=android', NULL, 'La obra aborda la historia de un minino el cual fue adoptado por una familia, este es quien narra los acontecimientos. La trama comienza cuando la rutina se ve afectada por una epidemia que ha llegado a la ciudad, el felino comienza a indagar sobre lo que est├í ocurriendo mientras la hermana mayor de su humano est├í en desacuerdo con la cuarentena que fue impuesta, tomando as├¡ una decisi├│n que mete en serios problemas a todos y da inicio al conflicto principal de la historia. El minino y su familia humana deber├ín superar esta dif├¡cil prueba juntos o morir v├¡ctimas de la irresponsabilidad ante tan delicada situaci├│n.', NULL, 'Busco trasmitir la incertidumbre que aqueja a la sociedad ante un suceso como lo es una epidemia y el grado de irresponsabilidad de algunas personas, as├¡ como la corrupci├│n y malos manejos de parte de algunas instancias de salud. Tambi├®n el tema de la familia y la atenci├│n que los padres deben prestar a sus hijos para evitar que estos se involucren en situaciones que pongan en riesgo a todos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/f1e8641a-d669-46d5-accd-793cd3b44ff7.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=dcp1URfpVgy0ItbZmS0KsugP03zKXS3CzrOqZd1hY06lVazlTcSvBkBzSwwu%2Bpcpx1Nz5qdqR9muoWx6B7TYrrS7Tuln5x94nSTxl2t%2BbxoM1GGwFjJqZ%2BpNeUTxnYrCJy8lv9cjxTFwembQ9rqRfvGRMHkRVqBCY0nJZaUoJLFAw9Fn4cIM3n71k%2BdyT1iqhqw1SWTUHGAmbS7XcJd5gZlhMJMuG25slxfvrHFJoz3K7QhF1GLA2c1cTSRCAc3N%2FqA%2FSxaCxQR47mmDaPnIzLJlPXvojVW1DfbtDbYXAI4aZ2j1CTr7WO0XdPCs4B7SkT4fJpZw6LBYPI3o5xLzgQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-23 23:59:49', '2021-04-07 09:49:30'),
(DEFAULT, NULL, 'Priscilacena14@gmail.com', 'Priscila Ayelen Cena', 21, '+549 3484527507', 'WSP', 116, '2021-07-13 22:01:22', '2021-07-20 22:01:22', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'Cassiope├¡a orwell y la piedra filosofal', 'https://www.wattpad.com/story/188959969?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=PriCena14&wp_originator=BUD4vUdpuup4P%2FF5pG64QLnwjOSHZYEFPA%2Fh6B5BrkYilhfNk4YwT8HhCgzCIWOHP2l597zklt0Kvc69oBIcoBY1Wx237rfgZ%2FHBLWe10GQdjkcmcKm1AeYVPu1EOfRx', NULL, 'Trata sobre Cassiope├¡a Orwell, una ni├▒a de once a├▒os, que entra al Colegio Hogwarts de magia y hechicer├¡a.', NULL, 'Deseo transmitir magia y emoci├│n, en est├í historia basada en el universo creado por J. K. Rowling.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-07-03 08:28:54', '2021-07-13 22:01:22'),
(DEFAULT, NULL, 'isamxk@gmail.com', 'Natalia Isabel', 55, '+39 3473531866', 'WSP', 52, '2021-05-15 21:56:39', '2021-05-22 21:56:39', NULL, 1, 'DISENO', 'POR', 'TOMADO', NULL, NULL, 'Amalia,victima de violencia,con diego recobra esperanza y aprende que hay sue├▒os por los que luchar.', 'https://www.wattpad.com/story/247734398-amalia-parte-1', 'Natalia Isabel', NULL, NULL, 'La imagen y la idea que tengo de Amalia, una muchacha de 17 a├▒os en 1848, que tuvo una infancia dif├¡cil, tuvo que enfrentar varias p├®rdidas y una experiencia de violencia que la dej├│ marcada. Ella est├í malherida, pero encontrar├í el valor de abrir su coraz├│n a lo nuevo, a las ideas y los sentimientos que conocer├í de la mano de Diego.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F49749c3e-2282-4613-8b99-b907b368b6ec?alt=media&token=ebde8bf9-6b08-46be-b1bb-cbe48e9bd58c","createdAt":"2021-04-25 13:13:22"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-04-25 13:13:22', '2021-05-15 21:56:40'),
(DEFAULT, NULL, 'fjberistain@gmail.com', 'F J Beristain', 82, '+34 655918651', 'WSP', 51, '2021-04-23 11:55:52', '2021-04-30 11:55:52', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Remordimiento', 'https://www.amazon.es/dp/B01N77MRRL/ref=cm_sw_r_cp_apa_S9SX7Z90BBBEPVN38AYV', NULL, 'Novela polic├¡aca', NULL, 'Suspense', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a26a5433-8c5e-4d29-8982-295bf944b653.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Kf%2BTM3FTwwBW4ALNZeb7BLGSrV4DUCQjX4wUCVNU0MxuKjFI7owy8%2BLawqrwH%2BIQGuTfYzjMCwD7bbdTjafaaWPk3rjnG03hil0Z1uimYUs54qhzMNiwRvjpkdqBhxGzIR45lu73Uzn5q3oylON9Fa8BtOiGlkAf5A1zWYd8CuHhkGj91qf5Gd5ncF0ZQ7Qh%2BNiSinEcDtgMXtzLuvbIJoqoanS3vTV53u4T%2FwLCQ0G0Phh1VoaoQx3SxiBnFCaloSpTlEjk%2BQT7kEfl49LKyk7BWMFfYlJjrYs%2FEzcGvU6xU02h0Z2GWZjVpEnEo9Qg8aK5%2F0kjUQfeON826hNtGg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-01 10:18:52', '2021-04-27 22:38:26'),
(DEFAULT, NULL, 'lovelibros2233@gmail.com', 'Melody Dom├¡nguez', 23, '+503 77381264', 'WSP', 112, '2021-04-18 13:36:37', '2021-04-25 13:36:37', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Cansada de Tanto Cuento', 'https://www.wattpad.com/story/195866772?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=library&wp_uname=SkyDmngz&wp_originator=NA7Lwodtv1OBZAu4IKYMX%2FqcDYqzU41DQpxJ%2Fj6lIJjPkHi8TZ3N3vapbkrjCst%2FRnl9jYNZaJ1thCvktnYAaDxLJMPozuhEpNvU55oQBbP99pIfXOdwSbH%2Bc33LGexs', NULL, 'Mi obra trata sobre como las cosas que se sufren en determinado momento de nuestra vida pueden afectar a la larga nuestra salud f├¡sica y emocional y nuestro trato y relaci├│n con las personas, mi protagonista ha sufrido mucho y cuando se trata de intentar superar sus traumas pierde y gana, pero lucha para dejar sus miedos atr├ís', NULL, 'Deseo transmitir el dolor y drama de las situaciones como violencia intrafamiliar, abortos, da├▒os emocionales y soledad y no solo eso, sino transmitir esperanza, de que las cosas siempre se pueden solucionar, que todos los miedos se pueden vencer y que podemos ver hacia adelante con esperanza.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/bb2bf9a6-1672-4ccc-a136-c6e8c65ed362.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=lsakHYG816mue%2FRvx3Z8NDg%2FSn52Hpr6wTCsfOabA5tUO1mxPT0bqykIS1WgKi6MfszxkdY1FMAzrdrWx8VvyJO3iq8934302ZtLZeiAoS1lCpOzu9SjSt6u4RTw%2FsPAjeIo57Bu7aZI9IOZrenRW%2Btp3NfhIWB%2BH20gMTl%2BnNro7AbVALAPL0yFw%2B2hBeRDjPGYRIsKWcz3t7z4mGtH3e29Sl6v8WfX%2FlzwDDsAoPVDw8jhUsDfdMAsBDRHpt5HlhEoKDTHF%2B727yCQEcvePZpLwpf02ZzXje5yBHE%2FNUZghidabRkvJ%2FAkvv3kttWorgjdgGnMJ21xtmhjs5Nvjg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 22:01:42', '2021-04-21 20:47:19'),
(DEFAULT, NULL, 'rolopordios@gmail.com', 'Daniel Alejandro Mora Avila', 18, '+53 55995290', 'WSP', 64, '2021-03-01 23:21:09', '2021-03-04 23:21:09', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Stigma', 'https://www.wattpad.com/story/253359968?utm_source=ios&utm_medium=link&utm_content=share_writing&wp_page=create_story_details&wp_uname=DanielAlejandroMoraA&wp_originator=vi1CSj5qgC84mTHWiUoDAxiwNXqLsxO6GPycTVZDyjljouPeCmoq4N7is2q0P4Bs1ACvj21%2FLBRTU7L1E3tItdmSNi6wEGEGG1c8aANbaPLwPighs8a63nfVZeCLOW5k', NULL, 'Mi obra trata sobre un grupo de personas llamadas Segadores,personas que  cargan con un stigma al ser tocados por monstruos sombras llamados Souls', NULL, 'Deseo transmitir al lector esa sensaci├│n de querer se el personaje principal,de tener sus poderes,de sentir sus tristezas y victores,en fin emocionarlos', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0263f20a-1c90-402c-a278-a6ea10067efc.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=ajVmYNIs9Wa2pvHLe0UNtynDmWcLekFQETP2eE09W%2FSaLD6fc%2Ba9EWaOeZKDVmx7BUdQWJEg61uopZ5QTgAiDxOrWss2TbeNPerByBe8dkPQIWGfTe%2FuuZZPjRuirSjKlmKHb2A6fw9vdE%2F6q81DqfmzOVMTKEMiuZAa09V9XL1bCiiUc39GoQ%2BQX5%2Fs4VdIFYcgriEvRmf3LWn5wCh2esPqE506rjry2jY97ewIzK5fp%2BzFWsaIkAP29W4Oa6iSpUzdntodyVoQ%2BokaqUXRZ%2F1nphfkYHXiCnV%2Fg82Olo18IhaSopN5PToWK3j4SvFGip5BPYh0LRrpVrR7XXDLmg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:57:41', '2021-03-01 23:29:29'),
(DEFAULT, NULL, 'faby.45eltalvan@gmail.com', 'Fabiola', 24, '+519 76015411', 'WSP', 58, '2021-05-06 10:44:20', '2021-05-13 10:44:20', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Bit├ícora personal...', 'https://www.wattpad.com/story/257550998?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=montelv7&wp_originator=%2BPIPXBCKnojMVF35nrvhNJDhQo%2Fq9%2FtcEygBqcn4zpQ24WsXXkTkXuFj8AbvVItVB%2FMK6zs%2FA7%2BDqPXdLd3UeVG1Jy%2FHviRt8rjET8GqGoqmUlLVFhA806uOBGBlUhSR', NULL, 'Trata de un adolescente que en su desesperaci├│n de buscar un trabajo acepta espiar a una compa├▒era de su curso que no sab├¡a que exist├¡a. El adolescente piensa que el hombre que lo contrato intenta secuestrar a su compa├▒era de curso, pero le urge tener el dinero por lo que se dice a s├¡ mismo que el d├¡a en que la secuestren, ├®l llamara a la polic├¡a para que se hagan cargo.  Pero descubre que el hombre que lo contrato es el hermano mayor de ella, y su intenci├│n es buscar evidencias de que los tutores que tienen a su hermana la est├ín abusando y sobre-explotando, nadie de la autoridades le creen porque tiene un historial criminal.  El adolescente har├í lo posible por ayudar a que su compa├▒era salga de ese agujero en que vive.', NULL, 'Deseo trasmitir una historia de misterio, juvenil, leve romance de adolescentes, mostrar la vida que algunos sufren pero lo oculta por el temor a que suceder├í, esperanza de que alguien pueda ayudarte.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/d66a8676-e857-4033-9457-3fe8e6957afa.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=wt%2FlCIBlD2cA62ZUDZBXEQ%2BxofearvlX1ai3LUyZNo25UThZ0xJ%2BfzNPNYVBwUOH5eJ8bYkUtaCOs79DHX07jmPV4PeeMI4qh7FRkg%2Br16%2BbQCzdJVwB0R4TCwzDOBtNTzKBIDsshdjf122CRbkE%2FGVqEKh3p%2F7JnFH2gGvJDMqIH7Qg453wylIIBCaxakXBq3rBBX%2B38qVGtWisWWG6R6bUsKoIQMsqqa4xAFUSdUxqOykR1s71SE8ral7EaFvWO%2Bx2%2B3HigQF9lQocUOdpNNXjo1zbSfzFqPN8AcbI%2FAkDUzQ3cNs1N%2FeYDVeqTw6uDi%2BKn4oduRIRwHcmDFaDhw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-22 13:00:52', '2021-05-13 11:16:23'),
(DEFAULT, NULL, 'monicagranada30@gmail.com', 'M├│nica Granada', 18, '', 'WSP', 49, '2021-03-24 22:08:02', '2021-03-24 22:08:02', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Aborto Fallido.', 'https://www.wattpad.com/story/251382037?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=moniklejandraherrera&wp_originator=NGEKHXM7hSOp%2BZl9kwsmL7fOsYAUvzDDROktNaibsK4tQnxOCbRyO70p2Gb5JSYDRDL%2F6OftYxfCQEYvQSzgVL%2FERsgM%2F%2Fq5HRgbhU%2F%2BcTTi%2FPLb3wt00NiAiUWIT18N', NULL, 'De una chica que hace todo lo posible para vengarse de sus padres', NULL, 'Deseo trasmitir el temor hacia las personas que no apoyan a sus hijos cuando cometen un error.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/80365fd1-68f3-4ef4-8b39-88b9d83bdf62.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Cv%2F9FjiRrYSqVmswsMNdQ6qo55B36ttFmE9KS5NeSGlHbmEX9Ghf4Kbp6o2FpQKn7YZaHsWzrNZlNFIT5KTplE7ehYlpJ0hlAEq3sHM9H4xPi196EFywBh%2F4sEbuR5Zoin%2BoCLNp3mouLqnqN0MytmdLF%2FP1QBf%2BN%2FTey9dAVtxjqTEyjqVgyQDPxxG9W2jtI2mjZVq6lLcv2l8ZAQOZBw6wIA%2BnlIWipmEkHAHdRnApX8%2BZRO5cuDem3AohCrr3okhAow7NOqi43u%2BclHuOHOnoQUYGFIk25Oi0f2wPhJqCuZfdj3JLe10DVIyrSp92TTz9pvqvRCaBNa0NccSh3g%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-24 17:40:15', '2021-04-01 12:09:19'),
(DEFAULT, NULL, 'kenserjavierlopez@gmail.com', 'Kenser', 26, '+5804128440883', 'WSP', 116, '2021-04-20 23:36:42', '2021-04-27 23:36:42', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Vampiros y Brujos. El Inicio', 'https://www.wattpad.com/story/244984359?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KenserJ&wp_originator=ztWNKvxiNrtWrLuO5WV5xS9G40vKws7DXY0QE%2BEe7AwDBqQR6uEp1zH0Sz2B7sns8ATuCihBvZa%2Fp%2Fe89m%2BjmsVMLJKA%2Foo4deeMNRMMuTXR2oseoR%2Bqa2GkZ9Gh%2B1TN', NULL, 'Es una saga de fantas├¡a, trata sobre la rivalidad entre las razas de Vampiros y Brujos, enemigos desde hace siglos pero tendr├í un cambio transcendental cuando una Vampira y un Brujo se enamoren llevando a que ambas razas se vayan a guerra.', NULL, 'Qu├® no importa de qu├® raza, o especie se sea, lo importante es dejar fluir el amor y la uni├│n entre todos. Que el mundo est├í lleno de diversidad por razones l├│gicas y as├¡...', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/c459b3ed-b0b1-4870-9d0f-7e88ad9bc3da.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=UIIPYjdMUjljMNZvsDw7BodJvzbScZPgSoDq7f9pL31UTl%2FZjq0xgj4Gxbom7zhdA2QgxUIhmmxBSRAdha%2B6qB0BnCb5Gwiqs6uVPbV%2B7zscUJfx3cw3GCuCabEs5mU4B58X%2FF1VPIur9J8jyDTP1UwxjPLJzD7fdQ%2BBvTu87QBZLhz%2BqY4gyK4Zs2xJNHKWEiK1C3QUxeY2mJ5ISRPuVbiGft7nlSlMnAauaG1aXqqly7b4yTlXVyH%2BxMCvpvoEiqa24ep0YRQcDU54rXsqyyEEmIGm0hLG3DU3%2B1L3Dtq3MHAKXuu3%2BYSHBHGUGZbSlLCeI%2FDSwgpZCe6kc5WBIA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 23:20:10', '2021-04-22 14:19:03'),
(DEFAULT, NULL, 'dafne.roj.19@gmail.com', 'Lisa', 21, '52 55 3035 8427', 'WSP', 52, '2021-06-15 16:01:17', '2021-06-22 16:01:17', NULL, 1, 'DISENO', 'BAN-WTT', 'TOMADO', NULL, NULL, 'Fui creada para reinar no para amar', 'https://www.wattpad.com/story/269030769?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Ainadprecius&wp_originator=6ejTcOikhagJghn4CZPc5n6HTUd45GO0l57m3neopCfkwqsTI%2FGt2Xbyhi1bIn0G0w9WbcmsTuvF6hnwbLNW0KrDtNSP8XDURoj5MzVRuC89EJf3UMFz0%2FGtizjY%2F8Mp', 'Central city', NULL, NULL, 'Una mujer besando a un hombre, detras de ellos unas explosi├│n. De preferencia que la mujer tenga un vestido rojo y el hombre un traje', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-06-14 16:04:21', '2021-06-15 16:01:18'),
(DEFAULT, NULL, 'yackelincastro384@gmail.com', 'Yackelin', 17, '+51946535783', 'WSP', 115, '2021-03-24 22:33:24', '2021-03-24 22:33:24', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Tormenta en mi Vida(escritos al coraz├│n)', 'https://www.wattpad.com/story/261193647?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Yoba_Castro&wp_originator=71nzUYTCNAnj7F0h31a2hZme5oQT9OIruOTH1455S8eeqRjZCj3crUwRT59K%2FddGrcb%2Bv9V%2BuhFJjs%2F%2Fqq7hhQdJIcGrjSC803tVNvKriD6EfKNSbEdr%2FSJRYV0TwfJ9', NULL, 'Mi obra son escritos al coraz├│n de una adolescente, en cada escrito habla de como se siente y vive con temas como el amor, relaciones toxicas, depresi├│n, soledad, abusos.', NULL, 'Deseo que a la hora que los lectores lo lean se sientan comprendidos. Tambi├®n busco transmitir tristeza, melancol├¡a.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/c271d28b-2dd7-49bb-ae92-9a187827a8d7.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=FaoCsyUT9E9b8zo8ekanC6AWtHTrOuC1Be64Y6hQl3BOE0nbr53pW%2BnY4dHl3qoAiZK6b1KRAOo4CGSnAjHO10EmOP2atzzHkVhR4VDAYd9cAdEDHUwzJBDmpsEQ%2Fl9RrHTp1d8jvu%2Fa3x1GW0SIB0SAAIdWaBxkLOQPzYiSywEDDBxfSHJmMsmVa8YkwhTXIe0yiodDUaE1Xpb6iVVRY2Gyc1%2FSU5w0TEq%2FBlaf2wepwcckCEtiiPOx3l5ALlmBZB0FBg%2BY3nydU%2BonKLZI9DOenumpdU0mQyzdnk0KbuV8Vf9Z1XnkBits081BMd6sMdiL4ddq3zeMOv7NCONvJA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-24 17:31:32', '2021-03-28 17:29:26'),
(DEFAULT, NULL, 'nhardwer@gmail.com', 'Marcelo Hardwer', 22, '+56954343393', 'WSP', 67, '2021-03-31 13:07:58', '2021-04-07 13:07:58', NULL, 1, 'DISENO', 'BAN', 'HECHO', NULL, NULL, 'El sue├▒o de un pueblo', 'https://www.wattpad.com/story/256602983-una-gallina-espacial', 'Marcelo Hardwer', NULL, NULL, 'El estallido social que hubo en Chile (la violencia)', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fff2c4475-ae30-4357-80f3-aaef772681e5?alt=media&token=50472205-8399-4b77-98c7-038c2b51be73', 0, 0, 0, 0, 1, '2.2', '2021-03-04 13:03:18', '2021-03-31 14:07:59'),
(DEFAULT, NULL, '5585453784cuatro@gmail.com', 'Mart├¡nez Mishell', 18, '5515388405', 'WSP', 120, '2021-03-23 19:01:43', '2021-03-23 19:01:43', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Amor y ODIO', 'https://www.wattpad.com/story/117961833?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KatSuMeAkAkKu&wp_originator=UiLWU%2BIILL1FaPTDFsjjr7EcuIxdw0Tk0AsEeMiRE1gJ5vkUkM%2BmAFdEsR0H%2BEOP4W5kzmbIRcu3ZLo48WJB%2BANjpYuR8ktbDbhKQSigPXBZ8ky0UM0g%2BYjabzMzahtB', NULL, 'Trata sobre dioses, los cuales, dos de ellos, los protagonistas, tienen un problema el cual los lleva a tener problema e incluso desaparecer.', NULL, 'Diversi├│n, romance en comedia y un poco de misterio.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/86c61a46-394b-4b5c-801a-251f4b870722.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=OTT3Tt9DNw3aKfdQMd0%2B5Jalx3j6WFmnB6Iz6me5yTsV5AY1OXOVXNFEtHgKmfhaLnuvUmgJSSiUE8jq4DWR4Oq4KVEjdyerYPLYJZ7BM7dD6h%2FYEN8YKg8WaxdLqHajxvmGmucPa2REbPYNCyCIMzlx4dgqFOipEfTLnGTZqPpU66d2ax7ySun2wtfpNUesEtgHw6H3O0wn%2BkDTiumMSFqPm9Huxwucc9%2BiC%2FMfGwCB%2BaYWzY%2FqotUuvexCtxIEBOs5IF2IAWwnTbFtCUYtwsVxYSE8gezGSUifAxirt5weSZFSqxlURD573V7TapAWLeqpiKkes%2FCavzFAHzo73Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-19 23:25:13', '2021-03-29 12:22:09'),
(DEFAULT, NULL, 'minare_regelle@hotmail.com', 'Mitzi Nallely', 21, '+52 5521332082', 'WSP', 56, '2021-02-27 17:48:34', '2021-03-02 17:48:34', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Mon├│logo de un boceto', 'https://www.wattpad.com/story/244715263?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=MinareMountRegelle&wp_originator=%2BWnwnIV2wDkpj%2BCB3oY9EykDR7tjmc8%2Fn1Eaae1w60fZaD3TCLOS5xbGvlvfzLj43H%2BHRPWyy5GKkN9k8fwMKQKPoI2jFJ2rc8nbvcSw3l9Ca8uU%2B6gdNEaDY2ILuziw', NULL, 'Mi obra trata sobre las formas en que el arte puede ayudar a una persona a sobrellevar una situaci├│n muy dif├¡cil.', NULL, 'Deseo transmitir un mensaje de superaci├│n o liberaci├│n. Tambi├®n de aceptaci├│n.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/03884efe-056f-4f66-b51b-fc4290ec8678.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=E1rmGWc6LUJZh%2FBXQXTZUQ1%2BqCKXKylPy5Fm0%2F2Yvssnn4VIuAGJ5GETeTbRrx89CNcu1ndlZB1MG0nFJ562GABtDa880z%2FQ0Gl7ScDrZIGODflNDsc%2B2ZUQxEXxrYcR6V2jWQnYHFW6pPvAUyPqme2UeQVRYRX%2BrIxHGv5cnNf43Q6nUxHuYdgHxjB98x%2FK9bWgmQru2d08sUI%2BcXJGr4uhPZMwVtutc5dOSED%2BErgvl5o%2FhXQbmqdyiVUvacX5YJUsHknIgDAhGRrb%2FoaDuWf6ow%2BLNR5tEDpJpYRnwqyGKIPiDYS6C5hLBN65dIkKy6F328vzNQPXdPsTtX6o%2Bw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 17:30:35', '2021-02-28 11:50:48'),
(DEFAULT, NULL, 'karen.rosas@ceuni.edu.mx', 'Karen Rosas', 23, '7352060371', 'WSP', 54, '2021-06-04 19:14:09', '2021-06-11 19:14:09', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Cayendo por ti', 'https://www.wattpad.com/story/245932461?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KaryRose7&wp_originator=4uexb3CuMzDcaB7dQ1LMUJF9fKRNcrBa2wjiPe79mPq6uOiK0MhzsUSoDX7zGpQg8a9doEqOocO165m6zfvLRE%2B7F6TbFRXiqzWfepjrfi6gifNoYCUZ%2BNGaP8%2BDZyDW', NULL, 'Romance, er├│tico Audrey es una estudiante de ├║ltimo a├▒o de psicologia, quien termina con su novio, las circunstacias la llevaran a conocer a un enigmatico hombre quien revuelve su vida, incluso 3 a├▒os despues', NULL, 'La pasi├│n de los dos amantes, el drama y los conflictos', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/d68f31cd-eded-4fe3-bdba-cf2600061268.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=O8w6pts1Uo696D6IFYL6XwhcD3L6ROa9h3gzZ4miDds15WbW27K%2BXY3HGmyhh0F92CcvCAwnZwsTtrlD62PGTDUINZB8FM%2Br0BcDHI1MmHIPrPwoYPF5cMkT7LZRIae3WBZHN9J3i7pln32LvzNL6sWeAJbeh%2BD4ujIAfOYJnFJMgoyNq6CrsItaDrCGeK121O8ZtduJrPAQNKcXWbVWmyqZJhKdvlwgspAAnBrJAUtiai2iY41lXkslsJPPXbSjw%2FgcOn03wX%2Flg5przTjNDngkyAop8uJUONOleGQN9hlr2eYq1Ifv7ITSoHbIjD72r1D7bcOh0OkumykrXeIrqg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-26 16:14:26', '2021-06-14 13:13:34'),
(DEFAULT, NULL, 'conchafigueroa236@gmail.com', 'Roxanna Navarro', 16, '6421403916', 'WSP', 62, '2021-03-21 22:57:00', '2021-03-21 22:57:00', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '├üngel guardi├ín', 'https://www.wattpad.com/story/260309403?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=cheixxgei_&wp_originator=X5GvU3E6afxVOQx5bmfdrehBNuWVO2wgcv7KUNzHgiT2FG5%2BYUkzHhAtOHb4huiLI3IFAR3ca29POM1PIIj28tC%2BrxxrKL8JaT%2BfzLWR3f1PfGq5WriH3EwC11w%2BvXi5', NULL, 'un hilo rojo roto, dos dioses que son hermanos y ya no se hablan m├ís. Pero espec├¡ficamente de la relaci├│n entre el ├íngel y el humano.', NULL, 'Amor.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ce180c75-7a57-47a0-bcba-066ec068795d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=3L7C1kYEbOY3PyM00zY3Iz4P%2FWB%2Bt5BRmMPgqsxl3WbiRfsVJP%2BaOYjPs%2FTglkBHQbzHcbpwN9IlapczMFWmmUQ40Q6CoXbzHom6G94uMaXV%2BjTJQvIyVRLHe5XSCfZXUHA8%2B0Cf93F0cUN5wfJekyQuCRwoIL6aru1IJnCk78ki6mtPapWhoOPaRpYKN8TKadS7neq43c%2Bx0Yn7m4JwecrnbBcH8OmA3iLcce0hiWaMn65V2a8aQXvnuyf71YLoHKSiGS%2B8cE0%2FTbNvaEBzTYO%2BDqhOnWCSXS3ZMWT9vXGdoyqQRdxEXnrnFUIa4s0VLTRhRbQ3MWRTl2xAtEVriA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-19 00:25:01', '2021-03-21 23:02:08'),
(DEFAULT, NULL, 'm.alejandracampor@gmail.com', 'Alejandra Campo', 24, '+573103278832', 'WSP', 58, '2021-06-01 12:04:35', '2021-06-08 12:04:35', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Hypnotized I todo tiene un precio', 'https://www.wattpad.com/story/231858144-hypnotized-i-todo-tiene-un-precio', NULL, 'Romance, drama y relaci├│n prohibida', NULL, 'Quiero transmitir emociones que lleven al lector a empatizar con los personajes y ayuden a que deseen leer m├ís y m├ís', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/44fa5b81-5947-48d8-93e3-37c342233481.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=h15Shk35VwSyI0YvdfDS6SLsH8Eu0yBnbqGraCRFyKXdo1aBlY5AlEWjd8DI9ovibX%2BL3qqVnuDc0Lvk%2FJc2Exy5IGBxI7ajgOwJlC6OtzZjU%2FAk6iFIW7ADiZ2ytsbs52%2BE1dn%2Blg8A0YyaO8yaDmo5obuYARKjGiPj21rs3prOL8jjoUJ3uBbxkytTzhkyjP9CwCqtEgBbz7JldKnbxjorUCKmI6MiWt7M7HHIMwBp%2BzA77id7NVQeYbs6syu2zD3tleO1B6Rn0nvyQu5Vcz9gQvhYlYduNl8ZCsB7aJ%2BvfAWhmEozuTCkwe52gSWLPuYinu%2FxxsWQuOoQf0Z16A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-17 18:06:56', '2021-06-04 15:43:53'),
(DEFAULT, NULL, 'nururia28@gmail.com', 'Nuria', 21, '', 'WSP', 62, '2021-04-01 00:40:16', '2021-04-08 00:40:16', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Desesperados [correcci├│n]', 'https://www.wattpad.com/story/220193586-desesperados', NULL, 'Son 5 historias enlazadas de un grupo de 5 amigos. Principalmente trata la superaci├│n personal.', NULL, 'Superaci├│n personal. Cada uno de los protagonistas tiene que enfrentarse a diferentes problemas y sobreponerse a ellos, creciendo como personas en el proceso.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4aac7e0e-db94-42cb-9bc7-572f02b9a6c4.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=w0dGyik9%2FA%2BuGlsZYUzWs%2FZysF8t0%2FullAXH%2BfPeUud9WGlma0BJkN3qnQ%2FjkrrzV76m9DkVGbp9fpCsmBodq3JtNlzw2by56IqlygYK%2BwsgJeJlmNUT0PvE%2B9hLXHWAE2ryXvWynTrV2qGuNKjedMp4QF%2FEQmnf9TqZWJKbPDGIh%2B%2Fc2V%2BSJUduZXTSxGtUPhc0ekXTC%2BVLOaUqnP4Qs3k708vnzcwuq9w%2FCYFZctKCpSW%2F%2Fi2B28UVXtCGdpivcoOLR1PBKMZAyW%2BaxhXwdQW33ckiK02DenuaCgsb6i7xfDULu6BV%2F4ornOLpjKVRwZm7YMpI5TqcuAWo79HJ6w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 00:38:16', '2021-04-01 00:51:07'),
(DEFAULT, NULL, 'karen.rosas@ceuni.edu.mx', 'Karen Rosas', 23, '7352138041', 'WSP', 52, '2021-04-22 02:05:08', '2021-04-29 02:05:08', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, '├ël es mi destino', 'https://www.wattpad.com/story/245932461?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KaryRose7&wp_originator=PdjAd4UVZzVuLm7lyOecqQf8fcdzMvhtZod05bBvRjVYjzwKzprTRTjiUo12CDfw7tHf%2FB%2B730EhZGvxGLctnMaqGTXF%2FaU7VspoHd%2F2fSX4F1gpUvy9648VwGel7b2E', 'Caroline Rose', NULL, NULL, 'Es una historia de una chica que ha tenido un solo novio el cual la enga├▒a, y lo deja, se encuentra entonces a su verdadero amor, pero con ├®l llegan dificultades en su vida, no sabe si ignorar el destino o luchar, hay dinero, secuestros, mafia, pero sobre todo tambien hay mensajes por flores, implico mucho el lenguaje de las flores.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F7fb9faea-8e6f-4f38-96f1-1543ac65fdd0?alt=media&token=75cebab8-20ac-435d-ac59-0984b9a4c27f', 0, 0, 0, 0, 1, '2.2', '2021-04-02 18:40:09', '2021-04-24 20:17:31'),
(DEFAULT, NULL, 'pablocdm2@gmail.com', 'Pablo C├®sar', 22, '+504 32373586', 'WSP', 51, '2021-05-10 19:10:06', '2021-05-17 19:10:06', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El rito', 'https://drive.google.com/file/d/1Nx7tRoJzlVkyyLqtJ7SUR-20cShN-mB3/view?usp=drivesdk', NULL, 'Carter y su mejor amigo llegan a concluir sus estudios a la universidad de T├ñtza donde comienzan a darse desaparici├│nes, suceso en el que ellos se ver├ín envueltos', NULL, 'Mi fascinaci├│n por el horror c├│smico', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0919ca69-730e-4186-8b87-4f064a94d35d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=YNY6M4MSfxUjMsXJ0eMe92YKlbzsme17P1%2FVlrTbhjnI6aJJmIDdE%2Bm3fHHfhXWwdMbYrI8t1u4cd0hZuN1yZ1Om5OeBN%2FCEQG2rSWDlcZ7sENSsFxDNeo8R4DJE0BdHlACBRs2I83wt5jE7T75BVB%2BR9CbXDrEwzjPwuBryzwEGPaBJUNPNi1qi4SiOxiy8hg0q1DAqfqEdzh0qPb2qLqx8i20aWEMRyPPu5wneP%2BBfs5B6TpL20OkxPiHLQk5WcE4ywzxQQFLbJhrRmUfRQC2q6oOacQTVN%2FleIFQwU70dxrlfkp3yBharigdM8JdOO6m52MdFGbB4sFFEFyhc9g%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-07 17:11:27', '2021-05-15 10:34:38'),
(DEFAULT, NULL, 'yen.ccdi@gmail.com', 'Yerainy Encarnaci├│n', 18, '8094647428', 'WSP', 67, '2021-05-08 12:59:54', '2021-05-15 12:59:54', NULL, 1, 'CORRECCION', NULL, 'HECHO', NULL, NULL, 'Por culpa de unos zapatos', 'https://mega.nz/file/yqZk1RpC', NULL, 'Una mujer con un pasado complicado que no quiere ataduras y un hombre que lo tiene todo pero lo que realmente quiere.', NULL, NULL, '', NULL, 0, NULL, NULL, NULL, 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-correccion/24b62372-44d3-46fe-9806-0f2a7fbd0b4d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=TcsP5%2FlYAlQJv5y9HJM%2Bw%2F3ToiBgc4f9Cd4Lad8etbUaJ2ibBe6K%2BbZhlyFHX13Ize8J%2BoyUehz0SzdEYCDhijRm8yeyYj7VQb2aXMxBBLLdqfiREb5yFEIeTNvRbs35ArKgsYzFQKQWXFEcHFeBW7VDQO9MI55LSirkHeB4OzAxCUvuQ8wFDJawzCKfENmGZG7nm2P6WlCvYT8WkmGGwu1XDwEACooURGwivqKJI0pyic6ZiiVxRBu7Cl3wPS4BLGkH0MvbSJ0NGdjlWGwC2tB34F9V%2FOUDxmX4sPCtIG7%2BJotPIzRet0cJgwMSSdkw8lmQOEyaIvVOFDfqj41tcQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 11:02:44', '2021-05-11 09:07:57'),
(DEFAULT, NULL, 'escritorabb1contactos@gmail.com', 'Ana Minaya', 16, '+51937614982', 'WSP', 62, '2021-04-12 21:31:50', '2021-04-19 21:31:50', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Que ocultan tus ojos', 'https://www.wattpad.com/1037104991-que-ocultan-tus-ojos-cap-1-familia', NULL, 'Mi obra trata sobre Denisse, ella es una chica muy social o eso aparenta, todos piensan que es una fuck girl por todos los chicos que dicen a verse acostado con ella, y no piensa rectificarlo porque siempre se le acercan chicos guapos que quieren con ella,  pero en una fiesta conoce a Darren un tipo nerd que bajo los lentes oculta un gran secreto, ser├í este el que cambie su vida para siempre.', NULL, 'Deseo transmitir un mensaje de un romance juvenil, que se enfrenta a problemas por los secretos que guardan.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/f9bc39d7-585d-43c9-85b7-5822c524ff1f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=a22dQ0S1D%2B%2ByJce%2BBBQyZbTMG5BeLFmVoIAZH87Ga751gjZ2T%2FdIBEf7%2B1qwadO6bH6S13c%2FIVLGK37TLaikdnXBGoVCbyISCeek0UKM%2Fv7FxaQivtZr6MAlj0AecnRd6zD5pON2eLNY0bBDNwbyvqUj58XPAd1f1Min860MYlvBA15cdHInRg9wUhHv3xmpe0%2B02u8w2e7ZoYpzLf%2B9wpt2bYLzFe9DjWkKg7HkDDf3CFEfiPXg6Qp8hDxtrHgvJ9alC1%2F6m6ESQvd3V88I0WODor1IRGD1i97EDLPCbltTjAAZ8Xpx7LeZu%2F1S11vI7rpa39scGcTK9UhbEMjExQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 09:54:33', '2021-04-12 23:57:29'),
(DEFAULT, NULL, 'melanyportilla@hotmail.com', 'Melanie Portilla', 19, '1123775114', 'WSP', 60, '2021-05-23 09:28:54', '2021-05-30 09:28:54', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Viajera', 'https://www.wattpad.com/story/232211289-viajera', NULL, 'Trata sobre una joven que viaja a una dimensi├│n diferente, la cual se encuentra dentro de un libro, y busca volver a su mundo pero se ve envuelta en la trama de este libro. Mientras hace amigos, va olvidando su mundo y descubriendo que su madre es de ese mundo.', NULL, 'Quiero hablar sobre los tipos de amores, la familia y como los planes de vida pueden cambiar.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/cc375a4f-cc67-47e1-8e9a-d6f4ced8d326.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=zYPcjYLJGdj%2B%2BzrtKHbFaD3nlvxw%2BMGUDmz1axgaMG%2FfuSlwuz%2FNkWfR5u%2B61h6Kh2M05CVRRV6K%2FjmVlwQqitP1YOXnaMuIxybNkAzEd%2FI85Chf5cI5JQmHVK414hcQ3eJs%2Bd5O%2FXfiluRAv%2BzQUicn%2B6Kfqzxkfa%2Fm7feTlZY4dPKSrkvHgLXX5rj%2FD2B1YOUjP%2FGRXieUnO03rSNFOc7m4DCts6iIVcQIBfK4%2BtmhNdp6qvs4JoAGkVcp3Obas%2BUVfxrwhzyhjsNeCHF9V4XamtItRbGKQU4bJo5Unn11onLGmEX1VNqR8QxqkF0ZheDBNyhK8A49gXcEl4%2Be8A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 21:59:34', '2021-05-26 15:31:12'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51 902123505', 'WSP', 58, '2021-04-21 16:44:19', '2021-04-28 16:44:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'A la vuelta del parque', 'https://www.wattpad.com/story/263097960?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=Ue0Ng%2BbUZ8V%2FR%2BZOzGcCP74IkxtCdVTpvULBrDAMrZfiSkOPK2p2rGrkrxhntnJSY6RpofcWxgMTXd2wQr96O3TKh%2F9GGB7LuR1cqBu4m5Sy7VLGdjQGrQ5jyMQZsEPI', NULL, 'Trata sobre el terror que siente un ni├▒o al vivenciar problemas entre sus padres y las exposiciones que tiene por ellos', NULL, 'Trato de transmitir suspenso y miedo, como tambi├®n hacer que los lectores vean como siente un ni├▒o el miedo en sus ojos de lo que sucede.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/110a9045-6841-4843-a0b4-99bcfeb0ff23.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=a7aE6NkyzbeTi2ZyXgNtAB9QVGxzApkoJxhWwrAXwPNl3fzkrPlTLOZMqtY0f8IjluzK0TCfktrCXQ2h6JUp5%2Bsqh8dxIOP0cfuKCQXvwr4l%2FRbNfiQGT8g4D0lZkpte2HxNpFwS48r5%2B%2BjSuGdA1oZqo9lBoeeqZm8qYmoPXwv6nsgSAGIAOKcXY1CbL3vLc1P4gHyApog5ryjFz%2FWWI9OfWrOfqz0i9PpyhDqMnNA%2BdrcazFXsrDCiNAy25IVDaD%2Fk1ky1vgbGUjONeCOFq%2F5Ql7U74A9Z8yuY%2F30%2BMfAV4RcSZ6Xk28ySYjXJ15O365g3EqqmhrERkR2NREYk3Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-16 00:41:26', '2021-05-06 10:28:55'),
(DEFAULT, NULL, 'Soniisvalderrama@gmail.com', 'Sonia Valderrama', 23, '3059443658', 'WSP', 50, '2021-02-26 23:32:44', '2021-03-01 23:32:44', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Presa de un demonio', 'https://m.dreame.com/novel/1pgf/n0eLzSw+wF4+3j+rg==.html', NULL, 'Mi obra trata de un ├üngel guardi├ín que debe sacrificar la vida de un ser mortal para poder salvar a su familia y humanidad. Sin embargo, se enamora de este ser mortal.', NULL, 'Deseo transmitir todo tipo de sentimiento desde nostalgia, hasta amor, sacrificio y curiosidad de leer cada vez m├ís', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/75165fca-6cd9-43ce-83ba-4da6a2d92c2e.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Jkml%2Bq%2BIMi4cuPwq%2BH2z2kmrhK9zFczGXGls0pR%2BrEM613Ekr96UZtGYnEFkg1MjZPisLGw9%2BiJP5J6Xn48cYdRyvs7mK7ssV0%2FW%2FB%2FWMY2TPne8N2nnWM1PWAqq5PGmXi%2FDPmZWXIInwBxiNOsvMBEDta66c7kVDMgWGwlYVYO%2F9SNkqcNoFBIBCV60fXiv95xHZ9I9uLna50DVeBh2R5e54KcEy%2FH08%2FM5ly8r%2BkKtmaRl%2Bm4Urt19IpIZ1KBqvTR1B8s5D8Mhy%2B9VyGDjHC2OrfAICWBGlHhyaDwFmYdgc8Qn7JriW5fhB5C%2BR4ivx6zxZgUrPkDXtQk0sQ1ZuA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-26 23:04:26', '2021-02-28 18:20:12'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51902123505', 'WSP', 62, '2021-05-29 01:17:30', '2021-06-05 01:17:30', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Hablemos del amor', 'https://www.wattpad.com/story/270692626?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=t6%2FHCnv%2FFiEHrXWBaRapYOqIHgy%2FKIM3ZGriJbIxOARoBAw7ti7pJO7dZy%2Bl95UUE9AKEwtvK1PuMTETcz%2FfT6I%2F1awldoYbshshFklO5GzJheg4l3fx2x%2BccQqVi4Cg', NULL, 'Son poemas y/o cortas frases sobre el amor', NULL, 'Romance, pasi├│n, tristeza', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/019fd8c6-1ceb-4111-9fe3-14489c4066e4.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=rrxbpkid2SLJN0oAPvK24tnFIo3zBx7AeE3dQdnk7yroWiEWOWoVz%2FvzYkL0heGVSRsMK8u7fbNId%2F%2FCZPCfTqVU%2F4zF7umVN9VstYMoaumCFdiqIX%2BoG5ZJb5XImkeSvaOgxYoH5bDvMWMFn4ndfcOs1bRA5y8jueSSkgMR4IlfeH1mawDJRyVXliPkDVcTKriMyR7kijTQm0oOVb%2BlfmAelOOdmo3KWsV%2BaiA6c1BQXrKXgXmYiNG1tjOrqrfuqKLIkJCKK6bQ7sSuYu4A3KdZCtX2AOWMUdAQUlgdVlQTvRTK9%2BY8rF7G0ZzcIwLBx0I1BW0jAkWJkJzqi1RiYw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-21 21:29:03', '2021-05-29 09:48:20'),
(DEFAULT, NULL, 'jessminp@gmail.com', 'Jessmin Pirela', 20, '+57 315 2978454', 'WSP', 112, '2021-05-04 09:16:21', '2021-05-11 09:16:21', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El diario de isabella', 'https://www.wattpad.com/story/260848450?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading_list_details&wp_uname=AdrianaJessmin&wp_originator=xI7lWjK4ltMeCZaPpsInAfoNWpg60Zu7SB86Wr4%2FOjwVstg5%2FRc4SJwLF3Y2HEbHF926O%2FSl3Vqgyap07EPEDIPq4%2B7yJZ7kUs5ncmwBsO0JK09H2NKGEDTxsUHk82qD', NULL, 'Trata sobre una chica que fue abusada sexualmente por su padre biol├│gico, y con el tiempo descubre que desde siempre le han gustado las personas de su mismo sexo. Se enfrenta a burlas por parte de su familia que no la aceptan, trata de llevar una vida normal, tratando de ser heterosexual se casa y tiene hijos, pero no le va bien, hasta que por fin decide que no me va importa lo que los dem├ís opinen sobre ella y sus gustos sexuales, y se enamora de una chica la cual no le corresponde al principio', NULL, 'Bueno se que muchas chicas y tambi├®n chicos les da miedo admitir su sexualidad delante de amigos y familiares por miedo al desprecio, quiero que entiendan que lo que importa es su felicidad, que vivan su vida y se atrevan hacer felices, y algunos tambi├®n pueden tener un pasado de abuso sexual el cual no hablan con nadie pero los atormenta el recuerdo', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0ee0c6f1-ed2f-49af-ad7f-e181ceabf0a2.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=VEVd7%2F2pQrswXyM72DSPx8ZDXQDUfw8e3iafSWv6y5Do6ySKzzYgf3WzJ71zdbVcylCIFPI5bpilmwHAEL75u1kIV9IHf8UiXbzQQ8IekG5FeNvj3v8J%2FhuLF2wzQuJXkUCYTv06jHzEEORINxJcCX0au%2B%2BsV3oGMCqpFCMCKigFNRXFCFzbsNgQr8q03H9Q18wsr8jmcWO8VvCx5Kw13TPxDo%2FYZWaobmWfsM1HpVU%2BXdZjOC0Ne7dgqTVvhFiJ499ofPICm2YTwPxfugI0jruaKwdKsxIy3WveuM0dRPm%2BsvpO2xzHmTf3o1bnrj6W4x8ldKhLa7JQa1uoovy42w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-20 13:55:08', '2021-05-08 09:46:50'),
(DEFAULT, NULL, 'saraespinoza568@gmail.com', 'Daniela Viveros', 15, '+57 3163908557', 'WSP', 68, '2021-04-05 00:11:24', '2021-04-12 00:11:24', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'I will make you see the future', 'https://www.wattpad.com/story/261628421?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=DanielaViveros793&wp_originator=gxSQ8TTRpDEpJJ4zWdnON8n0e2Sz3W3QN4fg1cujGw5wClKvOfoxWqGyQ43E0fU2p6OrTSMkw8CH60S9R5eKx1H%2BRHYa2TtT%2BBlPNEYi7WQfWB3F2F9lNagA4qH7DMYb', NULL, 'Mi obra trata sobre un hombre que estaba obsesionado por la muerte de su amado, por lo que con fervor y sin arrepentimientos decide viajar al tiempo para devolverlo a la vida.', NULL, 'Deseo mostrar un mundo donde todos son pecadores, un mundo donde por ser diferente cavar tu propia tumba.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/8ccf2e04-b165-4f45-b2c5-7bf9ff9a6c84.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=irkXbcf56ikdW7Ys4zqAkOsaCeb7RfD1xgqYxr%2BT6GO2XngQhIyFfZxWp0YI7elup0VjY3YGSO0ABlRNDPUd%2FrQoR2xZ%2B9o3sODrqtgIu2srlGPWgqyvz5MMiJe%2BDAVe2%2BSz8nbw0gmeIPPZ0TyZwoCieNFQB8%2FwQXDjSrv5c51MCRf3ts%2B2ZYXVLKfpAnB1msjvXr6F3NzMz1KrdM%2B82htXHUJQFeGUEiQnnNhDFs63shPQzLk%2Flz1%2FnY3F7HqWlVz3sjcWBatK0GFlNrvTLhVbORwSTlrc0NikozIk9bcrtgOl4nueF1ZEaum1ZZO0rOUboXa50LBDAJ%2FvW7XUgw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-03 19:46:56', '2021-04-08 23:59:42'),
(DEFAULT, NULL, 'maicoagustinherrera@gmail.com', 'Maico Herrera', 20, '+54 1121810711', 'WSP', 115, '2021-03-01 14:04:25', '2021-03-04 14:04:25', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '24 Horas', 'https://www.wattpad.com/story/234526593-24-horas', NULL, 'El apocalipsis zombi estalla y Mauro, un civil com├║n y corriente, deber├í emprender un gran recorrido para poder reunirse con sus hijas y ponerlas a salvo. La historia transcurre ├║nicamente en veinticuatro horas.', NULL, 'Trato de transmitir la desesperaci├│n del propio protagonista, a la vez que trato de NO glorificar actos tales como el asesinato, mostr├índolo desde un lado m├ís psicol├│gico que ├®pico. Asimismo, quiero mostrar como la estabilidad mental de un hombre puede ser reducida f├ícilmente solo con el caos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/19cadb8f-7977-48c2-9034-770f07d2676a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=2xyU%2B4IoOFHLBbbq3Ve12PjwdTyb9DHAJGTwTqn5hkEAPPM8EhVQ7jgv5FnFMiYcQtDxBl9%2BqoLNgzcLThXEhS8RLPf%2FiYLoifUV91Mr9qKN4F%2BzdYtc1Y%2FYPOMiL4aFKjf5MOGD3VwT5mLlIpEgsjdKY8i75%2FJ%2BbE7%2BNfWUT9wizRoiCZjTzByAu2kv8B0jgMDrunUyQK16OVNy14G6%2BHclQjfUJC%2BMi8vWN6Nd11kSv2%2Ftp3pO2Ek2W9p7c%2BoyK6KqYQbNAoQtaLZzEMOIHdniPBMIRYAF4H24mK%2F9wPl6GfgzlgRVIFKpHgUIXJ9kdmL6XJDqszoi%2BRzTjYzZWA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 15:47:33', '2021-03-01 15:25:21'),
(DEFAULT, NULL, 'carolinamartinez8022@gmail.com', 'Carolina Martinez', 19, '+0000000', 'WSP', 120, '2021-03-16 11:40:49', '2021-03-19 11:40:49', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Campamento para despechados', 'https://www.wattpad.com/story/246325404-campamento-para-despechados', NULL, 'Humor', NULL, 'Deseo transmitir un ambiente irregular, con un grupo de chicos que no quieren estar ah├¡, pero est├ín enfrascados en el recuerdos de sus ex y dos directores del campamento con metodos irregulares.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/bc95c1d3-918d-40d4-ac1d-2373f8d453d0.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=UM8E63mue75PdfOEMkyFE8%2FHGewxJg%2FHNfCSVCG7QOv05Oq%2FPGa%2B7C5Y7PkSjXg%2BcSS8SiXXMgaw%2FZbzVfEgnkrINRB2mNfcCfl%2F6uK4mR8F4RW3sKD8XwwC5sSo5F4j4LYSm6e7QyYwV8YVWKIAymnwaTWM6IprS8OLRbAeNS7q3yEmqTFDcoE1CIoiCfKrEHsr30DXJWaYVZdJRAhpv3o9cQLB4SXSlnGCGyePFdA2DX6veMBWsAU0UGil06hd1qg1h3LNEgu6UTKi2MQFpUrSS68lFbaYnZPFMokQebFIPrVdazKX5cuFGJWWr33vFq2fHWrdyecfztOprxFcrw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:59:01', '2021-03-18 00:52:41'),
(DEFAULT, NULL, 'claudiaelric@gmail.com', 'Natalia D├¡az', 34, '+34 639 27 76 79', 'WSP', 62, '2021-04-20 23:01:01', '2021-04-27 23:01:01', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Matar├® fantasmas', 'https://www.wattpad.com/story/262537042', NULL, 'Mi obra trata de dos chicos con una relaci├│n que no acaba de arrancar, mientras cosas extra├▒as empiezan a suceder en el vencindario en el que viven. Hay muchos secretos que quieren salir a la luz y algo oscuro est├í a punto de empezar.', NULL, 'Desear├¡a saber hasta qu├® punto engancha al lector. Si voy bien para llevar 6 cap├¡tulos. Si los personajes son carism├íticos. Y qu├® debo hacer para que la historia sea m├ís atractiva. Deseo transmitir misterio e inter├®s. Algo de inquietud.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/3cfaeb25-73bf-4652-89c0-67ed4f9472ce.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=StlURhIMmr3HXyZWh8MWRupaxi8ieR7Ab1EA6GoLTBMt2IVdOybOmTijp%2BUVsayqOurXMQwZjBaNibCZkevUxmT0gxVzh2rcPFCxpZ3%2FMgIgo25OIez9MHif62qMVONYNpj6jq3q7l2eqno%2Fek0PWMlL4E%2BpLbQSJr68bEvGSdXN44NIcgS5z36ZSSIdr5yFjiKdF4B5AfZx7%2FNsRVcTZrulynsAdJ173WEWykJ0Iowtpp8xNlL5JALxkcdBDtqalojiZJNpHqlVUyVbEigQkWs0LNKL48qBSgo7OSzaKKzWo8sjV7HIbur%2F1Nqy7%2BHl4Bf8cCmkYuaZMMZ211v9mA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-18 12:40:25', '2021-04-21 23:30:22'),
(DEFAULT, NULL, 'marthariveraantequera@outlook.com', 'Martha Rivera', 24, '+573137081263', 'WSP', 60, '2021-06-15 11:41:36', '2021-06-22 11:41:36', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Drama, amor y l├ígrimas', 'https://www.wattpad.com/story/212483096-1-drama-amor-y-l%C3%A1grimas-editando', NULL, 'La vida de Emily siempre fue sencilla y normal, pero as├¡ le gustaba. Era feliz con lo que ten├¡a y con sus padres, hasta que cierto d├¡a llega a su puerta quien dice ser su verdadera madre. Desde ese momento su vida toma un nuevo rumbo, uno inesperado y bastante frustrante. El cambiar da casa, familia y costumbres no es algo a lo que adaptarse tan f├ícilmente, mucho menos cuando tus ojos no ven de la manera correcta a quien es tu nueva familia. El amor surge de diferentes formas y circunstancias misteriosas.', NULL, 'La nostalgia de separarte de quienes consideras tu familia, y que a pesar de ello el amor siempre es incondicional.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4ebcd3c1-8b90-43d4-aeb5-c50288c984ca.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=MnNccGwNh6uDESpi9KDvrwJEYLyK8dIKENc6dM%2BqiCqACT2CNfcTvFtxSOJA4155OeOTrNlgd794teK%2B4r8dAfX7KG2NCZj%2BlKosU8SZDKbcFitsrcUQFWqh5WJY8DuGiqFSUTUuf2dxkkeiv9LqrJELKHThYXM1NzO27T%2FX8KOUYmJ5WQNS9COBl5FXbKdqwTCtjAExVkE3sEpPQH5HoO2kwpeoNX6%2BGH9ah1%2BzytSmXWFGJFvYNXctk%2Fpb%2FSQdJTaSGPiyPtCL%2BBwKrC%2FVW2KiGP%2FhUnWGWt1wwfZJyLBD8dY196vI5hDCQAbLHquZl%2Bus8xetP7Xg%2FV%2BaDZIJ1Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-06 18:41:22', '2021-06-30 18:38:34'),
(DEFAULT, NULL, 'ohani-el-30@hotmail.com', 'Ohani Poueriet Lugo', 21, '+1 829 959 9965', 'WSP', 64, '2021-02-27 14:38:17', '2021-03-02 14:38:17', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Cercan├¡a en la Distancia', 'https://my.w.tt/vjMtc3dQa3', NULL, 'Sobre el pasado de un juez y su vida en un barrio.', NULL, 'Asombro, cr├¡tica.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4d1dcec4-bb31-4bbc-bc07-9b74fa8659ab.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=CRDuVjaJtt0MdarbkJBaKUkwLp7fdFd4PODrzqKfNc3zp%2F%2FI20xUkE6V%2Bz01U33UtlXTygC%2F0Fi3dob8KGwnI42Nmy5AS0uP%2FftCe%2F%2BdQr88Sk4VuXgZnxL34HZpJPb77fY9zmDuYcDU8%2BJ2k9YEdj8e3zGPXmvfWGjvqxJb3PpYwKNx1JZTr%2FUjuUhDvq2%2FozRR7dG%2FXVor4gxlSjy8m%2FzJxumPccKaSQMrflgN3QiQqYFXtGc6w4nY3utmCni%2BOa5nWwXox%2BCbg9%2BncD7ygZKpDhrFx0bEpjb%2BzRhJ8wtjJf0n%2FTEOywldsdECbfNy06N6FYVJUB5Gs9zOE9daFQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:53:44', '2021-03-01 23:06:26'),
(DEFAULT, NULL, 'eve28venegas1432@gmail.com', 'Evelyn', 19, '+52 55 18314825', 'WSP', 56, '2021-02-28 11:52:52', '2021-03-03 11:52:52', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Una Estrella M├ís', 'https://www.wattpad.com/story/110764993?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=EveVenegas2830&wp_originator=Jcb2xZyaud0EET8xRz7UPRe2Ou61rUmSC7YO0yyvgEbE6Tb9mAOrF9hvWKx4PCI1THgpm9RJFboskb82zf%2FvQw6jhIT2D87nuxj0SdPtFRl8TwgFNV4NBE6W7cqUxzt1', NULL, 'La historia gira en torno a Tony, un chico que se ve involucrado sin querer en una serie de cr├¡menes por dejarse influenciar por su mundo exterior.  Se tocan temas como la traici├│n, el crecimiento personal y la deconstrucci├│n del ideal del amor rom├íntico.', NULL, 'La principal emoci├│n a transmitir en el lector es la expectativa, una expectativa de que los problemas se hacen cada vez m├ís y m├ís grandes, porque todo en la historia est├í conectado. Sin embargo, otra emoci├│n importante es la confusi├│n al encontrarse con que el amor rom├íntico en la vida real difiere de la ficci├│n, pero eso eso no es necesariamente malo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/3c7191fe-2f34-4227-9d19-f93d88ee6637.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=n6OnyhDMDv1ja3gRWrjPBO4YzImaal%2BWrS0eB7ut9b2GH0eXa1vbN8fAaHs3sFywrDDmQxd%2FxShxLi5QQ8AfSa7%2BxlIKzZeXu3meiTSM0TiBVhKgUD5ay7w5i1Q5fTcHAJnONbV9cP2byJYgvP%2B8%2FNnqZGbrRqYkjXsut9%2B%2BeuMYnl58rTPoSz2QXdLtWigRFwg4XYum6x5gu3RSxELRHqX81l49jvYJ7IkuXgkYJQAE0rhWXDevdNOYwV9kmiR4%2FQ8skOg4qt7lAUuELfBYl8JDf%2FX%2FcJhQ5ZFoCK93GZriCzHC%2BSGz2oQT6BHVBB8UOpVk3z%2FRon5jJcNvxki2ug%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 03:04:17', '2021-03-03 18:10:46'),
(DEFAULT, NULL, 'eva271992@hotmail.com', 'Eva Gonz├ílez', 24, '+18293672259', 'WSP', 61, '2021-07-28 11:58:01', '2021-08-04 11:58:01', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Si la ves, escondete, si te persigue, corre, pero nunca la enfrente', 'https://www.wattpad.com/story/264227166', 'Cira Li', NULL, NULL, 'Transmitir terror y suspenso.  Una mujer desnuda de piel morena, ojos negros, el cabello largo hasta la pantorrilla y con loa pies al rev├®s.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F24d072b7-3725-4607-aa87-19788aa43d57?alt=media&token=df2edc37-c5c2-4ef0-9583-e090fbfcf872","createdAt":"2021-04-03 11:50:16"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F704176bd-aff9-44e3-889c-8df88f1f2d5e?alt=media&token=9457a4f0-efdf-446b-ba0f-3283f47fa5d1', 0, 0, 0, 0, 1, '2.2', '2021-04-03 11:50:16', '2021-07-30 13:51:55'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51 902123505', 'WSP', 114, '2021-04-09 12:36:51', '2021-04-16 12:36:51', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Sin sentido', 'https://www.wattpad.com/story/264239533?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=HbTraJiHQPVSC401y35sEwcQaGU9x4qKJExP1Xg0Bhw7dzK3nCgEoOJtP18kpTZ5wSxzWxaO36GeSQaHl7PQR%2B%2B83LVJB0mhoDquuJCTBKCdfg23H4eMPl%2FLYHaCTQzc', NULL, 'Trata sobre la perspectiva de una madre que vive entre un esposo que no siente nada por ella y solo viene a la casa a dormir, una hija malcriada, un hijo vicioso y otro que no se comunica con ella', NULL, 'Los sentimientos o emociones que siente una madre al sentirse como inexistente en su propia casa o solo ser vista como una empleada o alguien que solo "jode".', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/3f770de4-b1b7-4d6c-b4e6-de5a85ef487d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=HY6QmZG9xejHl%2FcwmpIG7v4JW17EC265Caqtp1Z1YkVOg3hoF2r3gZfMUHh8YvP8PcuL32Df1yDVi2bINqa6k%2BqBeJUDZQr5ONykCothcAGA5qTd9EWWCO9btYninUnONzIKk5s6sriKnmcEODatgdcE8g9vr7pKhW5vJ46v%2FyS%2F7NcIOfuoLdWSSSpNg8dkezehfMm8365aswCmcW1YzehobJM78Qz9kQMn%2F7eQpiUoPzHH0wtC4ob6mhMrkCtlSXLhWC0dHj1%2BWGfrn%2Bt91ahp%2BWV0ke2bUScqmOeBjzC8Jirt%2FulVuc3XetDDHAaX7t5VYixpTgblWE%2F8gU%2FNVA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-30 22:26:09', '2021-04-16 16:29:29'),
(DEFAULT, NULL, 'jeynm.07.11@gmail.com', 'Jeimy', 23, '51929050119', 'WSP', 58, '2021-04-13 19:29:58', '2021-04-20 19:29:58', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Mi nueva primavera', 'https://www.wattpad.com/story/176501401?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=jeynm07&wp_originator=Rdq0OE2kwnTV04G%2BaxsONqCLkqwcxELgWRAnyGtOzP3un6kA5FS%2FzWatfNNbXu%2BFRZ9gK8htgzcsUJshQJ6vgkVKb8Ogpkug2i%2BrRnuIBVCi9JUhN1UVgo6o8hnLFU2K', NULL, 'Sobre la magia del amor', NULL, 'Quiero transmitir distintas emociones...', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/45de58bb-580f-4fae-9c11-d982dbb98e7d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=NOsvMfCYKLJCayVzKk2mLkkMVb%2FcCZMcsrpchl3iIpm4weN9xpIiAhWGjb7Jtzl%2FuHmIZG5c7QxtpUmgLGBLFQlj5wnsolUT4o%2B7kDvyBnBTIlzz%2BWdTGUgcYrq4z%2B2B8mwa9tV9VDpWk5P2fl7ICcLUDyedByHbnsubyZKAKCE0RiF8uB2FYRMqjjX%2B6djYsyRXS13oSQ5ZhIhCw1VIunHTZO6XVRc2Pfe0IgAPsqrSccVz7EwBKrkTS8whX39u%2F4cRdZv9HtGHbUMq0uWrN%2FkoJwAnoaH9jeqYbKNtqav%2B4WKfdy%2BA4gv6NkktICwv93qQAYhnAtpmBzRI5mO71g%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-13 17:36:31', '2021-04-14 19:12:04'),
(DEFAULT, NULL, 'ricellperu@gmail.com', 'Ricell', 16, '', 'WSP', 64, '2021-03-31 19:23:13', '2021-04-07 19:23:13', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'The cam of my dreams', 'https://www.wattpad.com/956991477-the-camp-of-my-dreams-visita-inesperada-%F0%9F%96%A4', NULL, 'Dioses griegos.', NULL, 'La importancia de ver el otro lado de las cosas', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ba46f30e-2810-4f6f-aba8-d0edfcfd6fc5.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=kzx6T0jc%2F%2B0lnvkT0NxC4EKTsVELCFqIehGIloILrQV95%2F6zu4ctrWbv7cWhJY6D8TsfY4mrYTyWEt4kcow3iEmS8hObeK756VmJf4TPPkY0mfepZigfuy4au32roo7xGpJb1brvq%2FHb6QpAP8oWj9PndcizZGxTFJEKdj7gZDmKjTW6H%2FLRgDozgWGJo0SHH2DdZhJ5ibfeaa8%2BixV89tFU9U2%2BwQZx%2FKbhtQHsayw5Nqvp146aiH8v4Pt%2BYXdDbT1IYqtst%2Fu1DgGOIMZYD%2Fi%2BRbOhB3C%2FkuwcepA%2Fyxr4YjXs8qztJR5Ot1xViDokDn3L%2BYdeibOP8ObTMUyPTQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 17:09:10', '2021-05-06 11:28:25'),
(DEFAULT, NULL, 'raqueleliza09@gmail.com', 'Elly', 18, '+1 8298780005', 'WSP', 49, '2021-04-01 00:27:09', '2021-04-08 00:27:09', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Tan solo una mirada', 'https://www.wattpad.com/1012683447?utm_source=android&utm_medium=link&utm_content=share_published&wp_page=create_on_publish&wp_uname=EllyDG09&wp_originator=RB4z4Mx%2BC7D2hQOz05VPSO7O2%2Fo4RkcbU9%2B7UpyCQSmyzjx0deVPdGPevDpzsTETtAl6BxZTqyZ%2FiLovOKbOr6UzcwCxl7iE82dFwY5FMZAGc2DQXiH3zSHtpXt54gTE', NULL, 'Sobre un romance no t├│xico, donde el destino decide poner dos personas totalmente distintas para as├¡ poder llevar una relaci├│n, con respeto, tolerancia y perseverancia a pesar de las dificultades que aparecen en el camino.', NULL, 'Quiero que transmita m├ís que todo superaci├│n por traumas del pasado, y hacerle entender a cualquiera que lo lea que no todas las personas son iguales; puesto que cada quien tiene sus principios y decide como llevar su vida.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0ee5454d-c80a-4b9c-952b-95ec82353f9e.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=qI2h9JbqPuzkQRUycVFNc8SWslXD0qvbRQe8T%2FFrWVc314uvcSJYIMNWpaODkM1SO78HBohPPQeU5QiaqgGJHp4EhfTV6IyJvPLEbpXCBoA2wNz6xm%2Fhk3j0xw4nL4S0KDul%2BOuS8mEndCZRn6zO75iW1sF6OWsdRZKRgM9qFuTS17RYg6zcEHrFHnXohX6DL4Rz2s5oAYffwRFRzK9kovzCDVMpqLxA3Sj3hSi4gfP5RWrFRLwbNsxsNPhDaV3MI9KqhXb76FKNhoSPSdshrm6%2BOaAwpNq3JHfBwm2wvbSHe6dkoi3VpL37fbi4u5ucCW4YpxFaSzg0GzNNcokvhg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 12:06:19', '2021-04-09 01:59:04'),
(DEFAULT, NULL, 'entheromania.22@gmail.com', 'Lourdes Moro', 20, '1132274723', 'WSP', 50, '2021-03-18 21:07:42', '2021-03-18 21:07:42', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Kilian: el pr├¡ncipe albino', 'https://www.wattpad.com/story/196127520?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=ether_22&wp_originator=hQ7QwKGWlOBP7zxi9jMpLNpJqouQo%2FEErt0gTxPX8F%2FFZs68N2qZkY7kyKfjTtZpTfdi5vkh85H5LqQWfHUDJJsTnEJTtA3WQ51l76L8FEaU%2FHJJ07%2BVJLr%2B%2FesCr%2Bzy', NULL, 'Mi obra trata sobre Chiara, una joven de 17 a├▒os, quien adopta un gatito como su primera mascota. Sin embargo, esa misma noche descubre que ese gatito en realidad es un pr├¡ncipe encubierto que escap├│ de su reino, el cual cay├│ bajo una dictadura. Ahora ambos, atados por un contrato, deben esquivar a los asesinos que buscan la muerte del pr├¡ncipe y recuperar el reino perdido.', NULL, 'Deseo que mi historia transmita un sentimiento de independencia. Mostrar que nosotros no somos nuestros antepasados y no debemos pagar por sus pecados, sino formar un mundo donde la paz siempre sea una opci├│n.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1f7e8213-6b6a-4f69-a30f-a45e15495d73.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=xqeCPi1gABA2Eej40pbFaq2NhZSGnzNdo2VWBP6Iog1t5HArcQIyXVCridWhprTk3zdAtESIntacTHva%2BdEmGi8AEhkyCHnpuRXPomdRHyeDPIVTZ7Fa%2BcOnYHsSmsL3KpMkVWiZ%2FyYW%2FsS9vWWvxH8PX8kKEtlq7%2BnXtvw1J0oyljkWq46PzdaCu%2B3pxSMHKSuISiNBouJMjytwvRgqZ8D7b0tC5LZdZdNCeV8kEI%2FMmR02akj5GK2EBffKrzKcyXv7PIft5AJE12gYr7e5T2RvSCDQ92eWTnJ9kt7%2FF2iwENdIzEZuaVeC%2FNbdAO54dnMIgnGdc%2Bb1RXezicz6MA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 00:15:29', '2021-04-24 23:05:28'),
(DEFAULT, NULL, 'monicagranada30@gmail.com', 'M├│nica', 18, '+573225912110', 'WSP', 49, '2021-05-30 23:01:17', '2021-06-06 23:01:17', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Candy Cat', 'https://www.wattpad.com/story/234349900?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=moniklejandraherrera&wp_originator=MKmjdtGBDPfUOH63u0cM4x1msl6fbO2qq8ZaDw6UhmvDyH7%2FSsQxMdTkObPW5YwBGx7TaDgfjXlrh6nRWewwgBkKcUN20NfQMftdF8zEzP%2F54OdermKRD9mcw8lwcHKd', NULL, 'Mi obra trata sobre un chico egoc├®ntrico que fue convertido en gato por una bruja.', NULL, 'Que no debemos creernos m├ís que los dem├ís', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2e499dbe-8824-4b6c-91a6-8257c6502034.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=OSucezdtwfzxywaOMJwXyIEnRBib1FU0dALHAvYq2ruFHRVjaHtKb5tqLf4UzpYNcWkimGNiMA86ixnRhRHuaX%2F3EnKsAEVLcbV2anfcHS2ZqHrqz7CBDzO3ogbiFA8dtUa5NFtc3ipaF36mNCXVkApw4NTsX2TiygIg7FkkGPqKD0PVKwuZxo317RPRZBYXzvi66ctXAK4PIZ0UC4jvmZuMG%2FjCPBOjviu1pktZ15aFzTMhbulcqyAAe%2FJsP6CcDljh2DAf8ZxqEvi%2FhGlarGJsmGp9pRHMxGluqBvMUDZP%2FJ%2B9GKjPetu1YOY4qjLCAlEzrcaiT4VH3DEh6AsH7Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 15:14:34', '2021-06-08 23:51:33'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51902123505', 'WSP', 54, '2021-05-11 11:36:42', '2021-05-18 11:36:42', NULL, 1, 'CORRECCION', NULL, 'HECHO', NULL, NULL, 'El idiota que me enamor├│', 'https://1drv.ms/w/s', NULL, 'Trata sobre una historia de romance en donde agregu├® ciertas vivencias. Tambi├®n como a alguien se le es dif├¡cil aceptarse viviendo entre insultos homofobicos y maltrato.', NULL, NULL, '', NULL, 0, NULL, NULL, NULL, 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-correccion/6c193c0e-456f-4b70-81a9-b948688fa0e1.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Ddpi8JBB6NMEdUJg5NZBG91Z996JtJ%2FsZ71NklHpEYx79iOcRhUt3dIcykO7PM9wWQuG8YR9c2fNHoPOA3680CbLxcQ4sf4IWxawuMvVOzFoHykAnnQy1UO1VieewFo9rRXuK9WvTo%2FOhIyZBEfx8j%2BuCWKOloyIoooO%2BZrHveWRhXxHLE7ISJf4bTWoix3oMeXomKw0hqVGgwnmkUx5D%2FqyiUf10dNdr%2FBd1huWP63eBAhM95%2BPE0Kw0GUaLjBwPWKf999wGchKWfyHYR0wQz2yXzSCXVLP2kk95GXGbwRsTpFn%2B9I1bUOio2YLsQk1c779INb8%2FVHKHDQK4eU46A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-10 18:13:12', '2021-05-12 21:53:23'),
(DEFAULT, NULL, 'Arletteyocastacorrea10@gmail.com', 'Arlette', 14, '829 457 6750', 'WSP', 64, '2021-04-05 14:41:56', '2021-04-12 14:41:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Mi Mate, Es Humana', 'https://www.wattpad.com/story/236800945?utm_source=ios&utm_medium=link&utm_content=story_info&wp_page=story_details&wp_uname=_EditorialParaiso_&wp_originator=6CUNy5%2FFcPiFpcqINVZSzSg5iqtbJs7jUuXNg4s2tMky0O%2B8Dy42ctvkTGqC2o04YJl5sRZKOs%2B9ZeAswfvORhRYgPDK%2BPiPsiNnC0ZmsRBIVDeOtnqg%2BsFpSn0kqC%2BC', NULL, 'De una chica con un pasado dif├¡cil que resulta ser mate de un alfa y este trata de cambiar sus recuerdos creando nuevos..', NULL, 'Mi historia desea trasmitir que no importa qu├® tan dif├¡cil sea tu pasado, por que siempre que te amara ha pesar de todo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1c4c3fd2-24c4-4424-ac2d-bfbcd1bf090a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=J6h8W6VuSFqWd5W2W0CYnQ%2BMLMhj0C9Gmq5sWAxDdYklJ%2B1JpKbbmsvTXIb98YRL8ji5cF3sFBe%2BxBxc1icgGpr0srYj7BRyJZIaSLbDrURUmr3x%2FIKMQSYPnTEH8HQhtVgX4YMhluAKGGnnh9l92usGnCq%2BRQlVR9nElWBj02OY4ylB1ewa9TxjskfzAO3F2sZW15nTJfITxo%2F5E%2FdXttkxHfP71PBV2He9UwD5CHxVqOsjxjb%2Fp4t5phKLAovZf3LH6ceGtz76QsKSQymvMvl8NpTzeMoAvvFDs3NeF%2B0Eej%2B8F%2BHG9BRPZPhOAUxewqLaIPdaTV%2BxHlLtMogYnA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-04 00:15:57', '2021-05-06 11:21:49'),
(DEFAULT, NULL, 'arianatomlinswift@gmail.com', 'Dove', 16, '+57 3242432472', 'WSP', 60, '2021-05-27 12:36:07', '2021-06-03 12:36:07', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Mentiras destructivas', 'https://www.wattpad.com/story/218757340?utm_source=android&utm_medium=com.whatsapp&utm_content=share_reading&wp_page=reading&wp_uname=dove_voice&wp_originator=OhF%2FwLdnqZQy35hNH7MnN2gDiWNObKC4MrAG26Jbvls%2BFoItvX9aNBpzrSuUGhYjGJekBZnRm%2F3GISfS34eSH9t%2Blj9CqbnFSl6L9CkOOFEjdFvx2gLrBfDjsK3Smrxd&fbclid=IwAR2TDMv_21un33ieGK38iMwjOC6KZwpSj2ER-a-pmKuEv4d3p4yCsrKZGEY', NULL, 'Mi obra trata sobre una vida oculta de una adolescente que dolorosamente tiene que descubrir diversas mentiras que han estado ocultas en su vida', NULL, 'Deseo trasmitir intriga y romance.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/97c7cb16-95f7-461d-a463-a3cb17ad48dc.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=RLy01CQKcxFCXxXbLywC7ypG6C6yh7dKpTTjg9o%2F1z6wUSeg16oOaSni4gcLaFsoifWVDEVrn41vGN2iPQucxvDQJW20ZdemcQkNlsShWaCo8PQEfnJ%2BORDHIJz5tp8Qe%2Bd4HBHopoGbGNoM7CWBDztpyiZraXlLMQm6Ri7znUMJ%2FqO%2BLe6aUltiTd8O3JDxENC1MmPSBz7cJMmaRCCcJe3H0T9cI9sIrQe7NDpafQNOGXHr0qbKpwEF%2FzO3G12dlXql8U%2FitkHydAIKbDERAvAKj2rWN13%2FpqnPQJqqHb7qc1PMu2SSS604Ikkyn5pAucx6ftakaKc9Q%2F56mJ21tw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 20:40:10', '2021-06-15 11:37:03'),
(DEFAULT, NULL, 'godoyparrapaz@gmail.com', 'Paz Godoy', 20, '+56959787995', 'WSP', 67, '2021-04-03 11:36:40', '2021-04-10 11:36:40', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Romance en el espacio.', 'https://www.wattpad.com/story/249916854?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=CalaberasYDiablitos&wp_originator=G%2BKzuNWeb4VLQedDqui5KU7Gy0c3X4S9cfk9gdUEbHBfMXy0virmihzEnl9SYhP9KF%2BDOp57G0GLgf7siaDIm7R5SenCR3YGsgACR%2FOG%2BbaW412ySzIgGUb%2BLRqzIV76', 'CalaberasYDiablitos', NULL, NULL, 'Quiero que transmita m├ís la idea que es algo en el espacio,no que se vea rom├íntico.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F3280061c-6c1d-41f7-95fc-70ab5a3c1b39?alt=media&token=c9d10760-5b6a-47c3-b91e-074d95268d61', 0, 0, 0, 0, 1, '2.2', '2021-04-02 11:16:52', '2021-04-03 15:07:31'),
(DEFAULT, NULL, 'silvia61991@outlook.com', 'Silvia', 27, '51 977603167', 'WSP', 55, '2021-07-03 16:03:59', '2021-07-10 16:03:59', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, '┬┐si hubiese libertad, en un camino de mil grietas, se hallar├¡a la felicidad?', 'https://www.amazon.com/dp/B07BTGRB7K', 'Vross', NULL, NULL, 'Quiero que describa bien en la imagen lo que dice en el t├¡tulo "Prisi├│n de Oro", es decir un amor prohibido entre dos j├│venes adolescentes en un internado para hombres, un amor que no puede ser libre por la presi├│n social y cultural de la ├®poca.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F6a8529d0-3c38-4760-a1eb-96ce9f6a0f18?alt=media&token=6af76af6-912c-4da6-a81b-d3265df07503', 0, 0, 0, 0, 1, '2.2', '2021-05-30 20:27:44', '2021-07-11 14:52:57'),
(DEFAULT, NULL, 'mcchorlost@gmail.com', 'McChor', 13, '', 'WSP', 58, '2021-06-01 12:03:49', '2021-06-08 12:03:49', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Fallen Gods', 'https://www.wattpad.com/story/185555552-fallen-gods-escribiendo', NULL, 'Mi obra trata de un chico que muere salvando a una ni├▒a y reencarna, pero, su reencarnaci├│n es un alma diferente y solo posee los mismo comportamiento que su otro yo, compartiendo los recuerdos, pero no familiariz├índose con ellos, haciendo que sean dos personas separadas.', NULL, 'Aun no s├® bien que quiero transmitir, en mi obra hay algunas batallas pero tal vez quiero causar una sensaci├│n como cuando vez a un personaje obsesionado con algo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ff42c643-306a-4b1f-b11d-0025f752bb94.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Bj6OivOVzXIHrik2Eh9efNfi18960mPzq%2Fgl3f1A7%2F103%2B3ep%2Bkc3W6ymoj7w0UXVS3RQJP%2FiJ0QxgpWdKDolNeCvirl6LOgjZpmPUoQfzK03tTYeukOm8C3t5lxRDoMe9%2BtC9h3vhHZY%2BLm6%2ByTURthUgDaztqIyi2cEZcGCwZY84lFYf%2Fz%2FG9X4fFDaguBCHYwyR27qwxePnT4oPnFl5ElduUE5fRFxeCatxKfQ%2FRJt5XVohPb7eUoa%2BlDNWuksSSSxnP3XHL3PB4jGKjkr0aJu8RDU121RBnllhQTikLmqW%2B73iSRuU0CguFc8e6he66YWdRjiZA889AJh9HOIQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-27 23:42:15', '2021-06-04 18:33:06'),
(DEFAULT, NULL, 'diva.kasa@gmail.com', 'Yazz Peralta', 39, '+522225997680', 'TLG', 58, '2021-04-14 18:34:28', '2021-04-21 18:34:28', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'FUGAZ - La noche de las estrellas rojas', 'https://www.wattpad.com/story/251805186?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=library&wp_uname=YazzPeralta&wp_originator=OssjOpnfS1LiDeGDqK%2BrR6Z7TpVboVbw6iCRvSYhGRwW6NOnhWNhDifUsfC%2FlKJ2yLiL2K%2FuRO6dlRuSwgWemCDS5glzv4YZYLzjjpQn%2BFuwRCxPn%2BWHGC1OFscAlZJV', NULL, 'Es un romance que se desarrolla en un futuro dist├│pico. En el camino, los protagonistas ir├ín descubriendo que pueden pensar por si mismos y valorar incluso la vida m├ís peque├▒a.', NULL, 'Que el valor de la amistad, la lealtad y el amor, no ha muerto y que incluso en medio de un mundo destruido, se puede amar. Porque el amor y la violencia, son desiciones humanas y cada quien puede decidir, de que lado inclina la balanza.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/e8fc8d41-a80f-4b56-9f61-7802f8b191f7.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=JSZeaeGMJk0cEbQd84bB1rbt2mT8DUR3zPl3%2FvqPG7tE8CykHMzX5xRmjeCEp6pYGF4t%2Fc3rX%2FCg1rSQUTVtTazUnia3F6XxlT6%2BBUIHVuYHeYICwZJzZpslAW3QnOswRtuOY4eu%2FoA9bBYapVayNyy7qkCXchW5mJ2YBGqJ%2BtJaipow5Bp4me3Runfn4oBRMi85P9WXLLAdojXEvwi%2F7CiGENWpuZxkKWZ3Pz164YJt2rPs1D4z9r5%2BFAam5F9EpOeNMAFfulOodRVFXqEGYd8HT7a8YUj8Rwl854jur78MFWTXUCNgTm7PrAObGEMKxhcdDjwkDAHsx47Q9NpsTQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-08 18:10:35', '2021-04-19 15:24:53'),
(DEFAULT, NULL, 'kleyber.caraballo@gmail.com', 'kleyber Alejandro', 21, '+584144066150', 'WSP', 62, '2021-03-18 20:37:17', '2021-03-18 20:37:17', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Cartas para Lissie', 'https://www.wattpad.com/story/261999421?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=kleybercar&wp_originator=RGnXBj1KUC1JRAaqlJ3vGF1y03BvjfBhKC2Q548UCJ0aQctbO%2FK9nnUN3KADGiLRMoErJYTf2kdgDwnfifOLmVwTuu6K1pOgo8GqMRhoVw5VBpVqUudbX%2F%2BH%2FFINb%2Fu2', 'kleybercar', NULL, NULL, 'Amor paternal de un padre que no ha conocido a su hija por qu├® esta encarcelado.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fe9f36aa7-4d41-47b9-9d06-d37c86031a52?alt=media&token=38d3f230-011d-4a88-8916-81f9f4feca70', 0, 0, 0, 0, 1, '2.2', '2021-03-16 13:12:24', '2021-03-19 07:20:56'),
(DEFAULT, NULL, 'leonadecirazon@gmail.com', 'Mariajulia Varela', 18, '+51 947728753', 'WSP', 67, '2021-04-03 11:22:42', '2021-04-10 11:22:42', NULL, 1, 'DISENO', 'BAN', 'HECHO', NULL, NULL, 'LA HISTORIA DE AMOR QUE CONMOVI├ô AL MUNDO', 'http://www.wattpad.com/user/MariajuliaV', 'MariajuliaV', NULL, NULL, 'Quiero que impacte. Y de la idea que es un libro', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ff5f67f2b-ade1-4ba2-9547-4bb8d3091ef2?alt=media&token=11ef2f7f-f76c-4f5f-afaf-4f7db5faedde","createdAt":"2021-04-02 00:41:52"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F1d27f0b4-4fbd-4f9c-ab17-4ff6e7ee20b8?alt=media&token=0e5302ba-faaa-461f-9e40-899f7f1ebc62', 0, 0, 0, 0, 1, '2.2', '2021-04-02 00:41:52', '2021-04-03 15:19:17'),
(DEFAULT, NULL, 'rociomelani@gmail.com', 'Rocio', 22, '', 'WSP', 63, '2021-04-17 14:50:04', '2021-04-24 14:50:04', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Lazos de Sangre', 'https://www.wattpad.com/story/211227815?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=picolenegro&wp_originator=gNaOCnSO6GDnrC0vDWjvh%2FByNjDvneTRRuub%2F5QxjkzCfnLz%2BeybxGDMNZ0yXpMb3mkSMtjmo%2BI1grcmPNFXAuKgcIfFM0LyjwlduT6lmAdRkYyP0U2l%2FKMdrf6E48PO', NULL, 'Rose Black. Una joven graduada reci├®n graduada para ser cazadora se encuentra en una fiesta de su graduaci├│n con su prima, pero esa misma noche la tragedia cae en su vida. Su familia es asesinada en la mansi├│n Black. Las ├║ltimas descendientes huyen por d├¡as hasta que su prima es secuestrada durante su huida. Rose deber├í luchar y encontrar la manera de traerla de vuelta adentr├índose al mundo del que tan deseparademente intento huir.', NULL, 'La historia es de fantas├¡a sobrenatural, con cada cap├¡tulo te adentras de a poco a la trama. Misterios, suspenso, amor...', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/e20e40e9-3767-43bf-aad0-9714bc08c5a5.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=fx5evkzDkYlKyhDfDyfKnJQo0IgXJoP%2F4x6jFkIZXKPrzkb8DXbafKJc1k1aMf94hkhijWsYvgYex4xm%2BE8tHMd9r8ry7S3bPSXygPpWH7x5dqDVvfe4OKjMD%2BcyqrA%2F0KhW824l%2BqSVRmilGCXnGGS26pLCp2%2FFzip%2BycNNH6e3FtFf0mqUicZ63oozZfIsecLNzkkgPJfZfIDC4K3oV7jaeMrrTmVFvpzHxhAMnJoFZgJSaEZLCvr6UFbBN9%2B7LxXehfGBjquhw2q9l8RXRgB83VBp%2BRuJwrc8iHFzPWHxnIiRFEep0o07gSiDusqTr9fk3diUL9S0TtEcoEpaxg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 08:39:26', '2021-04-22 00:54:44'),
(DEFAULT, NULL, 'solislopezcarmen@gmail.com', 'Carmen Sol├¡s', 31, '', 'WSP', 64, '2021-03-30 01:54:50', '2021-04-06 01:54:50', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Ingrid', 'https://www.wattpad.com/1046986997-%c2%a9-cofre-de-relatos-antolog%c3%ada-de-historias-breves', NULL, 'Relato corto', NULL, 'Hacer notar la discriminaci├│n en la ├®lite cultural', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/07455d2d-8370-45cd-aafc-d9ae69ba6882.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=wtDysh0IXkIgiSQ13zBlVBy2hHNFJr7wFcahB%2FhGbPGpeKlb%2B5tiwDDa5MHppxA4AkWRMZlYJWgFDG8rYqoraRNpw7Oxmckk0XM9FA8I6t6uo6rxGNE30F%2B8ckd2odkOsfJAIIONXQge22806z%2Bx47sjxHGYkVYiPVhyLn3dk2j%2FaKoU4t7nSlP0VAkbVDwMNryF0uYTX86OfECbhwRF7aTs9sX47KqzJsTrLIgt8XLOhBd3Zgo6bUDBDkdJvKirEe1XutRamTyOb%2B7huXoFKkpqso7h%2BZ9oeunHpIiyivVIE93E4bjrdOrI9bWGhbcNZidBD0uG5g1TdtXUoni%2BYg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-29 10:11:38', '2021-03-30 02:04:33'),
(DEFAULT, NULL, 'julietalencinas@hotmail.com', 'Julieta', 22, '3884560859', 'WSP', 56, '2021-04-22 15:26:50', '2021-04-29 15:26:50', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Pocas luces', 'https://www.wattpad.com/story/255507519?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Julilenbert&wp_originator=ApXuHNu1eSTR40WP0hWFQRMOAukVBRm3CSGhQyE%2FyjdEtK6brUJD4Jz9IrRNH5B5vt7wF2YA8cxw0z0%2FFPcf3kwgd%2FoWNvN2ZgySFFaDqtKsBiDUyzLBsuO0RB2Mv4Lu', NULL, 'Mi obra trata sobre los conflictos familiares y como se adhieren a todos los que rodean un ├írbol geneal├│gico.', NULL, 'Valent├¡a, autosuperaci├│n, comprensi├│n', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/eaa643d0-2959-4358-890f-63db1b9d381f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=sdaj%2FB5B6Sx7qUfe9sqL1WwApVtfz4GOtWBjXZ1VyRFFXzemSrXLtCUREuxOWVgW30KewA6rc1FjS%2FnjXbge%2FASYUWYrSJKJLcW2nxtT9zxF%2BfiQvM1rl2skq40XWoWASa2Nu6h7IDDxlhEmzN8YHO19mhFuN0aS542V3hfJFn3ttUb%2Bas%2FMP5%2F8zT80yMlJ0Trl%2Bmt7yACs9w2%2FywkNCREvf0krFhD%2BdTrsUsNqfcSsF1IFGOaRXwFIEO3s14dfRGpyNzG7BCd4w4lDWcpBKrSClZVzoR6qL42%2BdPdovK7kvRb3wilO7u1qCksj%2Fzu2QYEO6v9LkN9o38PYjZS1VQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 22:17:05', '2021-05-08 17:47:53'),
(DEFAULT, NULL, 'llacuagrayce@gmail.com', 'Jasmina', 21, '+51927395408', 'WSP', 62, '2021-04-06 01:18:39', '2021-04-13 01:18:39', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'SETIEMBRE ZOMBIE', 'https://www.wattpad.com/1042930517-setiembre-zombie-apolipcis-zombies?utm_source=web&utm_medium=email&utm_content=share_reading', NULL, 'Una ma├▒ana Alice levanta en un hospital sin saber que escena posappcaliptica sucederia cuando abrio los ojos todo el lugar habia sido infectado por una plaga zombie...', NULL, 'Miedo  Terror Emocion  Misterio', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5b8ed719-db0a-4c2b-adef-46e815e55d89.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=r%2By%2BgH6hFlQQO6DsOHzQn9JYe5GQNAVTfjiNk5mHvSTxoLVp%2FiYbTgTviSPWM7gk0YmM%2B%2FBdBqdCThdJK%2BdzLuaPA0sL9fPjxWzcpDeTsOFSBfqJ5p%2FpYtE6LvijYosD21BeCY3Dm6SkFmd0OjTehoQMWSa%2BS7k7Zn6wbV2DeTN4XlanmoY1rUR%2BXhYoyFulG0H9MEz1j%2BsADKtXrk5GeaWeRspzHBELrmNZhZcGULzAIfIfZ%2Bm82%2FP42GfyhqjB%2BS9Bc8c8PvwneRRdFlkpZssZcE48FKLuki7JSaTctW7Gz2PCO3DQhWT2uRHyd80SvzT3Rdbnzybd%2FyOKVvuH%2BQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-05 17:38:30', '2021-04-06 01:28:39'),
(DEFAULT, NULL, 'harveztrodriguez@gmail.com', 'Manuel Rodr├¡guez', 27, '', 'WSP', 103, '2021-03-02 11:49:21', '2021-03-05 11:49:21', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Precursor: armaged├│n', 'Precursor:  https://my.w.tt/u8UHbpWSG7', NULL, 'El apocalipsis b├¡blico', NULL, 'El sentir humano y los estigmas con Dios.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/c5ef07ef-9c58-4531-a4aa-9fd7f05f8469.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=kuWwj%2FnyEm%2FR5xpkYDF%2BhWh7L2fjciyglJxIrumSLps8zSHqhU1arO%2FQ5b4RIkMhNIKb8txcWDvqzqpVVJ19drbwCWbI%2BDt6lGrh9eXZKb1Em3Xdti79zBkASJQSjkyiJ3o0mD9NeILinyDHUnASOweocsDPLleTdD7NzyHwZOb8dV8PW8Dkkz9bjcICeGKBDCVqcDUmnfJ2CXe67K8lGvBl70MS23Q2JZ8D3yyIy6hN86WkZmH3cjgZAymlZ7nVt94gw3OYKmZ%2BRmyNPqMJ8Jr0SZJ6fyJqeN5jUgtgpdly%2FQlZSZ9Wui4LdIWUuOs7PE8lZtJT2dUFvSUnS%2FqubQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 13:03:20', '2021-03-03 16:32:10'),
(DEFAULT, NULL, 'dremurallen@gmail.com', 'Allen', 17, '503 76985022', 'WSP', 62, '2021-04-03 18:51:15', '2021-04-10 18:51:15', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Sobreviviendo entre Muertos', 'https://www.wattpad.com/myworks/205919125/write/836068707', NULL, 'Ciencia ficci├│n post apocal├¡ptica y drama, trata sobre el viaje de el protagonista por un mundo donde donde la sociedad a muerto, y el desarrollo de los personajes para adaptarse a un mundo donde sobreviven los m├ís fuertes', NULL, 'Deseo transmitir tensi├│n e incodidad, al exponer el quiebre mental de el protagonista y las malas desiciones de su alrededor', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/da23295e-c03a-4bbd-957b-d94de33234b4.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=QYdzhNx%2F3RMXIjsCCZ2XlwakPyVsNSvHxtOeQLX3D1Y%2FVeJcYWq6pd19yu%2FwhSfJiPF9VrP2w%2BbxMa2TWAjDVyq%2BzavYnPoCoaATD5HFcbtiHknevUaQay%2Fbdve9eEIC%2FfRsTXHyfEAwm9Y8dmPjyaxnwJR7JyBnTTMM6L3oe%2Bf3ffO9J0jaZHG9nMZewy2UHdcpkWCbJ4m0hajgeGzWQWZQPLFwZNmpGo2ptpqEokRSJVDrFN1czzEtEQX%2BcHOpG1AH5quhNlY5Pz5GbmLqdVeSe%2Be2Qk%2FL1LaPEgjys4xJ98kn%2Bug0ZVIMaiQ6O34DiNIrEg36WU20G%2BSPItFMlg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 12:56:29', '2021-04-04 01:11:39'),
(DEFAULT, NULL, 'marianahuerta316@gmail.com', 'Mariana Huerta', 19, '6642597116', 'WSP', 58, '2021-07-07 16:09:23', '2021-07-14 16:09:23', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Maldita temporada.', 'https://www.wattpad.com/story/256211340?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=xMarianaSwx&wp_originator=Ltd52u%2B6jIxn8cD0G68xsA%2BDPuTifC4gPZYSM%2F9%2BqEz1hnQPO8mKnnXGpBUNgVo5ew9Guvjjxa2ZWERxYFUDBxYylgJj9nxDtpLxDQI%2B3PVSFnv%2FPHBhgyICk1ij%2BnEo', NULL, 'Mi obra trata sobre una de las relaciones que dejo una gran herida en mi,pero gracias a ella pude superar lo sucedido.', NULL, 'Que no todo es para siempre, las cosas las puedes superar por m├ís triste que te haga sentir.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/352b760d-f7f0-4367-9e05-9608c7641689.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=UEZzk%2BetG0eZKz3E5%2F08rUqnxqptPXY92sRo38UF5XiaUFYfzS64EQszpXtQiQoCqO%2BoiVOQo0yGCneTATOK%2FTowAiGWzEitQUbqqff7I3jNqosSufnGBge%2BdovZRf3AE67omNuCObihVvyA9W9bBEgWYO%2BM%2FzNcrPtGtFrShyNFj8OGFWX01PBkGZS%2Buaai4zjOMbOimZc8rxgvOkhgtVzV1pglsoCYHcXNwlmulVx9dcidnlEYLQB5x2%2B6MReV47aNumfpbFZv2pWUuaPOokeHGdzTMe3iCJB4AxQvHBunlfVmfTUTQwX82uXklcCCs0Bb9UAo3uIcXppFKTAuVA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-29 01:19:42', '2021-07-13 11:19:59'),
(DEFAULT, NULL, 'esauaaronoorazma@gmail.com', 'Esau Orazma', 17, '+28 04160357222', 'WSP', 106, '2021-05-30 21:04:25', '2021-06-06 21:04:25', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'La luna se vuelve una compa├▒era', 'https://www.wattpad.com/story/253657075?utm_source=android&utm_medium=com.whatsapp&utm_content=story_info&wp_page=story_details_button&wp_uname=EsauOrazma&wp_originator=CJlgfKWA3edTp5rcNPKoynZ2WM94gEqEKDFRyaAAJ7mk7YFA9PXwGW9Bg6qHLDBQ5E4ZHn4AmOfAXDmYbjPg3546wScpfsrB1I5QMGH4iAkxsNlFKBAleNrWucLptcHP', 'Esau Orazma', NULL, NULL, 'Quiero una portada elegante y simple, que tenga relaci├│n con el espacio y la luna. colores oscuros y letras claras, que llame la atenci├│n. pero que no sea muy fuente ante la vista', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ffde6c76a-93cc-4628-b6f0-6c4a6cbc8fc0?alt=media&token=f15dab05-0614-491f-96fa-5f37640d2f35","createdAt":"2021-05-30 20:40:40"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F50aca5c4-1cad-4927-bb94-04b109baca9e?alt=media&token=df1e3f7b-8bd8-4c51-907e-def0ff96f14b', 0, 0, 0, 0, 1, '2.2', '2021-05-30 20:40:40', '2021-05-31 10:30:41'),
(DEFAULT, NULL, 'yen.ccdi@gmail.com', 'Yerainy Encarnaci├│n', 18, '809 464 7428', 'WSP', 64, '2021-05-06 11:32:19', '2021-05-13 11:32:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Por culpa de unos zapatos', 'https://www.wattpad.com/story/214086188?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=itsyen210&wp_originator=XLx1IlwjJehTAr%2Fy4AYEdtu6%2FiA%2FvGCyzOF8EZC9sVGhyPKb6RJnAnIyk6wt1lNohe%2FG%2BDDT63b4X%2BW4pY9XlXBMxJvJbMk8j1rn3sx0ByM5gEmNWm89765tb1AXHypg', NULL, 'Mi obra trata de una mujer que se limita internamente y de un hombre que tiene una vida limitada, ambos son diferentes pero ambos se necesitan.', NULL, 'Que no podemos permitir que nuestro pasado influya en nuestro futuro y que no podemos dejarnos guiar por las aperiencias.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/448a8faa-98dc-497b-8d54-881254d8d4f9.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Xw3ORfg3sUL8dDJsDN1d8seq%2FpDtVuylVvfQpMfptOCkF7WF3zzGAPYZ%2Bo5tiIwpCoSFxMeUaVH213QlVfZ8c%2Fb6DGGHaExsTzxmZMzlZclfhZpEGncFINwGZzNorFulYdBCP9iTcRa3UMt40boQnGne85pZinhidq19JvXg8Ce6wGpXarzE0bPy5FDSfk%2FjjHTY4vAdU10%2Bz5%2FGp9XLSSxmIETtgAIii9324Nrhi7vZX%2FwMWVuZxi6mwbOlBClV6JHYH6KRchGpws7VjlsbRp1zw%2BBsAp%2BoMtuWB%2BcMTwXIQ6oYQqdTavcvKZw2tPPCX1L%2F1U3NVUFvzdbe9lZFZw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-25 12:58:15', '2021-05-06 21:40:48'),
(DEFAULT, NULL, 'diazmayerly222@gmail.com', 'Mayerly', 16, '+57 3165091188', 'WSP', 62, '2021-06-11 15:27:35', '2021-06-18 15:27:35', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '┬┐cual es mi delito?', 'https://www.wattpad.com/story/272882906?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Maye_C_&wp_originator=%2FSTla%2BCJdYmkXwWOlppkeaSRMSliyu6kmGWh%2FVKEwdDrRybVqquLT3f7fBXmKlL8oHkOtbZga4VnjCT9r0A4KAFBCThPCuVOkOF0a0JP0V830XyhWECa3q%2F1%2BW1Gxj1Y', NULL, 'Mi obra trata de la realidad que se vive en la sociedad.', NULL, 'me gustar├¡a que las personas abarquen un poco mas estos temas y que se concienticen un poco mas sobre la sociedad en que vivimos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/479642f6-074e-4c92-a82d-8e1cd92257cf.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Js7y%2B2dSJJ8d4sZ8ruBz%2FN0EUPXK1VMvC4vT%2BtpGxNeLCBAkKXcePVYKJkBRN6RQxaav9lSBIlhHaI5i%2BO5BYQ0yYjLSmrg5RIt%2FKHl9uJDJltHiqqsWptYL7wkSwbxJVi9A0nuk8ZJW76U60HlGoLzr%2BTG3DNfitvVUdo9Rxh%2BT8u9nATdPCmq0uDdVr80rSvy1Oh5RrjtYDGXjhms084wbsgwSmj4ME49zZBLPR7e5eEFX0LaiQK6qyU6Cnc8iE%2BLE3SRAM97e%2Bur2T7dvTRnzC7qtVswNrKDd8uezmzSt2L8iWHMIkBjv1eHZA5s1xLxWbVAD9Xl7%2BenTRbXpJA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-08 21:54:50', '2021-06-11 16:17:54'),
(DEFAULT, NULL, 'juanarboleda537483y3u4@gmail.com', 'Juan', 19, '+593 99 7381 624', 'WSP', 54, '2021-05-15 14:16:29', '2021-05-22 14:16:29', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Secret love', 'https://www.wattpad.com/story/248977615?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=juanjose745&wp_originator=2tHb4jIhhb8a%2Bkk%2FgmSg7dh2%2BBM7R%2FP0S1JdoOyCZZ5w0C5ZQdvyey7srbMwIneLE%2BiPucKsTgWFQE7G4NZ0PurGWO7G5cWyVu44HZXaG%2B7QZKh5zPODFHAO%2Frizuen4', NULL, 'Sobre el amor, la estupidez de estar enamorado y seguir perdonando y al final morir en vano', NULL, 'El dolor que puede ocasionar un amor imposible.  Debes tener amor propio o morir├ís en el intento.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/7d3e0518-75a5-4b93-a013-147c94d73d5a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=g9oaeDyQdrjS5GrNOr686kAkREf4by2dWXxDaT410VfASfjg13GfNx5mHM%2BcSD1UOVDjrdYitCnzWSCUAnvZe0ds9EFAqSLyMckGPRpWoMQKtWrPVAfrgp2rUKUoT4TfaSedzdQFY%2FxBfLgtgs0TE%2B7HNAxK1%2FTcIJyECgMlWNvLaYk7Uvc0UfVP%2BYUApb0hDE5Bec%2F0qoecMUs0FXUEue3IzEWGNaJst%2BtxdpnNd8KRmH9JewhGyI9SmlcbLX%2FRa%2BRabO%2F8UjRjV1FntNPh5krePSbsMYaE9SlC6ylddMEdHzEhGqwn69IFIVBQ73ZegCinZpq5n0bt1YhjJJPeGQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-12 16:50:29', '2021-05-17 10:25:05'),
(DEFAULT, NULL, 'marthariveraantequera@outlook.com', 'Ml Bradley', 24, '+573137081263', 'WSP', 66, '2021-09-25 22:33:42', '2021-10-02 22:33:42', NULL, 1, 'DISENO', 'POR', 'TOMADO', NULL, NULL, 'Mi coraz├│n buscar├í el brillo de tu sonrisa', 'https://www.wattpad.com/user/MLBradley', 'ML Bradley', NULL, NULL, 'Quiero algo sencillo y que refleje el sentimiento del libro. Es una historia de romance tierno entre dos chicas, pero que tiene un final tr├ígico.  Hab├¡a pensado en algo relacionado con el cielo brillante, las letras en cursiva pero elegante, colores c├ílidos y claros. Puede ser minimalista o tipograf├¡a, pero creativa. No quiero sombras oscuras  PD: mi libro a├║n no est├í terminado pero ser├í publicado en macondika, wattpad y booknet cuando est├® listo y estar├í gratis', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-09-18 12:01:46', '2021-09-25 22:33:43'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '902123505', 'WSP', 120, '2021-03-28 15:32:41', '2021-03-28 15:32:41', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'A la vuelta del parque', 'https://www.wattpad.com/story/263097960?utm_source=android&utm_medium=com.whatsapp&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=qBi341OjaYdaZ9upsXmP%2FSyziNDbiGV6AjB%2BneOxAXjSVlLECKxiZ1actnP93mkSFQjXiGkxY75aGQ6pVKersG4Et711TLRPwaGr7SufVDRCJGWSa6XjqylFTIEdcrkS', NULL, 'Trata sobre el terror que se infunde en los ni├▒os, una forma de ver a los ojos de un ni├▒o que vive en medio del abuso y personas malas.', NULL, 'Temas sobre la violencia, la amistad, los traumas que se generan por una mala infancia y como se siente un ni├▒o.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4f5fd267-3ee1-41f6-92fd-e3a5c6bcdb9d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=SUcfVJ23l60XkZIlwZMqQNMZJ%2BnSUiMQykU7M4xu4duWMXTzLHh3A%2FekMUQzYytytjnpoPP3itc69wUt9WA3l6Gg4OWnyU1ivXJSKbeBys14U7R8Y6%2Btk28%2BII1Sgkv65%2BLQGPty3FCLcHS6JcoUb1%2FHE2C22xX8ya9ZvEMuaTmLqYSf7JAq6wA7iTkgAuoedoMTZ0skJRR0oKlSVF%2B9kXnx39DSr32wi9UM1PaJA6XInzuakZ2m0jEAd49Vj855Ax7NbEk5GtrwqjGx9QAFqn8kYDe5akmDQgPcfOLp1DAN4klTY6agtHmUuOQ5F0NcdM%2BZ0ss5aDfnB7ofEnzo7w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-24 22:27:10', '2021-03-29 11:50:53'),
(DEFAULT, NULL, 'miadurant4@gmail.com', 'Mia victoria', 23, '8299152943', 'WSP', 102, '2021-03-28 19:04:25', '2021-03-28 19:04:25', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, '"Almas gemelas" palabras que van mas all├í que solo dos personas destinas.', 'Creo que te gustar├í esta historia: " Bajo mi piel " de Gianna04G02DL en Wattpad https://www.wattpad.com/story/208966159?utm_source=android&utm_medium=com.whatsapp&utm_content=share_reading&wp_page=reading&wp_uname=Gianna04G02DL&wp_originator=fNcVQgZqhE3BwGTh%2FB1GihhOQwX8G5lMElyRbSrU3mLbCy19LYREsZk%2FEKtOgRv0C%2Bum5n3P61yq4nT0%2BrEJ0PUr4oy6en7NnlZDrWmoMQ1InGy3stJOUgcISQc3043D', 'Gianna G. Durant L.', NULL, NULL, 'La pasion de los protagonista cuyo amor es tan profundo que se funde bajo su propia piel.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fc9be28b1-44c9-4ed3-9dc0-495931e24993?alt=media&token=2cc8d326-80c7-4c09-8ab7-feb0e7be4340', 0, 0, 0, 0, 1, '2.2', '2021-03-22 17:19:40', '2021-03-28 22:33:13'),
(DEFAULT, NULL, 'sacgbautista@gmail.com', 'Sagk Bautista', 26, '+5804129056254', 'WSP', 54, '2021-08-17 13:06:52', '2021-08-24 13:06:52', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'Desbarajuste', 'https://www.wattpad.com/story/256949966?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=CallateOTeBeso&wp_originator=kSnIG9AGS5njmr2l5HyF96KjLF7ns9TmdvQAGrp3YbNxwPZmQgzuSVoyG7uaHZIa%2BufzHBgbxzAJD6lw0uDpWOYlLGilZjZrE%2F0x5UOW8FBnRLJK%2F2cWxRCuptUrYih8', NULL, 'Es basada en un hecho real  Inspirada en una interpretaci├│n musical. Donde los protagonistas se conocen en la fiesta de 15 a├▒os de la chica. Su historia de amor es interrumpida cuando la protagonista muere  por abortar, obligada por su padre.  El protagonista cuenta la historia desde prisi├│n tras ser acusado y condenado por la muerde de su amada', NULL, 'Una percepci├│n  de los cambios que puede tener nuestras vidas', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-08-09 13:25:54', '2021-08-17 13:06:52'),
(DEFAULT, NULL, 'isabellitaalejandra@gmail.com', 'Isabelle Viden', 18, '+58 4144777632', 'WSP', 60, '2021-05-16 12:21:22', '2021-05-23 12:21:22', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Vestigio', 'https://www.wattpad.com/story/256029575?utm_source=ios&utm_medium=link&utm_content=share_reading&wp_page=library&wp_uname=huevoizquierdodeLiam&wp_originator=%2BMPnPBWkrjIbIcD7pI%2BlbABIro%2FKfq24Lug1mkGRSaiFA8%2Fq46fSGFOyiOY%2BiZj6JkXL%2BWSzFLcTyIeXzOXZxcHoYRFSROFVBeIbjhVCmvutKy%2F7SRoxTq4vGt1am1s8', NULL, 'Un grupo de adolescentes que se ven atrapados en un pueblo fantasma, el cual les pone retos que podr├¡an costarle la muerte. Mientras que hay romances y dramas.', NULL, 'Amistad, confianza, cinismo y m├ís que todo misterio. Familiaridad, y deseo por estar viviendo la historia', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2d066053-62b1-49ca-b610-ef6df4a2bc60.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=1JKwNalXxsewOgB5a5h75ofSka6WPcmUzIULFzZmMME2qfj9E9ZjCKru%2F4RcQdbFzbLjrRyjKlYq%2B8F%2BwRTVnLPz2XUyMUl2VA%2Ft4JEETUqY5MrGkLUI5hnjA7TYEd6PtpczhtySfqXJVYpa0f5Sh22u4A%2BktpSs80V4NpLRWy5lnBMzUBLBvBf%2BdNTJX5ElX8JZevPmW3zBCTdO2pa2SVduJiIUoDptusuS%2BVFYENeQ1RdL6B0Fu%2BODcZXKnHZQFhjzLeqWFEc0Ji6zWI%2B%2B%2FeHAQIXyGvt90vQ0lkIUXslPBI%2BWpZLncfvhCKi%2F9b0z234fGniGqo5NbQOfzhezOQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-12 01:19:52', '2021-05-23 09:25:24'),
(DEFAULT, NULL, 'propuestasedicion@gmail.com', 'Richard Gutierrez', 23, '+58 4167496357', 'WSP', 66, '2021-09-02 12:39:01', '2021-09-09 12:39:01', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Cronicas de belkan', 'https://www.wattpad.com/story/243698024-la-lanza-del-destino-cronicas-de-belkan', 'J.M.A.L', NULL, NULL, 'Me gustar├¡a una imagen con el protagonista en el centro, portando una lanza de color dorado, mientras que a su lado se encuentra la protagonista femenina, y al otro lado 2 de sus compa├▒eras, ambas mujeres, mientras que en la parte de arriba, est├®n los 2 antagonistas de la historia, siendo 1 de ellos un caballero que porta una armadura plateada y el otro un bandido con apariencia agresiva, siendo la estructura de la imagen igual a la del boceto que les envi├®. el protagonista, es de piel blanca, cabello casta├▒o oscuro  y ojos casta├▒o oscuro, mientras que la protagonista femenina es de piel blanca, cabello rubio hasta la cintura y ojos azules, los otros personajes pueden ser de cualquier forma me gustar├¡a que en la parte de arriba se ve├¡a el titulo de la historia, "Cronicas de Belkan". Eso seria mas o menos lo que quisiera para el dise├▒o de la portada, muchas gracias.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ffc6b1b3a-71f1-4f46-83b5-4ad680a72d39?alt=media&token=3bc005e3-599a-428d-acbe-aca716c09522","createdAt":"2021-06-06 23:33:47"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ff8dc20e0-280f-4f7f-a5d8-872f98021ce2?alt=media&token=4fbaa0c4-17b9-4946-8625-0b79387a0246', 0, 0, 0, 0, 1, '2.2', '2021-06-06 23:33:47', '2021-09-05 21:54:45'),
(DEFAULT, NULL, 'amadorg317@gmail.com', 'Abby Amador', 16, '+50496830698', 'WSP', 50, '2021-04-10 18:13:13', '2021-04-17 18:13:13', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Un amor sin escape', 'https://www.wattpad.com/story/261259115?utm_source=android&utm_medium=com.whatsapp&utm_content=share_reading&wp_page=library&wp_uname=AbbiMejia03&wp_originator=dZvrIpCqlxNmdqvKtNZ%2F4An9PJ5RZyaIyeDNp6qIL6Z2GqAz1%2Bcs1pVy4c0YUvtdwbdqWPkAYkFEjeVSBDIsJR5fjPglJHWwH1fQg8N7t9fTfQR553mxo5agkrCrZ4%2FW', NULL, 'La obra trata de un matrimonio forzado en la que una chica tiene baja autoestima y el chico que siempre trata de huir de compromisos pero durante pase en tiempo se dan cuenta que ellos son el uno para el otro.', NULL, 'Que siempre va haber alguien que va querer sanar las heridas de cada coraz├│n a pesar de llegar en el momento que menos lo imaginas.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/eeac7a2f-d67a-43e1-a10d-4e48f193a7fa.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=MkfZ%2Bv05iJmkCinOcPVHNfy9XMSAkXFB8%2F2ogei57DDNlZ%2BnHGXyiLFG2FouHB5dAfmn4iy92LWBMfsl156ws4AIkRQE7vZH4ng0BsjnnT7RpCv1642TOmuADg4UdjXydboxwTl2D7jpvHLy7BmmmfgMMIPibqAVrSmMlXrvp0iDhp5A%2BAQlq9ceXoH6oDJlrXXfu2gDwGI69Q2BfuHxM%2FnscU%2B2b0aNoRIXnEVxbcdn86nYOer2bG5TJFUZvBW2tTucRfXd8GdfPmvhF6vDrICU7%2B51tDGgdzKr5sd0FUEEBrCycqvbD9Ax9vjpFNEGDnqttwDfIelpBTY25cwJ1w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-09 12:52:40', '2021-05-23 15:53:35'),
(DEFAULT, NULL, 'daniloroldanr@gmail.com', 'Danilo', 31, '01173602933', 'WSP', 54, '2021-10-12 07:22:58', '2021-10-19 07:22:58', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'Vuela villa', 'https://drive.google.com/file/d/1xQvpROERxjV6VHqAu80VBwvel4ZX-kyd/view?usp=sharing', NULL, 'Una ciudad voladora y los problemas de sus vecinos en cielo y la pobreza.', NULL, 'Solidaridad, fraternidad, amor, conocimiento de clase.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-09-23 15:12:27', '2021-10-12 07:22:59'),
(DEFAULT, NULL, 'arletteyocastacorrea10@gmail.com', 'Arlette', 14, '+1 829 457 6750', 'WSP', 62, '2021-07-08 23:04:33', '2021-07-15 23:04:33', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Me enamor├® de alguien que no s├® si existe', 'https://www.wattpad.com/story/265768816-me-enamor%C3%A9-de-alguien-que-no-s%C3%A9-si-existe', NULL, 'trata de un una persona que observa a las personas por la c├ímara y una chica llamada leah empezara a usar eso a su favor', NULL, 'suspenso, romance (Aunque tiene 5 cap aun el romance esta nulo)', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/325e4251-0e1b-4c26-87e6-2ec4c271f689.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Ls2VIv%2FNB0mefc%2BCUCQ9%2BAnFo7kyx46UYycVGwm%2FSI0XhR2FJoLWVqObGK4eRQYNRUVNc55QydTevaxq2OomYqfdAdpuLEvIQ7Jod6C6RpRKZDjD4A3Kut2slBN3TR047pTXUz72U2Gok8HxW%2BwjAr93QXWWCixgQA7M702yJQso9V9vQzFwdbPj0voRVraqph2MWlVSnwZKzvvC5xOIqJAfhHN4pWJfDx%2B3j%2FHRi4iFRt5usOMRnyVwayahE08rHvcFY%2FqAfUi2yiwUh%2FJEJNYHlMjAgZAxlzufA8WNvOd%2FiRP%2FIN%2Fts6UY%2BGlmZre9GsQAZdCG8NI4BVruDGEZzA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-07-06 19:34:39', '2021-07-10 18:21:52'),
(DEFAULT, NULL, '131monsrealalan@gmail.com', 'Alan', 17, '+52 999 996 2394', 'WSP', 63, '2021-04-22 01:04:27', '2021-04-29 01:04:27', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'De tu mano, gu├¡ame. [Larry]', 'https://my.w.tt/p3bGW9Y1Dcb', NULL, 'Trata del amor olvidado, de como un accidente es capaz de eliminar todos los recuerdos del cerebro pero jam├ís del coraz├│n.', NULL, 'Sentir amor, nostalgia y felicidad. Todo se puede.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4df73a4e-6be4-455c-a90f-90d4f3d5c685.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=BqQyCVz4LuIKzOERcKxrcb1uJdD85T67yNSHbuopsKWlxGoQS2FhumadFYioavRt%2F6U3JuVPzeHjvWqFov6DaBlEJK1I3JEEZbawBY8luazlVrUVY4sZnf1xPP7YugRXn4I9XZzVG%2FnC%2Fu57SlyevwZ6EzOPoj%2BPf53rswHZSR0aO0SaQBWNeQ2cKSYXcyEkHOCKXnA7%2BBMtvwvJ98qptiQqnQiWUPhCYdWyjsXCfZ%2F3tuGD1wChIolVGiQRrh15L%2F%2FDJgeIPxZIy1gyvqTfiL1afRRJ1ij6FRUewAq13ZfLznASaTvwRNGCkNNidzrMW44NwxOX3q%2Fbq6DyamvaSg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 15:41:14', '2021-05-25 13:20:18'),
(DEFAULT, NULL, 'Francobrescia8@gmail.com', 'Franco', 25, '+54 2954 15838708', 'WSP', 115, '2021-02-28 00:01:19', '2021-03-03 00:01:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Bullshit Baby', 'https://www.wattpad.com/story/221818330?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Un_cronopio&wp_originator=KIjdikpGvfgk5bdNNzmnoB9cwLXz2ax%2FrWVo4lhhxCJ5HuKQ6ta6hb6OMIiGhLmY%2FokR%2B1sNpvKjP%2FVW0Apq1Nck6F4gJjKx2lUybaXIt4xaCooEtSfjTCfHY5%2BAzfYh', NULL, 'Es un cuento policial, con elementos t├¡picos del g├®nero y otros menos habituales, como la narraci├│n directa y personajes m├ís humanos.', NULL, 'No deseo transmitir nada. Es solo un cuento, una historia breve sobre la moralidad, la inmoralidad y la desconfianza.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/21cbd405-1f06-4da0-b028-de12eab0a672.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=bCRZExis8LsvAm%2F65LiVJ02zuK4F7e4BnAI%2BeJ9b%2FEwzQ9xqikrklL7hURjp5BOkj5esHJ6zJ2hwI7KIr70ELWU2x2DDtgvvdgYFqUNztfE68hQGGQa6QstalVnMdki%2FIPtiK9U7ColwpK8urEMh24ZoeCKZHf4w15qzGxpbtol0uPHalW1wk6biqLimJ4mWrpGJ%2Bw4GUo7a5mfmdvNS6Qi9Y8q4h%2BdQC1dxhtm9iK6FB%2B3ZoCAZawVXjTi7dc070uBSAbZOyI6hMfBDcuniWRhaAGO%2FIdrUu%2FS4nqeELUNTXkSkr63MWxw%2FIarqdL6nFExm2JO%2B27ecu6z1dmhhHA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-26 23:33:58', '2021-02-28 00:22:09'),
(DEFAULT, NULL, 'kleyber.caraballo@gmail.com', 'Cartas para Lissie', 21, '+584144066150', 'WSP', 62, '2021-03-18 20:41:07', '2021-03-18 20:41:07', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Cartas para Lissie', 'https://www.wattpad.com/story/261999421?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=kleybercar&wp_originator=1y1QOHFoykVMOPWHJXdVjuaXRW09iwxEqW6oEfn6lIbASLcPS%2BJch%2Fb6n6i6OMcIu6toxsnXcEDGTYeHA813NfKIkr5gWG%2B1edu%2BwrdjZUMOalduloCEayF1W4rB1vz%2B', NULL, 'Una mala decisi├│n hace que un padre pierda el momento m├ís importante de su paternidad. Ver nacer y crecer a su hija es lo que ├®l quer├¡a, pero la vida no es siempre como queremos que sea y menos cuando tomamos el camino f├ícil que puede llevar a celdas, celdas donde estar├í todo su vida, celdas que lo tendr├ín alejado del ser que m├ís ama, a├║n sin conocerlo su amor por su hija es tan grande que lucha cada d├¡a contra sus demonios para poder salir, aunque la ley diga lo contrario.', NULL, 'Quiero transmitir melancol├¡a al transcurrir el tiempo con cada Carta, lo que puede cambiar unas vidas solo por la decisi├│n de una persona.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/241c020b-34ef-4ed1-b939-af8b4d56ce77.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=hOY9CpTBd1w8zZEkPKnJQHFBelL22%2BiQlOLrDYB8kKw4Ptf7V8eYBaJ0uGbR1R9pENtAGN%2FqZxASEkcSLkeNboXue233L72dFtBFgWES1%2Bbsi7uArg3cVuzu4rymuBNf%2FIvjHiDFVWmSAIUnUJqOWWww%2B2x8t5us6hYf8ARK0xPUWDi9mXBmr6gAvc80NI%2Bj6Ki1Ao4iGw4LHPJ3s3BaGTDKwdI3tlYyI0BaFuBsJNxRfHyT9if0vRX8%2FkcmXF3ZcbDqXpHIRc%2Ffx8Wzc7j1bXDk8IzoE1N1ZBGGlbTap2JIbZxvwi6yNj9PolqwgcWHRVwJcyOyzMRZCV03ZEmvQQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-18 20:35:11', '2021-03-19 07:19:00'),
(DEFAULT, NULL, 'vailenh19@gmail.com', 'Ail├®n Herrera', 21, '+543476566297', 'WSP', 49, '2021-04-12 20:27:46', '2021-04-19 20:27:46', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'INMARSECIBLE', 'https://www.wattpad.com/story/259169568', NULL, 'Mi obra trata sobre el destino y las ocurrencias que trae consigo, las vueltas de la vida y los errores que puedes cometer sino lo aceptas como viene.', NULL, 'Deseo trasmitir un ambiente fastasioso en una atm├│sfera ordinaria, la magia y la vida diaria tomadas de la mano.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/c5ac62b7-80a0-4a3f-8ab4-f55ade86c874.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=1hc3cZwt2OxlsGbOZsiyWN3YpQNmRgsiluw9SUecMIC30H99OwNCfcFA2qoLGjxcbmfgYZUJ1XO%2BtjI3P6FjI7SzZWwqPW6mrmuSbdBagiBMi%2BB%2BVcn%2BlHBme8zGWPLB0yy7oQ8SeFHnzulQSmYNzwcCc%2FOG7R4nntcFXr3RnRekmTjjru0vY%2B2Mn5%2F%2BWPkjGYJeyeEIrLECb236%2FX%2FPZo%2FXtbsFjVbSUiN6Wv5lyju0ZwcbDqpDwhUI%2BXYwuZhemntDdDYUWjj12Fk0WpQRX%2BLenMXaxuS4rCgsRBsF%2BWQxI3jjQ3%2FVjhec%2Bg4%2FF3r1h7BoZqxwIIoOaZ90WqcsqA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 22:37:46', '2021-05-27 21:24:35'),
(DEFAULT, NULL, 'esauaaronoorazma@gmail.com', 'Esau Orazma', 14, '', 'WSP', 50, '2021-03-01 09:10:56', '2021-03-04 09:10:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Love in the dark', 'https://www.wattpad.com/story/253657075-love-in-the-dark', NULL, 'mi historia trata de la vida de un adolescente con un pasado que lo esta consumiendo, y con la llegada de una chica nueva a la secundarias cosas misteriosas pasan como el asesinato de uno de los personajes, los protagonistas tendr├ín que  descubrir quien mato a esa persona y el camino sentimientos surgir├ín a la luz para bien o para mal.', NULL, 'romance, misterio, suspenso y secretos', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/e3b20251-0e04-4ff8-af0f-795046d05057.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=kME9btTKNP1zh3lRpYwK6R%2FsD5oudgfIBJI5y16mk0AkAM91YOYN2YJIPzrV7PLcBNDV4a98VxS4gYdqR5vprqLZCVKDk9rXWYSl975sj0%2FKvOgIRSIihDlDvacXUqaqeK3zrjauzG%2FH2RaYLaYumrELyupYa2yRIxpLPFfXy%2BNOyuKE%2BYzg0%2F9Ugjem43EVS11w0mVEmxPNuGhTuhES7X4UJWbPUiMctiwP%2BfY5oyRMgevcIG%2BKvSYROTD8oHAVpdlg5nae8mPYT25TrPHOVXK5B4xOgn8VO7nQ1STU6KiratHNvGtVesmYWiUNYY5qiLJe26sndPT%2FCNmiawut2g%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 20:21:37', '2021-03-03 20:56:26'),
(DEFAULT, NULL, 'ineskyblue@gmail.com', 'In├®s Silva', 24, '+59894549919', 'WSP', 56, '2021-03-07 17:28:36', '2021-03-10 17:28:36', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Lluvia con Sol', 'https://www.wattpad.com/story/229087075-lluvia-con-sol', NULL, 'Mi libro trata sobre cuatro adolescentes de diferentes clases sociales que tienen sue├▒os relacionados al arte, y c├│mo prevalecen las cosas que los unen por sobre las que los dividen.', NULL, 'Deseo que el lector se identifique con las situaciones familiares que los chicos viven, con sus inseguridades y sus conflictos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ac029b28-7985-43a6-ae85-fa80d26a6346.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=qXe%2FbazqPclMKbdMuI%2FVPiNLuObktN052bqjUuqpoMEBWvcptQ8X0ZV0xIpiomUlnPnz%2FT8yG%2FvFBQUx%2FSUoeEdzEDNeowqv5Mb8NCWpclH%2B5xK6GCuGezxnrYm3HPP2%2BNmtZLw4wEr6b5lcX%2F2NJoBqhv04W%2BulhR1t6NqhPXz4jRBT6ttki72M29l%2FUB5D%2FbTFewYBSwgLBdZcxAmZNkLzan6277AFyiogLSKPhvrvGYHFIZSxz3eh41upxvI4qJD8G3vbPkRUhiXjzyb4maTjy%2F%2FCvIAr1c9Ksj2NHxmZ%2Fnws4IILtznyL9xq53O%2Fx3SDv%2FrrQ621xNmklTOMcQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 09:37:52', '2021-04-22 15:24:17'),
(DEFAULT, NULL, 'arletteyocastacorrea10@gmail.com', 'Arlette', 14, '829 457 6750', 'WSP', 52, '2021-04-09 22:15:55', '2021-04-16 22:15:55', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'La muerte es un juego de preguntas donde solo t├║ tienes la respuesta..', 'https://www.wattpad.com/936581029?utm_source=ios&utm_medium=link&utm_content=share_reading&wp_page=reading_part_end&wp_uname=Arlette20YC&wp_originator=mMIzultwef4HfOMCxJ4FJnCljTZ3%2BdO%2Fi5CQ0gUqbZOKYYTvrMVHhCQ2ipS8hjXmzK8wjqv2nW1aTRBnDGK1m6Hpxokpdcal%2FAm%2FCmHdBZUQrKASPS2Rf%2BGdAMqpCZ5r', 'Arlette20YC', NULL, NULL, 'Suspenso y terror', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F44e56ab2-e712-4b5d-9cc4-5b76d2152621?alt=media&token=a922aafa-a1b1-4796-8977-67f0f663a503', 0, 0, 0, 0, 1, '2.2', '2021-04-08 23:29:46', '2021-04-10 02:46:13'),
(DEFAULT, NULL, 'mfernandartovalin@gmail.com', 'Mafer', 20, '6221501842', 'WSP', 51, '2021-06-07 13:23:09', '2021-06-14 13:23:09', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Skyscraper', 'https://www.wattpad.com/story/236065616-skyscraper-%C2%A9-%E2%9C%93?utm_source=ios&utm_medium=link&utm_content=story_info&wp_page=story_details&wp_uname=fractuscorheart&wp_originator=gtimmekqlfzdcg5vyxmyohgvf9j0ndlamkmnxo6qer%2faw0vhdlgzotlee19qkrb%2fxmsgw5dhctlyb%2fopscquuld3pmwfycizcfyboaqfszq7szfuswhh6tupwxpdjrvb', NULL, 'Mi obra trata sobre la historia de amor de un chico y una chica que se conocen en Nueva York, pero hay acci├│n de por medio debido a las cosas en las que el chico se encuentra involucrado en su trabajo como apostador.', NULL, 'Deseo transmitir amor, miedo, incertidumbre y curiosidad.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/773a0d98-6515-46b5-9ae9-93d906d1c6ea.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=3My2458SirpInxExsu8qkJ4tciPZZSSXfeqI81g5zNzGZRYPbtkm3MMAQclDyx%2Fi9E4%2FNDabN7T2rllICXPhJh0pzP3tVNYQErEwTfK39tKxDOjqXvfNq89ns9K%2Bwc0HWpofNKY7m5Y99odkKXS9h6oxAQM7SjnrrVAz5%2BmduhgYwxBnypm%2FPpJUy8cWmhowrK%2BWOVPfw%2BDeHG5M0gqTA2A9szVTLSibhaJhaYH5vhnRGyWYuMKhXEeE6iJZEEFHSOcG7GzPQXSwq0EF18usN8yovspQgSOSYKDBAvCIloykIm2g5evrKoSP0IG9OakIOsQU0n%2BF%2FBuj9ENKZx8bBQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-28 16:24:04', '2021-06-14 11:41:27'),
(DEFAULT, NULL, 'isabellapanqueca28@gmail.com', 'Isabela', 17, '+584148807500', 'WSP', 54, '2021-07-05 10:16:01', '2021-07-12 10:16:01', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '┬┐por qu├® muri├│ morgan?', 'https://www.wattpad.com/story/241481364?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Panchito_UwUr&wp_originator=BNb5pJk%2B5PxZV2i%2FkzyVK2wnamd3EOySTtJGhjodCE0SDwMe0OWta76bryEf4wiJNgwDTQC%2FgrT9k1a8X8LIbBHfYzzG9Z%2FVNF10HH5fnKLSBOsQD7sNUIbFD5hYKhc2', NULL, 'Un peque├▒o resumen, ser├¡a que trata sobre el misterio que trae consigo las violaciones que pasan en la ciudad donde vive Morgan.', NULL, 'Quiero transmitir que, no todo es lo que pinta el dinero, que la confianza apesta y la tristeza tiene en su cara una sonrisa.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/467ca787-4868-4ce5-9519-0d7e12f980f9.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=PS71zI%2FrqToM3jXjLv%2FA5Bvhv3S2NdH7l85oKGAf1cn5kIgblK%2F6Om7b8suf1qSb4yJ3VwYEMMaPOhwpFy73lIzs%2BiXO2AjiEPeTSJTUQVz6268UJiLEKP1X0m9JhhpZH4zw6rw4IooEgAPDt6EE6TVDMQYzJPpLV%2FHexoJG8%2FpAOwO7S0h8JjLrYT0zpu0LL6fdakXVkUBpdn5XCnZYinmshvsz%2FEaVRu8b%2BoQqtLyEFf2JKrN1sPO1urt7uDvekbAFBcbF7M2gd6flaUFbDjdbrYWZdP%2BR02HAdS11noEwn7%2BAAnot0fN%2FkdjxmsFGQ8%2BJiLJPWXqiB2t0UuVeqw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-27 00:01:47', '2021-07-11 17:50:11'),
(DEFAULT, NULL, 'bcaroyaranga@gmail.com', 'Brenda Caro', 27, '+51 902 717 018', 'WSP', 54, '2021-05-21 16:54:45', '2021-05-28 16:54:45', NULL, 1, 'CORRECCION', NULL, 'HECHO', NULL, NULL, 'Una lucha dimensional', 'https://drive.google.com/file/d/1ZqAl6Krvs9wx-xd3OvZeOoQhEwtqVtdy/view?usp=drivesdk', NULL, 'Es un fanfic de la serie shadowhunters y s├║pernatural. Fantas├¡a.', NULL, NULL, '', NULL, 0, NULL, NULL, NULL, 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-correccion/dcffe541-2d5f-46ae-a75a-a5dd7b046827.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=FIBrNwt%2B%2FdVRyrJscfqxC9WUfxdvBtQljo1JoSSTan4Jt7jie86cIiRJ2q7SOf2S9HefOD1FJY0NDF457EQBZjbu3O9UfIq8FRwzrUMtF64I2SVaCrKt93Q2hiBqihe44D29dti5tjLAoXm2Lwp%2Bg9XdD2CpDqu7tIyI9KtcJt24GV25I%2BlggAWeYAMwGrYgFLuAcRmWUeiFuKVLsFnuN9I0I81PEsFUCoje6oqhk7J%2BW3U7kX9nHzZkhA3gnJkNtcsILsrWmA41oMT62VaECYYmS7MsMpEI54B9dm64VToDgOD4XG4nuYld50aPnu9hCZTVts%2FRuB%2FQcb1RlPY80w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-07 23:46:32', '2021-06-07 09:51:56'),
(DEFAULT, NULL, 'alex.6.vb@gmail.com', 'Alex van Buuren', 29, '6142220996', 'WSP', 50, '2021-02-27 12:27:35', '2021-03-02 12:27:35', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Aufheben o el recordis de Helena', 'https://my.w.tt/g9GpWKirLcb', NULL, 'Una historia de amor imposible entre dos chicas que son saberlo luchan contra el mismo enemigo para buscar la verdad. Aunque esa verdad termine por separarlas.', NULL, 'Espero que el lector pueda adentrarse en el mundo de las protagonistas y que las acompa├▒e en ese viaje de incertidumbre e intriga que recorrer├ín a lo largo de la historia.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a00e323e-acea-48da-8805-0b48a9c7011f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=njJlRY6IkHh95G7W8PFSgKVw7AU0aQo3DUUuuPhjirHdPNh7FKUWus28fZ%2BoxYEd1xIzuh9SBUdt4vowGp39CKiKLwDthe3aQUAQ%2BDWrUF%2Bni%2Fxndw2gHOc4BZxQlCC3e1BsmuSraUGkpvNdg%2BbhZecqYTTHiKWmpRCfJem71Xc%2Bk1uMMQiE4Xj99dYxwYTTRK1sT%2B8u2CgYyA9ydepoZjTqUdbiF7r1ggTgOYWlXudMXNhx%2FQEKDGofDLrns1Bd9PV2tsmvU%2FZSU8jBSsHMAPlFpci7%2BE82ZeXF1rV4ZczgC%2FVpdO74dYNDaVUdZyicqfSr8wgF7xiEJeq5JoeEOQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:57:07', '2021-02-27 13:42:00'),
(DEFAULT, NULL, 'sandy.dudynskaya@gmail.com', 'Nana', 24, '+593978870453', 'WSP', 59, '2021-08-04 13:19:13', '2021-08-11 13:19:13', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Dream on little dreamer', 'https://www.wattpad.com/story/257451640?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=nanauser97&wp_originator=6j1wnaALVqUhXIcEn3ihbZXwiHkk4J2SKVMZHxnQ3SRZSBT08%2Bvu5NFl%2BJD2VWYGUlzpM6QXdmO5pFeVvfqSHBiBVHQgEbQETv2mEaJqz2hjfxKQe%2FA7%2FmDyhKnicism', 'Nana', NULL, NULL, '1. Algo con tonalidades fr├¡as /invernales. 2. La historia es relatada por un fantasma. (Quiz├í ayude esa informaci├│n) 3. Hay un campo de girasoles.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F53dba156-a467-4876-b55a-4413df2e1ff9?alt=media&token=ff2e4fa3-03cc-41c9-87e1-5d2bc4e90065', 0, 0, 0, 0, 1, '2.2', '2021-08-02 16:45:41', '2021-08-27 18:47:54'),
(DEFAULT, NULL, 'karen.rosas@ceuni.edu.mx', 'Karen Rosas', 23, '7352090371', 'WSP', 50, '2021-05-24 18:57:05', '2021-05-31 18:57:05', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Cayendo por ti', 'https://www.wattpad.com/story/245932461?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KaryRose7&wp_originator=gxry21EGKpqHwhlPqditNx445A%2FLog%2FCMFvcnMJKL899yrQifZ7aycdUOG%2FnXRfpndNFPnb93DzmgYewSWaz1n6jRNFeRsNR%2FE6UeLBYCvHPTUmsZ%2FdsLeH2LAsFe1Vd', NULL, 'Mi obra trata de una chica que acaba de terminar con su novio, pero que inesperadamente se le presenta el hombre perfecto en su vida, sin embargo las circunstancias y confilctos hacen dudar de ella al merecer a tal hombre y lo aleja de su vida, sin embargo tres a├▒os despues ├®l aparece de nuevo, y esta vez ella intentar├í tener algo con ├®l. Las ciscunstancias que los envuelven estan llenas de dramas, enga├▒os y deseos de venganza, ellos deber├ín decirdir si luchar por su relaci├│n es la mejor desici├│n', NULL, 'Deseo transmitir pasi├│n, insertidumbre por las deciciones, incluso amor', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/d5893cb5-f9d6-4cb1-bb9c-b3054dd23f1f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=lO5AYedefxR4jiHb2GBWQry78OLnV9PckDtVZeO1hdxz5fNJqvlh1wr%2BDrMHFVoqi3ujbWqzxg43V61T0x%2F3MzEflbJy0OwJwIMXBzOffhVWkipEEv7SvexLH1ZZFFE5x%2By8JyByuJZ4vZWQ83BvedbhbDDqgremJGfSolronGZfylJFgM%2F7yy%2B%2Bjt5UZxhmQ9C5ZddJMcBNEo8myq%2BsuXpObBSSvUaqH%2FYYiwzslmborgir%2FqCS5ZCxCwAlEdzDJR4FK4gidXsqZjf7TEcQIBZZq4RFgNt1pQFTUGmFK0sfCs94CP%2BMURP%2BG9t5sAFICBmGrQVbxQCH05mcK%2FdtkA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-20 13:56:09', '2021-07-17 18:46:39'),
(DEFAULT, NULL, 'esauaaronoorazma@gmail.com', 'Esau Orazma', 16, '+5804160357222', 'WSP', 60, '2021-07-07 15:56:19', '2021-07-14 15:56:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Love in the dark', 'https://www.wattpad.com/story/253657075?utm_source=android&utm_medium=com.whatsapp&utm_content=story_info&wp_page=story_details_button&wp_uname=EsauOrazma&wp_originator=CJlgfKWA3edTp5rcNPKoynZ2WM94gEqEKDFRyaAAJ7mk7YFA9PXwGW9Bg6qHLDBQ5E4ZHn4AmOfAXDmYbjPg3546wScpfsrB1I5QMGH4iAkxsNlFKBAleNrWucLptcHP', NULL, 'una chica nueva en el pueblo descubre que sus habitantes no son como pareces en el camino conocer├í al protagonista un chico con un pasado doloroso y su objetivo se vuelve sobrevivir en este pueblo, Smallblue es un peque├▒o pueblo virgen de maldad, o eso es lo que pensaban sus habitantes, hasta que misteriosos sucesos sumergieron, y acompa├▒ado con el ├íngel de la muerte; al igual que nuevos habitantes, alianzas, amor y pasi├│n ser├ín parte clave para descubrir  los misterios que tiene enterrado est├® peque├▒o pueblo.', NULL, 'misterio, romance, suspenso, secretos y que el lector se sienta identificado con algunos personajes.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6864750e-52d7-4e8a-b40c-45a65d097595.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=LCWk%2Btx1LF78%2F167FhBJbkg%2BrpJVkzuJUYjF5QhmcLyUp0WuuVgtD2Oz3rlU04JLe59VZ8%2FC%2BIhbBvCYexk5Ra2H8WOpItGyY3t8jMOA5zbnkiZ8jEJgplHooVp%2BIMYjmF7sWJFKpzEzNvX2zw2cNWW9L3lGun7KUfdpMcjRSm2mAyP9iZoQTrEf8ioz5b6hUux5l7orEgabS6clgV1IbHh51Tqs7CZ%2B7C7GRqJ6yOpgD8t6UN%2BrRfE4K9eff5EQN%2B6d9wAd2sJ0zOR1VENro4pjDcsrDIB0ef6L4QUy21quG5FJ38Zr9m7Wy5L9PK%2BjPw8Dy5TRnyNtA8UrGZI8Gw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-30 20:28:46', '2021-08-03 11:42:00'),
(DEFAULT, NULL, 'liyatsu2@gmail.com', 'Diego Valdez', 23, '+526566094892', 'WSP', 55, '2021-08-17 13:32:56', '2021-08-24 13:32:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Shine dream quest', 'https://www.wattpad.com/story/239315869-shine-dream-quest', NULL, 'Una banda de rock femenina en su camino al estrellato. Su ├║nico obst├ículo, les falta baterista, la soluci├│n es reclutar a un chico y que finja ser una chica.', NULL, 'Puro entretenimiento.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/3ed0f583-f242-4ff4-8d95-11e87762c94f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=lCMRC5nYipIc358c9UbH6fzwPACtGcnufIiaMl1FLYoTRKhBjCls%2BxmLV1mjY637QtMCJMak0hQ6lolezaMOcBJUIlnT1zoa97I%2BONzh%2FjvhzWsvhZuxwuBl72KnETJOzzYxkQeQaslzZMIidt9YMJNqjT0kaN3kwKVTlme%2Fk%2BkQJhXPammkvkCtyYYgCR9Zc7p%2B%2BYJeUVZNfK%2F88VfNe64G4KvubD8KHAjH%2F8vb7g6BQfEqDOwd3gl%2BYGjVChwldHKlzETMQEPDDk2QC0i5CtoY4W%2FOTp63x35dhpc%2BzO4aq8Gfk4DFVJgwOBySmkHP0wdVahAnFvO3s4lmDxsQwg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-29 01:12:40', '2021-08-23 11:20:05'),
(DEFAULT, NULL, 'katimosqueira@gmail.com', 'Katiusca', 45, '+5491168036476', 'WSP', 116, '2021-06-01 12:16:55', '2021-06-08 12:16:55', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Dos pr├¡ncipes en siam', 'https://www.wattpad.com/story/241887156-dos-principies-en-siam', NULL, 'De el hijo de un jefe yakusa que despu├®s de sufrir un atentado contra su vida se enamora de su m├®dico, de su hermano luchando contra sus miedos, de la relaci├│n de sus padres, de todo lo que ser yakuza significa', NULL, 'Suspenso, intriga, al no saber qui├®n quiso matar al protagonista, romance, y de lo que puede ser capaz una madre por salvar a su hijo', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/7f3eb38a-e150-4cea-b414-d66bb9c84f23.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=O8KACaHBCwujOfAkZWXfCAj1lKpSdHjJWu3eEsfjd0ixXXTSlimgBoraDar4gwsFkZjRqIFjV7%2BBZaWQurGUlV%2BTVb0v6g%2BW3sS96hwSz3UvpjXYbtXXQ%2Bq4bvEtpf2VSyLJiQ%2Bb%2Fa0rX1TGaR61C1GaHkOBtDBLMPFzrK73taUC8qohHLANg2CSGXHxGHLBZftf%2BxKO5wKRI%2F7EyZxmYWFOGIYbu04xUBieXQUY871xGbKXEo0zZ%2F3TfZ4%2BpkEJHxonK0ul5373PMIvqok6x41ht%2B5SmJUPycEE1UyXoAfgeb9xU3RnDdM9hexD%2FBgNz6gtOU782y6YO1mXXkvxmQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-09 05:01:10', '2021-06-10 23:01:32'),
(DEFAULT, NULL, 'eglez1701@gmail.com', 'Emiliano Glz', 18, '5561126041', 'WSP', 60, '2021-04-19 15:46:54', '2021-04-26 15:46:54', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Semper vigilant [cr├¡tica extendida]', 'https://www.wattpad.com/story/258230946?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=EmigHolmes&wp_originator=cpA8sHZiyFS6VKy6nI%2FUL85HLJD%2BmzijYf6Ke9OSanI%2B3ealh8%2B2VRPyOIpbzpraPjnisKpUo7U61kMBejn4MCacLnFd6uOFk88buKPyiu1KHf9E0Scmwi3B6tclkkB9', NULL, 'Las historias de una cadete reci├®n graduada de la Academia y un Capit├ín veterano se cruzan, en una carrera por detener una inminente guerra civil que podr├¡a hacer caer a la Rep├║blica, y con ella acarrear la muerte de millones de personas en la galaxia conocida', NULL, 'La incertidumbre y la duda sobre si las convicciones propias son las correctas, o en realidad, eres justo lo que repudias', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ed07d90b-8c3e-456e-9a18-6cf6db619418.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=z0XO2ns4itPEXBIBadAiJF3O%2BhJG3OSyanVSsAhpGL3D6k51AguoSe9geShHckfuFJ0FWJ6cUQkvZihweIOk1KY7I37jpa5l8Rm3zYcjXowp2ITsr75qH1VvWj3cln5R4zsiot5m4MfxaJq7yTgDR%2F056nWJYw%2FvAj6ck1f%2Fa350XLwXCJTDv8SNrqZUlHQ%2FP3LhAxsX08HKGXLC6MuZanuYvd5mmNVDY0I0Oh1abJkKc65ayQI0Ggswh0VkcmXb3r%2F9dfLHNuRjCSMXNvijO59F3r%2Bv2qNK39BW9zOHi%2Bl7FBfTxKJRYAG22hkURCcZlXU0cLWl%2FXUnU3TpJlV%2BNA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-19 15:38:43', '2021-04-19 21:12:08'),
(DEFAULT, NULL, 'azuajender24@gmail.com', 'Angello', 18, '+584244449156', 'WSP', 62, '2021-04-29 07:16:16', '2021-05-06 07:16:16', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'La s├®ptima ley', 'https://www.wattpad.com/story/251641046?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=library&wp_uname=AngelloAzuaj&wp_originator=JYLTTRsyC5LlaoBlYp8lU2MSUPwKMDBqcm5O540ly3E6cMYYoVsq81%2BCPbm%2FN9RMSY6PK0cPoVutJgl%2FNKTq7jTSZb44Uy9k%2FBFSfj5Zzjq9Ni%2BXZE38I%2FCWj5tpg2Ld', NULL, 'Es un mundo con una econom├¡a perfecta, oportunidades iguales de trabajo para todos y calidad de vida magn├¡fica; sin embargo se vive regido por una ley que regula la cantidad de personas que hay en el planeta. Mi libro relata el d├¡a el d├¡a a d├¡a de personas que viven en ese mundo.', NULL, 'Deseo transmitir una diferente perspectiva del valor humano y de la moral. Quiero hacer una cr├¡tica al mundo en el que vivimos y los ideales que lo mueven. Anhelo el transmitir un sentimiento de curiosidad y maravilla al leer mi obra.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/af613397-65a9-47c8-b0ae-567929922255.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=xfYneB2IE9AhD92t0cos0qzxLs7zR0snvrH4xExbXOrK9KgxZouPCaHD4ZgglZFIn5zgIJgvHi3WPJ0LCQ9YHujHlpTuPaoVBrW%2FnNGvZvHRkxZkOLP2%2BiMJzHs5CcFLSUS1pe8pkfe19aHc3y0z0sMWDY4yhYV%2BFlVMTfHfDnSfhUsyym61Zg9mOESVUhPwC%2BrroaZaT3ok50q6ELjb%2F8vF2Vb3kq5pll457vvfK15diJ9mAICpKjDMJXBsoeymtgURF4BwX1UNRQ7b9%2BwVbruD%2BcyGhJQ8SN8TiqW8rtk0uNbDkl9J%2BoKpHJgZMZ6p5HeR23QwSwAfLy7hhhx3lA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 23:00:42', '2021-04-29 08:57:26'),
(DEFAULT, NULL, '73472859@huanuco.coar.edu.pe', 'David Orlando', 15, '917316948', 'WSP', 51, '2021-04-27 23:27:02', '2021-05-04 23:27:02', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'MI CABEZA DICE: NO LO ESCUCHES', 'https://www.wattpad.com/1048658869-mi-cabeza-dice-no-lo-escuches', NULL, 'MI historia trata sobre una persona que tiene esquizofrenia.', NULL, 'Por medio del relato deseo transmitir miedo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6ee2af7a-2a13-46ff-936a-7019f96ddfa8.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=KivkVhAS7OeVAYZcjs0sFQHmA51QdC5tWgDKRD5INRptLbjAL3iJjdcZ8y%2Bq8L%2FuQSz6YwhDbRkpfR3%2FQQbXVIXYVWZKqtY91gn22nw53%2Fe33ttc0EiHCrQNQUpBVVM6XOYMu%2BrXMT%2FNO5uNGRgVfNi%2FCxw%2Fa12Yh4yiFZkIZ9sq4E6rYsQ9TvSUloHAEKEatNEECpnDB4TdWpDKReUsZ9cGX%2FvKkGubWHJMp0tyHo8pWQky49sp91yUnUwF9PBce7zqXLQ3tQf3avGK%2FBU%2Fu7eQyjDxf9qwIFjZj3rF%2FU0puzeJy1LIU9ILNXd4SVbcynhuWt%2B38JS%2BUMIawttH5Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-18 17:13:58', '2021-05-04 10:14:41'),
(DEFAULT, NULL, 'karen.rosas@ceuni.edu.mx', 'Karen Rosas', 23, '7352138041', 'WSP', 52, '2021-04-12 17:02:50', '2021-04-19 17:02:50', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'CAYENDO POR TI', 'https://www.wattpad.com/story/245932461?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KaryRose7&wp_originator=PdjAd4UVZzVuLm7lyOecqQf8fcdzMvhtZod05bBvRjVYjzwKzprTRTjiUo12CDfw7tHf%2FB%2B730EhZGvxGLctnMaqGTXF%2FaU7VspoHd%2F2fSX4F1gpUvy9648VwGel7b2E', NULL, 'Audrey es la oveja negra de su familia adinerada, solo ha tenido un novio que la enga├▒a y lo deja, el destino le tiene preparado conocer al amor de su vida, sin encambio, Leonard necesita una esposa urgente y Audrey desaparece, tres a├▒os despues se vuelven a encontrar, ├®l esta casado y ella prefiere evitarlo, con el tiempo ├®l se divorcia para estar con Audrey, la exesposa y un grupo de enemigos de Leonard se juntan para tratar de separarlos, orillandolos a aliarse con la mafia italiana.', NULL, 'Que se dejen llevar por la pasi├│n', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/719715db-be0d-4136-9e47-160a2bf05d06.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=UD9vwfxOOVTnuyfB1Ht%2FWrJSzwWzS0mHsH6FQI32e44xKi21KPPHfKGQBTXc2GuqfqeNNk%2Bk7yjkNguRZ87nBRjJwozpsa9kR92I%2FmPJzfLwI9utfPAJbwpn3ygRwc5unlxTzAOV5XSEVgGNPC26uGB09uew5O6yTcTJsIoz3y95ucSmnnAZqvw6C2T4mRQFk7roTEsicFV6m0VIrSkuKcnFD8O609RiQ3DbV9U6U2NCmhpfCakCjd%2BYtLoqCjV%2FfKIfMGKPdtyz0KNnmJphlMWjz9LHgAPSRpM69mv7ouv3C1hqqbXxdG0pB1JSc2cNd6ecbSQtXqwZadMx%2FfSwPw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 18:56:05', '2021-04-24 20:33:44'),
(DEFAULT, NULL, 'draketmadeleine@gmail.com', 'Madeleine', 18, '2211522005', 'WSP', 115, '2021-03-08 16:46:09', '2021-03-11 16:46:09', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Una nueva manada', 'https://www.wattpad.com/story/102843397?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Madeleinedraket&wp_originator=2fFm1v%2Bs5hWyvAf6LNEn9HWHl960NNLaQkDVUrdPyRO%2FIf3qW%2BrSS7%2BLtSxZ%2FeVSHW%2B%2FmR9GToVD%2FUZZEgQiscExs0rAA193%2B%2F%2F5M5paAs91IT2emPVR7LqLcSPrcm0i', NULL, 'Trata de Isis que es una fugitiva del rey de los lic├íntropos, c├│mo se encari├▒a con una familia que le da techo y comida y como enfrenta al rey cuando descubren quien es.', NULL, 'Empat├¡a, emoci├│n, adrenalina', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ff0e2a13-0c0a-404e-b5f9-8331a891ceb8.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=x%2FRrjo36E5EgHP2RS8XKnzo%2BLx23HFoG6fw%2FATl1JYXniIT%2Bg58%2F7jsVa%2FM2i9a5XNWiYZovTh%2FqMQNAhNwZZq4B%2BnaU80bSBY4pP%2Frg2yWfd5ly2qnHIq3phTfuysIhp3plzX%2F6LYRdq%2B0vySAuRAW68dKoBQI0zg1vtTGzDALqRQDiQjxx%2BOJNkmRStN4HYoFy4DGOemsdf8b%2FfN2P49UHl6tNTUbkHF0fB6RAmfdPT9bfhNCswbwY%2Be%2FiRAdtSI3PxDLat7fsXwI0axbV9jUIOHrhCbRwRQKS1GxzekYez%2Fx0kZBQbnNDTqOGBl0wUitvnJP0TnZ0jrUP3mZqEg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-06 20:40:56', '2021-03-09 19:07:41'),
(DEFAULT, NULL, 'yeneskytroconi20202720@outlook.com', 'Yenesky Troconiz', 21, '+58 04246660048', 'WSP', 112, '2021-04-14 16:54:40', '2021-04-21 16:54:40', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Las semanas problem├íticas de Cloy', 'https://www.wattpad.com/story/236003172?utm_source=android&utm_medium=link&utm_content=story_infoÔäÿ_page=story_details_buttonÔäÿ_uname=yenestrocÔäÿ_originator=1PKeW3VmRHvLrR1rks5ln1ksG%2Bu9MSZVG3lO1T9FS1VaqsQMl%2B%2B5OvPVMtdWjVgdZKQgsNR9%2FcPFJ88iOoDDt9W%2BTL1KD5bYt6Ub8%2B0jcFnQrNX4PCNDP%2Fd0yTpc%2BDXU', NULL, 'Mi obra trata sobre problemas juveniles realistas.', NULL, 'Frescura, originalidad, hacer mi marca personal y en la historia olvidar un poco la realidad con problemas que puedan sucederle a cualquier persona.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/f49f7eeb-84ab-4cbf-af0b-5605b8d93a45.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=F3vPOTjALiPeJj7HkS9Lc41VLaTIDAazDmAKiFO%2BQUGS%2BoFplDTry%2Fm%2FVyI0EvK%2BRvECjIzLiH92973sYEgfeuHJInL12kSqotxUV56mDvf2ORJXS519KgzDR2drDKqDvbjvDStu%2F%2B%2BNq3ZsrMs4FGfuDFHBD%2BEOmR00GLZVyKHDfHHLE6Ng6PuIyUz818hcJxgY4CMlBhM2n%2BYTv5S4c4WVHytW5tR506qRU40Ssj5hNoWXMbOiN5a2DEUHXApHIfGAKCmu8Rjy1fm0q2XzSOBExbongNlSSZeHsMu2hw1ftM6QI%2B07eDH3BeNAd8jLGkHLPrPNmq8BtARyyB5x6A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 15:16:11', '2021-04-18 14:33:15'),
(DEFAULT, NULL, 'vmathurin529@gmail.com', 'Vanessa', 18, '', 'WSP', 62, '2021-03-14 00:12:14', '2021-03-17 00:12:14', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Dulce amargo', 'https://www.wattpad.com/story/248564501-dulce-amargo', NULL, 'Samantha Brown, se caracteriza por ser una chica que busca un poco de libertad, se toma la vida a la ligera, no tiene muchas personas a su alrededor y las pocas que tiene son insoportables.  No quiere el dinero de sus padres y por esa raz├│n decide vender trabajo a estudiantes como a profesores en la universidad donde asiste, al momento de negarse a dar gratis un trabajo a un chico este decide vengarse haciendo un trato con un allegado a ella poni├®ndole laxante a su bebida y cerrando todos los ba├▒os de las chicas, pero no contaba que Samantha entrar├¡a al de los chicos.  All├¡ se topa con un chico, Alan, este le har├í el mejor sexo de su vida, para ella todo acabar├¡a en ese lugar, pero no contaba que Alan ten├¡a otros planes.', NULL, 'Lo f├ícil que puede ser manipulada una persona utilizando como cebo el cari├▒o y la necesitad de sentirse amados y la dependencia hacia otros', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6e1b1946-5491-43d8-838a-f5f6417c4a28.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=pVhlFJS1pjy59VDCkdhqcxtRt7qy0D4chlhJtfjNad5zCe2h3TVeMpEvjlXRpCTR0WAL1%2Bz30%2FymIBeQdOzEazYvfw0sSVlw7klqz1b%2FP6PMPBk5ZWM3TnnGDgICYvtrStd8sXrRoUH5PCpDAxTqPr%2FYpwGtKqdOvh4D%2Fmr6XirPFIP1lhc3MIZj%2FI8uMIDRKEY3aIyzQbRGvKCBdEBMAjKiQfAS3eJNLte27gHmubo6NzhSzFcbjU72j2Vua8j9xZ9BzP1D21ORW5kiTXgeh8awCSwSRimiC6XO3%2BMA8Gj0WKz%2FphASsJ92qw%2BHgrWAJ%2B3S7YtOLsDR0l6dJRWdzw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 22:05:09', '2021-03-17 23:09:38'),
(DEFAULT, NULL, 'alex.6.bv@gmail.com', 'Alex van Buuren', 29, '+52 6142220996', 'WSP', 115, '2021-03-05 13:59:24', '2021-03-08 13:59:24', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Aufheben o el recordis de Helena', 'https://my.w.tt/g9GpWKirLcb', NULL, 'Es una historia de romance/drama sobre dos chicas que se conocen y entre ellas surge cierta atracci├│n. Pero pertenecen a bandos distintos y una de ellas no es quien dice ser.', NULL, 'Deseo llevar al lector de la mano de las protagonistas a trav├®s de la intriga que existe en la trama.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2061f2df-69ee-468e-88ba-991f17c5a599.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=iCGoKq4NGMChj6afWqE4Rcoeq3lrXBY0wmSo0A%2BQNd22Yivue%2BV4Bf9xdm13zDstX6naCoiB%2BThb0S7mEcHfdDQDI5Cte3pGJd7tNjqaahF39H%2BA9j0a6XS8auBdF32gXpmWg7qPp3fPmKVEUzrHMaJWyYm%2BwVYBhBDdZyuEhiQ7abbK0RrTiktd4s2G%2F4kceXpbSkG%2FmsnYCbTlXQYSPk%2FhFRjFWIYPoM7eibthSxO4J4b5V%2FNKof1f0FaatdDmHmbKNpzT192qtqOY8QgT9N2ajgYJceEdylAKRkUa7LQRGLmGG8z6leFMlZ8WL8qIXQsUDyYD9fXfnw1FNZttkQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-01 18:26:09', '2021-03-05 21:06:42'),
(DEFAULT, NULL, 'monicagranada30@gmail.com', 'Alejandra', 20, '+57 3225912110', 'WSP', 60, '2021-09-11 10:42:13', '2021-09-18 10:42:13', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'Candy cat', 'https://www.wattpad.com/story/234349900?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=moniklejandraherrera&wp_originator=KTnUcPMSw%2FgZxsYrCd8fVTzKpsto3W20o%2BhjtKVVaRd8UXuw63NTqmQPNHFiuW%2F9bPascS7mK%2BMSpaRc18atoiK6Lb6SIYQCEWJiOV%2FX2hJCuIyl%2F2KhadHBBSVXv43U', NULL, 'De un chico con mala personalidad que es convertido en gato por rechazar a la hija de una bruja y la ├║nica manera de quitarse la maldici├│n, es encontrar a su esposa de las vidas pasadas.', NULL, 'Que todos sepas que somos iguales y que tratar mal a alguien trae consecuencias.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-09-09 18:43:24', '2021-09-11 10:42:13'),
(DEFAULT, NULL, 'danahehdz.cruz@gmail.com', 'Danah├®', 19, '55 272 206 2067', 'WSP', 55, '2021-09-26 16:44:59', '2021-10-03 16:44:59', NULL, 1, 'DISENO', 'POR', 'TOMADO', NULL, NULL, 'Amor a la distancia', 'https://www.wattpad.com/story/285248448-mis-6-meses', 'DanaHdzCruz', NULL, NULL, 'Quiero una carta sobre un mundo y que en la carta este escrito el titulo del libro "Mis 6 meses"', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F89600ea4-60fc-4041-9b86-149dbd5b00e5?alt=media&token=4547cb4d-b3c9-4477-957d-80093d0e378a","createdAt":"2021-09-15 12:26:23"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-09-15 12:26:23', '2021-09-26 16:44:59'),
(DEFAULT, NULL, 'hermosodiaeninvierno@gmail.com', 'Kiya Illari', 18, '+51 920 139 045', 'WSP', 60, '2021-08-17 10:19:29', '2021-08-24 10:19:29', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'M├ígica esperanza', 'https://www.wattpad.com/story/268172528-m', NULL, 'Mi obra trata sobre una chica que le gusta la magia (trucos de mago), pero que por circunstancias de la vida es una empresaria millonaria infeliz. Pero se cruzar├í alguien que cambiar├í su vida para siempre.', NULL, 'Mi intenci├│n es mostrar una historia donde te muestre que la vida es disfrutar cada momento que tengas, pero al lado de las personas que amas y no con cosas materiales.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-08-01 19:35:44', '2021-08-17 10:19:30'),
(DEFAULT, NULL, 'leoes1999@gmail.com', 'Leonardo Josu├® Espinal', 21, '+504 98373547', 'WSP', 62, '2021-03-10 12:17:56', '2021-03-13 12:17:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'P├║trido', 'https://esperantadigital.com/putrido/', NULL, 'P├║trido es un relato profundamente entrelazado que prospera en los sutiles y elaborados detalles repartidos a lo largo de su intrigante narraci├│n. El lector constantemente se encontrar├í con ansias de descubrir el misterioso e intimidante origen del p├║trido hedor que aterroriza al personaje principal en una angustiosa noche de verano en la cual nada es lo que parece.', NULL, 'Principalmente deseo transmitir intriga y tensi├│n con matices de terror al narrar todo lo que le sucede al personaje principal hasta la ├║ltima oraci├│n del cuento en la que se revela la verdadera naturaleza de todos los acontecimientos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/27810d5d-29c7-420f-87c4-959aa528138c.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=YC%2BRsBw7dwZhJRg3xF2dgC8%2BmF9FRGXo6FEDkfLvjrFOP7y6IGzFOWJI39l8G90TMbh2qA0fS13IUUmgAnaEeQjL8UV6Adt5rnu2g%2FN9Vx%2Btc4U4laraJF38bfeN9QHM1cko1OUG1pzY5Od1O3xTQmZlCWbfDyyyrilHVbi8Kna20yyKyNvLBWXYd%2BGXh8GxSTErjOP9D4nL65uer9ofiNL5MDmeCxL5B8KabPJUpmh8NvVwsxmh6ODD6KtFWgcK3NqVWx3TRbD8yTe8t6gODUvprNDlHtesJjlscIg1ELULVOJM9OYvFihoRxv%2FybnB%2BvgfCyZ%2Bc83OwieskS%2FY9A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-03 14:03:53', '2021-03-10 13:06:37'),
(DEFAULT, NULL, 'isabellapanqueca28@gmail.com', 'Isabela Alvarez', 17, '+584148807500', 'WSP', 50, '2021-03-01 21:03:17', '2021-03-04 21:03:17', NULL, 1, 'DISENO', 'BAN', 'HECHO', NULL, NULL, '┬┐Por qu├®?', 'https://www.wattpad.com/story/241481364?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Isa_Alv&wp_originator=cuUAEGYnpnuT0Q1Nj2fJKal8E1%2BgsI5h5HDMoA9QRyRxNd6xMCLNdGYmbSyHs%2BozS7oQaIzkjfVlsj0Aw0rFZyvgdbm%2FUdgktJIQvpzssH9cPu45v6oMViPqJ5PFn3WZ', 'Isa_alv', NULL, NULL, 'Quisiera que se sobre entendiera el punto clave de la historia, que es la necesidad de las personas por arruinar todo, por destruirlo. Por hacer de algo hermosos, algo horrible', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fefe6aaa0-a616-4983-b317-a0b52c4b6788?alt=media&token=4140234c-5016-4dee-838d-5e1503addbd3', 0, 0, 0, 0, 1, '2.2', '2021-03-01 13:36:35', '2021-03-04 21:24:05'),
(DEFAULT, NULL, 'angelbalague897@gmail.com', 'Angel Balague', 18, '+56988802744', 'WSP', 62, '2021-06-26 22:43:26', '2021-07-03 22:43:26', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El esclavo y la bestia', 'https://www.wattpad.com/story/266613967-el-esclavo-y-la-bestia-gay', NULL, 'Es una adaptaci├│n gay del cuento de la bella y la bestia', NULL, 'Intenta ser una expresi├│n de las emociones del autor y explayar lo que es estar en un romance juzgado por la sociedad', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1788c3a2-ad60-43e1-ade8-f91b86c9f449.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=cG898JPHD3AT9BIqMQwZWG0dkVCGqb9s4AxGY%2F1eyhusxBMFUkKNN6vzsKgxQG0nNXoxiwaudwjVHFfvZZmFeSDOhwLA%2BGtdndZs44HToNUHgA6SzDcIke3LXKxKY8KqUw5Zx0inB1%2BryJNfRmFjL2XjvaHA4XP3RHaHEagxCfUYFsmGbwwpF9d0vDZfsWx05YOjsj5HCIUqVZ%2BgcJA8ycyWKzbF2miNBafJ9RwhEvsAjsIKDcSWLwgmBDkG5GSfYbVUHnhpWDiqy%2BcR24L1f1l8BbdrBPAGXlSFQJfWT26ObQptWEkMVLt8mRwpFtOptMChnUgLyj62TUM92TryYw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-05 01:05:49', '2021-06-27 01:27:01'),
(DEFAULT, NULL, 'ooviedo12@gmail.com', 'Orlando Seoanes', 18, '+57 3106326313', 'WSP', 56, '2021-03-04 15:34:56', '2021-03-07 15:34:56', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El diario del poeta', 'https://www.wattpad.com/975915286-el-diario-del-poeta-noche-1', NULL, 'mi obra trata de un poeta que se despierta por las noches con unas ganas intensas de escribir sabiendo que eso es lo mata', NULL, 'deseo transmitir pena por el  personaje', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/ec77f23d-8ca4-4e4c-a42d-9034e53caee6.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=V7rv0pknmzy07fQDqhIKzVqADIaOOvZoUJRNXHOWRn4AyZlWOygyHxcDYM1jhy3oyOwGN8miSoe7C8rqq%2BVwhjsGEU0X1BAO7UAaAPi0YgtTyVaM1cpvMVDsPpyWsCVdoWtnHRqXDs2EjHwoualUq3gDCmKHkENz9Jd1RCKu6S1r1qQ2STbazCnoBPGlID5OAcjlsDIVkAu4WDw8snCbchK9r5H2qrHvYpJNsAqoiV5wA%2BwGBWOpRGxdql20dlV%2B9%2BbHD7ZfUB1HzHFwIPK5j9nDVD73aawXpV1e1h22Dl%2FrKUQuwMPMiSrGUJhvgUyprKXpzypOGl7vVnfylpYLjg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 10:02:42', '2021-03-05 13:53:09'),
(DEFAULT, NULL, 'feelingss.023@gmail.com', 'Piccola', 19, '+52 272 158 8788', 'WSP', 62, '2021-05-06 17:00:20', '2021-05-13 17:00:20', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Aventuras con la luna', 'https://www.wattpad.com/story/247978018-aventuras-con-la-luna', NULL, 'Quiero realizar diversos cuentos relacionados con la luna, no obstante en cada uno quiero dejar un mensaje, que me hubiera gustado recibir en ciertas circunstancias.', NULL, 'Intento transmitir que no importa que tan grande o peque├▒o seas, que si realmente te propones en hacerlo bien, podr├ís lograrlo, adem├ís me gustaria tu opinion en ella.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5c8cabef-7dbe-483c-9ed4-a0f2978594d8.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=D99%2BHA%2BivbaFuu6JhfbF7BkJ%2F7F35dcEDRH%2B%2Bg1BNE1ejSe08fPDc4Ry7kAq4miBbpHI4dh6Iwvs7pGg68zdVy%2FdcAh1VtNkLzU%2FOxXX3VBtewOmUwmTTw1s3tP2i0RbQNufElYddADTUCGCshLbdXO9rVzQVPF6k%2FAy%2BovG2gBBQUfev4RbZ4ezh2PFWBodc9W4fNT%2BhzEnqHpVoRhMrlDNi9YHpN%2B5SozAM7bymabwgT1JMV3eE6fOi%2FixXsD4Vr7YFD6%2FRhNVG%2F0yF19eZpT6RlQ%2FAkMwKMX4Ilir4Z537X9HGh8Lto4CfZsi7wd6RtnnqKlxlQE%2FptdVFKcBWg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-05 22:37:32', '2021-05-06 22:00:55'),
(DEFAULT, NULL, 'poetapobre2020@gmail.com', 'Francisco Miranda', 25, '+56982158081', 'WSP', 115, '2021-03-01 16:46:19', '2021-03-04 16:46:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Creo que te quiero', 'https://www.wattpad.com/story/35107651?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Poetapobre79&wp_originator=%2BG1BJG8%2BBHnl0jPtv%2FNM2T9zWqmeDQteEykZglC8gh%2B%2FGmQzUI0yr0Uu3kje53drtBqniovot8CJwOmg%2FFdyMaJOOhmlsJcrYP00oity3tvyKNJj6eqfj2EHuf9HdtK3', NULL, 'Es de un adolescente que al llegar a los 14 conoce el amor y tambi├®n aprende el valor de la familia y la amistad m├ís que nada es una retrospectiva de lo que es la adolescencia la b├║squeda del amor y la aceptaci├│n.', NULL, 'Un poco hacer una reflexi├│n de lo que es la vida de valorar lo que tenemos y lo aprendemos de nuestras experiencias de vida.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/dd3d29c2-250f-462a-9f26-5619de42d4a9.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=DMhtWYNIOXM0C0c6rGC%2BMnNul%2BxnC21nKusphjdTI0zCYq%2BGzjv%2FjkiB1Zs96aHP%2FhgZUf8NcNS%2FkEEIz%2BPiq8PcgTol5TIhPcCq8009Hv7SCOoFKTS4HhmuQd%2F1vtxf1iwzuNtqmHqcKK2oaCtbpjf69uBhy3RaomNMYVzy27JtXF%2BVF3GrQSh%2BDAbUc3VNZyCBXz29PYnKMJ7052fixRHeZuWAS3nR1fMr7fblMiHSkJLcnBDVQNXEZxEnZXaEa%2FwlLhWCVMcviCIgj4dRQMrwaWmYYIdk%2FjMSNeaFAFPLj25ezy9WgANDPsdAaAfpR%2F%2FgbIjeuSwleqUsAQov2w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 20:25:25', '2021-03-01 20:21:07'),
(DEFAULT, NULL, 'amcd0825@gmail.com', 'Ayra', 30, '8607198933', 'TLG', 63, '2021-05-25 13:26:19', '2021-06-01 13:26:19', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Nosotros', 'https://www.wattpad.com/story/218597442?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Cayra1&wp_originator=2hbG2KfjJSeuo5VWBTOxMGbNDi%2FD%2BtlXh54B3vumg0cz5dyMekmCie%2Bkw%2FWEJDgfBMYJNknHcZpPHoBoKIrknnefX3RTnpd0X6nNrzsnHQq1G%2B72kVF2JdgLhekMlbcM', NULL, 'Mafia, Romance.', NULL, 'Ficcion. Es para difriturar de leer un libro.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0947d044-eb4a-47b1-b79c-b54e59987e4e.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=zfGSWvJ8nv7rI%2BLW6mtVhHKeldOa23VhqDQShL4C%2FmmP%2BCkhbgXlKZzhqhxSNEV3YD85IpLa7qV8kEEMeZxcInpVEWeQDCVuNThia6dSpAtWeIDJ5z4dLFtGrjvcDcF6twF%2FA0oW5Jr8kCyh1669HTi0iSQ1l4qi8XXXtsI7ziqrMQg8UL1dt%2BGGItZQtER1TqVvMLYBrw6A0SsYyWErwVMsq0l8x%2BPe8%2BHeIfbkHVJTNWkNUe6n6P9TOUV3BUTP9UyBDkEO4I033n3q%2Bm%2BTaa%2BfRGaGIMj%2F%2F%2B3bn7Y5l7HJ3EGOX6Y2u3BZzxHA522HUOF4ML1n2Lz7SsooQhELag%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 18:44:46', '2021-06-11 14:21:05'),
(DEFAULT, NULL, 'keg.sanford@gmail.com', 'Grace Sanford', 28, '5527531960', 'WSP', 62, '2021-04-09 12:17:36', '2021-04-16 12:17:36', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Escritos de un coraz├│n terco', 'https://www.wattpad.com/myworks/75118943-escritos-de-un-corazn-terco', NULL, 'Escritos de amor y desamor', NULL, 'muchos se identifican al estar sinti├®ndose igual, depende del texto en cuesti├│n', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a68fc3c6-9193-45fc-aa40-4234016a644d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=N3zzLLDANxJuf6Kv9RCzSvE8krqR0%2BUr6l8O%2B0SGhaocN4Kr1kKqTg5Z%2FcucenPqQgMT3yIH2mTyWh3%2FfnbVr0YP7P1GoN2%2BavY2Ro9BtdV6eobleAII%2F7j7L%2F6mx3U5TEubx7l9953ICS1dK3hEcQc%2Br%2Bwjs5k47nAbzL1Fr7wW0tUIMLIfRzKSMyM9TWZBRWbwgyt0Fk%2Fy4Zidfk6P%2BHCHZEzXuy49fMcUJ7TLx7XisLsPctNpo2AU1WpeVG1KflIQzalBjpZAaMaxV8acC2J%2BIFhTsf%2FICkz8pxFFoSLgy0jsiUViODUlS1G2R31oVV7uSf8o73hw%2BEbaMlknFw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 23:50:43', '2021-04-09 19:46:15'),
(DEFAULT, NULL, 'vmuguerzagd@gmail.com', 'Valentina Muguerza', 25, '+1 2818832881', 'WSP', 105, '2021-02-27 17:28:36', '2021-03-02 17:28:36', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Soul Leaf', 'https://my.w.tt/3vqv7o5A10', NULL, 'Trade Dogan un solitario mago capaz de utilizar una de las siete magias naturales del mundo, vaga sin rumbo, con la esperanza de cumplir cierta promesa hecha hace mucho tiempo. Su viaje lo llevar├í a conocer un gremio de magos con los que, despu├®s de ciertos acontecimientos, ser├í forzado a convivir con ellos.', NULL, 'Deseo transmitir el sentimiento de amor propio, aceptaci├│n por el pasado y la idea de que sin importar las circunstancias de nuestro nacimiento uno puede elegir hacerlo diferente', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a7266ad0-24c1-45e2-9ecf-f8e7505d037a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=bvnKKHZfUMQ%2FFxyLX3X9%2FXQ0UtUWOPh19x63dtAEnWe3HWZ4jIQrue%2Fbxf7oYhpGRttcK%2FnTtK9dAqYRg6HHXy%2Ffe2%2BbwJEl8yZeI9TJ1Q2KVY9ReiXpDxYlbVKewicH30fhFxvAC0re4YQ8KmVdbYhVnLRvwmeyrGNzkOBQtPFxfPxH7vBZjZRKJ3AIobiLIHHpPdZRIt8huOQ%2FjZs9WKw5WJKCWfW7ocAObWIv45hBj8o3kgTRJjZtGJaZaLeqSCfRYo6dvj25aZX8FkWor5zYyKYmHP2ESEAArHLnWgjiFJOamSLbfkBZvf42uMseqM0PvZmMcaYkd66bHjs7ow%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 04:28:25', '2021-02-28 13:32:30'),
(DEFAULT, NULL, 'meyurrechez@gmail.com', 'Meydi Urrea', 19, '', 'WSP', 51, '2021-05-26 11:40:59', '2021-06-02 11:40:59', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Secretos Oscuros en Isolated Town', 'https://www.wattpad.com/story/240790589?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Mey_Urrechez&wp_originator=kkLJ28au%2FjAoJX9Mp2fdug7LP8ucxQp3fKOefPEJ%2FtegVxnK3KddZFB1oYN5LYVvmrbo19F%2BwLG2%2F56mo4PU0c91LuoEwkUczsFXbKYP0UH2JGZsZP5v%2B3EbD9PkLjBJ', NULL, 'Mi historia trata sobre la vida de Maeve dentro de una religi├│n cat├│lica llena de misterio', NULL, 'Quiero transmitir que no todo es como se cree, que aprendas a no confiar en nadie y que todo ser superior oculta algo tenebroso, que aquella persona que no se revele como tal es la m├ís macabra que existe.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0ad1d7bd-a246-4c6b-8794-3f8107d5e68c.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=wBga7kPAFCq33gM2C8%2Bp9qu6pxuaiLG50ez5KKA%2B8jplZF5BlPIUSK251VcnPjiYtzeOr22%2B96pzv3uRKBD%2FfWJiYUiFKnkVQuz%2Fi6J%2Fox5QRKfBqbDTkVozhvD2Mr%2BqhIOjG0%2BE5TMe9y5EgWX8iOjpBf240xnhEG%2FBimYT4gJwyZ4cYxTX9AOeKJCb2azoq3VuDrtjSUK%2Flh66dHqumXAJjzaJKyMLQ9X7y7%2FpttSCsE7FbQPOASOhnZQpBdK03MaRxGtpQLa2Rje%2FjA2I%2Br838znODyOlxP3M1dsBbkcEcABwB2RSOVoB%2BxtCSQ3%2B22xISurKa2XdmkGNsvAe5Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 17:59:51', '2021-06-14 15:31:58'),
(DEFAULT, NULL, 'mauro.19931113@gmail.com', 'Mauro Herrera', 27, '+541124635303', 'WSP', 116, '2021-05-28 13:52:10', '2021-06-04 13:52:10', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Ebrios Can├¡baleZ-El principio del fin', 'https://www.wattpad.com/story/125993844?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=MauroFabian11&wp_originator=KNlUO03UZd2yyVaqonO9Uv3RhXXObpKNL4oSn3SJvgCOwKInhR%2BVvF6ykSrNd9n7Tw3KlOzdlOVhDKr2LOtYph69058Vare1s0jHoyCoxHKgFNFhzBsWYHocdEVeYmCo', NULL, 'Trata sobre el apocalipsis zombie y un hombre que no teme defender a su familia de lo que sea', NULL, 'Deseo transmitir pasi├│n, tambi├®n sorpresa y que la gente se desaparezca de su vida por un momento', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1c53ba18-f461-4961-ad49-f7f51a76a379.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=PdJTVxbLtEcjExWZKkUdUXIAyamuM54tozNMvEfv607ZM9ioPZamRBPafP7A0PMNyLTvZ4eyw2iFg%2BTXdtKxj%2FlI7QpzjOunnThNRCWqn9TU3aZJPzn%2F4UKCraUXPsOxPVku%2F26qrutnKokCw37iPxyEjJ9xAwYa6zlrZJmCyPuOLAFER7rBMLxTCXZUIvxlOc5pTOctiYuNPz76CIzaMbFdnurCxz7LZyXkQqtt6WudpydFSQTrfpRzgvmnBc28Yvv4NwboA%2BMb05fBcH2a3keYJPSgTwAtCbY%2Bk%2FLdkpi4c%2FE5whuuTc%2BuSsxNvIxVu8MDI8wkmY%2BfPZEhuayvxg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-02 12:27:34', '2021-06-01 12:15:36'),
(DEFAULT, NULL, 'fannyamador26@gmail.com', 'Estefani Amador Curiel', 19, '+52 3222531321', 'WSP', 102, '2021-04-03 18:35:08', '2021-04-10 18:35:08', NULL, 1, 'DISENO', 'BAN', 'HECHO', NULL, NULL, '┬┐Alguien me amar├í?', 'https://www.wattpad.com/story/255519391?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Leycar_Beltran&wp_originator=QKcN2GvQClVd0p58bQUmeNXEy1d7trFOghtVfC4%2Bx3oQrVfWTo7%2B1k9m%2FBqfNJHrWUhA4%2FXinPW7NGl1wdRsWa7L6mmzi%2FhfqSUiD47aXq2xXgLkHh0ujoxlHurQNueP', 'Leycar C. Beltr├ín', NULL, NULL, 'Quiero transmitir un poco de lo que se siente tener depresi├│n e intentos de suicidio sin que nadie haya podido ayudarte', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F1f41ce29-0f93-450f-ad9a-04965787126a?alt=media&token=3869fca2-e406-4571-95b0-5f323f7c5c58', 0, 0, 0, 0, 1, '2.2', '2021-04-02 14:13:35', '2021-04-10 00:54:37'),
(DEFAULT, NULL, 'lucelyssoyyo@gmail.com', 'Lucelys', 24, '+573137081263', 'WSP', 106, '2021-06-01 20:27:04', '2021-06-08 20:27:04', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'El coraz├│n nunca se equivoca', 'https://www.wattpad.com/story/212483096?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=MLBradley&wp_originator=NcVm9NdvbAA1Bxf6J7EDJBcPVG%2F0deaL7U6e5AGFZH5ROpILWWimpa2Lgj5oYivXgTjEgtnxlHIQKXVbiu7LmyH8kivXbcwwjuAZJsGocIBmHk3tkW5Exv7YgJBbnEuf', 'ML Bradley', NULL, NULL, 'Quiero que se vea el cambio de vida de una chica, en especial el cambio de familia y estrato social y que adem├ís refleje sentimientos encontrados', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F2b3d9354-3ac1-45f0-958b-05a2e8bbd0c0?alt=media&token=ed189e18-e240-484c-b893-53c55b5cd0b0', 0, 0, 0, 0, 1, '2.2', '2021-05-31 17:29:30', '2021-06-07 20:36:08'),
(DEFAULT, NULL, 'monicagranada30@gmail.com', 'Alejandra', 20, '+57 3225912110', 'WSP', 66, '2021-09-05 22:29:53', '2021-09-12 22:29:53', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'No tengo ninguna frase jeje', 'https://www.wattpad.com/story/277062266?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=moniklejandraherrera&wp_originator=SoTqiw19kJeor8czmPil2nzfgE4hLDD2%2F8oKnUgAcKN5d2izTxBy6jOL8m6byyfWHaOBPS6UO%2FStUimrbnK0sGqg8qqnAa4aq1gDjGxRMB5r%2FiyegAD7oJsjI%2BUNi70h', 'Moniklejandraherrera', NULL, NULL, 'Quiero que aparezcan dos silueta  (Hombre y mujer) que se est├®n dando la espalda, que en el interior de las siluetas sea como galaxias, estrellas etc.  Qu├® el fondo sea totalmente blanco, que solo sean esas dos siluetas y el t├¡tulo que sea colorido.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F0d7f26e2-2931-4ddb-8fb2-bf687bbc4f84?alt=media&token=35cc12ab-205d-49cc-92b1-f1fe178a7808', 0, 0, 0, 0, 1, '2.2', '2021-07-11 21:21:33', '2021-09-07 19:13:21'),
(DEFAULT, NULL, 'rominaroca377@gmail.com', 'Romina Rojas C├íceres', 18, '987476340', 'WSP', 50, '2021-07-13 21:43:38', '2021-07-20 21:43:38', NULL, 1, 'CRITICA', NULL, 'TOMADO', NULL, NULL, 'Una boda por un contrato', 'https://www.wattpad.com/story/231034287?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=zarai37&wp_originator=KjMk%2F%2B3oeh8XFMSiJC%2FmtWsTU4seIWXMc2zpgUbE2UCJiY2EmBhIy5VPcHM9KYPUrpNjjYTqvxS99jzu4e%2FknCWsPb9kKAOP2KBEi9%2FbuNbHv8gtFPptvPMtqOea8ccO', NULL, 'Trata sobre una chica que necesita dinero para la operaci├│n de su madre, y de un chico que necesita una esposa para la herencia de su abuelo este en sus manos. Una trabajo los har├í encontrarse, y un necesidad firmar un contarto por un boda.', NULL, 'Deseo transmitir el hecho de que las personas deben seguir con sus vidas a s├¡ hayan perdido un poco de ellas. Y de que a veces por las grietas se pueden colar luz que nos llena por completo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-07-12 14:35:25', '2021-07-13 21:43:38'),
(DEFAULT, NULL, 'Lauraospina1d@gmail.com', 'Laura Ospina', 23, '+573155269685', 'WSP', 60, '2021-05-10 10:50:47', '2021-05-17 10:50:47', NULL, 1, 'CORRECCION', NULL, 'HECHO', NULL, NULL, 'Quince d├¡as a tu lado', 'https://www.wattpad.com/story/45469565?utm_source=ios&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=DetrasdeBrithany&wp_originator=imOapP3bQ%2FGpxPJLWP%2BbX5sF6DoxWY52YplnbxkAEgz7b6rz5NfrC1V9vYj6T7rpX%2B3WxNDt1XLlawbf%2BSvrfGnxVaL5FT69Hb7JaUIceIArzCseDkIlj0awMJd9Zufm', NULL, 'Se trata de una chica que narra como pasa quince d├¡as en una cl├¡nica mental.', NULL, NULL, '', NULL, 0, NULL, NULL, NULL, 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-correccion/6e8544ca-0c97-4c31-acbc-4b6092cafaf7.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=2zfvZFbSU3eMfs7UgTYGIsLLVBFvC%2F2U90nTesIbzd3maMVFBO8%2BrijNJJsdiZiw%2BBYaoawIU7gEO%2BZ3OZmS%2F9rasH0ECJqVmxdSV0l4oD3DxeSloKZlw0UilZSK2po9Uo157JJBTLNZPWezekhrat3%2Bs4PGK9mMK4dhfL%2BTC55gk3lLYPYsDhAySg7V6m5RS3HFXat55nN4qMVSLKBtjvHercV%2B5FzYS4zUJh1rNGYoM0wCZNMsPnr2YpLKV8cCJ1nRMvysbkJfZwtNcD%2BsE%2F86aePaKCXJ1HaRnuFRGsDj48dWZaZvYzcD4LSg9gP%2BgW4cuxBXH3E2rIgRPpbVhQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 19:01:19', '2021-05-12 12:32:02'),
(DEFAULT, NULL, 'sanchezmelisa065@gmail.com', 'Melisa Luciana S├ínchez', 23, '+54387155878367', 'WSP', 58, '2021-06-16 15:26:35', '2021-06-23 15:26:35', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Close to heart', 'https://www.wattpad.com/story/213065043?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=JoneySenz&wp_originator=1xot3Ig1qM1h%2FjjtYhO%2BEzzfIVGkXgimevhPJPf5bKXf0z4NKn%2Fs4AtAGPYM57i4mHM8a0WUKaep9re5kRmGuEoBwsuxYpVNQQAPrcmrQwO1i2AZqSgm%2F3k51ejHoMz%2B', NULL, 'Mi obra trata de un chico que ha sufrido maltrato psicol├│gico y ahora busca vivir mejor ya que logr├│ salir de ese problema', NULL, 'Deseo que el lector simplemente logre meterse tanto en los problemas de un personaje, que se olvide de los propios.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/c8ad3959-3e3e-4543-be97-fff69202fdf1.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=dcbiLISD6Bm7f1jvyFzZin1PIKntL%2FZj37lo6czPRCxyTzW0kWY%2Bo7pkcbWu1rybfrUjNLSJWgROkYmNLP3nZ8y2KZPl1etT0NYeO23N5K9X6kCLUhoMykrMm5b1f%2FdG7gPAMRjwkepNmeb5qkb8jVsjACP0rcqNoMNXpzDzbPENmGv4SHoC1BS4PkmmEu50YghEgFiTO3n991qJ9dIotpQA9Mo05IYN4wQHp6YOGGWFq3SkqDRPn54KL9WAPGPkmlF2GL6dgqPL9svPmTIvMg4pFNRMR6r6Q%2FN02aduJf5j9Aq%2BCEGl5SQ7AmnJlU%2FaFtPKf3484dAV71DXtAgTUQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-30 20:37:04', '2021-06-22 14:48:04'),
(DEFAULT, NULL, 'Lauraospina1d@gmail.com', 'Laura Ospina', 23, '+573155269685', 'WSP', 58, '2021-06-16 15:25:57', '2021-06-23 15:25:57', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Eclipse', 'https://www.wattpad.com/story/192314076?utm_source=ios&utm_medium=link&utm_content=story_info&wp_page=story_details&wp_uname=DetrasdeBrithany&wp_originator=zOnAjYoIz4Z5BM7D55ZROiP4Ry%2FcRhpS9R2yPF9lb2gC2S4xrPZczysxq4y1vghZCr4Y2CX81iHtyR0dDA1p%2BKo77LrM6XEeIW0CIAYDEPQtyoJTp1N4P1D3QoVLwbT1', NULL, 'Segunda parte de Mermaid, se trata de un pr├¡ncipe qu├® se enamora de un forastero y aunque hay posibilidad de que el ajeno muera por su culpa decide enamorarlo. Tambi├®n narra la continuaci├│n del libro anterior', NULL, 'Demostrar que cuando encuentras tu alma gemela, es muy probable que vuelvas a reencontrarte con ella en tu pr├│xima vida, ense├▒a sobre los sacrificios, el amor incondicional, etc.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/be40d42a-3c75-4bcf-82fd-181713de5cbb.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=nR3Oy3V0CO1jUhNgRwbvYWMQsjKvdcNbZEfCyHuIlBz%2Fyo%2BXH%2BDZcQyNBX8AEInnRH0LZDcoqT7hAnrKbPT9sDxDtOuqpvTUt7Pqm%2B7U4yqjTKEH6wdOn322kXKc6Cdb2VpG3w0mstv%2BJOmJOUVghKVupJyy7uE5Bya3x%2Bhhwo0GYZ4BEGAe7Vhd4ygewF2txsmK8y7wvfb%2F%2FildNexbQL5IGUHPqcKEYJwQjw6bAuaXhwl1cQypO4E3BGSIxYXRhcJrbc6Ie8ogt5zGICFzpXsdNydPehdmfrKW%2F82n%2BQiqNxZ%2B0meqocGZP5G1z6dEPbnAw5rzyXOjmNxhWfeCPg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-12 12:44:06', '2021-06-22 14:59:20'),
(DEFAULT, NULL, 'moralesjasmin179@gmail.com', 'Jasm├¡n Morales', 21, '+56977467527', 'WSP', 60, '2021-05-10 14:56:38', '2021-05-17 14:56:38', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Una noche estrellada', 'https://www.wattpad.com/story/266007334-una-noche-estrellada-%C2%A9', NULL, 'Trata sobre un chico enamorado con una enfermedad y una chica herida por sucesos anteriores de su vida que adora las estrellas. ├ël la ama a ella en secreto, pero ella nunca se daba cuenta. Finalmente, ambos comienzan a interactuar para poder llegar a un momento en que comienzan a superar sus miedos y heridas.', NULL, 'Consciencia sobre las enfermedades, sobre los errores, sobre lo complicado que puede ser el amor de vez en cuando y sobre las superaciones.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5894fd7b-6114-43d1-8f48-5675c14df89d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=BLIvwf1andml9pCsnWdvv4KXQNy0FfDZYtR7fSvSeHGB8wFMhF8kfvsv2Y0PKs3JhS8Rn%2Bx2kYswdg4LahMYYVyDEjuc6nG8F%2Bv85Bqtv4TdMy4Co1DR4kMLeSamsLyV9CZmH0GjU5qYzB%2B84tvYAqPj9Teh7eNtUbCt1UVXUP9GOTiMWwm0D%2FGyj7chQFDS1tke01Qs64FIa8xnH1wPNbh6feItKKWYtKOOG8GvTrF89oEaio0RKPoIJacEifE1MwrhRqwoU8NlZtROb8oWH1OdolQ6DWZ%2Fz5kLIggn0hZM5eAQymx2a61MKm6%2BnLgAC2NwnHSijRnC2eQd%2FyWiSQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 00:16:59', '2021-05-16 13:37:22'),
(DEFAULT, NULL, 'reds.words@outlook.es', 'Reds Letters', 21, '+504 9936 1230', 'WSP', 120, '2021-03-18 00:47:31', '2021-03-21 00:47:31', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Escritos En Soledad', 'https://www.wattpad.com/story/254542358?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Reds_letters&wp_originator=NqMK7bUcJHkSLSjd%2BFH7t0kHHmiZeiHJU6GrmZX5DLOkn6OLGVqjxdNY7Pt%2BWs3c4xafcBwhIVx9PMx8nu7r8CASrib6vYYA4LsbfFr6DxIluT5nV9TJ5%2FjjAJluT7RW', NULL, 'Mi obra trata de un chico en depresi├│n el cual, para desahogarse, realiza escritos de manera cr├¡tica tratando de liberar su dolor. No es una historia como tal, sino un intento desesperado de ser comprendido.', NULL, 'Los sentimientos del chico; esos sentimientos que no se pueden expresar, pero tal vez si entender', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/b35f471c-25e0-49f1-91dd-669a25a40f3a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=KxA4%2B8Z5fBt%2BSETX1AzmeO4J6DXZrKrl2o7xeNrhn3MhxZ%2F%2BdJIHJBXO4CfmyGDloM3bxbI1%2BzPYsVv0EaNmJQ4t%2FYXX8jK1%2FSTPlzaEdbAbhh4mLL5yc22Bjsc2aBoTeQEhKW5pZcS3GsT9gKt0XFG5%2BN8wD8sKACeYwA60FVqmbHGPiM9PlSRZ64oH6FuLJMe%2BuvEiW9mqCioBxrJPK88uYzSXvskS1atWMnanunHviq3dc52WaJLYEf4AQ8XGzgE8d7OBnqZZkh995GXUfaHPsSWSR2jRzkvcVUY36HBOQTL9ev7jslNm1uSXJvKy6LlxYm3FtmKCawF6ABnHvQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-17 17:58:48', '2021-03-18 12:11:36'),
(DEFAULT, NULL, 'marifervill22@gmail.com', 'Marifer Villegas', 20, '68418548', 'WSP', 115, '2021-03-01 19:30:16', '2021-03-04 19:30:16', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Si los p├®talos se cayeran', 'https://www.wattpad.com/story/229731742?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=marivillegxs&wp_originator=CId%2B3GxSSlZxL5JaRKioeLGD7Rgo4owtwn3aSvhiCc7doG8j4mpaj%2FlGU3kx8uS3oEFQhObrxLSVZCN3mSynSPJAIDy1x4%2FTgtrb%2BGS02K%2Fgx4xSnkuP6B7dNmrOnaQK', NULL, 'Mi obra trata de una chica que ama demasiado y que de su primer amor fue robado sus sentimientos y que con ├®l tiempo acepta su realidad, amandose as├¡ misma, haciendo que al final sea recompensado.', NULL, 'La ense├▒anza de que no podemos obligar nuestro coraz├│n a amar a alguien cuando todav├¡a no has sanado, tambi├®n amor, esperanza y ense├▒anzas.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6138b1aa-d6ab-4681-ad44-e7a7d005f728.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=3Zw1FOqfgIiQ6SHj9IAO4o%2Fl5dx%2FHWY5xp8oRWbsKltdUPvOm%2BodeCcv1uZe8R9A2U5OvHO3HrWbS84Qp9exZYDaUPnbyc6PNTv9m2xsDFnGf5mWQIU5R%2F1SjLDAR%2BVHf5inKi1u9wlCugZFsZWNlLh4PNtn5xcDp8DCaZMXM4IDTxjaY44645WIJdoFWzzMBGLxf%2BLVwmPYcDVRkgb3VwkcUrZPttvy8r495BhJkqZAuHpOqTjKsb961ni3kzwv6zQh1KOgzy9bSisGO%2F7ekPJgkxGP7PaBUjt0K8QenQlTrzQ8TeQoBmnWzq3KzIUA27bbLm%2BP5YDcHu3r50X29w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-26 23:40:12', '2021-03-02 16:10:11'),
(DEFAULT, NULL, 'william.sandoval2001@gmail.com', 'William Sandoval', 19, '+502 35121486', 'WSP', 59, '2021-06-14 20:44:22', '2021-06-21 20:44:22', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Un amor que te cambia', 'https://www.wattpad.com/story/248791258?utm_source=android&utm_medium=com.whatsapp&utm_content=share_reading&wp_page=reading&wp_uname=WilliamSandoval8&wp_originator=WbEVw5ielSNUyHNwdDRwzMJzp3HX40yLqGqDEfu4dm%2F%2BU%2B1G9d9O2yxsPYGdcbWF9CvLHJfgnVVsXZn1vF%2FB87yqCEy2CTt2O1J5si%2BhCSrf7n67%2BaAHnD%2FX%2BGCV%2BSw4', 'WilliamSandoval8', NULL, NULL, 'Un chico pensando que parezca que est├í como deprimido', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fb4d74378-df1f-41ff-8582-927278833c64?alt=media&token=ad22a1a6-e7f7-4737-ac51-91bb67936ba0', 0, 0, 0, 0, 1, '2.2', '2021-06-14 20:34:08', '2021-06-18 00:20:29'),
(DEFAULT, NULL, 'haru13miyara@gmail.com', 'Jinx', 22, '', 'WSP', 114, '2021-02-27 13:27:51', '2021-03-02 13:27:51', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'GIZA', 'https://www.wattpad.com/story/253935190-giza?forcerefresh=1', NULL, 'Mi obra trata sobre un grupo de estudiantes que descubren un portal a una dimensi├│n m├ígica, donde una de sus compa├▒eras de clase es la l├¡der de un reino en contra de su voluntad.', NULL, 'Deseo transmitir la naturaleza de los seres humanos al verse expuestos ante ciertas situaciones como enga├▒os, traiciones, infidelidades, la b├║squeda del beneficio propio y ego├¡smo, adem├ís de sus consecuencias.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/919c0b45-fb9a-45f2-b27c-c9d7c32923cc.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=vaSCoBmNyV%2BcsS9MuwR8%2BNPbnnI2HkI4rDMlz08lMy%2BJcZndm7RajJaXTWTKscJW7F5lXGkOt72qLsD4LOJhCygLTRz8NzdGGWK7iMNC%2BARrI5BAvH19sLhdw4bdRBgm6bN%2BgNaohCOhVr87c0YULVAaKPKHIm8BCdm9KOj7oal1WnGhXspUmFZDDsa9nOYO4%2BZWxiGbsXtTi%2F4iPAb7KJXJ6%2BEF3R425v9G2z7G8RqYZEoJvXM1WzLTsSfdNSaGYYS85U6rmSvyToH65BYRwobCB1%2FxelbVuZLxxqJjNIVM7jJHnoxLn%2B6WFLVnGwZaFKVYJvGYFyFfUqR6Mj4w8A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 00:23:22', '2021-03-02 01:38:08'),
(DEFAULT, NULL, 'leonmarielis9@gmail.com', 'Marielis', 16, '+5804127430887', 'WSP', 117, '2021-04-03 15:02:58', '2021-04-10 15:02:58', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'El amor que es un fragmento de lo puro puede estar manchado de sangre', 'https://www.wattpad.com/story/209939656?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=16marielis24&wp_originator=G3aPolcoS4%2BDdcYR1k552tWU4t6%2FROYrBTuFc5JaEc45zT6F1RENCIj4%2FgswMK7Q%2FEDOmKdirxlnNDsapZKdWK%2FYxG4Aa7dowH6lOXngoDec43N9F8Vhxu52nVmlkGCm', 'Eli┬╗Ignis', NULL, NULL, 'Quiero transmitir que el aunque el amor es puro tiene su parte oscura. Tiene dos caras, la parte hermosa donde es una historia de amor y la parte oscura donde ocurren muertes', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F96797ba7-6b59-4845-a892-efac8e091a5f?alt=media&token=d8f09c06-f0cb-4488-9ac1-5f72e9a71002', 0, 0, 0, 0, 1, '2.2', '2021-04-02 11:16:53', '2021-04-06 18:37:13'),
(DEFAULT, NULL, 'elizabethgc55555@gmail.com', 'Aurora Elizabeth Guti├®rrez Ch├ívez', 28, '5568851948', 'WSP', 54, '2021-05-15 14:20:31', '2021-05-22 14:20:31', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Sobrevivir al matrimonio', 'https://www.wattpad.com/story/259085163-sobrevivir-al-matrimonio-1%C2%AA-y-2%C2%AA-temporada', NULL, 'Trata de una joven que se casa para salvar su empresa familiar y sin saberlo termina entrando en un matrimonio abusivo, y su amante es una de las razones para soportar la situaci├│n, sin embargo, ├®l tambi├®n tiene segundas intensiones, la pregunta es si la protagonista lograr├í salir de ese mal matrimonio donde su esposo esconde muchos secretos casi criminales.', NULL, 'Algo de conciencia a temas como el suicidio y el abuso sexual y que deje de romantizarse los personajes t├│xicos, el antagonista por muy atractivo que sea NO es una buena persona.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/d6fb2b38-c396-4873-8985-411f3ed6dd5f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=DHuZbuwm8UetEezZGVRhhoaEJfOmdk24%2FSoeiYoLVYACmve0dVFIL8wWEcawePb3WyP%2F5l9TMsl5eNOH9G1qX7rsp3cgjfTO50oLJ6qGDjuSW%2FeZCeGBPeyocvpAYN%2F%2FvsAItk8tyw6Qbj6MQDvpnjtOKqYkskQxxZNoObN%2BZ90GOc1l7N6Fro7sGsSKrgg2DXloKroTF%2BrBQxpaIlgh04caN6u60sUnPapJfBTF1mYycSTPoKEvamw9kCMiHxFhrOa0zd5FH0IAm2z7Brf9uyoGA1hgVo4nERxDsBm4PmhpZ4YQe2t%2FwUp7qnvT5f2W%2BL%2FAoeGA9%2BMDTKZQV8B5LQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 23:07:22', '2021-05-18 14:02:46'),
(DEFAULT, NULL, 'karen.rosas@ceuni.edu.mx', 'Karen Rosas', 23, '7352090371', 'WSP', 60, '2021-05-21 16:06:18', '2021-05-28 16:06:18', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Digna de dios', 'https://www.wattpad.com/story/266977927?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=KaryRose7&wp_originator=5%2BGrYyHkoP99oLnF3MEJkW4FxTBaJo5ltWsbOBMnDvLltHszVo0%2BjUPlSWxK2Z53pddMKG%2BJ8W0PrOKtJzPA%2F7wUym5v9Jdvc6rqeAauSnIBZNAcDk358ziLU81LWID4', NULL, 'Mi obra trata sobre vampiros en reinos antiguos, agentes de San Peterssburgo en la actualidad', NULL, 'Deseo transmitir interes, dudas, suspence', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/65e4e7ec-cbcc-4c25-a9f4-dadcf7080342.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=aicYo%2FfCDCSb6cuyfxcjfP3mmk%2FSPvCVhMvIytTXBC5pyvrrEJ7%2BwlhjdW9cXXwSUEOPY5qOz0rYG8gF%2FHrjG9TiOk5VIr7GDWj%2B6Dz%2FjZCLQvoPSUB%2F4oSVeTNAo94%2Bm%2BlL%2Ffw%2B3tan%2B%2B0k2WFCFXorhzYEoHYPgm0k9ws7LZa8f8Eivch8YnVyyCqi1tN%2BrkECzQr7LN%2BZgIr9SoNKJNDZXdUwYrVwChXQC3SP25hVvxicvChc%2BIDs71%2ByTbTH%2FRpMMwuA1AvhUUVwZYlsrMKzkXeQ41ZP8NqT%2F%2FhrpDant%2FOo0SFxxSTWa%2F9pIELq5lzQBZpwwMItB3bEcJddIw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-20 14:02:43', '2021-05-25 11:04:21'),
(DEFAULT, NULL, 'sanchezgonzalezmariagabriela@gmail.com', 'Mar├¡a Gabriela S├ínchez', 16, '+58 4120357218', 'WSP', 55, '2021-06-21 20:29:07', '2021-06-28 20:29:07', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Reg├ílame algo de color┬®', 'https://www.wattpad.com/story/270656317?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=marisanchezgg&wp_originator=%2FIeJQ6xePHofr%2B3WRaF0AMWGDWH%2FjbBEBoRzP3gb0DB4nkRoN%2FHGDKPazT55KyvfwGZUWF2YqbUrQIHhA61gAjWaz7pEJ1Wc9zZ%2B9SwzdoQNtXwn4SyEiC5Q1lkJXURW', NULL, 'El padre de kimy Louis le dejo un acertijo que ella tiene que resolver, el problema es que ella no recuerda nada sobre su ni├▒ez, solamente viene peque├▒os recuerdos derrepente y all├¡ es donde se encuentra su respuesta', NULL, 'Con el hecho de integrar acertijos, deseo transmitir un aire lleno de secretos a la historia', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/de722b28-cdfd-4d26-a75c-96b839de54c1.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=zzP4TRPIPYycfjluQ9E99XUGgwOao5L2OJLrfxxfqnv4BaDl%2BwOaBUlgDtqlmjp%2FafKyBstOFNmRk4pJijujqRzNyag8l67SSMTG%2FWZpQ%2FRrmu85E9dXnStv6JqM21OWyTRG86sDNwZcstutL0m2EouqFxYQjr23Lsqs9q5OGdST6uHpILFUjJxah%2F3AwcIqarZhJGsNMYn2BZz5NWnpX006DeZzInaEgEk%2BZ7HaREqcglIvir8RyUfZaT0I5BVaxZS87LfGME%2FmQDdwSa27YyL4jVt5v35oZpU4h9t%2FpuXDPyOSflUKaKCZPKiGZBOLeSXP1zKu9a%2BOelhY9P5YDw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-30 20:35:35', '2021-06-28 20:54:36'),
(DEFAULT, NULL, 'LauraMP14@outlook.es', 'Laura Mu├▒oz', 28, '', 'WSP', 58, '2021-05-12 18:33:26', '2021-05-19 18:33:26', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Te necesito en mi vida', 'https://www.wattpad.com/myworks/186692699-te-necesito-en-mi-vida', NULL, 'esta es la historia de una chica de 17 a├▒os llamada  Alexis una chica de nacionalidad Espa├▒ola/Japonesa, tras la muerte de su madre por la libertad  y la paz  del imperio ella junto con su Hermano Tatsumi llegan a Japon luego de que todo acabara, Alexis regresa con un objetivo y es cumplir la voluntad de su madre, cuando llega a la Capital del imperio no se imagina lo que le aguarda.', NULL, 'para parejas que no son comprendidas y que desean tener su lugar en el mundo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0f45bb2d-f40a-4157-b759-921bcd12ff44.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=hvobyGQiR6l01uAhsT9ZHuewqbxDpi9UWVavPJzc%2FQ%2F1p98Ec3Pbw%2BQHMygmxYIlnzrL3HhKH1vBJRl%2FDP8vzf%2BbDv%2B38Y%2F4WaFs%2Fnv%2Fgi%2FLCSwyiq4eNA%2BgOgZw0f%2F9L%2FfQzygCWDTNKMFj5Ey3ORGHz8u8eJHZ0dr2BQNgs%2B59G%2B4Y%2Bg4QDiU5LeePqaY2OS%2Fmhr2Ezbw8vtvAh51Lk82Uf9Ol0iglJyeaHKCAXuk0SGQaG8w2oIV6lmGjyo0Jf9kE3F1EJFdP8mSwyrLLtnLPvw6%2FNsD9AXUo%2FiKuisyu0xh9fEb%2FBD3vRuI5Od9q9x45gpo%2BwCKg2VzVD6XCgQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 00:07:44', '2021-05-17 17:05:28'),
(DEFAULT, NULL, 'rosimarpineda11@gmail.com', 'Rosimar Perez', 19, '+584264421783', 'WSP', 55, '2021-08-04 16:02:54', '2021-08-11 16:02:54', NULL, 1, 'DISENO', 'BAN-WTT', 'HECHO', NULL, NULL, 'Me enamore de el sabiendo que nada ser├¡a f├ícil pero d├¡ganme. c├│mo no caer en el deseo por un italian', 'https://www.wattpad.com/story/266361418?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=RosPerez995&wp_originator=gyYJVcL0WjjIMfSmlxc%2FdikW5ocBai3AbAxgT5uEsB4nqFe%2BFyyKRFn%2Bj%2FVJe2xtKbc%2BQiNrcRyYlmgv2H2iv%2FRDbCzOvfwbW5ENZM7pp1IwORIxILq1%2BOgEZt5XKHBt', '@Rosperez995', NULL, NULL, 'Lo puedo dejar en su imaginaci├│n', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fff6182ab-1002-4702-af96-252eb11f4906?alt=media&token=e03948ab-1d48-4779-89f7-b7392486dfbc', 0, 0, 0, 0, 1, '2.2', '2021-07-31 12:04:49', '2021-08-09 11:36:17'),
(DEFAULT, NULL, 'okamisakura93@Gmail.com', 'Kaira Daireth', 16, '+584126147215', 'WSP', 62, '2021-06-03 22:48:30', '2021-06-10 22:48:30', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Compru├®balo', 'https://www.wattpad.com/story/249450380?utm_source=android&utm_medium=link&utm_content=share_writing', NULL, 'Mi historia trata de como la protagonista pasa por varias etapas cuando por fin logra tenerla completa atenci├│n del chico que fue su refugio (sin saberlo ├®l) en tiempos dif├¡ciles, lo que indirectamente la llevar├í a una peor situaci├│n m├ís adelante.', NULL, 'Quiero transmitir lo mucho que el ser humano, bajo la etapa de enamoramiento, es capaz de volverse ciego ante las verdades que est├ín frente a sus ojos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/73aba64c-4ea5-4aa5-ba2f-c8e620cb9230.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=kKqFsiytjGitj5c2gGTyPwfOvW7tfiPTdMFPgoOu%2BmJdAeTUjILiCW%2BSqdE9kUEIG7%2FDUJbTMdxYp7kLITXAe6QqnWy51%2FQq1MxdAM6YBOcrB1fLVYC20t97qOOJKlpkYFXrkvXpgVy2F7fFavbfepPZX2akqTGCXco412iXIMviJX3UIEYDM%2B%2F2lUlhhQZamyE64OKaAsBW96ZDFL292%2F9JzTQdBjENAlg%2FkBD4rJaYKmIMu6u6skJjo40TxiJ5SATMuivSKZXdCliS%2FdgY0XB4%2BkOwQMkKScVglHhjMOsgYKMio0oDSmqjaTFdl2hucVCrKOiJzivCGyjsTEf2mg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-27 00:02:47', '2021-06-04 01:27:03'),
(DEFAULT, NULL, 'Eury12mercedes@gmail.com', 'Eury S├ínchez', 18, '+1 8293162982', 'WSP', 67, '2021-03-31 00:23:41', '2021-04-07 00:23:41', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'University Power', '', 'Eury_TeenX', NULL, NULL, 'Dos chicos tipo delante de un castillo, que el ambiente sea tipo anocheciendo, hayan dos sombras (los chicos) uno con los ojos verdes y una: plantas en sus manos o dos; dos plantas a cada lado, tipo creciendo. Y otro de ojos rojos y colmillos, que hayan murci├®lagos para dar la impresi├│n de que es el vampiro que los controla. La imagen del castillo atr├ís a opcional, pero ser├¡a s├║per genial si estuviese :)', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F42d2f93d-e7ef-47b0-a522-cef537bbd4ae?alt=media&token=7e1aed40-f3a3-4602-8d71-a6042d710d3f', 0, 0, 0, 0, 1, '2.2', '2021-03-18 16:12:43', '2021-03-31 09:56:24'),
(DEFAULT, NULL, 'draketmadeleine@gmail.com', 'Madeleine', 18, '2211522005', 'WSP', 120, '2021-03-11 21:51:44', '2021-03-14 21:51:44', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Un trono de mentiras', 'https://www.wattpad.com/story/226566433?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Madeleinedraket&wp_originator=JaP5YOufcVeYdbgoGXMfOlmi9OyPeFGpxr4ydW6A%2Fg81oGrK4tICZZMKyQJsQFyVP%2ByH8GBNYRBAVCMzlJXkPEZw%2F9jARUoe7Pp0QZFpvuGUzjYpohGjaVd49TDmqCAn', NULL, 'La primog├®nita del rey de los lycans despierta despu├®s de haber sido condenada a vagar por el mundo como una loba sin conciencia. Se topa con que su hermana ha matado a su padre, su mate es su guardia y su familia est├í m├ís fragmentada de lo que esperaba encontrar. Adem├ís, un nuevo enemigo los ataca y parece ser que es invencible.', NULL, 'Emoci├│n, terror, una subida de adrenalina, empat├¡a, que le guste al lector, misterio', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/854f4287-31c2-4522-9e0c-d4fee2288f7a.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=XELMhL3cIrqvrslPggUzyv7jCq3UhIEp3FR1bac7BC%2F7nN62l4a%2FA17WSalfWxu5Zt2AxUHwJSK4gL3kWECd%2FAIdoQWHpokNKHHb9kUnIT2HpQkhG1J%2F7ZlUv2X7andjUv86hsapKxhyBgXifiv2MxUQqV8gG9fLB6dksGLlFJJCdOAhbYiAK8Vit5z9TYNOk6ePvY94eMCwS8ZsaxycNs7ZNQSUS2osSn5GuuxYKQsHelYv3cW3q0QI0jKeDLbD9xHgdD8vvjeJOg6%2B0igGExtJ%2BhAInAnD%2BzNet1uGTXCfKmeRBNYep5hgPA31CaXyvKydX1PSbKCyQ0g%2B1%2BoPng%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-06 20:45:56', '2021-03-18 10:51:23'),
(DEFAULT, NULL, 'isabellitaalejandra@gmail.com', 'Isabelle Viden', 15, '+584144777632', 'WSP', 106, '2021-06-01 12:54:14', '2021-06-08 12:54:14', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Ten cuidado con lo que deseas', 'https://www.wattpad.com/story/231362685?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=javiqntpray&wp_originator=j3srqvB%2FxYbnZFkZsGEh5d69uESxgvTNELuJ8Ppoqhb%2F4Zhn7AKJfjvk9wqVathmgW6yrpKBpZ3Be8iVvbniNIgaG5bRVS2eLDCxtO7QzQaBBeAxe7vXOy%2F5K3QC2reH', 'Isabelle Viden', NULL, NULL, 'No tengo idea. Tal vez la protagonista, o un internado', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fc442343a-2896-47cc-b269-a2290618ce5d?alt=media&token=242060e9-3487-4f56-9013-c461f2a59661', 0, 0, 0, 0, 1, '2.2', '2021-06-01 00:43:37', '2021-06-01 13:26:49'),
(DEFAULT, NULL, 'karensolangej@gmail.com', 'Solange Jordales', 16, '+5493454936660', 'WSP', 60, '2021-04-21 17:53:01', '2021-04-28 17:53:01', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, '"exanimun": azul [libro 1]', 'https://www.wattpad.com/story/224305565?', NULL, 'Sobre una distop├¡a futurista. Es una historia de fantas├¡a que mezcla la maravilla de los superpoderes ficticios que anhelamos los humanos, y la cruda realidad superhumana como el clasismo, la guerra, la ira y dem├ís.   En rasgos generales, trata sobre la profec├¡a de una muchacha para acabar con este mal conjunto a un gran equipo de guerreros', NULL, 'Deseo transmitir algunos mensajes de como el abandono familiar, la violencia, la clasificaci├│n, etc afectan en peque├▒os y grandes rasgos a una persona o a una sociedad entera.   Adem├ís, en paralelo, de la superaci├│n propia y la importancia de tener un amigo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4c26a6f3-da7e-4399-9a2a-74292e900dfa.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=qCtvj%2B6iUV0XM7cN0Erhoi0RFGyZ6TCDVtwAiJb1wbaFlM9cu9NFgvI8R0vVQK8UisPSr9QyHkZANMr8lpxqTcgH1ETi7EgTuyYVFk0aOeu2DcoUA6X3cJ8Z37a%2FT%2B9VXmp9EOyRj0zDT6Rh7u0xwGryX8XKc2JBrH8WlxVeFyJVCs%2BL10REbrSciPXTybbyqtW6mSubk4WZo%2BywOJCu28NPmdPXeBl53al611tQa7POCq54%2FZYZxyMidMvJGOD2ksifVjPmD3lQR7GcXD2NsoEQBRTGwrYAnuZB2zA6dsiP4RyYn87pqopBgWwP8YDIFzJO4y6e8OxfHuOGldamzw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-20 09:39:18', '2021-04-28 17:22:55'),
(DEFAULT, NULL, 'ohani-el-30@hotmail.com', 'Ohani Poueriet Lugo', 21, '+1 829 959 9965', 'WSP', 60, '2021-05-23 09:30:16', '2021-05-30 09:30:16', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Imperio Ca├¡do', 'https://my.w.tt/WRklhVKXu0', NULL, 'Una alternativa de lo que ocurre en Am├®rica con la ca├¡da de la Uni├│n Sovi├®tica.', NULL, 'Reflexi├│n, cr├¡tica.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4cabd02e-3e08-4d68-b53a-2e6eabd76e85.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=dn%2Fd0WPhtZU4FMs9adQWHRzKfj3kUegpa9DYox7a9wqpBJLGchxQSKUR4WxU52LPRRIJMqcKuhNHpGl92nCwk8gYoQSL9BRY5yBBk8BiKgcCSYrnacRgV6AqpsY6d45tCtaYs2EdKDbqprbekJVCmFVGq8H3R6wk0C%2FYYLEO9sjcISd0s4Qfo1fG051jNUxXmudlCA5v8hPL9qhRudwzXudTaakv4Ud%2FieMQDIEL2MOWk%2BENZwg0d7kiOdX70N8LyeIlerW%2BZ20ZKt88wBkfgzq43eegJaAtJnDjQjQ6Ms7U9NmqC0%2FuAoRw1c42tHlSRFwLZXh25k2mv7ou5uZo6Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:54:23', '2021-05-27 12:32:20'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51902123505', 'WSP', 54, '2021-05-08 16:16:07', '2021-05-15 16:16:07', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El idiota que me enamor├│', 'https://www.wattpad.com/story/267990999?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=RickRock02&wp_originator=r65Lkhg0cYtzaaldCYAKBIHsPKpRW5O%2FQaaYeqYBazhW%2FAKlUk8QOIe0bR0mSJa0E0AzM6snDVT9TFzlxK5kElG1pGeW5Ttap26FXOSidBPQtcnSvd7u01QUXIGX5iU9', NULL, 'Trata sobre el romance, la homofobia, el maltrato familiar hacia alguien que reci├®n est├í descubriendo su sexualidad sin tener nadie en quien confiar.', NULL, 'Trato transmitir el dolor, los sentimientos y lo dif├¡cil que puede llegar a aceptarse, como tambi├®n los sentimientos de alguien que est├í enamorado pero constantemente se pregunta si est├í bien o no.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/7dd06cf9-caa5-4086-8503-09fb303fa9e9.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=dxJ3Rfsi14r%2FBJF9tQhzvhzFTJOXsL2N3dAai0vA0riVMX%2FB2rO9OP9QgDT5T%2BEYFKfBkWHlW%2Bbn%2FDSDZuV2dD0w4lGsrdqiamXaYznd%2FyZByFeAGa%2BDldO%2BWwfbA8Ivp0XJWhxGnm3B7rwoHIAxY2FhmlFh%2FopuG%2F0vv47q31PaGXLmNB75YtKB8vZvRz6BtHc5ZBEbtGFOBOq1dQKqzGi9sOhp4JylElordlKzNplpJlPeENhuztWPbVlMZkENb%2FSjNlwyI1v3E4nSNZrwv66W66dXfD1CPWoV9tc2wA24lg5ENRqPJgkidVmromtQ3ATSphryV0kMaztcFGHOPA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-29 23:36:10', '2021-05-10 11:48:22'),
(DEFAULT, NULL, 'onalovegood@gmail.com', 'Ona Spell', 22, '634507498', 'WSP', 60, '2021-05-27 12:36:58', '2021-06-03 12:36:58', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Gu├¡a para dejar de ser idiota', 'https://www.wattpad.com/story/224987595', NULL, '┬½Noel, lamento decirte que un buen cerebro vale m├ís que un buen culo┬╗.   Cuando Noel Mart├¡n (un idiota en toda regla) pierde su popularidad, no le queda m├ís remedio que pedirle ayuda a Lena Rose, la chica m├ís rara del universo.   Una comedia rom├íntica d├│nde nada es lo que parece ser.', NULL, 'Deseo transmitir todos los prejuicios que tenemos la sociedad y como no siempre es como nos pensamos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/2b803171-0ddc-4492-8bbc-a57ad713a89c.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=YiMuEI0KHI1%2BTlcq0eO5lKclzNGlDQpIUdXmpTACB7mwgkQr5hpe%2BAAaylqQ0IBVn0IRNXCGcu1rKqRlQSKL6kOvScgBFot85jcvesR%2FdV5gsl3ZNVolOuaoxBYzKj%2Bbe4HgapPEZICU1La6gDxaOzAJBtABZWpBMBFIGtchupAC79S%2BXMvsG9KvoVyVzn3FUIU1Btty8fymIHWryc%2FVHtzK8NOeusfO1FKgytgKmEJlVKqhIeWGEhhJrCDKnZv31CU1xJj2VIOxHvIoyAvsrbVqfkrdIIpnct2r%2FbSRjV4pT03ad3c%2BeOyDHmoTP9Jx6GiI0YJwGawscZ98h5Qehg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-29 20:51:04', '2021-05-31 12:43:38'),
(DEFAULT, NULL, 'malakbounasse080@gmail.com', 'Malak', 19, '+34 691635372', 'WSP', 61, '2021-08-26 09:12:28', '2021-09-02 09:12:28', NULL, 1, 'DISENO', 'POR', 'TOMADO', NULL, NULL, 'El lobo siempre va disfrazado de oveja (no hace falta poner ninguna frase)', 'https://1drv.ms/w/s', 'no se que es eso (pero mi historia se llama desventajas de enamorarse)', NULL, NULL, 'quiero una pareja formada por un chico y chica, besandose o que el chico sea "posesivo" y la tenga como atada y tal pero que no parezca un secuestro', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, NULL, 0, 0, 0, 0, 1, '2.2', '2021-08-20 12:40:37', '2021-08-26 09:12:29'),
(DEFAULT, NULL, 'kingdomofinkcats@gmail.com', 'Mar├¡a Gonz├ílez', 20, '+584146130740', 'TLG', 55, '2021-08-28 11:18:48', '2021-09-04 11:18:48', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, '├ël no usa drogas, el es la droga.', 'https://www.wattpad.com/story/282959732?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=StellarisGirl&wp_originator=ug%2FocOvAmGtH6mhe%2FUEO94kSzVagDUBoRKd8Z4Y340sFNd6FIUshEYo9Txa5Wm7RlraOamr4imwL8exttTSHTTYA2wBuRpsuvhboW%2BfifY4%2FltpgZN7NqHd3z5ojk%2BMB', 'StellarisGirl', NULL, NULL, 'Si es posible quisiera que fuera un hombre a media luz, ├®l iluminado a medias por el cigarrillo en su mano, exhalando el humo y que se resaltes sus ojos plateados.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F2b39894f-11e2-4736-ba93-09e853ee40dc?alt=media&token=a313179d-3146-4478-97d2-53e3847830e2', 0, 0, 0, 0, 1, '2.2', '2021-08-26 15:43:41', '2021-09-06 12:34:01'),
(DEFAULT, NULL, 'efrainrichardapazabustamante@gmail.com', 'Ricardo', 17, '+51 902123505', 'WSP', 55, '2021-06-12 22:50:16', '2021-06-19 22:50:16', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'El color de la mentira', 'A├║n no publicado', 'Efra├¡n Apaza', NULL, NULL, 'La mentira. Puede ser un lado algo diferente o contrario al otro, puede ser volteado o distorsionado. O quiz├ís tener un animal o color que represente la mentira.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F2bd011b4-dd4d-405a-8ea6-291568885451?alt=media&token=af4314a9-4c51-4201-ae30-e7dd5f36e92a', 0, 0, 0, 0, 1, '2.2', '2021-03-04 22:59:43', '2021-06-13 17:24:16'),
(DEFAULT, NULL, 'kattyespa97@gmail.com', 'Kathy', 27, '0051960598406', 'WSP', 54, '2021-06-14 13:17:54', '2021-06-21 13:17:54', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Coraz├│n latiendo', 'https://www.wattpad.com/myworks/259982817-corazn-latiendo-en-edicin', NULL, 'La historia narra el amor prohibido de Xial├® e Ideki, miembros de la nobleza de dos reinos enemistados desde hace 50 a├▒os. Todo comenzar├í cuando, Xial├®, princesa de la naci├│n de la ciruela, ya no est├® dispuesta a permitir que sus padres decidan todo en su vida, por eso terminar├í escap├índose, pero para su mala suerte, el d├¡a de su escape se accidenta y llega de casualidad al reino enemigo, conociendo as├¡ al pr├¡ncipe Ideki, quien es el sucesor al trono del reino cascada. Su amor prohibido comenzar├í a nacer cuando ambos se reencuentren un a├▒os despu├®s y, por cosas del destino terminar├ín estudiando en el prestigioso instituto llamado ÔÇ£AriangÔÇØ, lugar donde ser├í revelada toda la verdad con respecto a sus reinos y ellos.', NULL, 'Quiero transmitir la historia de un amor en tiempos de guerra. Estos dos personajes, Xial├® e ideki, son j├│venes de car├ícter diferentes. Quiero que el lector conforme vaya leyendo, vea la evoluci├│n de ambos personajes, y que al principio su amor suene lejano pero despu├®s,  las cosas poco a poco, ir├ín cambiando y ambos tendr├ín que luchar con todos esos obst├ículos que se aproximan porque hay secretos que ser├ín revelados.  Los dos tendr├ín que hacerle frente a la desmedida y terrible maldad del Rey enemigo.  ┬┐Qui├®nes son los buenos? El reino Cascada o el reino Ciruelo. Ese misterio se revelar├í conforme avancen la lectura.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/b1bd0240-f0dc-40bc-a439-6438c43428f2.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=OnGePGDAZpeKk%2FNdWSzqj%2FogDt%2BlBEwQ7tWdBLbVjyJdG1AeJ9aqUWHXRonnTMTHmwWVOVl8peXQbm8t0BLHfrYJIdm0S9cftU14QjhLBZFN0HVzLsFWi45tuihuA6c2Ph34TfLLdtdQGBQWQrAP8uYu8Ca2EpOZCW7jvTPnFSQmhLIIGdoo%2FpCXvlG5ZX4H4Qa%2Br9h%2FqW0QrgedtKwMVIr%2Fk73Jz8AXjlqkW3esoY6WWAX90zC8NmCnh12PDhSozkNvWowNv1ex74yCFwPnm28x52X5wUHBWe862OwHWwp6cykqPxuiZiDQOqq73%2FsoozfBn%2BIb%2BKLK3%2FO%2F6%2BmmzQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-06-11 15:41:35', '2021-06-29 14:13:00'),
(DEFAULT, NULL, 'eglez1701@gmail.com', 'Emiliano Glz', 18, '5561126041', 'TLG', 116, '2021-04-22 14:29:30', '2021-04-29 14:29:30', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Semper Vigilant', 'https://www.wattpad.com/story/258230946?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=EmigHolmes&wp_originator=meZrVB9RqOvuRN681y1m4CuthTkFVtAVKMh1qLy%2FZFZNvI7sWrfWUG7e9oTo%2B8c%2BhlRr4OPBotNfnQqQR5zABlKYuD3WyLRs%2FxJvJW5UYait3u36XZ1xs6HIWloxWezH&fbclid=IwAR1bJm0tCrXrnPrX7Mu3_pXGlUf_nAIYXeUHmSiWx9oGpe9vWFjwquvD7T4', NULL, 'Una carrera por detener una inminente guerra civil que podr├¡a hacer caer a la Rep├║blica, y con ella acarrear la muerte de millones de personas en la galaxia conocida.', NULL, 'Un deseo por un futuro brillante, lleno de vida y pr├│spero; junto con las preguntas siguientes: ┬┐Realmente somos los buenos?, ┬┐Las decisiones que he tomado son las correctas?, ┬┐A caso soy la persona indicada?', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/625a0c80-b37b-4e4f-a791-68a25bcd8e2d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=zX5WdXRZZPW2goh%2FsWqBtMMvkHmDV3ims2l4O%2BRq40p%2F6pEFTGQxF1%2Bf6%2FZW8R6YEINsBKdAyaMQk18Vp9elKc1d7XA3yp3OXaq27xwcX2cLHl7wXwDQeaV9%2FGRn3rjORZtEoiXNxdnLSm6nv5hAv8EFJNNktAFlmdLuL6dA68cVXp2wnjSqv08FIuSmHFT%2BBpp9OM2oIWyBoiI%2BaLorRv2JsvgyEvzSlc%2FMyXCsN6IY86gN0Ie3BbKVIvLQZ9LuCCFmfzYz8LlpW3bOPhN6g74Vjs%2B2PddnvG2VytipVxBurxObd7TNQ8ludnx2m4v0oUOeOss%2FKdWyBQqxNDahwA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 14:52:41', '2021-04-25 18:34:37'),
(DEFAULT, NULL, 'javikusenpai896@gmail.com', 'Euliser Fern├índez', 17, '+58 04261246244', 'WSP', 120, '2021-03-17 17:23:51', '2021-03-20 17:23:51', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Sin Destino: El Inicio', 'https://www.wattpad.com/story/236041935-sin-destino-el-inicio-libro-1', NULL, 'Trata del principio del fin. Todo con un deseo de venganza por parte de una super soldado rusa, Kaira Ivanovs, pero con el paso del tiempo descubrir├í que hay cosas m├ís grandes que ella, que solo es un pe├│n dentro de un gran y maquiav├®lico juego, uno donde todos aparentemente quedaran sin destino alguno.', NULL, 'Emociones como la tristeza, adrenalina, la ternura. Sacar tanto l├ígrimas como sonrisas al lector. Sacarlo de la ambigua y aburrida realidad que tenemos para presentarle una mejor, un mundo diferente con personas y individuos interesantes y ├║nicos.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/df7f3db9-203f-42a9-bd76-d5c552ee9698.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=T0jJvp0GfGnWUKDOkw7VuqgluSNQKtKPi8UN441kz9LFEZbvhjxA0SqSuZgAbS1aLfj4wnvvZ6nJXU32XOrKQCnCb%2B6D2fiQ8oGQHFFcpPusem5e7UuOgcnSOaH6wHkG7qy87d3nFlSG760alaMHSnInlj9Vu3nUtHJAXPJVB6QYOA8GQwlMH9PTHd0NgSewD%2BR8Ii5IipaFPEVT4F9L4zpva%2FIF7dRRTwPyumzL1QDr9D8hkz4vn57thkDWXrxPtmSBdZTtzzzYvWOJSj49OxhitdEcwSl4SFRubdzL4XZg2GaS42gyqzcUkk8%2BARkzOFva53Unay435C%2B4LBMPhQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-03 14:16:54', '2021-03-18 11:29:45'),
(DEFAULT, NULL, 'noeliaramal72@gmail.com', 'Noelia', 16, '', 'WSP', 56, '2021-02-28 11:51:50', '2021-03-03 11:51:50', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Aiden~', 'https://www.wattpad.com/story/256241101?', NULL, 'De una chica que se desahoga a trav├®s de la escritura lo que ha vivido con su amigo y posible amor plat├│nico, Aiden.', NULL, 'Deseo transmitir al lector una historia en la que sienta que fluye demasiado las emociones, que se sienta identificado y c├│modo con lo que lee', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/097b2dc3-695e-4e1e-815c-c32c8d06b24d.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=RLeF6M8fjttZXdgIkKGYN7dvpEipg9D%2Bjk8iwuS3x6wvAYMyBrNTV%2BjyhmzNH9onNF%2B%2Bs%2FvqonjcYLIXTTZPKMNnW18pPUxLqAdqUnSVKqgwcYPv2kJDH1ITOXOfMEVYK33vpvcAYY7qDHy75Tx2NTLYRT3umTwQknQDDlKgnecc%2Fseurc5bfk6wWUtQNn7dVnWLm7fMTcZKQGFjRJIOl7shC2fUZu4hw%2BTHE4PkhIb6lE81xl0xwIF7dnFRcRIs52obRuOv547Sr3fbXDjCBWZYCYsBsen7jEsVGI1fumNG7gc0NgoEzoe%2B3uWSMBJismQxPo4ZJ%2BSG%2FfTFBPECUg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 11:44:07', '2021-03-03 12:10:13'),
(DEFAULT, NULL, 'j.lynnesquer@hotmail.com', 'Lynn', 17, '', 'WSP', 63, '2021-04-22 00:58:39', '2021-04-29 00:58:39', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Maldici├│n Fraternal', 'https://www.wattpad.com/story/240427901?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=lynnesquer&wp_originator=QWZUu6onvEWXOzuCqjiqekSggKEWgXs1hvGCSnyO6ONybJtC1lJLOPgg5S2R0%2B76x0hKyqCKGr5Xbb6GkmmBGUDlc42Jvsf%2B1%2BxPDxQX3BSXOCB94VSztSPtNJDO6JQR', NULL, 'Es de hombres lobo, pero por una maldicion dos hermanos de sangre terminan siendo parejas destinadas.', NULL, 'Es de amor, pero al mismo tiempo la rareza de saber que es tu hermano, su verdadero enemigo es la sociedad y uno que otro mas peque├▒o.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/95d0bb14-912f-4590-a179-4b7ecb86fe04.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=NAEvcxaQZIcQSWUzrTtFn0HOusn36P66jypxiDAlMT2okOO4C%2Bo41Mxv1V%2FY8jobe68nttSzJx9RKO7fj4eKpO2%2BI%2BLLc8JBixx0VGrqfpuYN%2Bwfu4DPUHu3IB5wy8IC7VSPkG%2BigydIxoUU5JGexiYUOt%2BXe94%2FfBRDJ8Bsw47zmrR5j3lZH4LsFRxAPqqy7AcFsE82ThGqgg5PKuKo8rb%2F%2BEKPtdgn57YCT9IcC4sESTfPdCqM%2BQnEdv6YZcF1bhZh2yUJ0lwaaLG0pnwBWTMSmUtOMbzc4TkHJesjiKhhHd1KKAdnEhCjyYiUpydSReERVod%2FouS0V9k9QT8qjg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-31 23:30:54', '2021-05-24 18:29:35'),
(DEFAULT, NULL, 'jennifergarrigosmartinez1232@gmail.com', 'Jennifer Alison', 13, '52 2224427652', 'WSP', 55, '2021-09-11 11:24:14', '2021-09-18 11:24:14', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'La novia de la muerte', 'https://www.wattpad.com/story/280978313?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=Jenny9866&wp_originator=ergeQbwQVbDj6CAXYWojAO%2FmcQaSuxZT8NVj4aGNyOlkW5Og%2BBIKoiETm6UPa%2Fp9LYzVFo%2BtmmOLo6C0UB0P5dnh8Pg2gSdmqvIWsNvVhe9gsZ7lElpuLwbYqX2Aomni', NULL, 'De una chica de 18 a├▒os que muere por C├íncer, y ella cre├¡a que esa vida hab├¡a sido la primera pero no era as├¡', NULL, 'Dese├│ transmisitir una historia diferente, aunque ahora ser├¡a de asesinos desde otro punto de viste  Desde el punto de vista de una chica', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/555bddf0-3ba7-4d14-b3ba-d05dc4e27b8b.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=ji7th6FLpjGF4V4TK9DP75fluUEsRmwNdDx%2F%2FtqUn8FO99yFl52eKhY89xsXjR%2BySgYmMIqtyCVIVnujoitII4M9BtKeAgNTb13pCrBNQ4%2FgQAihLVjr6E%2BI8Fgi9IZvAmZfaiXnXV7EdEc1e1icBs083JPNJB3lsV6b8GTw8oumelvRk2bmugePCzH7haxGlvBO%2ByLQYVPnAh5QncT364fnqGaEJHYEeZaa2EH279j%2B6H19Ql%2FVLdF4jQ5LsIHX7PCPLEzcXFXAtfySp0MpIa0YAQuMWK3LJI0GCaY8h79nGcu5eo6Il4R2V5Vq3ZrlE2e1Nk0GyJBBTP1hzNRm6A%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-08-27 21:54:44', '2021-09-26 16:43:41'),
(DEFAULT, NULL, 'fariasaurimar1999@gmail.com', 'Aurimar Farias', 21, '+584242512297', 'WSP', 112, '2021-04-21 20:36:53', '2021-04-28 20:36:53', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Bajo la sombra de tus alas', 'https://www.wattpad.com/story/265858916?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=Aurifarias21&wp_originator=wwYG9wQnDUOHxupsqcqWBrPdnmU3zZ7NpZVoVLhtlBXTWXcw%2BF4j%2BtY2yVuOVe%2Bs9y5k71JM68PGgbXmyOUJbLTwrA3xUvan2YZXJFxGerbezYD1q%2FVv%2BFUhQTdOLG17', NULL, 'Mi obra trata sobre la vida de Matheus, un adolescente adicto a las drogas que por tener problemas legales es   obligado a ir un correccional cristiano, en ese lugar conoce a Kasvell una chica que le ense├▒ar├í a ver la vida de una manera diferente.', NULL, 'Deseo transmitir buenas ense├▒anzas y palabras de aliento.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/74673731-6cd8-4e08-88ab-92154a2576aa.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=ng1uKtlzO7jO%2BChbj6akMjz5LVW5ZoTFDq3nbbedjizDciUmRnbZKW3Hkmv0wLa4xSqGP%2BFNyxsRFRCHbOaKqsDDPiSSpscTgkzrwpn3Shy6nUiXftslT9tsSMrIcBV%2BUlMwVnJNqkaSUUPxcgcnqdD%2BVp2jY9Dj5KPpFJ%2BQ0isBVqaY98i1H182FwNdek2Coj%2BiMHJXNiWvt9ET%2BkdYIIgroxHex4q55a12S99S4%2BMbYS0tFXOhLC4R07s89M3Q5ymVtGLWSCVdecMyAQxtYk%2B%2FAsFKdLzdc9dfpaagH18gkIcH1rlJ6fkO3sImkYkRc%2BF1Bkl3TCxvN%2FYGM8BPiA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-21 15:23:15', '2021-04-26 16:25:56'),
(DEFAULT, NULL, 'spitreful@gmail.com', 'Enzo Camilo Guevara Loayza', 18, '+51927509097', 'WSP', 51, '2021-05-18 21:15:36', '2021-05-25 21:15:36', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Losing value', 'https://www.wattpad.com/story/269667602-losing-value', NULL, 'Es un compilado de escritos que presentan la etapa del duelo y como esta avanza con el tiempo.', NULL, 'Transmitir el sentimiento de dolor de perder a alguien, de aprender a valorar a las personas antes de que no las puedas volver a ver. Que el duelo es diferente a como lo tenemos imaginado y es m├ís complejo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/e99e7151-93aa-4dbc-b092-543072e1fa25.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=HH8mlJBr4QrfB39%2B1Uz%2B55K31Y%2BWecXqoLxGAiPc6esRB8dS7ENyglq7xU0D40mHz0lhCeRQ6fhTVwosLB0z%2BDbCdblkghtunkKoxzZdXiV7fhIvYdZZ3KuoWkYPGFCZRh%2B4qILYX28wK5CTwgb%2B2FvHpwNcD%2FOoZylCQQ0U19EBnJb5c50gIq0WfbmkzXO6MwAZcAaJKod4vY1amtfJVYcQvQAHA6%2BqZdTu7rWm9j4dVN4MtjuZzkbugo7fONPmWNbvmMSU3zsDmLxrqefAs%2BvxeQ2scI5QoT1Dn2%2FInmymKhwgcR03Sd0dpWRXC3PZX0jnNLzE58Zc0ufQmS5bqw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-15 17:25:14', '2021-05-26 19:12:26'),
(DEFAULT, NULL, 'isa_cv@outlook.es', 'Isabel', 17, '88271143', 'WSP', 55, '2021-09-06 10:54:41', '2021-09-13 10:54:41', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'No quiero usar una frase', 'https://www.wattpad.com/story/173384382-las-cr', 'Uso mi nombre: Isabel Chac├│n', NULL, NULL, 'Quiero que se usen tonalidades verdes. Quiero una chica en el centro, ella es de cabello casta├▒o ondulado, y piel morena. Quiero que se refleje el uso de poderes de ser posible, ella tiene el control de cambio de forma animal y control de la naturaleza. El t├¡tulo puede estar en con letras doradas o que tenga cierto brillo. Tengo la imagen de mi portada actual que tengo como boceto, pero quiero algo nuevo, que represente mejor la historia.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F4740b7d0-422d-4ffc-8e1d-9df2f5925c89?alt=media&token=8503f04b-9460-4f79-8266-c11334f21f99","createdAt":"2021-07-13 11:02:27"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Ff6aad22c-6582-4d61-80f8-bf63497a7833?alt=media&token=9e5851f7-5612-4fbd-89e7-a75e816fb2e7', 0, 0, 0, 0, 1, '2.2', '2021-07-13 11:02:27', '2021-09-11 12:37:55'),
(DEFAULT, NULL, 'alex.6.bv@gmail.com', 'Alex Van Buuren', 27, '6144478667', 'WSP', 116, '2021-06-01 12:16:11', '2021-06-08 12:16:11', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Soltar las amarras', 'https://www.wattpad.com/story/259057641-soltar-las-amarras', NULL, 'Es una historia sobre dos chicas que se conocen gracias a una amiga en com├║n. Sus vidas de unen a partir de es encuentro pero el destino no es lo que ellas esperan.', NULL, 'Me gustar├¡a transmitir un mensaje a las personas que lo lean sobre c├│mo a veces hacemos cosas malas que parecen buenas y esto puede acabar afectando la vida de otras personas. Tambi├®n, deseo transmitir las emociones de amor, decepci├│n, frustraci├│n y anhelo que viven los personajes con la intenci├│n de lograr una reflexi├│n en el lector en torno a la situaci├│n que se presenta', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/5371adf0-e160-4fb0-8f0e-95e416c07008.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=Hx%2BSyF8CY3uiP%2BrBRiHpFAhPE%2BhD4NSC8evTIuzJOmj%2FETDM9IRhECjX4u1KtTL70WKXtTUcdPj5oZJUpKoGiTOwWQCJdcbZW57glD7EZWjk6ejEMSR4ccCQ3kYNX5Am2Yf5cn7qGtdqn3CHSe0qwJJDzkM%2FhLwjJIDG0VndV8rGfYgPA%2FQAU8DpP4hBReI6u4LVFEq8u04LonTAoSq2lUAvOqjZTN9NuqshsVOPQJphHFkOUmwrGCUPxLUTLuv5dEebO52%2BR8CQj3lHi14D19FXN7I9sSTNsz%2FfagNclvu8IZLhCNt8nzPEsA9M0CA7RTinlkfMrKJmUD9Su3Olcg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-05-08 19:48:09', '2021-06-11 01:37:44'),
(DEFAULT, NULL, 'nhardwer@gmail.com', 'Marcelo Hardwer', 22, '+56954343393', 'WSP', 56, '2021-02-27 12:40:40', '2021-03-02 12:40:40', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Una Gallina Espacial', 'https://www.wattpad.com/story/256602983-una-gallina-espacial', NULL, 'Mi obra trata de una gallina que sue├▒a con volar hasta el espacio durante el periodo de Estallido Social en Chile.', NULL, 'Dos conceptos: Que no existe sue├▒o inalcanzable, y que no existe una verdad absoluta.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/69782dca-ad76-4a0b-a66e-7531ec626e93.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=qB6yt89ytOiJDa203fh%2BAESGju%2BIGVMCIPP0adMx7ADDcOANYwK5utBGd3p%2BPq4%2B5k%2FosYA32d5IztKvCWMVSN6qOXwTNWjGhBYQ79uSsa1acVap0Jc2rYdwLEmU1skqO8qUkRqmqhSVUHtfu4%2BcKSQS6PEVy%2F7tVtHyaQp1cNfOXVjQYxS5UCTbwuYGlIWQ0wFc9Mqj%2BMy8PSBUJmST%2FyuDxHrDYpyljXnsrjS1v7HT8TdSEVKZFdhbnRXLNsMvVpSpi8ey9T2PlLsup8Nhkg62I3L0M5tb3eyOawIFYshaPS%2FBI2RmadrgZzbFdzGG0eEPUV9LoZwrAnHICRaYew%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:56:31', '2021-02-28 10:56:34'),
(DEFAULT, NULL, 'mejiakatherinet@gmail.com', 'Katherine Mejia', 18, '+54 88597555', 'WSP', 119, '2021-03-02 00:49:23', '2021-03-05 00:49:23', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Andrew: La oscuridad prevalece', 'https://www.wattpad.com/story/220935230?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=reading&wp_uname=Kxty_jhna&wp_originator=v7ijuqGm18kcs5BANirxh%2FZHAlcF0UMErw7DlHFliICEEHSXuR8wBuWtDhUwZCsb0vuYkBNcO%2B7xxdLwhLnrjgHGRmjA1ITrxXJ9cMviogj1tvoA7yvVnWlIu7vGY5Dh', NULL, 'Trata de un chico el cual parece perfecto, el mejor estudiante, el mejor hijo y hermano, pero oculta un secreto y una chica que vuelve al pueblo percibe algo en ├®l que la hace querer saber m├ís de ├®l', NULL, 'Quisiera transmitir inter├®s y atracci├│n hacia los personajes, curiosidad acerca de su alrededor', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/b5139058-0db5-478a-8c8c-e1374665f55c.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=ZFnSyIvF7qNWvMY5scsJ4GrkFuZFumn1EcBQl0RxULrWPi9PIAua6t%2FluZ47IXr913Fnblh1XN6HwtLHYjIbCdwsaY9vZPGcz89t6k25pxc8dQ8Ho6nohCBx6ygXiuBJ2smP6smueg5q86vJEfygmG3cCiO7O8aVKtWeI%2BAlNJMpG6zuoyeGz1WD1g4qHJLnKA%2F8iuQvAkK2fjBH8sO7ElNTS9cgxakBwLHcUkCho1TBCckyEFoy6h3sDB483A6Uvza9w2HsSfsnVuNYFvXhwfMkZMgmzlIWEHOI0EPOhbW%2FGCT%2Fy4%2BDsw1xtFkgRhaC6Huvnlb16ezs0ozTrMxWDQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-02 00:34:16', '2021-03-04 22:56:24'),
(DEFAULT, NULL, 'efrainapazabustamante@gmail.com', 'Ricardo', 18, '+51 902123505', 'WSP', 62, '2021-04-13 23:37:09', '2021-04-20 23:37:09', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Donde las flores se marchitan', 'https://www.wattpad.com/story/264606476-donde-las-flores-se-marchitan', NULL, 'Es un grupo de cuentos cortos sobre el tema de desamor.', NULL, 'Sentimientos que genera una p├®rdida. Siento que el desamor no solo es que te rompa el coraz├│n tu enamoradx, sino diferentes situaciones.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/18b5f459-b66b-4d0a-a272-192116a2f3e1.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=LzfnzlvjxjEBQZtHJjmTSXi4HzIaJpojSqswtvGsSPIYTldPs1yFi8HoCelK4jXQ%2BT1dmTOthwrCaJM%2Fq3xWRWv%2FoPx74%2FzNbZf9c3T8nxFG3eN%2FycJn%2BEewyKRHyqzVVP8NLS2QdXFjw72cIlM9Bt3q%2Fr%2FPyxwyDoVNRJfWVcekal57Gcgd4BvT6DAXUwCvHa9UTgSscEhdy5zjZJF9LqdfMFjH5ZMDxKQ63mENd3I4MnjulUn97zv5yYSOAEOLTNy298LxUnpZSb9oDWfBbG2RFwX7fdKw4lhmxhnG%2BvcxKNXoOuwrLJ%2Bhr7sKytMrGRbpMah1gMGPdZCrQOx9wg%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-13 13:11:56', '2021-04-14 14:58:55'),
(DEFAULT, NULL, 'marco.vt109@gmail.com', 'Mark', 22, '+51 990256526', 'WSP', 56, '2021-03-07 17:29:03', '2021-03-10 17:29:03', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Desde Cero', 'https://www.wattpad.com/myworks/219832015-from-zero-desde-cero', NULL, 'Mi obra trata acerca de viajes en el tiempo y experimentos con ni├▒os.', NULL, 'Deseo transmitir emociones que demuestren que los experimentos  humanos son malos y que tratar de viajar en el tiempo jugando a ser "dios" puede hacernos perder nuestra humanidad.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/d173ec4c-5b61-4a07-a4eb-1e8adf60edcf.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=ULssrv9S1Tpx%2F3jCDXW4JKUMICnCVg25R9VIoPVGbq4feNhipR%2FMyauwZIArw58P8I992QkmMtfqupiXi0etDuH1udsrKedHizGPwxKbiy78pecNXlbv73RVKBWCoyITeFA6JFFlwgI9gcim6u03g9ZRj91jCduhwUA6oZ4FiNnzemFs%2BZaWfbUxOBcAiO%2FXxpl0by0hcuPU%2F%2FrCGgKpsDLqYmNGf8XvRqgJC6dWFSqpfpjojiFU5CRfIZMnVNI90OciPRzRdJEUN5FtRfsd1e3vlRSwsO91RArD3ple0%2F1OUERhVMLZCRRn3hJhy3csrOCSwp1keLJHfNUdbQkT1Q%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 02:05:27', '2021-04-24 10:30:16'),
(DEFAULT, NULL, 'isamxk@gmail.com', 'Natalia Isabel', 55, '+393473531866', 'WSP', 102, '2021-04-06 13:18:15', '2021-04-13 13:18:15', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Amalia - Ya nada ser├í igual', 'https://www.wattpad.com/story/247734398-amalia-ya-nada-ser%C3%A1-igual', NULL, 'Es algo como una novela hist├│rica y de desarrollo personal: la historia de una muchacha que ha pasado por una experiencia de violencia y de su encuentro con un joven involucrado en las luchas revolucionarias de 1848.', NULL, 'No s├® si tengo un mensaje que transmitir, pero me gustar├¡a que me dijeran si perciben alguno. Cuento la historia porque nace en mi mente. Solo quisiera que haga sentir emociones al lector/la lectora, les permitan involucrarse, compartir la experiencia de desarrollo de estos dos j├│venes y conocer un poco su tiempo.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/113e7f0f-db49-4008-b3cd-def115075245.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=bTqZfo%2B9AV8A8Jy1Lo2UCOUV5n6n5hGK4pSC4R3ShnwNTtHlK7ni7tk%2BUDFpEq3NR0V66DaPp1goU6FyyVmnn2r%2BNdcTM2BXRX2pd%2FxKNIkF47qTQTQ5a9Nija%2FIk%2Fcon777xhZ%2FjG5%2Bhc%2F02nBN8xB%2BQD7%2BXdLk3cedmVAAmzk5R%2BsflRn3nF1FqMu0deumy8gaND5%2F%2BjXe2AN4fydKl6jaY2horel9J9W35BIqNlMbb2%2BfimcsmGGyQXOpB7vS%2FxjrQ3EXHTUhwALPBnF%2BYeZaIL2t542FETktXA%2F%2FBpU4KI9ZcTJfK6npFJrs4QO6SbQoLSyfvMqkJmJac1Fy%2FQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 15:17:59', '2021-04-13 18:19:32'),
(DEFAULT, NULL, 'monicagranada30@gmail.com', 'M├│nica Granada', 19, '+573225912110', 'WSP', 59, '2021-05-29 12:42:17', '2021-06-05 12:42:17', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Hijo de la luna 2', 'https://www.wattpad.com/story/268850538?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=moniklejandraherrera&wp_originator=THqK%2Fwa19CzeNQU25hfvcMiKkOdDrij1yhWq%2B8Ln5k1xwHX1WfFo80NvoczkO39cRyikEWruPFfC9Oi4EkTZShENltDdjpbzmojePVgz07FsBfEqhCD3qVmoNiQmh7ZG', 'M├│nica Granada', NULL, NULL, '(La portada de referencia no es m├¡a y realmente no s├® de qui├®n ser├í jeje) me gustar├¡a que mi portada fuera as├¡, pero que en el fondo hubiera una sombra de un gato y un hombre d├índose la espalda (como si el gato y el hombre fueran la misma persona) ya que ├®l se convierte en hato. Me gustar├¡a que tambi├®n tuviera un bordo as├¡ parecido al de la imagen y que en una esquina estuviera el logo de Wattpad.   El t├¡tulo de la historia es: Antes de ser gato.', '', NULL, 0, '[{"urlImg":"https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F8376f717-1ed9-47ef-b7a7-7dc15dd81c09?alt=media&token=f328ebed-5bf0-4cab-9255-04d7255c2a12","createdAt":"2021-05-29 09:54:39"}]', NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2F2a68e73c-20cb-41cb-a53a-627180df7def?alt=media&token=0a3b8abb-1b20-435b-83c5-606c13d975a7', 0, 0, 0, 0, 1, '2.2', '2021-05-29 09:54:39', '2021-05-31 11:33:27'),
(DEFAULT, NULL, 'Bcaroyaranga@gmail.com', 'Brenda Caro', 27, '+51902717018', 'WSP', 120, '2021-03-18 11:41:36', '2021-03-21 11:41:36', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Amor Entre Guerra', 'https://www.wattpad.com/story/213016348?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=brenda_yurico&wp_originator=ixKqlESP4I4BXtrAvWfBQEHbEHcftDY1SNctZiW6n%2BqsOBJpktCDZ%2BRIVUFcXjRF79yxKRwHCMgxlsncyUmXJgmkOy4Cu8BYjNtc7BBqe1v5ux63X%2Bh%2Fp9EYjqdpYf40', NULL, 'Mi historia trata de un romance que surge en la segunda guerra mundial. Entre un jud├¡o y un soldado alem├ín.', NULL, 'Lo que deseo transmitir que a pesar del dolor siempre hay algo que te motiva a vivir y que te hace cambiar.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/1578c4e7-f4d1-4b09-a311-45a96592aa4e.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=vyoPtkic%2FmprgKKrlYEsonuqdwQx%2FjKMT8uDc8v0qZdrEu8yp9D9gqrX0t7de0OuX95yrw7v0LSOQCLmbS55uQVl6VbjnBAodoZqySP83abvdKssYcVubS58wLFgn%2F6MnssDUDh5hQHNeUa9EPCfRA3q1HPCypPld216mIi8Ua5ZpBzoWhsslp4K%2FfrF9YAORRL7NtQ9p61%2Bh%2BPOIW0OCnAO7LkkuD6pOthlm%2FrUbtzr%2B2wM8Zyw%2BIcc4OYtq20jQR1aRcgi1l9T4lbwzLraFSwtlZDkBntdMCpTGxm5F%2Fxr5HnPO2JJEEdy83c0OQ8drYqjcviRWPsmUfEXppY2Mw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-27 11:55:55', '2021-03-18 15:40:01'),
(DEFAULT, NULL, 'corderojhc@gmail.com', 'Jonathan Cordero', 29, '+5804128446516', 'WSP', 62, '2021-04-06 01:31:38', '2021-04-13 01:31:38', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El llanto del ni├▒o', 'https://www.wattpad.com/story/220640968?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=ElDeLasLetras&wp_originator=2vYWps2Li2SD2X53Pi71GukECbcf5Kk%2FhWJjkz%2BVkk7KdB50m3lmRjx8BJO02wW8PbMivC9tzLpXzN0jMcymQO0EpnrfWN8yCUDGCY2UPhsQGwmjE3%2F0VMGkrG8iwbFb', NULL, 'Una corta historia de terror, misterio y suspenso.', NULL, 'Miedo, temor. Entretenimiento.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/3aea7028-50f8-418c-91eb-7e46238495a4.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=0FGrAmSAhN99Z9Wzzsg3ghYKo%2Bt6TVXXSAdWug80Tq3SxZ02jeFuUoHePcjpRL13HT8jjMYeMVThrxkTPjF6qu3bG0zWAci9sEY5XL0xR4mGg2elSDv%2B%2FNZQwFYdPeBZyaCWticBGINbJAdvaT6CHzh9UEEiOkFCHnlvZtjnlHdB3WpADyONfQ7sWcmWDoWDfu6fRKmlmluLEg1OY6icLLFcj7OhBQMRwVrO0MNfjJVuUbEGIcB1IBnarNHHFbWlVpCA0SYqLfH%2BhNEKlzhcbKpxPnl8h3sHdBwRnbRIyT3U7KvPZxcxd0bdCIYNRY5mU7H0DjvFuqZMhurC9ATzoA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 13:07:41', '2021-04-06 19:44:58'),
(DEFAULT, NULL, 'sinsajoeverdeen100@gmail.com', 'Abisai Jim├®nez', 20, '+52 922 227 6959', 'WSP', 64, '2021-03-09 15:28:39', '2021-03-12 15:28:39', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'IMPOSSIBLE LOVE', 'https://www.wattpad.com/story/191801046?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=SinsajoEverdeen100&wp_originator=WpLHKxdD9vbzweoeFu1uLO0RHHDxntBpka%2F87HaLjhRsz8uwX3Os%2Bq9p9jBUzxyFj875iZZDWSNiLH%2F9PPcgkPV0O3JwPWncFBlBou%2FTnSQkpiMZ2UOkmfZdycrHi6A1', NULL, 'Mi obra trata sobre el enamoramiento de un chico hacia una chica y c├│mo es que sus inseguridades lo limitan mucho.', NULL, 'Deseo transmitir lo que algunos chicos con baja autoestima hemos experimentado cuando nos enamoramos y el sentimiento de ser insuficientes. El hecho de poner en un pedestal a alguien y que pese a todo tambi├®n podemos amar incondicionalmente', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/0703c6fd-fd9a-433c-a548-875bdfb0ab7e.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=1EyUxVDs0jmlZiZBc3qzpI2KYxVvUrPF7dqMl0pTrjQzmPE7LJgxcP0ka9QrtTchnPfRpUNdbaR6tO1fP6CqLYujVe7pqZc%2BkXDbFuqZd6y%2BYNbWXQKUh%2F0HSkLy1Gevo228Vi3GSdcPkYC7D9WRmOlhGJSP50CGX1%2Bs1hg47bDHyRtWZvvwoagLcYshekzBLl5NNQBK6jbQC0RbuwXiYGX4YM%2B5bSRgtyoT6FnHw54rURetwx%2FoZMqDGKtcP%2Bv%2BcidbUXEa4fvL3rwFMXf%2F%2FwZUa5wFQHOux9zvUDtwU%2Bv%2BT8P8lRdC5ZVFe7rsjkObEJIsPTfVOHo3ToHrrDSvqw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-08 20:02:23', '2021-03-30 01:22:24'),
(DEFAULT, NULL, 'ThardysVelarde@gmail.com', 'Thardys Velarde', 20, '+52 2461784533', 'WSP', 60, '2021-04-21 17:51:28', '2021-04-28 17:51:28', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Force and Blood', 'https://www.wattpad.com/story/211445396?utm_source=android&utm_medium=link&utm_content=share_reading&wp_page=library&wp_uname=Thardys&wp_originator=bgxl3UxfyxdBMusq9y0EKP%2FPP8bdU0QUfZy3uHCU74Ks69tIKANKhYRgY%2FJtA89CarOL%2BhFodCPvQJCC51hrZZ1R5GSQOz1AVcSs7wWm8rAat6wCENTa7OVaDWiAEHdZ', NULL, 'Es un fanfic de Star Wars basado en la trilog├¡a de precuelas de la saga.', NULL, 'Es una historia de romance, identidad y poder.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/150f89cd-3a49-4194-a4c4-c77fafc25f06.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=GYFo1x67phE1OIDVmEpKrw3ThcvQUvI8uZXfn4d6R%2FVLHbk%2Bzp7lNOR%2FOE3OIOfjp2gXaQl2OXyPGndUtIIoRDLrpJaEeVjpzgR79y0dDDpABQgiJkcKYRwiKTiLxBQiOE1iG9CmMLxHAqIeBnJk3tnNZVqCKR3YH7M8MmJTzc8yli5ATVwvZeChU30zkD55T53HYd3yanNRBdjuNJIrcrySGresfTz8HEL1TDCpXi7gpydfS5xhJHFLlGW%2Bvh1S4KgnrbfJYj3yVptNmWvYbbjMmKE%2BEATg2Xt5AIIRcRG44b6elueR1di4WCNpGIMd2aFpXYsJ0AwmciRRGSRujw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 20:28:09', '2021-04-26 10:45:24'),
(DEFAULT, NULL, 'ariaswarias@gmail.com', 'Wilian Arias', 33, '323 617 7797', 'WSP', 64, '2021-03-05 12:34:28', '2021-03-08 12:34:28', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'La Novia de Negro', 'https://www.amazon.com/-/es/gp/aw/d/061599248X/ref=tmm_pap_title_0?ie=UTF8&qid=&sr=', NULL, 'Mi obra trata sobre los buenos sentimientos,  las herencias que van m├ís all├í de patrimonios a los odios. Tambi├®n toca temas de ni├▒os en orfanatos,  mujeres enga├▒adas que debido a diferentes situaciones terminan renunciando sus hijos.', NULL, 'Deseo transmitir uni├│n familiar,  los buenos h├íbitos como la lectura,  reactivar los valores en nuestras sociedades.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6b6ba8af-e172-4f11-b48b-b7edc07cc3f5.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=a60OFRM6ZsJuMMjVsZfthxduJ6zIvk9RH3pJYGTR62ERTgnn1ZGWgBfSiODYldEBJApmmuYwlpxO0rpKRIx3B4mjFXiARhFbHz1we7%2FxBwjYpzAWnFP9q8HStNqMu9s2pJ3GD%2BhEiTiEgR6QoIJ179waTYBOtgObCuaQFat%2BRGfLcmmo2coh9XCrI%2BO8L%2F4lzmOAXjoRWWJaasejHExqCKaOUpq9rygSRVIRlW0i2SCkRgC4W%2BWpF1wvLzcC6DtP49aN1YwLByC8wC%2FCwa5ep1HY2V4auFsN4NOjhR0qAFbu93QU74MhCrdp4kxDWzba4CkX411JhufgLjXQ7JNdAw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 00:10:59', '2021-03-07 14:55:09'),
(DEFAULT, NULL, 'eduardoaguilar0002@gmail.com', 'Iv├ín Aguilar', 20, '+52 55 24 91 81 26', 'WSP', 68, '2021-04-12 21:39:34', '2021-04-19 21:39:34', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El bardo', 'https://www.wattpad.com/story/260457033', NULL, 'Fantas├¡a ├®pica, se trata de viajes; viajes que hacemos para probarnos a nosotros mismos', NULL, 'Todo lo que una gran obra puede tener, desde diversi├│n, momentos emotivos, tristeza y romance.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/4c06eb09-df0e-4a25-a7a6-bafa956757e3.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=0qg6FMg267jEyUYotYgniAlzUwR8%2Fi6yCefAaJIS8zxRyDALdA1hsG%2FLZ7dttRYYyw5ya4fDavMfki0hH%2BImQ0yGNFs3V6yerUTRp7vXq7IBze0DuGfADhjEytSjS2EfqrTvnIguLBucMpe%2FH%2F3nLOfDwmNhdZDghhG1eFPYqxez3CwalFg%2B33R%2FW6ytwPvzk4VMxPbcZ5fkQY1fOQMYdJhd%2FrVtr9mn2LcpeW8ZBRLrBp1XP2GECnAsZasfGNZBeLu1NtGl2Vbny%2FHJkxFtev8bq%2FJgJMsCclfZjXyCMfRKxGoMDxA7ANNpGTN8lMD%2BkCvJOIZ%2BZLn%2BXd52sv4Epw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-04 01:15:59', '2021-05-04 12:36:22'),
(DEFAULT, NULL, 'viqui2266@gmail.com', 'Virginia Desiree Weber', 28, '5493435042383', 'WSP', 120, '2021-03-11 11:32:21', '2021-03-14 11:32:21', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'El Pecado de Ivania', 'https://www.wattpad.com/story/242114064?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=AinhoaVW&wp_originator=Shw3lAwiyqwl1zKXWy%2BDbIN2M5cGOnyB03QiccHDnhdqYx9yGNwSnDxtKCf0R%2FST0qqByxXue032cm6%2F20zNJaL2YxKZInYHZKZKznfJqXeLsfUQtvc9GHX9%2F07injwG', NULL, 'Mi historia se basa en el trabajo de una agente, Ivania, en la CIA y en su vida amorosa y afectiva que se ve trastocada cuando ingresa como su superior, Brandon.', NULL, 'Es una historia para nada clich├®, intento transmitir los errores que d├¡a a d├¡as cometemos las personas, relaciones de amistad y amor t├│xica, triangulo amoroso, mucha acci├│n ya que realizan trabajo encubierto, muerte...', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/6e2197a1-96b4-48a5-97d8-bd2813edcec1.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=wtaAoohLDbrJjoqCm7sUstf973ejsXY6r866iUBrRABuPzcLwNUP%2Bdx2Gnxkl%2BITa%2BoxlfWHc93QJzLNW0s%2BJTOMYlDz7nd3bvlAchOHWUiYtlah1aPsXFFHz7sPjNmsxAvOq5NRLTtgDBcBIXuhUzHB%2FXAon7azC7ksbyeGADDYJ2tV8DWFktX2KEDlcOzdNopz0U2hQD%2FCZ6mTFpu%2BT04HSG3Z6Ox3zhO4lQtzGYLlgGpqdLIQx0zwI2Tob9J1r64bXWHSn%2FpsUMlgFn3Oc%2FdXbyy0zihd%2BeUjpJ%2BMHiCgi%2BaWfA1j2KRLzJiTR4hJyk5iDGCp4VvWyS7Wszm2fQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-02-28 12:58:03', '2021-03-11 21:41:48'),
(DEFAULT, NULL, 'arenamcr@hotmail.com', 'Arena', 24, '961762582', 'WSP', 62, '2021-04-03 18:35:02', '2021-04-10 18:35:02', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'S├¡n titulo', 'https://www.youtube.com/watch?v=lmO6psCTVxU', NULL, 'No hay texto de inserto, solo pasaba a decirte lo mucho que te extra├▒o y amo.', NULL, 'Apagarlo en todo sentido.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a0820909-c832-4d73-ae84-ec4accbc9a6f.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=jkZ4ejZHLFCcT14WxGdSVansSHM8KqYup2ahTdWN3O8cscqtuHJ1aH9EXIa2spw9ApRa0%2FCNAmRmMO%2F5Cm4CIIqaKFhp8S056TsB55Z4bhP%2BVU87rtkpBSjaNXZH11aMbZ%2BK3%2Fu4cotRajb3dgmBcfwta8kR%2BGhSaTHUORNcaA%2FpIpqnfGL6ZYBGKeTuPSMHP5U8FM6JrTgtm1oPHbE3f5gNFGIsuwd4zcFRZxySbCFHtpMVj9mu2xbZS855jcD6dYWxhBUOL7EDb2eJ%2B1YewYvkclm4qXJxpPJeNe4dXbbomfOVJxFFw1IydwVlFhiERJ9C32S3g0Qrz5W1K0evwA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-02 22:44:56', '2021-04-03 18:49:57'),
(DEFAULT, NULL, 'little_dhampir17@hotmail.com', 'Annabella Giovannetti', 26, '+528123098439', 'WSP', 67, '2021-04-02 12:20:37', '2021-04-09 12:20:37', NULL, 1, 'DISENO', 'POR', 'HECHO', NULL, NULL, 'Cuando descubres la maldad que existe en el mundo, no vuelves a ser la misma persona', 'https://www.wattpad.com/story/2191203?utm_source=ios&utm_medium=link&utm_content=story_info&wp_page=story_details&wp_uname=AnnabellaG&wp_originator=gL8cxNbxlWWvorornlmdZrdMaMvPpkMFiU%2FMTOBoi57I7WHHsdlISkwTM3ZWJwU2762t7b%2BaNSSC04c7k6nPlZsJoD0gyxZUsvUDNKwrvIEX%2BqcuCAcEdyYItkww1a1P', 'Annabella Giovannetti', NULL, NULL, 'Quisiera transmitir el misterio de la protagonista y su sensualidad. Cuestiones que est├ín ocultas tras el antifaz que usa cada noche cuando baila.', '', NULL, 0, NULL, NULL, '{"composition":"LIBRE","typography":"","style":"LIBRE"}', 1, 'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/solicitud-diseno%2Fec0dbd2a-8640-4ea6-8ad6-8576f9f987b3?alt=media&token=27f97bd8-e4b6-4669-ba14-cfc983841b48', 0, 0, 0, 0, 1, '2.2', '2021-04-02 01:03:18', '2021-04-02 15:53:17'),
(DEFAULT, NULL, 'ximenarosianapd@gmail.com', 'Ximena Peralta', 23, '', 'WSP', 64, '2021-03-05 12:31:01', '2021-03-08 12:31:01', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Close to you', 'https://www.wattpad.com/story/251337802-close-to-you', NULL, 'Trata de Lam Visanet de Leire y Bendt, dos estudiantes que pareciera ser felices con l o que tienen y dispuestos obtener la beca universitaria en su ultimo a├▒o decir colegio. Pero ambos fingen que todo est├í bien, que no le atormenta cosas de pasado, que la presi├│n social, culpa, arrepentimiento y traumas y puede o no que sea un impedimento para que el ÔÇ£amorÔÇØ entre ellos funcione.', NULL, 'Deseo transmitir angustia por lo desconocido, felicidad de a ratos, atracci├│n f├¡sica y odio hacia las acciones de algunos de mis personajes.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/383d2ff4-1e0b-49de-801e-b540f5b1b49b.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=FivzqRNkf26KMe1QfH5SXy16hlG2rlfATy1N7lURmAHekI3ibDas7JlfOnAOgutO8nfO1bpRv5CTkFMSH6apFuTPJkB%2FWJaAmq1HPCzjz4fIAyI36WlBx8nIT2Pqf5nI8i%2BojiS%2FF2RHZpGbFmuCoYhkdt1ieCfZiqC%2BDwWkZD8aPWwwFGMJISKizFdv%2F8E53BFQnzoJMzX87fj6PvjxqXrGtBYFap9t2lLo0OZfgWHLBSjMbJY1uqaDayFytU3ecTHuX671ufV3LgN75JgNFDLu%2FhUbNESnfguULwqu09Xj2P9zpRbTOFLFGMhvvZTKtLiJHaYPPyhVHkXneJ3wuA%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-02 11:41:14', '2021-03-30 01:53:28'),
(DEFAULT, NULL, 'daercimi@gmail.com', 'Daniel', 20, '+51 973198435', 'WSP', 112, '2021-04-30 07:58:44', '2021-05-07 07:58:44', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'After Life', 'https://www.wattpad.com/story/134873784?utm_source=android&utm_medium=link&utm_content=share_writing&wp_page=create&wp_uname=DAN_Cifuentes&wp_originator=Wg6cfCDGMoafyTsAnKJYylcL3OIH6%2BfkX9GfOV11tCppcqwELZDKGdhPa0sa3VLheTvknpw%2B%2F302GyyY67KYFcaqCVMJkFF3uWHj5QZ6HWJg4puFKYRVKADXclxUQF5l', NULL, 'Neoandro es un se├▒or de incontables primaveras y muchos mon├│logos quien en sus ├║ltimos d├¡as se pregunta por la preocupaci├│n de los vivos hacia los muertos.   El anciano se considera un estorbo m├ís que nunca antes y cuando est├í por dejar nuestro mundo se arrepiente cuando ya es muy tarde.   Neoandro, muerto ahora, despierta; pero lo que llega a pasar no es nada de lo que alguna vez imagin├│.', NULL, 'Valoraci├│n de la vida y la muerte. Aceptaci├│n cuando esta llega y la noci├│n de que todos tenemos un momento y lugar.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ORTOGRAFIA","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/a70a1b1e-aa25-40a7-83ba-87ccd83269a1.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=fgI7zTSKvKJe3aQxkE11648%2BopOppswHaNqtdfknyllomL7h19ydqo9slHENKaHB8W5S4fT6UCFvY%2FKOCzbFwM3KfmMk9zSDrLsGVnXCT4kDc44yh0Up2IL7Kwbp9EXxSNGmNGDfKzRZrdFVJ2MnODECaxpFeckYXbnO65sypMCgbCCsppwVU%2F4qlwEnCQvqufegg6Ye6Pn8fe9VB43jfUNoHM1TZl8V1xott61AXBNQbIzX0ar1NgETq5NHO%2B93h4L04XHeIj2kEH%2FaIBTDnM11o2BTh9Ws6DKPp2%2Fdn4Lm8AGgWNp7k3vjfON8xDD%2B3Ma0nDYsINLVNMUbuTgpnw%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-04-01 10:55:47', '2021-05-04 09:11:02'),
(DEFAULT, NULL, 'haru13miyara@gmail.com', 'Jinx', 22, '+1 999999999', 'WSP', 103, '2021-03-02 11:10:48', '2021-03-05 11:10:48', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'GIZA [correcci├│n]', 'https://www.wattpad.com/story/253935190-giza', NULL, 'Mi obra trata sobre un grupo de estudiantes que descubren un portal a una dimensi├│n m├ígica, donde una de sus compa├▒eras de clase es la l├¡der de un reino en contra de su voluntad.', NULL, 'Deseo transmitir la naturaleza de los seres humanos al verse expuestos ante ciertas situaciones como enga├▒os, traiciones, infidelidades, la b├║squeda del beneficio propio y ego├¡smo, adem├ís de sus consecuencias.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/fe271ddc-ff2d-4627-baad-5c4270aca970.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=f0qfSC1WMdmpzAnC6rhkUdx1IWdmnygsLPTnT%2BUk8ZU1P87mGm2ZMezyYTDfQFDm3KWrX5qbXeUodOgrf%2BVnYKjv17UqmRXG8VheGXmkDs8He8hbLI1AgGyKq1ell7av0T3CL8MNmpoieGU5CYoFzo18XN8EoeqQLGlkRTm25P%2B6wvO09Q9kfUMBtv1PJXctSih1ZlB%2F3zvMw26tsCUoiJ8oWhIhA9Be3d0cMObWM9k6LgjshHU1zujh0REQif4kitHwgAc%2F68%2BWDDeSYjMtwRZNsNGQ5crHCbQxC7KEKJr%2B5yK4yMWUMr5bpgJKfy3th%2FD5hFdz20RXcN5IOGMD%2BQ%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-02 11:07:11', '2021-03-02 11:44:09'),
(DEFAULT, NULL, 'gqmafe2@gmail.com', 'Fernanda Guerrero', 22, '+506 71145554', 'WSP', 115, '2021-03-03 13:45:55', '2021-03-06 13:45:55', NULL, 1, 'CRITICA', NULL, 'HECHO', NULL, NULL, 'Traje de Humano', 'https://www.wattpad.com/story/260206409?utm_source=android&utm_medium=link&utm_content=story_info&wp_page=story_details_button&wp_uname=madredemonstruos&wp_originator=DAS0EisCOfXMe9EofD4%2FfkrM1LraVssI5I5R5oRpAZIv9V2bBpXZlMYpawzI%2FmMQsN3ytXobjVa5eoyLmgHv3tcOB5MPTW1equ2ZEzIBxwTx4ST%2B5LRtxn61%2F%2BpfENN8', NULL, 'Es de terror. Se trata sobre un chico enfermo, muy enfermo. Se ir├ín relatando las cosas poco a poco, pero b├ísicamente es de terror.', NULL, 'Realmente de todo. Hay muchas personas que han sentido desde p├ínico a tristeza, incluso han llorado, as├¡ que estoy abierta a cualquier sensaci├│n.', '', NULL, 0, NULL, NULL, '{"critiqueTopics": ["INTENCION","ENGANCHE","ORTOGRAFIA"]}', 1, 'https://storage.googleapis.com/temple-luna.appspot.com/solicitud-critica/86029e15-0c4b-4780-a5e9-c104f7062594.pdf?GoogleAccessId=templeluna%40temple-luna.iam.gserviceaccount.com&Expires=16731014400&Signature=TekJ6S2m0Ou%2F8wLZ2Sz4Sbf23%2FMhGnURDIsdct4bxcPiuMc0lhKO4Zp7%2FQ5Aguotm7aaE2e%2BJUj0E%2B7dau5noZ5DMQ6PpQsvosLI5AseVyoqAq8BIllVX23cFQoYcjWtccUj6SFGTIkr7PlJaCjb8HK845L0RWujbO1WBO4wElODfo991fJfeKxciJse7PW92aOP5rASs7gxLAcsICIYq6uOx38lJ5YjIznIF9XJNIRbo2Us5DpmjbnvbSKCxA%2FnaNhlEWqcfaFr%2BmZ%2BT12OhlI6Yr%2BK46lAvqNASaGpIdiWGFHBmMfnNwjod%2BVdTOwKnwzbOTzxaY8FIy3QSxho4w%3D%3D', 0, 0, 0, 0, 1, '2.2', '2021-03-01 13:30:11', '2021-03-03 19:21:21');

-- Prueba de crítica para Axel Chacón
-- Actualizo el rol de Axel
UPDATE USERS SET roleId = 'COLAB' WHERE id = 101;

-- Agrego a Axel a la editorial Temple Luna
INSERT INTO EDITORIAL_MEMBERS VALUES 
(101, 1, 'COLAB', NULL, DEFAULT, DEFAULT, DEFAULT, DEFAULT);

-- Les asigno el rol a Axel
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(101, 1, 'CRITICA', NULL, 'Artista', 1);
INSERT INTO EDITORIAL_MEMBER_SERVICES VALUES
(101, 1, 'DISENO', NULL, 'Artista', 1);

-- Inserto la revista de octubre 2021
INSERT INTO MAGAZINES VALUES 
(DEFAULT,
'Para los que ya no están',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2Fpreview-revista-2.PNG?alt=media&token=f47222f9-5565-40d9-b1e5-d93caf8907cc',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FRevista-TL-2_compressed.pdf?alt=media&token=de30ff12-891a-4a56-bf73-fa65b4e682e3',
'https://firebasestorage.googleapis.com/v0/b/temple-luna.appspot.com/o/revista%2FRevista-TL-2.pdf?alt=media&token=f7326ad1-50a5-4764-a913-e7d2f5634a67',
27,
1,
11,
2021,
1,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
DEFAULT,
'PARA-LOS-QUE-YA-NO-ESTAN-1-2021',
DEFAULT, -- activo
DEFAULT,
DEFAULT
);

--

-- call USP_GET_MAGAZINE_SUBSCRIBERS;
SELECT*FROM USERS WHERE roleId = 'COLAB';
SELECT*FROM USERS WHERE email = 'shanydubi@gmail.com';
SELECT*FROM ORDERS;
SELECT*FROM MAGAZINES;
USE TL_PROD;