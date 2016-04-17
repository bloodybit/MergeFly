-- phpMyAdmin SQL Dump
-- version 3.5.8.1
-- http://www.phpmyadmin.net
--
-- Host: polleg.it.mysql:3306
-- Generation Time: Apr 12, 2016 at 02:12 PM
-- Server version: 5.5.47-MariaDB-1~wheezy
-- PHP Version: 5.3.3-7+squeeze15

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `polleg_it`
--
CREATE DATABASE `polleg_it` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `polleg_it`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`polleg_it`@`%` PROCEDURE `acceptMembership`(IN user_id INT, IN group_id INT)
BEGIN
  UPDATE members AS mmbr SET mmbr.accepted = 1 WHERE ( (mmbr.user_id = user_id) AND (mmbr.group_id = group_id) ) ;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addEvent`(IN name VARCHAR(100), IN description VARCHAR(2000), IN place_id INT, IN startdate DATE, IN stopdate DATE, IN creator_id INT, IN event_type VARCHAR(20), category_name VARCHAR(20))
BEGIN
  DECLARE lastid INT DEFAULT -1;
  DECLARE user_type VARCHAR(20);
  SELECT usr.type INTO user_type FROM users AS usr WHERE usr.id = creator_id;

  IF event_type = "private" AND user_type = "basic"
  THEN
    SIGNAL sqlstate '45000' set message_text = "A basic user can't create private events!";
  ELSE
    -- Create the event
    INSERT INTO events (name, place_id, startdate, stopdate, creator_id, type, description, category_name)
      VALUES (name, place_id, startdate, stopdate, creator_id, event_type, description, category_name);
    -- Save event id
    SET lastid = last_insert_id();
    -- Add the creator as (accepted) partecipant.
    call addPartecipant(lastid, creator_id, 'accepted');
    SELECT lastid;
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addGroupToEvent`(IN groupID INT, IN eventID INT)
BEGIN
    BEGIN
      DECLARE cursor_ID INT;
      DECLARE done INT DEFAULT FALSE;
      DECLARE cursor_i CURSOR FOR SELECT user_id FROM members WHERE group_id= groupID AND accepted=1 ;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
      OPEN cursor_i;
      read_loop: LOOP
        FETCH cursor_i INTO cursor_ID;
        IF done THEN
          LEAVE read_loop;
        END IF;
        INSERT INTO partecipations(event_id, user_id) VALUES(eventID, cursor_ID);
      END LOOP;
      CLOSE cursor_i;
    END;

  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addMember`(IN user_id INT, IN group_id INT)
BEGIN
  IF((SELECT COUNT(*) FROM members AS mmbr WHERE mmbr.group_id = group_id) = 0)
  THEN
    INSERT INTO members (user_id, group_id, accepted, role) VALUES (user_id, group_id, 1 ,'admin');
  ELSE
    INSERT INTO members (user_id, group_id) VALUES (user_id, group_id);
  END IF ;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addNote`(IN typeI VARCHAR(7), IN contentI TEXT, IN descriptionI VARCHAR(200))
BEGIN
  INSERT INTO notes (type, content, description) VALUES (typeI, contentI, descriptionI);
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addNoteToDoc`(IN type ENUM('code','text', 'image', 'link'), IN content TEXT, IN description VARCHAR(200), IN document_id INT, IN title VARCHAR(300))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Generic error" as "";
      ROLLBACK;
    END;

  START TRANSACTION;
  call createNote(type, title, content, description, @lastid);
  IF (@lastid <> 0) THEN
    call createNode(document_id, @lastid);
    COMMIT;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "Insert Error";
    ROLLBACK;
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addPartecipant`(IN event_id INT, IN user_id INT, IN status ENUM('accepted','waiting','declined'))
BEGIN
  DECLARE alreadyPartecipant INT DEFAULT 0;
  SELECT COUNT(*) INTO alreadyPartecipant FROM partecipations AS part WHERE ((part.event_id= event_id) AND (part.user_id= user_id));
  IF alreadyPartecipant <> 0 THEN
    SIGNAL sqlstate '45000' SET message_text = "The user is already a partecipant";
  ELSE
    INSERT INTO partecipations(event_id, user_id, status) VALUES (event_id, user_id, status);
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `addPlace`(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN name VARCHAR(100), IN address VARCHAR(200), IN cap VARCHAR(10), IN city VARCHAR(50), IN nation VARCHAR(50))
BEGIN
  DECLARE lastid INT DEFAULT -1;
  INSERT INTO places (latitude, longitude, name, address, cap, city, nation) VALUES (latitude, longitude, name, address, cap, city, nation);
  SET lastid= last_insert_id();
  SELECT lastid;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `changePassword`(IN user_id INT, IN old_password VARCHAR(300), IN new_password VARCHAR(300))
BEGIN
    UPDATE users AS usr SET usr.password= new_password WHERE ( (usr.id= user_id) AND (usr.password= old_password) );
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `checkRights`(IN user_id INT, IN doc_id INT, OUT result INT)
BEGIN

  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `createCategory`(IN name VARCHAR(100), IN description VARCHAR(2000), IN colour VARCHAR(6))
BEGIN
  INSERT INTO categories (name, description, colour) VALUES (name, description, colour);
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `createDoc`(IN creator_id INT, IN name VARCHAR(100), IN event_id INT, IN event_visibility_type ENUM('public', 'private'))
BEGIN
  DECLARE returned_id INT DEFAULT -1;
  DECLARE alreadyExists VARCHAR(150) DEFAULT 0;
  DECLARE visibility_type VARCHAR(1);
  IF (event_visibility_type = 'private') THEN
    SET visibility_type = '0';
  ELSE
    SET visibility_type = '1';
  END IF;
  SELECT COUNT(*) INTO alreadyExists FROM documents AS doc WHERE ( (doc.creator_id = creator_id) AND (doc.event_id = event_id) );
  IF alreadyExists > 0
  THEN
    -- Returns the already existent document
    SELECT doc.id AS returned_id FROM documents AS doc WHERE ( (doc.creator_id = creator_id) AND (doc.event_id = event_id) );
    SIGNAL sqlstate '45000' set message_text = "The documents already exists!";
  ELSE
    INSERT INTO documents (creator_id, name, event_id, public) VALUES (creator_id, name, event_id, visibility_type);
    SET returned_id = last_insert_id();
    SELECT returned_id;
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `createGroup`(IN name VARCHAR (100), IN image VARCHAR(300), IN description VARCHAR(2000), IN admin_id INT)
BEGIN
  DECLARE lastid INT DEFAULT -1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SELECT "Generic error" as "";
      ROLLBACK;
    END;
  -- transaction
  START TRANSACTION;
    INSERT INTO groups (name, image, description) VALUES (name, image, description);
    SET lastid = last_insert_id();
    IF (lastid = -1) THEN
      SIGNAL sqlstate '45000' SET message_text = "Error during group creation, rollback.";
      ROLLBACK;
    ELSE
      call addMember(admin_id, lastid);
      -- select the last inserted id.
      SELECT lastid;
    END IF;
  COMMIT;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `createNode`(IN doc_id INT, IN note_id INT)
BEGIN
  INSERT INTO nodes(document_id, note_id) VALUES (doc_id, note_id);
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `createNote`(IN type ENUM('code','text', 'image', 'link'),IN title VARCHAR(300), IN content TEXT, IN description VARCHAR(200), OUT lastid INT)
BEGIN
  SET lastid = 0;
  INSERT INTO notes(type,title, content, description) VALUES (type,title, content, description);
  SELECT last_insert_id() INTO lastid;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `createNoteWithDate`(IN type ENUM('code','text', 'image', 'link'),IN title VARCHAR(300), IN content TEXT, IN description VARCHAR(200), IN creation TIMESTAMP, OUT lastid INT)
BEGIN
  SET lastid = 0;
  INSERT INTO notes(type,title, content, description, creation) VALUES (type,title, content, description, creation);
  SELECT last_insert_id() INTO lastid;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `damnatioMemoriae`(IN user_id INT)
BEGIN
    DELETE FROM users WHERE users.id= user_id;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `deleteNode`(IN doc_id INT, IN note_id INT)
BEGIN
  DECLARE num_of_instances INT default -1;
  DELETE FROM nodes WHERE ((nodes.document_id = doc_id) AND (nodes.note_id = note_id));
  -- Count the number of notes inserted.
  SELECT COUNT(*) INTO num_of_instances FROM nodes AS nd WHERE nd.note_id = note_id;
  IF num_of_instances = 0 THEN
    DELETE FROM notes WHERE (notes.id = note_id);
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `deleteUser`(IN user_id INT)
BEGIN
    UPDATE users AS usr SET usr.deleted="1" WHERE usr.id=user_id;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getCategories`()
BEGIN
  SELECT * FROM categories;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getDoc`(IN doc_id INT)
BEGIN
  SELECT doc.*, usr.name as creator_name, usr.lastname as creator_lastname FROM documents AS doc, usersInfo as usr WHERE (doc.id= doc_id) AND (doc.creator_id = usr.id);
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getDocContent`(IN doc_id INT)
BEGIN
  SELECT * FROM notes,nodes WHERE (nodes.note_id = notes.id) AND (nodes.document_id = doc_id) ORDER BY notes.creation;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getDocumentsGroupByUserId`(IN user_id INT, IN group_id INT)
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
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEvent`(IN user_id INT, IN event_id INT)
BEGIN
  -- Verify user partecipation
  DECLARE presenza INT default 0;
  DECLARE type VARCHAR(20) default "private";
  SELECT COUNT(*) INTO presenza FROM partecipations AS part WHERE (part.user_id= user_id) AND (part.event_id= event_id);
  SELECT evnt.type INTO type FROM eventsInfo AS evnt WHERE evnt.event_id = event_id;

  IF ( (presenza = 1) OR (type = "public") ) THEN
  SELECT evnt.id AS event_id, evnt.type AS event_type, evnt.name AS event_name, evnt.description AS event_description, evnt.creationdate, evnt.startdate, evnt.stopdate,
  evnt.category_name, evnt.place_id, plc.name AS place_name, plc.latitude, plc.longitude, plc.address, plc.city, plc.cap, plc.nation,
  evnt.creator_id, usr.name AS creator_name, usr.lastname AS creator_lastname, usr.image_profile AS creator_image_profile
  FROM events AS evnt, places AS plc, usersInfo AS usr, categories AS cat WHERE ( (evnt.creator_id = usr.id) AND  (evnt.place_id = plc.id) AND (evnt.id = event_id) AND (evnt.category_name = cat.name) );
  ELSE
    SIGNAL sqlstate '45000' set message_text = "You are not a partecipant!";
    -- cat.name AS category_name, cat.description AS category_description, cat.colour AS category_colour,
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEventDeclinedPartecipants`(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "declined");
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEventNodes`(IN doc_id INT)
BEGIN
  DECLARE event_id INT DEFAULT 0;
  DECLARE creator_id INT DEFAULT 0;
  -- select the event and the creator
  SELECT doc.event_id, doc.creator_id INTO event_id, creator_id FROM documents AS doc WHERE (doc.id = doc_id);
  IF (event_id <> 0 AND creator_id <> 0) THEN

    SELECT *
    FROM nodes AS nd, notes AS nt
    WHERE ( (nd.note_id = nt.id)
      AND (nd.document_id = ANY (SELECT id
                                  FROM documents AS dcmt
                                  WHERE ( (dcmt.event_id = event_id)
                                    AND (dcmt.creator_id <> creator_id)
                                  )
                                )
          )
    );
  ELSE
    SIGNAL sqlstate '45000' set message_text = "Event does not exists";
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEventNotes`(IN doc_id INT)
BEGIN
  DECLARE event_id INT DEFAULT 0;
  DECLARE creator_id INT DEFAULT 0;
  -- select the event and the creator
  SELECT doc.event_id, doc.creator_id INTO event_id, creator_id FROM documents AS doc WHERE (doc.id = doc_id);

  IF (event_id <> 0 AND creator_id <> 0) THEN
    SELECT nt.*, COUNT(*) AS copies_number FROM nodes AS nd1, notes AS nt WHERE (
              (nd1.note_id <> ALL (SELECT nd2.note_id FROM nodes as nd2 WHERE (nd2.document_id = doc_id) ))
              AND (nd1.note_id = nt.id)
              AND (nd1.document_id <> doc_id)
              AND (nd1.document_id = ANY (SELECT dcmt.id FROM documents AS dcmt WHERE dcmt.event_id = event_id ))
            ) GROUP BY nt.id, nt.title, nt.type, nt.description, nt.content;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "Event does not exists";
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEventPartecipants`(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (usr.id = part.user_id) AND (part.status = "accepted");
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEvents`()
BEGIN
  SELECT * FROM eventsInfo;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEventsGroupByUserId`(IN user_id INT, IN group_id INT)
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
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getEventWaitingPartecipants`(IN event_id INT)
BEGIN
  SELECT * FROM partecipations as part, usersInfo as usr
  WHERE (part.event_id = event_id) AND (part.user_id = usr.id) AND (part.status = "waiting");
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getGroupInfo`(IN group_id INT)
BEGIN
  SELECT * FROM groups AS grp WHERE grp.id = group_id;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getGroupMembers`(IN group_id INT)
BEGIN
  SELECT * FROM members as mmbr, usersInfo as usr
  WHERE (mmbr.group_id = group_id) AND (mmbr.user_id = usr.id);
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getGroupsRequest`(IN user_id INT)
BEGIN
    SELECT grp.*, mmbr.accepted
    FROM members AS mmbr, groups AS grp
    WHERE mmbr.user_id = user_id
      AND mmbr.group_id = grp.id
      AND mmbr.accepted=false;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getNote`(IN idI INT)
BEGIN
  SELECT * FROM notes WHERE id = idI;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getNotifications`(IN user_id INT)
BEGIN
    SELECT evnt.*, part.status
    FROM partecipations AS part, eventsInfo AS evnt
    WHERE part.user_id = user_id
      AND evnt.event_id = part.event_id
      AND part.status="waiting";
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getPartecipationStatus`(IN user_id INT, IN event_id INT)
BEGIN
  SELECT part.status AS status FROM partecipations AS part WHERE (part.event_id = event_id) AND (part.user_id = user_id);
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getPlace`(IN place_id INT)
BEGIN
  SELECT * FROM places AS plc WHERE plc.id = place_id;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getUser`(IN user_id INT)
BEGIN
  SELECT * FROM usersInfo AS usr WHERE usr.id = user_id;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getUserDoc`(IN doc_id INT)
BEGIN
  SELECT * FROM documents AS doc WHERE doc.id = doc_id;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getUserDocs`(IN user_id INT)
BEGIN
  SELECT doc.*, cat.name AS category_name, cat.colour AS category_colour, cat.description AS category_description
  FROM documents AS doc, events AS evnt, categories AS cat WHERE ((doc.creator_id = user_id) AND (doc.event_id = evnt.id) AND (evnt.category_name = cat.name));
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getUserEvents`( IN user_id INT, IN which ENUM('next','past','all') )
BEGIN
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
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getUserGroup`(IN user_id INT)
BEGIN
   SELECT mmbr.* FROM members AS mmbr WHERE mmbr.user_id = user_id AND mmbr.accepted = true;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `getUserGroups`(IN user_id INT)
BEGIN
  SELECT mmbr.group_id AS group_id, mmbr.accepted AS accepted, mmbr.role AS role, mmbr.joindate AS joindate,
  grp.name AS group_name, grp.creationdate AS creationdate, grp.image AS group_image, grp.description AS group_description
   FROM members AS mmbr, groups AS grp
   WHERE ( (mmbr.group_id= grp.id) AND (mmbr.user_id= user_id) );
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `insertUser`(IN name VARCHAR(100),
 IN lastname VARCHAR(100),
 IN born DATE,
 IN type INT,
 IN image_profile VARCHAR(500),
 IN password VARCHAR(300),
 IN mail VARCHAR(150))
BEGIN
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
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `login`( IN mail VARCHAR(150), IN password VARCHAR(300), IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  DECLARE user_id INT default -1;
  SELECT usr.id INTO user_id FROM users AS usr WHERE (usr.mail = mail) AND (usr.password = password) LIMIT 1;
  IF (user_id <> -1) THEN
    call updatePosition(user_id, latitude, longitude);
    call getUser(user_id);
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `modifyNode`(IN doc_id INT, IN note_id INT, IN title VARCHAR(300), IN content TEXT, IN description VARCHAR(200))
BEGIN
  DECLARE num_of_instances INT DEFAULT 0;
  DECLARE note_type VARCHAR(200) DEFAULT "";
  DECLARE creation_note TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
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
    SIGNAL sqlstate '45000' SET message_text = "Error: no note found.";
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `refuseMembership`(IN user_id INT, IN group_id INT)
BEGIN
  DELETE FROM members WHERE ( (members.user_id = user_id) AND (members.group_id = group_id) ) ;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `removeMember`(IN user_id INT, IN group_id INT)
BEGIN
  DECLARE isMember INT DEFAULT 0;
  DECLARE isAdmin INT DEFAULT 0;
  SELECT COUNT(*) INTO isMember FROM members AS mmbr WHERE ( (mmbr.group_id= group_id) AND (mmbr.user_id= user_id) );
  SELECT COUNT(*) INTO isAdmin FROM members AS mmbr WHERE ( (mmbr.group_id= group_id) AND (mmbr.user_id= user_id) AND (mmbr.role= "admin") );
  IF( isMember = 0 ) THEN
    SIGNAL sqlstate '45000' SET message_text = "The specified user is not a member of the group";
  ELSE
    DELETE FROM members WHERE ( (members.user_id= user_id) AND (members.group_id= group_id));
    IF (isAdmin > 0 ) THEN
      UPDATE members SET role = "admin" WHERE (group_id = group_id) AND (user_id = (SELECT mmbr2.user_id FROM members AS mmbr2 WHERE mmbr2.group_id = group_id HAVING min(mmbr2.joindate)));
    END IF;
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `searchEvents`(IN user_id INT, IN chars VARCHAR(200))
BEGIN
    -- search (1) public events (2) partecipation
    (SELECT evnt.* FROM eventsInfo AS evnt
      WHERE ( (evnt.type="public") AND (evnt.event_name LIKE CONCAT('%', chars , '%')) ) LIMIT 6)
    UNION
    (SELECT evnt.* FROM eventsInfo AS evnt, partecipations AS part
      WHERE ( (part.event_id = evnt.event_id) AND (part.user_id = user_id) AND (evnt.event_name LIKE CONCAT('%', chars , '%')) ) LIMIT 6);
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `searchGroup`(IN text VARCHAR(200))
BEGIN
    SELECT id, name FROM groups WHERE ( name LIKE CONCAT('%', text , '%') ) LIMIT 10;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `searchPlaces`(IN chars VARCHAR(200))
BEGIN
    -- search
    SELECT plc.* FROM places AS plc
      WHERE ( (plc.name LIKE CONCAT('%', chars , '%')) OR (CONCAT(plc.address, " ",plc.city) LIKE CONCAT(TRIM(chars) , '%')) ) LIMIT 6;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `searchUser`(IN text VARCHAR(200))
BEGIN
 SELECT id, name, lastname, image_profile
 FROM usersInfo
 WHERE ( CONCAT_WS(' ', name, lastname) LIKE CONCAT('%', text , '%') OR CONCAT_WS(' ', lastname, name) LIKE CONCAT('%', text , '%') ) LIMIT 10;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `similarPlaces`(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  -- Get all the places in 50 meters
  SELECT evnt, ( 3959 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM places AS plc
  HAVING calculated_distance < 50
  ORDER BY calculated_distance;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `suggestedPlaces`(IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist DECIMAL(11,8))
BEGIN
  SELECT plc.* , ( 3959 * acos( cos( radians(latitude) ) * cos( radians( plc.latitude ) ) * cos( radians( plc.longitude ) - radians(longitude) ) + sin( radians(latitude) ) * sin( radians( plc.latitude ) ) ) ) AS calculated_distance
  FROM places as plc
  HAVING ( calculated_distance < dist )
  ORDER BY calculated_distance;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateCategory`(IN oldname VARCHAR(100), IN name VARCHAR(100), IN description VARCHAR(2000), IN colour VARCHAR(6))
BEGIN
  DECLARE checkname INT DEFAULT 0;
  SELECT COUNT(*) INTO checkname FROM categories AS cat WHERE cat.name = name;

  IF checkname = 0 THEN
    UPDATE categories AS cat SET cat.name = name, cat.description = description, cat.colour = colour WHERE cat.name = oldname;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "the specified category name already exists";
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateDocName`(IN doc_id INT, IN user_id INT, IN name VARCHAR(100))
BEGIN
  DECLARE checkCreation INT DEFAULT 0;
  -- check rights
  SELECT COUNT(*) INTO checkCreation FROM documents AS doc WHERE doc.id = doc_id AND doc.creator_id = user_id;
  IF checkCreation = 1 THEN
    UPDATE documents AS doc SET doc.name = name WHERE doc.id = doc_id;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "A user can't update other user's document";
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateDocVisibility`(IN doc_id INT, IN user_id INT, IN public ENUM("0", "1"))
BEGIN
  DECLARE checkCreation INT DEFAULT 0;
  -- check rights
  SELECT COUNT(*) INTO checkCreation FROM document AS doc WHERE doc.id = doc_id AND doc.creator_id = user_id;
  IF checkCreation = 1 THEN
    UPDATE documents AS doc SET doc.public = public WHERE doc.id = user_id;
  ELSE
    SIGNAL sqlstate '45000' set message_text = "An user can't update other user's document";
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateEvent`(IN idI INT, IN nameI VARCHAR(100), IN placeI INT, IN startdateI TIMESTAMP, IN stopdateI TIMESTAMP, IN creatorI INT, IN typeI VARCHAR(10), IN descriptionI VARCHAR(2000), IN categoryI INT)
BEGIN
  UPDATE events SET id=idI, name=nameI, place = placeI, startdate = startdateI, stopdate = stopdateI,
    creator = creatorI, type = typeI, description = descriptionI, category = categoryI
    WHERE id = idI;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateGroup`(IN group_id INT, IN name VARCHAR(100), IN image VARCHAR(300), IN description VARCHAR(2000))
BEGIN
  UPDATE groups AS grp SET grp.name = name, grp.image = image, grp.description = description WHERE grp.id = group_id;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateNote`(IN id INT, IN type VARCHAR(7), IN content TEXT, IN description VARCHAR(200))
BEGIN
  UPDATE notes AS nt SET nt.type = type, nt.content = content, nt.description = description WHERE nt.id = id;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updatePartecipationStatus`(IN event_id INT, IN user_id INT, IN status VARCHAR(20))
BEGIN
  UPDATE partecipations AS part SET part.status = status WHERE ( (part.event_id = event_id) AND (part.user_id = user_id) );
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updatePosition`(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8))
BEGIN
  IF ( (latitude IS NOT NULL) AND (longitude IS NOT NULL) ) THEN
    UPDATE users AS usr SET usr.latitude = latitude, usr.longitude = longitude WHERE (usr.id = user_id);
  END IF;
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `updateUser`( IN id INT,
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
END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `upgradeUser`(IN user_id INT)
BEGIN
    DECLARE type VARCHAR(100) DEFAULT "";
    SELECT usr.type INTO type FROM usersInfo AS usr WHERE usr.id = user_id;

    IF type="basic" THEN
      UPDATE usersInfo AS usr SET usr.type="premium" WHERE usr.id=user_id;
    ELSEIF type="premium" THEN
      SIGNAL sqlstate '45000' set message_text = "You are already premium";
    ELSE
      SIGNAL sqlstate '45000' set message_text = "User error";
    END IF;
  END$$

CREATE DEFINER=`polleg_it`@`%` PROCEDURE `userNearEvents`(IN user_id INT, IN latitude DECIMAL(11,8), IN longitude DECIMAL(11,8), IN dist INT )
BEGIN
  DECLARE userLng DOUBLE;
  DECLARE userLat DOUBLE;
  SET userLng = longitude;
  SET userLat = latitude;
  -- Get old position if not provided a new one
  IF ( ((userLat IS NULL) AND (userLng IS NULL)) OR ((userLat = 0) AND (userLng = 0)) ) THEN
    SELECT usr.longitude, usr.latitude INTO userLng, userLat FROM users AS usr WHERE (usr.id = user_id) LIMIT 1;
  END IF;
  -- Neither old position nor new position
  IF ( ((userLat IS NULL) AND (userLng IS NULL)) OR ((userLat = 0) AND (userLng = 0)) ) THEN
    SIGNAL sqlstate '45000' SET message_text = "No position, no party";
  ELSE
    -- Update Position
    call updatePosition(user_id, userLat, userLng);
    -- Find Events
    SELECT *, ( 6367 * acos( cos( radians(userLat) ) * cos( radians( evnt.latitude ) ) * cos( radians( evnt.longitude ) - radians(userLng) ) + sin( radians(userLat) ) * sin( radians( evnt.latitude ) ) ) ) AS calculated_distance
    FROM eventsInfo as evnt
    WHERE ( (evnt.type = "public") OR ( evnt.type="private" AND evnt.event_id = ANY ( SELECT part.event_id FROM partecipations AS part WHERE part.user_id = user_id)) )
    HAVING (calculated_distance < dist)
    ORDER BY calculated_distance;
  END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
  `name` varchar(100) NOT NULL,
  `description` varchar(3000) DEFAULT NULL,
  `colour` varchar(7) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`name`, `description`, `colour`) VALUES
('Lesson', 'A lesson is a structured period of time where learning is intended to occur. It involves one or more students (also called pupils or learners in some circumstances) being taught by a teacher or instructor.', '#388DD1'),
('Meeting', 'In a meeting, two or more people come together to discuss one or more topics, often in a formal setting.', '#FF9800'),
('Press Conference', 'Convention, meeting of a, usually large, group of individuals and companies in a certain field. Academic conference, in science and academic, a formal event where researchers present results, workshops, and other activities.', '#8D6E63'),
('Product Launch', 'A product launch is when a company decides to launch a new product in the market. It can be an existing product which is already in the market or it can be a completed new innovative product which the company has made.', '#F44336'),
('Seminar', 'Educational events for the training of managers and employees. Most seminars are not comparable with boring lectures. Interactivity is core!', '#9C27B0'),
('Shareholders Meeting', 'Meeting of the shareholders of a corporation, held at least annually, to elect members to the board of directors and hear reports on the business'' financial situation as well as new policy initiatives from the corporation''s management. In larger corporations, many shareholders vote via proxy.', '#3F51B5'),
('Workshop', 'A seminar, discussion group, or the like, that emphasizes exchange of ideas and the demonstration and application of techniques, skills, etc..', '#4CAF50');

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE IF NOT EXISTS `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creator_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT 'unknown document',
  `event_id` int(11) DEFAULT NULL,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `public` enum('0','1') DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `creator_id` (`creator_id`),
  KEY `event_id` (`event_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `creator_id`, `name`, `event_id`, `creationdate`, `public`) VALUES
(1, 1, 'Event Number 1', 1, '2016-04-10 18:16:09', '1'),
(2, 2, 'Documento di Filippo dell''evento 1', 1, '2016-04-10 18:17:20', '1'),
(3, 3, 'Event Number 1', 1, '2016-04-10 19:45:26', '1'),
(4, 4, 'Event Number 1', 1, '2016-04-10 19:46:36', '1'),
(5, 2, 'Lezione di lab di creazione di impresa', 3, '2016-04-11 12:12:10', '1'),
(6, 4, 'Lezione di lab di creazione di impresa', 3, '2016-04-11 12:13:13', '1'),
(7, 1, 'Lezione di lab di creazione di impresa', 3, '2016-04-11 12:31:14', '1'),
(8, 1, 'Teoria dell''Impresa', 4, '2016-04-12 12:58:32', '1'),
(9, 2, 'Le teorie sul progresso tecnologico', 4, '2016-04-12 13:01:22', '1');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE IF NOT EXISTS `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `place_id` int(11) DEFAULT NULL,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `startdate` date DEFAULT NULL,
  `stopdate` date DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `type` enum('public','private') DEFAULT 'public',
  `description` varchar(2000) DEFAULT NULL,
  `category_name` varchar(100) DEFAULT 'Meeting',
  PRIMARY KEY (`id`),
  KEY `place_id` (`place_id`),
  KEY `creator_id` (`creator_id`),
  KEY `category_name` (`category_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `name`, `place_id`, `creationdate`, `startdate`, `stopdate`, `creator_id`, `type`, `description`, `category_name`) VALUES
(1, 'Event Number 1', 5, '2016-04-10 18:10:17', '2016-04-10', '2016-04-20', 1, 'public', 'First Class Event', 'Shareholders Meeting'),
(2, 'Programmazione a casa mia', 6, '2016-04-10 19:11:41', '2016-04-11', '2016-04-11', 2, 'private', 'Proviamo a fare qualcosa di grande', 'Press Conference'),
(3, 'Lezione di lab di creazione di impresa', 7, '2016-04-11 12:12:05', '2016-04-11', '2016-04-11', 2, 'public', 'Oggi Bugamelli ha portato un''altra testimonianza', 'Lesson'),
(4, 'Teoria dell''Impresa', 8, '2016-04-12 12:58:04', '2016-04-10', '2016-06-10', 1, 'public', 'Fumagalli', 'Lesson');

--
-- Triggers `events`
--
DROP TRIGGER IF EXISTS `check_event`;
DELIMITER //
CREATE TRIGGER `check_event` BEFORE INSERT ON `events`
 FOR EACH ROW BEGIN
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

END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `eventsInfo`
--
CREATE TABLE IF NOT EXISTS `eventsInfo` (
`event_id` int(11)
,`event_name` varchar(100)
,`type` enum('public','private')
,`creationdate` timestamp
,`startdate` date
,`stopdate` date
,`event_description` varchar(2000)
,`creator_id` int(11)
,`creator_name` varchar(100)
,`creator_lastname` varchar(100)
,`place_id` int(11)
,`place_name` varchar(100)
,`address` varchar(200)
,`cap` varchar(10)
,`city` varchar(50)
,`nation` varchar(50)
,`latitude` decimal(11,8)
,`longitude` decimal(11,8)
,`category_name` varchar(100)
,`category_description` varchar(3000)
,`category_colour` varchar(7)
);
-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE IF NOT EXISTS `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `image` varchar(300) DEFAULT NULL,
  `description` varchar(2000) NOT NULL DEFAULT 'No description.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `name`, `creationdate`, `image`, `description`) VALUES
(1, 'Polleg', '2016-04-10 18:30:28', 'http://polleg.it/MDEF/Server_v02/images/570a9bc49ab4b.png', 'Polleg Group'),
(2, 'SPINO MERDA', '2016-04-10 19:35:16', '570aaaf484dc7.jpeg', 'Suca');

--
-- Triggers `groups`
--
DROP TRIGGER IF EXISTS `check_group`;
DELIMITER //
CREATE TRIGGER `check_group` BEFORE INSERT ON `groups`
 FOR EACH ROW BEGIN
  -- random image if no profile image is provided
  IF ((NEW.image IS NULL) OR (NEW.image = "null")) THEN
    SET NEW.image = CONCAT("http://lorempixel.com/200/200/sports/", CONVERT(FLOOR(RAND() * 10), CHAR(2)));
  END IF;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE IF NOT EXISTS `members` (
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `accepted` tinyint(1) DEFAULT '0',
  `role` enum('admin','normal') DEFAULT 'normal',
  `joindate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`user_id`, `group_id`, `accepted`, `role`, `joindate`) VALUES
(1, 1, 1, 'admin', '2016-04-10 18:30:28'),
(2, 1, 1, 'normal', '2016-04-10 19:06:11'),
(2, 2, 1, 'admin', '2016-04-10 19:35:16');

-- --------------------------------------------------------

--
-- Table structure for table `nodes`
--

CREATE TABLE IF NOT EXISTS `nodes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_id` int(11) DEFAULT NULL,
  `note_id` int(11) DEFAULT NULL,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `document_id` (`document_id`),
  KEY `note_id` (`note_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=55 ;

--
-- Dumping data for table `nodes`
--

INSERT INTO `nodes` (`id`, `document_id`, `note_id`, `creationdate`) VALUES
(1, 1, 1, '2016-04-10 18:16:37'),
(2, 2, 2, '2016-04-10 18:18:43'),
(3, 1, 2, '2016-04-10 18:19:14'),
(4, 2, 1, '2016-04-10 19:15:49'),
(5, 1, 3, '2016-04-10 19:27:06'),
(6, 2, 4, '2016-04-10 19:36:45'),
(7, 2, 5, '2016-04-10 19:37:38'),
(8, 1, 6, '2016-04-10 19:37:43'),
(9, 2, 7, '2016-04-10 19:41:22'),
(10, 1, 8, '2016-04-10 19:41:26'),
(11, 1, 9, '2016-04-10 19:42:35'),
(12, 2, 10, '2016-04-10 19:42:57'),
(13, 1, 11, '2016-04-10 19:43:36'),
(15, 6, 13, '2016-04-11 12:14:45'),
(17, 5, 15, '2016-04-11 12:17:59'),
(18, 5, 16, '2016-04-11 12:19:22'),
(19, 5, 17, '2016-04-11 12:20:59'),
(20, 5, 18, '2016-04-11 12:22:06'),
(21, 5, 19, '2016-04-11 12:22:56'),
(22, 5, 20, '2016-04-11 12:24:40'),
(23, 5, 21, '2016-04-11 12:26:26'),
(24, 5, 22, '2016-04-11 12:28:39'),
(25, 5, 23, '2016-04-11 12:31:10'),
(26, 5, 24, '2016-04-11 12:36:37'),
(28, 5, 25, '2016-04-11 12:47:04'),
(29, 5, 26, '2016-04-11 12:49:14'),
(30, 8, 27, '2016-04-12 12:59:59'),
(31, 8, 28, '2016-04-12 13:01:49'),
(32, 9, 29, '2016-04-12 13:03:28'),
(33, 8, 30, '2016-04-12 13:04:08'),
(34, 8, 29, '2016-04-12 13:04:13'),
(35, 8, 31, '2016-04-12 13:10:44'),
(36, 9, 32, '2016-04-12 13:10:50'),
(37, 8, 32, '2016-04-12 13:11:00'),
(38, 9, 33, '2016-04-12 13:11:10'),
(39, 8, 34, '2016-04-12 13:14:02'),
(40, 8, 35, '2016-04-12 13:20:13'),
(41, 8, 36, '2016-04-12 13:21:56'),
(42, 9, 37, '2016-04-12 13:23:41'),
(43, 9, 38, '2016-04-12 13:23:59'),
(44, 8, 39, '2016-04-12 13:29:37'),
(45, 8, 40, '2016-04-12 13:29:57'),
(46, 8, 41, '2016-04-12 13:30:09'),
(47, 9, 40, '2016-04-12 13:31:24'),
(48, 8, 42, '2016-04-12 13:31:46'),
(49, 8, 43, '2016-04-12 13:33:07'),
(50, 9, 43, '2016-04-12 13:44:49'),
(51, 8, 44, '2016-04-12 13:46:14'),
(52, 9, 44, '2016-04-12 13:50:40'),
(53, 8, 45, '2016-04-12 13:54:37'),
(54, 9, 45, '2016-04-12 14:00:49');

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE IF NOT EXISTS `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('code','text','image','link') DEFAULT 'text',
  `title` varchar(300) DEFAULT 'Note title',
  `content` text,
  `description` varchar(200) DEFAULT NULL,
  `creation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=46 ;

--
-- Dumping data for table `notes`
--

INSERT INTO `notes` (`id`, `type`, `title`, `content`, `description`, `creation`) VALUES
(1, 'image', 'Evento numero 1', '570a98859e41f.jpeg', 'Immagine numero 1', '0000-00-00 00:00:00'),
(2, 'text', 'Nota numero 2', 'Bene bene bene adesso ho scritto la prima nota sul sito. Sono molto contento.', 'Sottotitolo opzionale', '0000-00-00 00:00:00'),
(3, 'text', 'Fillo Gay', 'Fillo gay', 'Fillo Gay', '0000-00-00 00:00:00'),
(4, 'text', 'Ma spino?', 'BElla', 'Ciao ooooooo', '0000-00-00 00:00:00'),
(5, 'code', 'VEdiamo....', '{\n    ciao\n}', 'Na na na', '0000-00-00 00:00:00'),
(6, 'link', 'On fire', 'https://www.youtube.com/watch?v=wJKT8rDxXqs', 'Bombe', '0000-00-00 00:00:00'),
(7, 'link', 'Bellla', 'htp://google.it', 'google', '0000-00-00 00:00:00'),
(8, 'link', 'Danish Top 5', '', '', '0000-00-00 00:00:00'),
(9, 'link', '1', 'https://www.google.it/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwji-dL96YTMAhVDYA4KHWzCCdsQyCkIHzAA&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DUuX6YYgkVTU&usg=AFQjCNEFSbcBU6bH18tmKh40uMG5Bw3hSQ&sig2=y8v0of3VAOmI8nu_xRrDTg&bvm=bv.119028448,d.ZWU', 'Allerede is', '0000-00-00 00:00:00'),
(10, 'code', 'Belle', '<?php\n// This is a single-line comment\n\n# This is also a single-line comment\n\n/*\nThis is a multiple-lines comment block\nthat spans over multiple\nlines\n*/\n\n// You can also use comments to leave out parts of a code line\n$x = 5 /* + 15 */ + 5;\necho $x;\n?>', 'Prova', '0000-00-00 00:00:00'),
(11, 'link', '2', 'https://www.google.it/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwji-dL96YTMAhVDYA4KHWzCCdsQyCkIHzAA&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DUuX6YYgkVTU&usg=AFQjCNEFSbcBU6bH18tmKh40uMG5Bw3hSQ&sig2=y8v0of3VAOmI8nu_xRrDTg&bvm=bv.119028448,d.ZWU', 'CPH GIRLS - CHRISTOPHER', '0000-00-00 00:00:00'),
(13, 'text', 'asd', 'afnvdvnrewuvnerqwjklv', 'mica tanto', '0000-00-00 00:00:00'),
(15, 'text', 'Into', 'Seguono delle startp interessanti. \n\nCon interessanti si intende: \n- innovativa \n- digitale\n\nProgetto di open innovation di telecom italia. \n\nC''Ã¨ un''altro porgetto chiamato GIOL...', 'Cosa fanno?', '0000-00-00 00:00:00'),
(16, 'text', 'Storia', 'Scopo: selezionare idee interessanti e asseganva un grant, ma non c''era un percorso di acceleraiznoe. \n\nLo scorso anno sono stati investi 5.5 Milioni di euro. \n\nCi sono 5 acceleratori: \nMIlano Catania Bologna ecc...', 'Vediamo un po''...', '0000-00-00 00:00:00'),
(17, 'text', 'Adesso', 'Quest''anno Ã¨ una call sia per ideas che per start-up. \n\nNon basta piÃ¹ avere un''idea, bisogna avere un team che giÃ  sta lavorando su un prodotto che Ã¨ prototipale. \n\nQuesto per motivi logistici e di costo di accelerazione.', 'Cambino le cose...', '0000-00-00 00:00:00'),
(18, 'image', 'Bugamelli parla', '570b96eea2470.png', 'Ma l''apparecchio?', '0000-00-00 00:00:00'),
(19, 'link', 'Link alla WCAP', 'https://www.facebook.com/groups/222687814589406/?fref=ts', 'WCap Facebook', '0000-00-00 00:00:00'),
(20, 'text', 'Adesso', '- Grant maggiore (40 000 euro) \n- Bonus per i migliri della classe (+10k);\n- 32 progetti da accelerare\n- 3 mesi di accelerazione\n- 9 mesi di mentorship e co-working', 'Cosa Ã¨ cambiato ancora?', '0000-00-00 00:00:00'),
(21, 'code', 'Mi sto annoiando', '{\n  for(i = 0; i<10000; i++) {\n    console.log("Che noia");\n  }', 'Ho scritto del codice a caso....', '0000-00-00 00:00:00'),
(22, 'text', 'Albo veloce', 'Le start up entrano in questo albo e hanno la possibilitÃ  di diventare fornitore di telecom. \n\nEntrare come fornitore non Ã¨ facile perchÃ¨ ci sono parametri molto stringenti. \n\nPer abbattere queste difficoltÃ  Ã¨ stato creato l''albo.', 'Cos''Ã¨?', '0000-00-00 00:00:00'),
(23, 'text', 'Esempi', '- WiMan (router per connessione ai vari wifi tramite Facebook e G+);', 'Startup uscite da WCap', '0000-00-00 00:00:00'),
(24, 'text', 'Criteri di accettazione alla WCap', '- Idea interessante \n- Pitch\n- Marketing plan \n- Roadmap di sviluppo.', 'Lista:', '0000-00-00 00:00:00'),
(25, 'text', 'Bugamelli parla', 'Puglisi risponde: "Dipende dai soggetti: ci sono startup che alla fine del percorso vanno via, mentre altre rimangono e si affezionano. Il punto Ã¨ che il wcap fa ancora fatica ad unire le business unit alle startup. Ci sono degli incontri trimestrali tra le business unit (partner di TIM) e le startup in fase di accelerazione. Da quest''anno ci sono delle figure che hanno lo scopo di fare da tramite tra business che acquistano i servizi e le startup."', 'La quotidianitÃ  dell''impresa rispetto a voi com''Ã¨ scandita?', '0000-00-00 00:00:00'),
(26, 'text', 'Dpixel', 'Esiste una collaborazione tra questa impresa e wcap. \nPerÃ² adesso si Ã¨ staccato da working capital ed Ã¨ una sorta di concorrente, anche se la collaborazione rimane', 'Cos''Ã¨ e che rapporto c''Ã¨?', '0000-00-00 00:00:00'),
(27, 'text', 'Manca metÃ  lezione', '.', 'comincia dalle 15', '0000-00-00 00:00:00'),
(28, 'text', 'Intro', 'Il progresso tecnico ha creato due scuole di pensiero:\n- analisi neoclassica ortodossa\n- analisi max-schumpeteriana  eterodossa', 'intro', '0000-00-00 00:00:00'),
(29, 'text', 'Progresso tecnologico', 'Ricardo e Smith hanno considerato nella loro analisi questo fattore mentre i neo classici hanno considerato il progresso tecnologico come variabile esogeneamente data.', 'Negli anni l''analisi Ã¨ cambiata...', '0000-00-00 00:00:00'),
(30, 'text', 'Analisi neoclassica ortodossa', 'L''investimento Ã¨ la parte iniziale Ã¨ principale perchÃ¨ essenziale per creare ricchezza', '---', '0000-00-00 00:00:00'),
(31, 'text', 'Non so chi (schumpeter)', 'Dotazione iniziale:\n- Ognuno ha una dotazione iniziale (anche solo il proprio tempo)\n\nIl proprio tempo ha un valore (W ).', '--', '2016-04-12 13:10:44'),
(32, 'text', 'Gli individui', 'Un individuo ha a disposizione il tempo. Offre il suo tempo in cambio del salario.', 'Il tempo', '2016-04-12 13:10:50'),
(33, 'text', 'Non so chi', 'Dotazione iniziale:\n- Ognuno ha una dotazione iniziale (anche solo il proprio tempo)\n\nIl proprio tempo ha un valore (W ).', 'Penso Shumpeter', '2016-04-12 13:11:34'),
(34, 'text', 'Cos''Ã¨ Î©?', 'Insieme delle possibilitÃ  di consumo del consumatore (tutti sono comunque consumatori)', '--', '2016-04-12 13:14:02'),
(35, 'text', 'Produzione Ã¨ data', 'La produzione dipende dalle conoscenze scientifiche esistenti (fattore esogeno, cioÃ¨ indipendente e dato).\nIl produttore domanderÃ  anche lavoro, ma il mercato del lavoro Ã¨ price taker.', '--', '2016-04-12 13:20:13'),
(36, 'text', 'La domanda di produzione Ã¨ data [predeterminata]', 'Ma il consumo non Ã¨ price taker. I consumatori decidono se comprare in base al prezzo.\nE li compra in base alle preferenze che determinano un ranking', '--', '2016-04-12 13:21:56'),
(37, 'text', 'Analisi Neoclassica di Hicks', 'Il consumatore sceglie soggettivamente quanto acquistare in base alle preferenze mentre il produttore decide oggettivamente quanto produrre.', 'Equilibrio economico generale', '2016-04-12 13:23:41'),
(38, 'text', 'Cos''Ã¨ Î©?', 'Insieme delle possibilitÃ  di consumo del consumatore (tutti sono comunque consumatori)', 'Analizziamo le formule', '2016-04-12 13:14:02'),
(39, 'text', 'Consideriamo il breve periodo', 'y = f(k,l)\ncon k costante (nel breve periodo ragionevole)\n\npongo\ny1 = f(Kcost, L) => y2 = f(K2, L2)   \nk2>k1', '--', '2016-04-12 13:29:37'),
(40, 'image', 'Formula', '570cf85552704.jpeg', '--', '2016-04-12 13:29:57'),
(41, 'text', 'Analisi Neoclassica di Hicks', 'Il consumatore sceglie soggettivamente quanto acquistare in base alle preferenze mentre il produttore decide oggettivamente quanto produrre', 'Equilibrio economico generale', '2016-04-12 13:23:41'),
(42, 'text', 'La numero tre (prossima slide)', 'La numero 3 non puÃ² essere, non verrÃ  mai utilizzata una tecnologia che peggiora le cose.\n\nOvvero si sceglieranno le tecniche piÃ¹ produttive', '--', '2016-04-12 13:31:46'),
(43, 'image', 'Grafico', '570cf913568cd.jpeg', 'Quindi tutto si sposta verso l''alto man mano che la tecnologia migliora', '2016-04-12 13:33:07'),
(44, 'text', 'Immaginiamo ci sia un progresso tecnologico', 'Lo studiamo attraverso l''isoquanto.\n\ne il saggio marginale di sostituzione (misura la pendenza dell''isoquanto in un determinato punto.\n\n[n.b. isoquanto tiene inalterata la quantitÃ  prodotta]\n\nIL PROGRESSO TECNOLOGICO\nporterÃ  ad usare una quantitÃ  di input e/o di lavoro inferiore quindi tre possibilitÃ :\n1) - lavoro\n2) - input\n3) - lavoro e - input', 'Quali sarebbero gli effetti?', '2016-04-12 13:46:14'),
(45, 'text', 'Definizione algebrica di progresso tecnologico', '(k/y) / (k/L)\n\nK Ã¨ il capitale  ==> L/Y  ==> Ovvero il lavoro necessario per fare una quantitÃ  di prodotto.\n\n\nLa produttivitÃ  del lavoro Ã¨ calata non vuol dire che i lavoratore Ã¨ peggiorato (puÃ² anche essere dato dalla tecnologia). [?]\n\nSettori tecnologici hanno un rapporto K/L piÃ¹ alti del normale \n\nSe voglio migliorare la produzione devo aumentare il k.', '--', '2016-04-12 13:54:37');

--
-- Triggers `notes`
--
DROP TRIGGER IF EXISTS `check_note`;
DELIMITER //
CREATE TRIGGER `check_note` BEFORE INSERT ON `notes`
 FOR EACH ROW BEGIN
	IF ( (NEW.type = "image" OR NEW.type = "link") AND (NEW.description IS NULL) )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "You must provide a description";
  END IF;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `partecipations`
--

CREATE TABLE IF NOT EXISTS `partecipations` (
  `event_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` enum('accepted','declined','waiting') DEFAULT 'waiting',
  PRIMARY KEY (`event_id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `partecipations`
--

INSERT INTO `partecipations` (`event_id`, `user_id`, `status`) VALUES
(1, 1, 'accepted'),
(1, 2, 'accepted'),
(1, 3, 'accepted'),
(1, 4, 'accepted'),
(2, 1, 'accepted'),
(2, 2, 'accepted'),
(3, 1, 'accepted'),
(3, 2, 'accepted'),
(3, 3, 'waiting'),
(3, 4, 'accepted'),
(4, 1, 'accepted'),
(4, 2, 'accepted');

-- --------------------------------------------------------

--
-- Table structure for table `places`
--

CREATE TABLE IF NOT EXISTS `places` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `latitude` decimal(11,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `address` varchar(200) NOT NULL,
  `cap` varchar(10) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `nation` varchar(50) NOT NULL DEFAULT 'Italy',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

--
-- Dumping data for table `places`
--

INSERT INTO `places` (`id`, `latitude`, `longitude`, `name`, `address`, `cap`, `city`, `nation`) VALUES
(1, '44.49248530', '11.23798100', 'kk', 'Via Lazio 12', '40069', 'Zola Predosa', 'Italy'),
(2, '44.49248530', '11.23798100', 'kk', 'Via Lazio 12', '40069', 'Zola Predosa', 'Italy'),
(3, '44.49248530', '11.23798100', 'kk', 'Via Lazio 12', '40069', 'Zola Predosa', 'Italy'),
(4, '44.49248530', '11.23798100', 'kk', 'Via Lazio 12', '40069', 'Zola Predosa', 'Italy'),
(5, '44.49248530', '11.23798100', 'Polyflash', 'Via Lazio 12', '40069', 'Zola Predosa', 'Italy'),
(6, '44.31699650', '11.25567120', 'Casa di filippo Boiani', 'via val di setta 31', '40043', 'Marzabotto', 'Italy'),
(7, '44.51576270', '11.32066340', 'facoltÃ  di Ingengneria', 'Via Terracini 7', '40135', 'Bologna', 'Italy'),
(8, '44.49716400', '11.35628980', 'Ercolani', 'Mura anteo Zamboni', '40121', 'Bologna', 'Italy'),
(9, '44.49716400', '11.35628980', 'Ercolani', 'Mura anteo Zamboni', '40121', 'Bologna', 'Italy'),
(10, '44.49716400', '11.35628980', 'Ercolani', 'Mura anteo Zamboni', '40121', 'Bologna', 'Italy'),
(11, '44.49716400', '11.35628980', 'Ercolani', 'Mura anteo Zamboni', '40121', 'Bologna', 'Italy');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `lastname` varchar(100) NOT NULL,
  `born` date DEFAULT NULL,
  `subscriptiondate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `type` enum('basic','premium','admin') DEFAULT 'basic',
  `image_profile` varchar(300) DEFAULT NULL,
  `latitude` decimal(11,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `password` varchar(300) NOT NULL,
  `mail` varchar(150) NOT NULL,
  `deleted` enum('0','1') DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `lastname`, `born`, `subscriptiondate`, `type`, `image_profile`, `latitude`, `longitude`, `password`, `mail`, `deleted`) VALUES
(1, 'Riccardo', 'Sibani', '1994-09-24', '2016-04-10 16:58:02', 'premium', '570aa10634cac.jpeg', '44.49707280', '11.35661070', '21232f297a57a5a743894a0e4a801fc3', 'riccardo.sibani@gmail.com', '0'),
(2, 'Filippo', 'Boiani', '1993-10-28', '2016-04-10 18:00:24', 'premium', '570aa6b8cd4f6.jpeg', '1.00000000', '1.00000000', 'f6fdffe48c908deb0f4c3bd36c032e72', 'filippo.boiani2@gmail.com', '0'),
(3, 'Giovanni', 'Caccamo', '1994-09-24', '2016-04-10 19:29:18', 'basic', 'http://api.randomuser.me/portraits/men/7.jpg', '44.69840160', '10.44850470', '0fe4f43e1dd173abc07ce508a74800e2', 'giovannicaccamo@gmail.com', '0'),
(4, 'John', 'Doe', '1993-09-30', '2016-04-10 19:33:08', 'premium', 'http://api.randomuser.me/portraits/men/8.jpg', '44.51436850', '11.32080620', 'e45d37b96e04014bdd286bb60cdc0f8a', 'admin@admin.it', '0');

--
-- Triggers `users`
--
DROP TRIGGER IF EXISTS `check_user`;
DELIMITER //
CREATE TRIGGER `check_user` BEFORE INSERT ON `users`
 FOR EACH ROW BEGIN
  -- CURRENT_TIMESTAMP() - UNIX_TIMESTAMP(NEW.born) > 1009846861  -- 14yo in timestamp
	IF (NEW.born IS NULL) OR ( (YEAR(CURRENT_TIMESTAMP()) - YEAR(NEW.born) - (DATE_FORMAT(CURRENT_TIMESTAMP(), '%m%d') < DATE_FORMAT(NEW.born, '%m%d'))) < 14 )
  THEN
    SIGNAL sqlstate '45000' SET message_text = "Age must be more than 14 yo";
	END IF;

	IF ( (NEW.mail NOT REGEXP '^[A-Z0-9._%-]+@[A-Z0-9.-]+.[A-Z]{2,4}$' ) OR (NEW.mail = ANY (SELECT usr.mail FROM users AS usr WHERE usr.deleted = "0")) )
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
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `usersInfo`
--
CREATE TABLE IF NOT EXISTS `usersInfo` (
`id` int(11)
,`name` varchar(100)
,`lastname` varchar(100)
,`born` date
,`subscriptiondate` timestamp
,`type` enum('basic','premium','admin')
,`image_profile` varchar(300)
,`mail` varchar(150)
);
-- --------------------------------------------------------

--
-- Structure for view `eventsInfo`
--
DROP TABLE IF EXISTS `eventsInfo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`polleg_it`@`%` SQL SECURITY DEFINER VIEW `eventsInfo` AS select `evnt`.`id` AS `event_id`,`evnt`.`name` AS `event_name`,`evnt`.`type` AS `type`,`evnt`.`creationdate` AS `creationdate`,`evnt`.`startdate` AS `startdate`,`evnt`.`stopdate` AS `stopdate`,`evnt`.`description` AS `event_description`,`usr`.`id` AS `creator_id`,`usr`.`name` AS `creator_name`,`usr`.`lastname` AS `creator_lastname`,`plc`.`id` AS `place_id`,`plc`.`name` AS `place_name`,`plc`.`address` AS `address`,`plc`.`cap` AS `cap`,`plc`.`city` AS `city`,`plc`.`nation` AS `nation`,`plc`.`latitude` AS `latitude`,`plc`.`longitude` AS `longitude`,`evnt`.`category_name` AS `category_name`,`cat`.`description` AS `category_description`,`cat`.`colour` AS `category_colour` from (((`events` `evnt` join `places` `plc`) join `usersInfo` `usr`) join `categories` `cat`) where ((`evnt`.`place_id` = `plc`.`id`) and (`evnt`.`creator_id` = `usr`.`id`) and (`cat`.`name` = `evnt`.`category_name`));

-- --------------------------------------------------------

--
-- Structure for view `usersInfo`
--
DROP TABLE IF EXISTS `usersInfo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`polleg_it`@`%` SQL SECURITY DEFINER VIEW `usersInfo` AS select `users`.`id` AS `id`,`users`.`name` AS `name`,`users`.`lastname` AS `lastname`,`users`.`born` AS `born`,`users`.`subscriptiondate` AS `subscriptiondate`,`users`.`type` AS `type`,`users`.`image_profile` AS `image_profile`,`users`.`mail` AS `mail` from `users` where (`users`.`deleted` = '0');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `events_ibfk_1` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`),
  ADD CONSTRAINT `events_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `events_ibfk_3` FOREIGN KEY (`category_name`) REFERENCES `categories` (`name`) ON DELETE SET NULL;

--
-- Constraints for table `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `members_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `nodes`
--
ALTER TABLE `nodes`
  ADD CONSTRAINT `nodes_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `nodes_ibfk_2` FOREIGN KEY (`note_id`) REFERENCES `notes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `partecipations`
--
ALTER TABLE `partecipations`
  ADD CONSTRAINT `partecipations_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `partecipations_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
