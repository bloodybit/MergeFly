/*
  SHARED EVENT DATABASE
  TABLES:
   1 -  users
   2 -  groups
   3 -  members
   4 -  events: an event created by user
   5 -  categories
   6 -  documents: written by users during an event
   7 -  nodes
   8 -  notes
   9 -  places: an event location
  10 -  partecipation: user's partecipation to events

  NOTE:
    1 - In mysql we can only have one table with CURRENT_TIMESTAMP as default (or on update value)
    for a timestamp value. (I don't know why though)

    2 - first step, after you have switched on the MySQL server,
    type: /Applications/MAMP/Library/bin/mysql --host=localhost -uroot -proot

    3 - A check statement inside a table is parsed but not ignored because it is not supported by mySQL

    4 - Cascade doesn't activate triggers.

    5a - Enter the DB: /Applications/MAMP/Library/bin/mysql --user= <user> --password= <user-password>;

    5b - Enter the DB: /Applications/MAMP/Library/bin/mysql --user=user --password=user-password;
    /Applications/MAMP/Library/bin/mysql --user=root --password=root;
*/

/* Database cretion */
CREATE DATABASE IF NOT EXISTS merge;
-- USE polleg_it;
USE merge;

/******************** TABLES ***********************/

/* USERS */
CREATE TABLE IF NOT EXISTS users (
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  lastname VARCHAR(100) NOT NULL,
  born DATE,
  subscriptiondate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type ENUM('basic','premium','admin') DEFAULT 'basic',
  image_profile VARCHAR(300),
  latitude DECIMAL(11,8), /* it must be defined */
  longitude DECIMAL(11,8), /* it must be defined */
  password VARCHAR(300) NOT NULL,
  mail VARCHAR(150) NOT NULL,
  deleted  ENUM('0','1') DEFAULT '0',
  PRIMARY KEY (id)
) engine=INNODB;

/* GROUPS */
CREATE TABLE IF NOT EXISTS groups(
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  creationdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  image VARCHAR(300),
  description VARCHAR(2000) NOT NULL DEFAULT "No description.",
  PRIMARY KEY (id)
) engine=INNODB;

/* PLACES */
CREATE TABLE IF NOT EXISTS places (
  id INT(11) AUTO_INCREMENT,
  latitude DECIMAL(11,8),
  longitude DECIMAL(11,8),
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  cap VARCHAR(10),
  city VARCHAR(50) NOT NULL,
  nation VARCHAR(50) NOT NULL DEFAULT "Italy",
  PRIMARY KEY (id)
) engine=INNODB;

/* CATEGORIES */
CREATE TABLE IF NOT EXISTS categories (
  name VARCHAR(100) NOT NULL,
  description VARCHAR(3000),
  colour VARCHAR(7),
  PRIMARY KEY (name)
) engine=INNODB;

/* NOTES */
CREATE TABLE IF NOT EXISTS notes (
  id INT(11) AUTO_INCREMENT,
  type ENUM('code','text', 'image', 'link') DEFAULT 'text',
  title VARCHAR(300) DEFAULT "Note title",
  content TEXT,
  description VARCHAR(200),
  creationdate timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(id)
) engine=INNODB;

/* MEMBERS */
CREATE TABLE IF NOT EXISTS members(
  user_id INT(11) NOT NULL,
  group_id INT(11) NOT NULL,
  accepted BOOLEAN DEFAULT 0,
  role ENUM('admin','normal') DEFAULT 'normal',
  joindate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, group_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
) engine=INNODB;

/* EVENTS */
CREATE TABLE IF NOT EXISTS events (
  id INT(11) AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  place_id INT,
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  startdate DATE,
  stopdate DATE,
  creator_id INT,
  type ENUM('public','private') DEFAULT 'public',
  description VARCHAR(2000),
  category_name VARCHAR(100) default 'Meeting',
  PRIMARY KEY (id),
  FOREIGN KEY (place_id) REFERENCES places(id),
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (category_name) REFERENCES categories(name) ON DELETE SET NULL
) engine=INNODB;

/* DOCUMENTS */
CREATE TABLE IF NOT EXISTS documents (
  id INT(11) AUTO_INCREMENT,
  creator_id INT,
  name VARCHAR(100) DEFAULT "unknown document",
  event_id INT,
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  public ENUM('0','1') DEFAULT '1',
  PRIMARY KEY (id),
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL

) engine=INNODB;

/* NODES */
CREATE TABLE IF NOT EXISTS nodes (
  document_id INT(11),
  note_id INT(11),
  creationdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (note_id, document_id),
  FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
) engine=INNODB;

/* PARTECIPATIONS */
CREATE TABLE IF NOT EXISTS partecipations (
  event_id INT(11) NOT NULL,
  user_id INT(11) NOT NULL,
  status ENUM('accepted','declined','waiting') DEFAULT 'waiting',
  PRIMARY KEY (event_id, user_id),
  FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) engine=INNODB;

/******************** VIEWS *************************/

CREATE VIEW usersInfo(id, name, lastname, born, subscriptiondate, type, image_profile, mail) AS
  SELECT id, name, lastname, born, subscriptiondate, type, image_profile, mail FROM users WHERE deleted="0";

CREATE VIEW eventsInfo(event_id, event_name, type, creationdate, startdate, stopdate, event_description, creator_id,
  creator_name, creator_lastname, place_id, place_name, address, cap, city, nation, latitude, longitude, category_name, category_description, category_colour) AS
  SELECT evnt.id, evnt.name, evnt.type, evnt.creationdate, evnt.startdate, evnt.stopdate, evnt.description,
         usr.id, usr.name, usr.lastname, plc.id, plc.name, plc.address, plc.cap, plc.city, plc.nation, plc.latitude, plc.longitude,
         evnt.category_name, cat.description, cat.colour
  FROM events AS evnt, places AS plc, usersInfo AS usr, categories AS cat
  WHERE ( (evnt.place_id = plc.id) AND (evnt.creator_id = usr.id) AND (cat.name = evnt.category_name) );

/******************** TRIGGERS **********************/

/* 1 - check_user
  Checks the user date of birth
  Checks the mail format
  Checks if the mail is duplicated
*/
DELIMITER //
create trigger check_user
BEFORE INSERT ON merge.users
FOR EACH ROW
BEGIN
  -- CURRENT_TIMESTAMP() - UNIX_TIMESTAMP(NEW.born) > 1009846861  -- 14yo in timestamp
  IF (NEW.born IS NULL) OR ( (YEAR(CURRENT_TIMESTAMP()) - YEAR(NEW.born) - (DATE_FORMAT(CURRENT_TIMESTAMP(), '%m%d') < DATE_FORMAT(NEW.born, '%m%d'))) < 14 )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Age must be more than 14 yo";
  END IF;

  IF ( (NEW.mail NOT REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$' ) OR (NEW.mail = ANY (SELECT usr.mail FROM users AS usr WHERE usr.deleted = "0")) )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Invalid email address";
  END IF;
  -- random image if no profile image is provided
  IF (NEW.image_profile IS NULL) THEN
    SET NEW.image_profile = CONCAT("http://api.randomuser.me/portraits/men/", CONVERT(FLOOR(RAND() * 10), CHAR(3)) , ".jpg");
  END IF;

  IF (CHAR_LENGTH(NEW.password) < 8) THEN
    SIGNAL sqlstate '45000' SET message_text = "password must be at least 8 char long";
  END IF;
END //
DELIMITER ;

/* 2 - check_event_creation
  - Checks the if the creation date is correct
  (it can be omitted since we use a stored procedure and set creation with current_timestamp)

  - Checks if the email provided by the user is correct.

  - Check if the startdate comes before the stopdate
*/
DELIMITER //
create trigger check_event
BEFORE INSERT ON merge.events
FOR EACH ROW
BEGIN
  IF ( (NEW.creationdate IS NULL) OR (NEW.creationdate > CURRENT_TIMESTAMP()) )
  THEN
      SIGNAL sqlstate '45000' SET message_text = "Invalid creation date";
  END IF;

  IF ( NEW.startdate > NEW.stopdate )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Date interval is not correct";
  END IF;

  IF ( NEW.category_name IS NULL )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "you should specify a category";
  END IF;

END //
DELIMITER ;

/* 3 - check_admin
  When an admin leaves a group, it replaces the admin with the first member who has joined the group.

  INFO: we have removed this trigger since it has a conflict with a related stored procedure.
*/
/*
DELIMITER //
create trigger change_admin
AFTER DELETE  ON merge.members
FOR EACH ROW
BEGIN
  IF ( OLD.role = "admin" )
  THEN
      UPDATE members SET role = "admin"
      -- it should call update admin
      WHERE (group_id = OLD.group_id) AND (user_id = (SELECT user_id FROM members WHERE group_id = OLD.group_id HAVING min(joindate)));
  END IF;
END //
DELIMITER ;
*/


/* 4 - check_note
  Checks if an image note or a link note has the description associated
  (NECESSARLY?)
*/
DELIMITER //
create trigger check_note
BEFORE INSERT ON merge.notes
FOR EACH ROW
BEGIN
  IF ( (NEW.type = "image" OR NEW.type = "link") AND (NEW.description IS NULL) )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "You must provide a description";
  END IF;
END //
DELIMITER ;

/* 5 - check_group
  Checks ...
*/
DELIMITER //
create trigger check_group
BEFORE INSERT ON merge.groups
FOR EACH ROW
BEGIN
  -- random image if no profile image is provided
  IF ((NEW.image IS NULL) OR (NEW.image = "null")) THEN
    SET NEW.image = CONCAT("http://lorempixel.com/200/200/sports/", CONVERT(FLOOR(RAND() * 10), CHAR(2)));
  END IF;
END //
DELIMITER ;
/******************** STORED PROCEDURES **********************/

/* login( mail, password, latitude, longitude )
    Authenticate the user and set his location.
*/
DELIMITER |
CREATE PROCEDURE login( IN mail VARCHAR(150), IN password VARCHAR(300), IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  DECLARE user_id INT default -1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Login error" AS message;
      ROLLBACK;
    END;
  START TRANSACTION;
    SELECT usr.id INTO user_id FROM users AS usr WHERE (usr.mail = mail) AND (usr.password = password) AND (usr.deleted="0") LIMIT 1;
    IF (user_id <> -1) THEN
      call updatePosition(user_id, latitude, longitude);
      call getUser(user_id);
    END IF;
  COMMIT;
END |
DELIMITER ;

/* updatePosition(user_id, latitude, longitude)
  Update a user's position given his id.
*/
DELIMITER |
CREATE PROCEDURE updatePosition(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Error in position" AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
    IF ( (latitude IS NOT NULL) AND (longitude IS NOT NULL) ) THEN
      UPDATE users AS usr SET usr.latitude = latitude, usr.longitude = longitude WHERE (usr.id = user_id);
    END IF;
  COMMIT;
END |
DELIMITER ;

/* getUser(user_id)
  Get user's info.
 */
DELIMITER |
CREATE PROCEDURE getUser(IN user_id INT)
BEGIN
  SELECT * FROM usersInfo AS usr WHERE usr.id = user_id;
END |
DELIMITER ;

/* insertUser(name, lastname, born, type, image_profile, password, mail)
    Insert a User.
*/
DELIMITER |
CREATE PROCEDURE insertUser(IN name VARCHAR(100),
 IN lastname VARCHAR(100),
 IN born DATE,
 IN type INT,
 IN image_profile VARCHAR(500),
 IN password VARCHAR(300),
 IN mail VARCHAR(150))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Error in insert user. " AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
    IF type = 1 THEN
      INSERT INTO users(name, lastname, born, type, image_profile, password, mail)
        VALUES(name, lastname, born, "premium", image_profile, password, mail);
    ELSEIF type = 2 THEN
      INSERT INTO users(name, lastname, born, type, image_profile, password, mail)
        VALUES(name, lastname, born, "admin", image_profile, password, mail);
    ELSE
      INSERT INTO users(name, lastname, born, image_profile, password, mail)
        VALUES(name, lastname, born, image_profile, password, mail);
    END IF;
    SELECT LAST_INSERT_ID() AS last_id;
  COMMIT;
END |
DELIMITER ;

/* userNearEvents( user_id, latitude, longitude, dist )
    Select a number of places filtered by a given distance (in km)
*/
DELIMITER |
CREATE PROCEDURE userNearEvents(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist INT )
BEGIN
  DECLARE userLng DOUBLE;
  DECLARE userLat DOUBLE;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "No position, no party." AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
    SET userLng = longitude;
    SET userLat = latitude;
    -- Get old position if not provided a new one
    IF ( ((userLat IS NULL) AND (userLng IS NULL)) OR ((userLat = 0) AND (userLng = 0)) ) THEN
      SELECT usr.longitude, usr.latitude INTO userLng, userLat FROM users AS usr WHERE (usr.id = user_id) LIMIT 1;
    END IF;
    -- Neither old position nor new position
    IF ( ((userLat IS NULL) AND (userLng IS NULL)) OR ((userLat = 0) AND (userLng = 0)) ) THEN
      SIGNAL sqlstate '45000';
    ELSE
      -- Update Position
      call updatePosition(user_id, userLat, userLng);
      -- Find Events
      SELECT *, ( 6367 * acos( cos( radians(userLat) ) * cos( radians( evnt.latitude ) ) * cos( radians( evnt.longitude ) - radians(userLng) ) + sin( radians(userLat) ) * sin( radians( evnt.latitude ) ) ) ) AS calculated_distance
      FROM eventsInfo as evnt
      WHERE ( (evnt.type = "public") OR ( evnt.type="private" AND evnt.event_id = ( SELECT part.event_id FROM partecipations AS part WHERE part.user_id = user_id)) )
      HAVING (calculated_distance < dist)
      ORDER BY calculated_distance;
    END IF;
  COMMIT;
END |
DELIMITER ;

/* getUserEvents(user_id, which)
    Select events in which the user has been invited to. We can decide wheter
    to get all the set of events or only the next/past ones.
*/
DELIMITER |
CREATE PROCEDURE getUserEvents( IN user_id INT, IN which ENUM('next','past','all') )
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Error in get user events." AS message;
      ROLLBACK;
    END;
  START TRANSACTION;
    CASE which
      WHEN 'next' THEN
        SELECT evnt.*, part.status AS status
          FROM partecipations AS part, eventsInfo AS evnt
            WHERE ( (part.event_id = evnt.event_id) AND (part.user_id = user_id) AND (evnt.startdate > current_timestamp()) );
      WHEN 'past' THEN
        SELECT evnt.*, part.status AS status
          FROM partecipations AS part, eventsInfo AS evnt
            WHERE ( (part.event_id = evnt.event_id) AND (part.user_id = user_id) AND (evnt.stopdate < current_timestamp()) );
      ELSE
        SELECT evnt.*, part.status AS status
          FROM partecipations AS part, eventsInfo AS evnt
            WHERE ( (part.event_id = evnt.event_id) AND (part.user_id = user_id) );
    END CASE;
  COMMIT;
END |
DELIMITER ;

/* searchEvents(user_id, chars)
    Search for all public events or private, if the user has been invited to (or he's the creator).
*/
DELIMITER |
CREATE PROCEDURE searchEvents(IN user_id INT, IN chars VARCHAR(200))
  BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
        SELECT "Generic error" AS message;
        ROLLBACK;
      END;

    START TRANSACTION;
      -- search (1) public events (2) partecipation
      (SELECT evnt.* FROM eventsInfo AS evnt
        WHERE ( (evnt.type="public") AND (evnt.event_name LIKE CONCAT('%', chars , '%')) ) LIMIT 6)
      UNION
      (SELECT evnt.* FROM eventsInfo AS evnt, partecipations AS part
        WHERE ( (part.event_id = evnt.event_id) AND (part.user_id = user_id) AND (evnt.event_name LIKE CONCAT('%', chars , '%')) ) LIMIT 6);
    COMMIT;
  END |
DELIMITER ;

/* searchPlaces( chars )
    Search places by name.
*/
DELIMITER |
CREATE PROCEDURE searchPlaces(IN chars VARCHAR(200))
  BEGIN
    -- search
    SELECT plc.* FROM places AS plc
      WHERE ( (plc.name LIKE CONCAT('%', chars , '%')) OR (CONCAT(plc.address, " ",plc.city) LIKE CONCAT(TRIM(chars) , '%')) ) LIMIT 6;
  END |
DELIMITER ;

/* suggestedEvents()
  Suggest some public events 5km nearby.
*/
-- DELIMITER |
-- CREATE PROCEDURE suggestedEvents(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
-- BEGIN
--   SELECT evnt.*, ( 3959 * acos( cos( radians(latitude) ) * cos( radians( evnt.latitude ) ) * cos( radians( evnt.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( evnt.latitude ) ) ) ) AS distance
--   FROM eventsInfo AS evnt, partecipations AS part
--   WHERE (evnt.type= 'public') AND (part.event_id= evnt.event_id) AND (part.user_id= user_id)
--   HAVING (distance < 5)
--   ORDER BY distance;
-- END |
-- DELIMITER ;

/* suggestedPlaces(latitude, longitude, dist)
  Resturns a set of suggested places based on the user's position.
*/
DELIMITER |
CREATE PROCEDURE suggestedPlaces(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist DECIMAL(11,8))
BEGIN
  SELECT plc.* , ( 6367 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM places as plc
  HAVING ( calculated_distance < dist )
  ORDER BY calculated_distance;
END |
DELIMITER ;

/* updateUser(id, name, lastname, born, image_profile, mail)
  Update the trustworty information only.
*/
DELIMITER |
CREATE PROCEDURE updateUser( IN id INT,
 IN name varchar(100),
 IN lastname varchar(100),
 IN born date,
 IN image_profile varchar(300),
 IN mail varchar(150))
BEGIN
  UPDATE usersInfo AS usr
    SET usr.name = name, usr.lastname = lastname, usr.born = born,
      usr.type = type, usr.image_profile = image_profile, usr.mail = mail
         WHERE usr.id = id;
END |
DELIMITER ;

/* upgradeUser(user_id)
  cahnge the grade from basic to premium.
*/
DELIMITER |
CREATE PROCEDURE upgradeUser(IN user_id INT)
  BEGIN
    DECLARE type VARCHAR(100) DEFAULT "";
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
        ROLLBACK;
      END;

    START TRANSACTION;
      SELECT usr.type INTO type FROM usersInfo AS usr WHERE usr.id = user_id;
      IF type="basic" THEN
        UPDATE usersInfo AS usr SET usr.type="premium" WHERE usr.id=user_id;
      ELSEIF type="premium" THEN
        SELECT "You are already premium" AS message;
        SIGNAL sqlstate '45000';
      ELSE
        SELECT "User error" AS message;
        SIGNAL sqlstate '45000';
      END IF;
    COMMIT;
  END |
DELIMITER ;

/* changePassword(user_id, old_password, new_password)
  Change the password for the specified user.
*/
DELIMITER |
CREATE PROCEDURE changePassword(IN user_id INT, IN old_password VARCHAR(300), IN new_password VARCHAR(300))
  BEGIN
    UPDATE users AS usr SET usr.password= new_password WHERE ( (usr.id= user_id) AND (usr.password= old_password) );
  END |
DELIMITER ;

/* deleteUser(user_id)
  Fake user deletion: set a "deleted" variable true
*/
DELIMITER |
CREATE PROCEDURE deleteUser(IN user_id INT)
  BEGIN
    UPDATE users AS usr SET usr.deleted="1" WHERE usr.id=user_id;
  END |
DELIMITER ;

/* damnatioMemoriae( user_id )
  Delate the user from the table.
*/
DELIMITER |
CREATE PROCEDURE damnatioMemoriae(IN user_id INT)
  BEGIN
    DELETE FROM users WHERE users.id= user_id;
  END |
DELIMITER ;

/* getEvents()
  Gets all events.
*/
DELIMITER |
CREATE PROCEDURE getEvents()
BEGIN
  SELECT * FROM eventsInfo;
END |
DELIMITER ;

/* getEvent( user_id, event_id )
  Return Event, Creator and Place info.
*/
DELIMITER |
CREATE PROCEDURE getEvent(IN user_id INT, IN event_id INT)
BEGIN

  -- Verify user partecipation
  DECLARE presenza INT default 0;
  DECLARE type VARCHAR(20) default "private";
  DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
  -- Transaction
  START TRANSACTION;
    SELECT COUNT(*) INTO presenza FROM partecipations AS part WHERE (part.user_id= user_id) AND (part.event_id= event_id);
    SELECT evnt.type INTO type FROM eventsInfo AS evnt WHERE evnt.event_id = event_id;

    IF ( (presenza = 1) OR (type = "public") ) THEN
      SELECT evnt.id AS event_id, evnt.type AS event_type, evnt.name AS event_name, evnt.description AS event_description, evnt.creationdate, evnt.startdate, evnt.stopdate,
      evnt.category_name, evnt.place_id, plc.name AS place_name, plc.latitude, plc.longitude, plc.address, plc.city, plc.cap, plc.nation,
      evnt.creator_id, usr.name AS creator_name, usr.lastname AS creator_lastname, usr.image_profile AS creator_image_profile, part.status AS status
      FROM events AS evnt, places AS plc, usersInfo AS usr, categories AS cat, partecipations AS part WHERE ( (evnt.creator_id = usr.id) AND  (evnt.place_id = plc.id) AND (evnt.id = event_id) AND (evnt.category_name = cat.name) AND (part.event_id = evnt.id));
    ELSE
      SELECT "You are not a partecipant!" AS message;
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;

/* addPlace()
  Add a place.
*/
DELIMITER |
CREATE PROCEDURE addPlace(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN name VARCHAR(100), IN address VARCHAR(200), IN cap VARCHAR(10), IN city VARCHAR(50), IN nation VARCHAR(50))
BEGIN
  DECLARE lastid INT DEFAULT -1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

  START TRANSACTION;
    INSERT INTO places (latitude, longitude, name, address, cap, city, nation) VALUES (latitude, longitude, name, address, cap, city, nation);
    SET lastid= last_insert_id();
    SELECT lastid;
  COMMIT;
END |
DELIMITER ;

/* similarPlaces()
  Return the places nearby the new place coordinates (maybe the place to add is already inside the db).
*/
DELIMITER |
CREATE PROCEDURE similarPlaces(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  -- Get all the places in 1 km
  SELECT plc.*, ( 6367 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM places AS plc
  HAVING calculated_distance < 1
  ORDER BY calculated_distance;
END |
DELIMITER ;

/* addEvent(name, description, place_id, startdate, stopdate, creator_id, event_type)
  Check if the user has the permission to create a private event.
  If there are no problems, it creates the event
*/
DELIMITER |
CREATE PROCEDURE addEvent(IN name VARCHAR(100), IN description VARCHAR(2000), IN place_id INT, IN startdate DATE, IN stopdate DATE, IN creator_id INT, IN event_type VARCHAR(20), category_name VARCHAR(20))
BEGIN
  DECLARE lastid INT DEFAULT -1;
  DECLARE user_type VARCHAR(20);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "A basic user can't create private events!" AS message;
    ROLLBACK;
  END;
  START TRANSACTION;
    SELECT usr.type INTO user_type FROM users AS usr WHERE usr.id = creator_id;

    IF event_type = "private" AND user_type = "basic"
    THEN
      SIGNAL sqlstate '45000';
    ELSE
      INSERT INTO events (name, place_id, startdate, stopdate, creator_id, type, description, category_name)
        VALUES (name, place_id, startdate, stopdate, creator_id, event_type, description, category_name);
      SET lastid = last_insert_id();
      SELECT lastid;
    END IF;
  COMMIT;
END |
DELIMITER ;

/* updateEvent()
  Update event infos.
*/
DELIMITER |
CREATE PROCEDURE updateEvent(IN event_id INT, IN name VARCHAR(100), IN place_id INT, IN startdate DATE, IN stopdate DATE, IN creator_id INT, IN type VARCHAR(10), IN description VARCHAR(2000), IN category_name INT)
BEGIN
  UPDATE eventsInfo SET  eventsInfo.event_name=name, eventsInfo.place_id = place_id, eventsInfo.startdate = startdate, eventsInfo.stopdate = stopdate,
    eventsInfo.creator_id = creator_id, eventsInfo.type = type, eventsInfo.event_description = description, eventsInfo.category_name = category_name
    WHERE eventsInfo.event_id = event_id;
END |
DELIMITER ;

/* createCategory(name, description, colour)
  Simply adds a category.
*/
DELIMITER |
CREATE PROCEDURE createCategory(IN name VARCHAR(100), IN description VARCHAR(2000), IN colour VARCHAR(6))
BEGIN
  INSERT INTO categories (name, description, colour) VALUES (name, description, colour);
END |
DELIMITER ;

/* getCategories()
  Get all categories infos.
*/
DELIMITER |
CREATE PROCEDURE getCategories()
BEGIN
  SELECT * FROM categories;
END |
DELIMITER ;

/* updateCategory(oldname, name, description, colour)
  Update a category given the old name.
*/
DELIMITER |
CREATE PROCEDURE updateCategory(IN oldname VARCHAR(100), IN name VARCHAR(100), IN description VARCHAR(2000), IN colour VARCHAR(6))
BEGIN
  DECLARE checkname INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT  "The specified category name already exists" AS message;
    ROLLBACK;
  END;
  START TRANSACTION;
    SELECT COUNT(*) INTO checkname FROM categories AS cat WHERE cat.name = name;

    IF checkname = 0 THEN
      UPDATE categories AS cat SET cat.name = name, cat.description = description, cat.colour = colour WHERE cat.name = oldname;
    ELSE
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;

/* getUserDocs(user_id)
  Gets all user's documents given his id.
*/
DELIMITER |
CREATE PROCEDURE getUserDocs(IN user_id INT)
BEGIN
  SELECT doc.*, cat.name AS category_name, cat.colour AS category_colour, cat.description AS category_description
  FROM documents AS doc, events AS evnt, categories AS cat WHERE ((doc.creator_id = user_id) AND (doc.event_id = evnt.id) AND (evnt.category_name = cat.name));
END |
DELIMITER ;

/* getUserDoc(doc_id)
  Get document content.
*/
DELIMITER |
CREATE PROCEDURE getUserDoc(IN doc_id INT)
BEGIN
  SELECT * FROM documents AS doc WHERE doc.id = doc_id;
END |
DELIMITER ;

/* createDoc(creator_id, name, event_id, visibility_type)
  creates a document, if the user has the rights.
 */
DELIMITER |
CREATE PROCEDURE createDoc(IN creator_id INT, IN name VARCHAR(100), IN event_id INT, IN visibility_type ENUM('0', '1'))
BEGIN
  DECLARE returned_id INT DEFAULT -1;
  DECLARE alreadyExists VARCHAR(150) DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "The documents already exists!" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    SELECT COUNT(*) INTO alreadyExists FROM documents AS doc WHERE ( (doc.creator_id = creator_id) AND (doc.event_id = event_id) );
    IF alreadyExists > 0
    THEN
      -- Returns the already existent document
      SELECT doc.id AS returned_id FROM documents AS doc WHERE ( (doc.creator_id = creator_id) AND (doc.event_id = event_id) );
      SIGNAL sqlstate '45000';
    ELSE
      INSERT INTO documents (creator_id, name, event_id, public) VALUES (creator_id, name, event_id, visibility_type);
      SET returned_id = last_insert_id();
      SELECT returned_id;
    END IF;
  COMMIT;
END |
DELIMITER ;

/* updateDocName()
  Update a document name.
*/
DELIMITER |
CREATE PROCEDURE updateDocName(IN doc_id INT, IN user_id INT, IN name VARCHAR(100))
BEGIN
  DECLARE checkCreation INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "A user can't update other user's document" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    -- check rights
    SELECT COUNT(*) INTO checkCreation FROM documents AS doc WHERE doc.id = doc_id AND doc.creator_id = user_id;
    IF checkCreation = 1 THEN
      UPDATE documents AS doc SET doc.name = name WHERE doc.id = doc_id;
    ELSE
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;

/* updateDocVisibility()
  Update doc visibility.
*/
DELIMITER |
CREATE PROCEDURE updateDocVisibility(IN doc_id INT, IN user_id INT, IN public ENUM("0", "1"))
BEGIN
  DECLARE checkCreation INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "An user can't update other user's document" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    -- check rights
    SELECT COUNT(*) INTO checkCreation FROM document AS doc WHERE doc.id = doc_id AND doc.creator_id = user_id;
    IF checkCreation = 1 THEN
      UPDATE documents AS doc SET doc.public = public WHERE doc.id = user_id;
    ELSE
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;

/* getDoc(doc_id)
  Get doc info.
*/
DELIMITER |
CREATE PROCEDURE getDoc(IN doc_id INT)
BEGIN
  SELECT doc.*, usr.name as creator_name, usr.lastname as creator_lastname FROM documents AS doc, usersInfo as usr WHERE (doc.id= doc_id) AND (doc.creator_id = usr.id);
END |
DELIMITER ;

/*  getDocContent(doc_id)
  Get all notes related to the doc.
*/
DELIMITER |
CREATE PROCEDURE getDocContent(IN doc_id INT)
BEGIN
  SELECT * FROM notes,nodes WHERE (nodes.note_id = notes.id) AND (nodes.document_id = doc_id) ORDER BY notes.creation;
END |
DELIMITER ;

/* createNote(type, content, description, @lastid)
  Creates a note and returns its id.
*/
DELIMITER |
CREATE PROCEDURE createNote(IN type ENUM('code','text', 'image', 'link'),IN title VARCHAR(300), IN content TEXT, IN description VARCHAR(200), OUT lastid INT)
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "Note error" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    SET lastid = 0;
    INSERT INTO notes(type,title, content, description) VALUES (type,title, content, description);
    SELECT last_insert_id() INTO lastid;
  COMMIT;
END |
DELIMITER ;

/* createNoteWithDate(type, content, descriprion, date, @lastid)
    Create a note keeping the old date and time of creation
*/
DELIMITER |
CREATE PROCEDURE createNoteWithDate(IN type ENUM('code','text', 'image', 'link'),IN title VARCHAR(300), IN content TEXT, IN description VARCHAR(200), IN creationdate TIMESTAMP, OUT lastid INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "Error in note creation" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    SET lastid = 0;
    INSERT INTO notes(type,title, content, description, creationdate) VALUES (type,title, content, description, creationdate);
    SELECT last_insert_id() INTO lastid;
  COMMIT;
END |
DELIMITER ;


/* createNode(document_id, note_id, title)
  Creates a node given document id and a note id.
*/
DELIMITER |
CREATE PROCEDURE createNode(IN doc_id INT, IN note_id INT)
BEGIN
  INSERT INTO nodes(document_id, note_id) VALUES (doc_id, note_id);
END |
DELIMITER ;

/* addNoteToDoc(type, content, description, document_id, title)
  Creates a note and then adds the note to a document.
 */
DELIMITER |
CREATE PROCEDURE addNoteToDoc(IN type ENUM('code','text', 'image', 'link'), IN content TEXT, IN description VARCHAR(200), IN document_id INT, IN title VARCHAR(300))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Insert error" AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
  call createNote(type, title, content, description, @lastid);
  IF (@lastid <> 0) THEN
    call createNode(document_id, @lastid);
    COMMIT;
  ELSE
    SIGNAL sqlstate '45000';
  END IF;
END |
DELIMITER ;

/* modifyNode(doc_id, note_id)
  If an user modifies a note that has not been imported by other users, the procedure simply
  updates the note, otherwise it crates a new note and changes the note_id attribute in nodes table.
  - variation - we can save the creator name in the note table and check if the note has been imported by other
  users simply counting the number of instances in the nodes table.
*/
DELIMITER |
CREATE PROCEDURE modifyNode(IN doc_id INT, IN note_id INT, IN title VARCHAR(300), IN content TEXT, IN description VARCHAR(200))
BEGIN
  DECLARE num_of_instances INT DEFAULT 0;
  DECLARE note_type VARCHAR(200) DEFAULT "";
  DECLARE creation_note TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "Error: no note found." AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    SELECT COUNT(*) INTO num_of_instances FROM nodes AS nd WHERE nd.note_id = note_id;
    IF num_of_instances = 1 THEN
      UPDATE notes SET notes.title = title, notes.content = content, notes.description = description WHERE notes.id = note_id;
    ELSEIF (num_of_instances > 1) THEN
      -- Create a new note from the old one.
      SELECT type INTO note_type FROM notes AS nt WHERE nt.id = note_id;
      SELECT creation INTO creation_note FROM notes AS nt WHERE nt.id = note_id;
      call createNoteWithDate(note_type, title, content, description, creation_note, @lastid);
      -- Change reference to the new node in nodes table
      UPDATE nodes SET nodes.note_id = @lastid WHERE ((nodes.document_id = doc_id) AND (nodes.note_id = note_id));
    ELSE
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;

/* deleteNode(doc_id, note_id)
  Delete the node and the related note if not imported in other documents.
*/
DELIMITER |
CREATE PROCEDURE deleteNode(IN doc_id INT, IN note_id INT)
BEGIN
  DECLARE num_of_instances INT default -1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "Error in delate node." AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    DELETE FROM nodes WHERE ((nodes.document_id = doc_id) AND (nodes.note_id = note_id));
    -- Count the number of notes inserted.
    SELECT COUNT(*) INTO num_of_instances FROM nodes AS nd WHERE nd.note_id = note_id;
    IF num_of_instances = 0 THEN
      DELETE FROM notes WHERE (notes.id = note_id);
    END IF;
  COMMIT;
END |
DELIMITER ;

/* getEventNodes()
  @DEPRECATED: use getEventNotes!!
  Get all event nodes during the writing of the document.
  Devo prendere tutti i documenti dell'evento e tutte le note di quei documenti attraverso i nodi
*/
DELIMITER |
CREATE PROCEDURE getEventNodes(IN doc_id INT)
BEGIN
  DECLARE event_id INT DEFAULT 0;
  DECLARE creator_id INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "Event does not exists" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    -- select the event and the creator
    SELECT doc.event_id, doc.creator_id INTO event_id, creator_id FROM documents AS doc WHERE (doc.id = doc_id);
    IF (event_id <> 0 AND creator_id <> 0) THEN
      SELECT * FROM nodes AS nd, notes AS nt WHERE ( (nd.note_id = nt.id) AND (nd.document_id = ANY (SELECT id FROM documents AS dcmt WHERE ( (dcmt.event_id = event_id) AND (dcmt.creator_id <> creator_id) ))));
    ELSE
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;

/* getEventNotes()
  Get all event nodes during the writing of the document.
  Devo prendere tutti i documenti dell'evento e tutte le note di quei documenti attraverso i nodi
*/
DELIMITER |
CREATE PROCEDURE getEventNotes(IN doc_id INT)
BEGIN
  DECLARE event_id INT DEFAULT 0;
  DECLARE creator_id INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT "Event does not exists" AS message;
    ROLLBACK;
  END;

  START TRANSACTION;
    -- select the event and the creator
    SELECT doc.event_id, doc.creator_id INTO event_id, creator_id FROM documents AS doc WHERE (doc.id = doc_id);
    IF (event_id <> 0 AND creator_id <> 0) THEN

      SELECT nt.*, COUNT(*) AS copies_number FROM nodes AS nd1, notes AS nt WHERE (
                (nd1.note_id <> ALL (SELECT nd2.note_id FROM nodes as nd2 WHERE (nd2.document_id = doc_id) ))
                AND (nd1.note_id = nt.id)
                AND (nd1.document_id <> doc_id)
                AND (nd1.document_id = ANY (SELECT id FROM documents AS dcmt WHERE dcmt.event_id = event_id ))
              ) GROUP BY nt.id, nt.title, nt.type, nt.description, nt.content;
    ELSE
      SIGNAL sqlstate '45000';
    END IF;
  COMMIT;
END |
DELIMITER ;


/* getGroupMembers(group_id)
  Get members given a group id.
*/
DELIMITER |
CREATE PROCEDURE getGroupMembers(IN group_id INT)
BEGIN
  SELECT * FROM members as mmbr, usersInfo as usr
  WHERE (mmbr.group_id = group_id) AND (mmbr.user_id = usr.id);
END |
DELIMITER ;

/* getEventPartecipants(event_id)
  Gets every users that partecipate to an event and have accepted the invitation.
*/
DELIMITER |
CREATE PROCEDURE getEventPartecipants(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (usr.id = part.user_id) AND (part.status = "accepted");
END |
DELIMITER ;

/* getEventWaitingPartecipans(event_id)
  Gets every users that haven't still answered to the invitation.
*/
DELIMITER |
CREATE PROCEDURE getEventWaitingPartecipants(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "waiting");
END |
DELIMITER ;

/* getEventDeclinedPartecipans(event_id)
  Gets every users that won't enjoy the event.
*/
DELIMITER |
CREATE PROCEDURE getEventDeclinedPartecipants(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "declined");
END |
DELIMITER ;

/* getPartecipationStatus(user_id, event_id)
  Get the status of private event
*/
DELIMITER |
CREATE PROCEDURE getPartecipationStatus(IN user_id INT, IN event_id INT)
BEGIN
  SELECT part.status AS status FROM partecipations AS part WHERE (part.event_id = event_id) AND (part.user_id = user_id);
END |
DELIMITER ;

/* createGroup(name, image, description, admin_id)
  Create a group and set the admin.
*/
DELIMITER |
CREATE PROCEDURE createGroup(IN name VARCHAR (100), IN image VARCHAR(300), IN description VARCHAR(2000), IN admin_id INT)
BEGIN
  DECLARE lastid INT DEFAULT -1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Error during group creation, rollback." AS message;
      ROLLBACK;
    END;
  -- transaction
  START TRANSACTION;
    INSERT INTO groups (name, image, description) VALUES (name, image, description);
    SET lastid = last_insert_id();
    IF (lastid = -1) THEN
      SIGNAL sqlstate '45000';
      ROLLBACK;
    ELSE
      call addMember(admin_id, lastid);
      -- select the last inserted id.
      SELECT lastid;
    END IF;
  COMMIT;
END |
DELIMITER ;

/* addMember(user_id, group_id)
  Adds a member to a group. The first member is an admin.
*/
DELIMITER |
CREATE PROCEDURE addMember(IN user_id INT, IN group_id INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Error in add member" AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
    IF((SELECT COUNT(*) FROM members AS mmbr WHERE mmbr.group_id = group_id) = 0)
    THEN
      INSERT INTO members (user_id, group_id, accepted, role) VALUES (user_id, group_id, 1 ,'admin');
    ELSE
      INSERT INTO members (user_id, group_id) VALUES (user_id, group_id);
    END IF ;
  COMMIT;
END |
DELIMITER ;

/* removeMember(user_id, group_id)
  Remove a member (if present) from a group. Conflict with trigger change_admin: trigger removed.
*/
DELIMITER |
CREATE PROCEDURE removeMember(IN user_id INT, IN group_id INT)
BEGIN
  DECLARE isMember INT DEFAULT 0;
  DECLARE isAdmin INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "The specified user is not a member of the group" AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
    SELECT COUNT(*) INTO isMember FROM members AS mmbr WHERE ( (mmbr.group_id= group_id) AND (mmbr.user_id= user_id) );
    SELECT COUNT(*) INTO isAdmin FROM members AS mmbr WHERE ( (mmbr.group_id= group_id) AND (mmbr.user_id= user_id) AND (mmbr.role= "admin") );
    IF( isMember = 0 ) THEN
      SIGNAL sqlstate '45000';
    ELSE
      DELETE FROM members WHERE ( (members.user_id= user_id) AND (members.group_id= group_id));
      IF (isAdmin > 0 ) THEN
        UPDATE members SET role = "admin" WHERE (group_id = group_id) AND (user_id = (SELECT mmbr2.user_id FROM members AS mmbr2 WHERE mmbr2.group_id = group_id HAVING min(mmbr2.joindate)));
      END IF;
    END IF;
  COMMIT;
END |
DELIMITER ;

/* acceptMembership(user_id, group_id)
  Accept invitation to a group.
*/
DELIMITER |
CREATE PROCEDURE acceptMembership(IN user_id INT, IN group_id INT)
BEGIN
  UPDATE members AS mmbr SET mmbr.accepted = 1 WHERE ( (mmbr.user_id = user_id) AND (mmbr.group_id = group_id) ) ;
END |
DELIMITER ;

/* refuseMembership(user_id, group_id)
*/
DELIMITER |
CREATE PROCEDURE refuseMembership(IN user_id INT, IN group_id INT)
BEGIN
  DELETE FROM members WHERE ( (members.user_id = user_id) AND (members.group_id = group_id) ) ;
END |
DELIMITER ;

/* getUserGroups(user_id)
  Select all groups where the user is member.
*/
DELIMITER |
CREATE PROCEDURE getUserGroups(IN user_id INT)
BEGIN
  SELECT mmbr.group_id AS group_id, mmbr.accepted AS accepted, mmbr.role AS role, mmbr.joindate AS joindate,
  grp.name AS group_name, grp.creationdate AS creationdate, grp.image AS group_image, grp.description AS group_description
   FROM members AS mmbr, groups AS grp WHERE ( (mmbr.group_id= grp.id) AND (mmbr.user_id= user_id) );
END |
DELIMITER ;

/* updateGroup(group_id, name, image, description)
  Update group information given its id.
*/
DELIMITER |
CREATE PROCEDURE updateGroup(IN group_id INT, IN name VARCHAR(100), IN image VARCHAR(300), IN description VARCHAR(2000))
BEGIN
  UPDATE groups AS grp SET grp.name = name, grp.image = image, grp.description = description WHERE grp.id = group_id;
END |
DELIMITER ;

/* getGroupInfo(group_id)
  Select group info given its id.
*/
DELIMITER |
CREATE PROCEDURE getGroupInfo(IN group_id INT)
BEGIN
  SELECT * FROM groups AS grp WHERE grp.id = group_id;
END |
DELIMITER ;

/* getPlace(place_id)
  Get a place given its id.
*/
DELIMITER |
CREATE PROCEDURE getPlace(IN place_id INT)
BEGIN
  SELECT * FROM places AS plc WHERE plc.id = place_id;
END |
DELIMITER ;

/* addPartecipant(event_id, user_id)
  Adds a partrecipation to an Event.
*/
DELIMITER |
CREATE PROCEDURE addPartecipant(IN event_id INT, IN user_id INT)
BEGIN
  DECLARE alreadyPartecipant INT DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "The user is already a partecipant" AS message;
      ROLLBACK;
    END;

  START TRANSACTION;
    SELECT COUNT(*) INTO alreadyPartecipant FROM partecipations AS part WHERE ((part.event_id= event_id) AND (part.user_id= user_id));
    IF alreadyPartecipant <> 0 THEN
      SIGNAL sqlstate '45000';
    ELSE
      INSERT INTO partecipations(event_id, user_id, status) VALUES (event_id, user_id, 'waiting');
    END IF;
  COMMIT;
END |
DELIMITER ;

/* updatePartecipationStatus(event_id, user_id, status)
  The user can accept, decline an invitation to an event or keet it in waiting status.
*/
DELIMITER |
CREATE PROCEDURE updatePartecipationStatus(IN event_id INT, IN user_id INT, IN status VARCHAR(20))
BEGIN
  UPDATE partecipations AS part SET part.status = status WHERE ( (part.event_id = event_id) AND (part.user_id = user_id) );
END |
DELIMITER ;

/* addNote TODO duplicated!! */
DELIMITER |
CREATE PROCEDURE addNote(IN typeI VARCHAR(7), IN contentI TEXT, IN descriptionI VARCHAR(200))
BEGIN
  INSERT INTO notes (type, content, description) VALUES (typeI, contentI, descriptionI);
END |
DELIMITER ;

/* getNote(note_id)
  Get a note content.
*/
DELIMITER |
CREATE PROCEDURE getNote(IN note_id INT)
BEGIN
  SELECT nt.* FROM notes AS nt WHERE nt.id = note_id;
END |
DELIMITER ;

/* updateNote(id, type, content, descripiton)
  It simply updates a note gived its id.
*/
DELIMITER |
CREATE PROCEDURE updateNote(IN id INT, IN type VARCHAR(7), IN content TEXT, IN description VARCHAR(200))
BEGIN
  UPDATE notes as nt SET nt.type = type, nt.content = content, nt.description = description WHERE nt.id = id;
END |
DELIMITER ;

/* searchUser(text)
  Search all users whose name contains the given sequence of chars (text).
*/
DELIMITER |
CREATE PROCEDURE searchUser(IN text VARCHAR(200))
BEGIN
 SELECT id, name, lastname, image_profile FROM usersInfo WHERE ( CONCAT_WS(' ', name, lastname) LIKE CONCAT('%', text , '%') OR CONCAT_WS(' ', lastname, name) LIKE CONCAT('%', text , '%') ) LIMIT 10;
END |
DELIMITER ;

/* searchGroup(text)
  Search all group where the title contains the given sequence of chars (text).
*/
DELIMITER |
CREATE PROCEDURE searchGroup(IN text VARCHAR(200))
  BEGIN
    SELECT id, name FROM groups WHERE ( name LIKE CONCAT('%', text , '%') ) LIMIT 10;
  END |
DELIMITER ;

/* addGroupToEvent(group_id, event_id)
  Insert partecipations for all members in a given group.
 */
DELIMITER |
CREATE PROCEDURE addGroupToEvent(IN group_id INT, IN event_id INT)
  BEGIN
    DECLARE cursor_ID INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_i CURSOR FOR SELECT user_id FROM members WHERE members.group_id= group_id AND members.accepted=1 ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;

    OPEN cursor_i;
    read_loop: LOOP
      FETCH cursor_i INTO cursor_ID;
      IF done THEN
        LEAVE read_loop;
      END IF;
      INSERT INTO partecipations(event_id, user_id) VALUES(event_id, cursor_ID);
    END LOOP;
    CLOSE cursor_i;
  END |
DELIMITER ;

/* getNotification(user_id)
  Get all event partecipation requests.
*/
DELIMITER |
CREATE PROCEDURE getNotifications(IN user_id INT)
  BEGIN
    SELECT evnt.*, part.status FROM partecipations AS part, eventsInfo AS evnt WHERE part.user_id = user_id AND evnt.event_id = part.event_id AND part.status="waiting";
  END |
DELIMITER ;

/* getGroupsRequest(user_id)
  Get all group membership requests.
*/
DELIMITER |
CREATE PROCEDURE getGroupsRequest(IN user_id INT)
  BEGIN
    SELECT grp.*, mmbr.accepted FROM members AS mmbr, groups AS grp WHERE mmbr.user_id = user_id AND mmbr.group_id = grp.id AND mmbr.accepted=false;
  END |
DELIMITER ;

/* getEventsGroupUserId(user_id, group_id)
  Get all the public events where a group member has accepted the partecipation and the event creation date
  comes after the group creation date.
*/
DELIMITER |
CREATE PROCEDURE getEventsGroupByUserId(IN user_id INT, IN group_id INT)
  BEGIN
    SELECT evnt.*
    FROM events AS evnt
    WHERE evnt.type = "public"
          AND evnt.creationdate >= (
                            SELECT grp.creationdate
                            FROM groups AS grp
                            WHERE grp.id = group_id
                          )
          AND evnt.id = ANY (
                      SELECT part.event_id
                      FROM partecipations AS part
                      WHERE part.user_id = user_id AND
                      part.event_id =  ANY (
                                    SELECT DISTINCT part2.event_id
                                    FROM partecipations AS part2
                                    WHERE part2.status = "accepted" AND
                                            part2.user_id = ANY (
                                                        SELECT mmbr.user_id
                                                        FROM members AS mmbr
                                                        WHERE mmbr.group_id = group_id AND
                                                                mmbr.user_id <> user_id AND
                                                                mmbr.accepted = true
                                                      )
                                  )
                    );
END |
DELIMITER ;

/* getDocumentsGroupByUserId(user_id, group_id)
  Get all the public docs written by a member of the group during a public event.
  The doc must have a creation date successive to the group creation.
*/
DELIMITER |
CREATE PROCEDURE getDocumentsGroupByUserId(IN user_id INT, IN group_id INT)
BEGIN
 SELECT doc.*
 FROM documents AS doc
 WHERE doc.creationdate >= (
              SELECT grp.creationdate
              FROM groups AS grp
              WHERE grp.id = group_id
      )
      AND doc.creator_id = ANY (
              SELECT mmbr.user_id
              FROM members AS mmbr
              WHERE mmbr.group_id = group_id
                AND mmbr.user_id <> user_id
                AND mmbr.accepted = true
      )
      AND doc.event_id = ANY (
              SELECT part.event_id
              FROM partecipations AS part
              WHERE part.user_id = user_id
                AND part.event_id = ANY (
                            SELECT distinct part2.event_id
                            FROM partecipations AS part2
                            WHERE part2.status = "accepted"
                              AND part2.user_id = (
                                            SELECT mmbr2.user_id
                                            FROM members AS mmbr2
                                            WHERE mmbr2.group_id = group_id
                                              AND mmbr2.user_id <> user_id
                                              AND mmbr2.accepted = true
                              )
                )
      )
      AND doc.public = '1';
END |
DELIMITER ;

/******** PRIVILEGES *********/
CREATE USER 'mergefly_prova'@'localhost' IDENTIFIED BY 'mergefly_pwd_x12yAA9z7';
GRANT SELECT ON merge.* TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE login TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE insertUser TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE createCategory TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE createDoc TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE createNote TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE createNoteWithDate TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE createNode TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE createGroup TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE addMember TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE addPartecipant TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE addNote TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE addGroupToEvent TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE addNoteToDoc TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE addPlace TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE addEvent TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE getUserGroup TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getUser TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getUserEvents TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEvents TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEvent TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getCategories TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getUserDocs TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getUserDoc TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getDoc TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getDocContent TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEventNodes TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEventNotes TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getGroupMembers TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEventPartecipants TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEventWaitingPartecipants TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEventDeclinedPartecipants TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getUserGroups TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getGroupInfo TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getPlace TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getNote TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getNotifications TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getGroupsRequest TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getEventsGroupByUserId TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE getDocumentsGroupByUserId TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE updatePosition TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateUser TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE upgradeUser TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateEvent TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateCategory TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateDocName TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateDocVisibility TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateGroup TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updatePartecipationStatus TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE updateNote TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE changePassword TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE modifyNode TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE userNearEvents TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE searchEvents TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE searchPlaces TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE suggestedPlaces TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE similarPlaces TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE searchUser TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE searchGroup TO 'mergefly_prova'@'localhost';

GRANT EXECUTE ON PROCEDURE acceptMembership TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE refuseMembership TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE removeMember TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE deleteNode TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE deleteUser TO 'mergefly_prova'@'localhost';
GRANT EXECUTE ON PROCEDURE damnatioMemoriae TO 'mergefly_prova'@'localhost';
