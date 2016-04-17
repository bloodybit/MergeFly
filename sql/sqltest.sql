/****** TRIGGERS TRIALS *******/

/* Tests for change_admin */


/* Tests for check_age */
insert into users(name, lastname, born, subscriptiondate,password, mail) values("ciccio", "prova1", CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), "bellaaaaaa", "bellllla@mail.com");
insert into users(name, lastname, subscriptiondate,password, mail) values("ciccio", "prova1", CURRENT_TIMESTAMP(), "bellaaaaaa", "bellllla@mail.com");




/****** STORED PROCEDURES TRIALS *******/
DELIMITER |
CREATE PROCEDURE getData(OUT TotPrenotazioni int)
BEGIN
	DECLARE b timestamp default 0;
	SELECT born INTO b FROM users WHERE (id=1);
	SELECT year(CURRENT_TIMESTAMP()) - year(b);
END |
DELIMITER ;

call getData(@x);
/* Test of stored procedure */
insert into users(name, lastname, born, subscriptiondate, password, mail, actual_lat, actual_lng) values("Filippo", "Boiani", "1993-10-28", CURRENT_TIMESTAMP(), "HASHEDPASS", "mail@mail.com", 44.48407585006587, 11.238670349121094);
insert into users(name, lastname, born, subscriptiondate, password, mail, actual_lat, actual_lng) values("Riccardo", "Sibani", "1994-09-24", CURRENT_TIMESTAMP(), "HASHEDPASS", "mail@mail.com", 44.48407585006587, 11.238670349121094);
insert into users(name, lastname, born, subscriptiondate, password, mail, actual_lat, actual_lng) values("Ludovico", "Loreti", "1992-11-11", CURRENT_TIMESTAMP(), "HASHEDPASS", "mail@mail.com", 44.48407585006587, 11.238670349121094);
insert into users(name, lastname, born, subscriptiondate, password, mail, actual_lat, actual_lng) values("Antonio", "Messina", "1899-01-01", CURRENT_TIMESTAMP(), "HASHEDPASS", "mail@mail.com", 44.48407585006587, 11.238670349121094);
insert into users(name, lastname, born, subscriptiondate, password, mail, actual_lat, actual_lng) values("Andrea", "Diprè", "1960-01-01", CURRENT_TIMESTAMP(), "HASHEDPASS", "mail@mail.com", 44.48407585006587, 11.238670349121094);

insert into places(lat, lng, name, address, city, nation)  values(44.48407585304587, 11.238670349122094, "Duomo di Milano", "Piazza Duomo 1", "Milano", "Italy");
insert into places(lat, lng, name, address, city, nation)  values(44.48407583333333, 11.238670341111111, "Torre di Pisa", "Piazza dei miracoli", "Pisa", "Italy");
insert into places(lat, lng, name, address, city, nation)  values(24.48407585304587, 41.238670349122094, "Palazzo re Enzo", "Piazza del Nettuno 1", "Bologna", "Italy");

insert into events(name, place, creationdate, startdate, stopdate, creator, description) values("Saluto alla Madonna", 1, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, "Bellissmo Evento");
insert into events(name, place, creationdate, startdate, stopdate, creator, description) values("Salto dalla torre", 2, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, "Bello da morire");
insert into events(name, place, creationdate, startdate, stopdate, creator, description) values("Rob0t Festival", 3, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, "Pompo nelle casse");
insert into events(name, place, creationdate, startdate, stopdate, creator, description) values("Evento Lontano Lonatano", 3, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, "Non so");
insert into events(name, place, creationdate, startdate, stopdate, creator, description) values("Evento Vicino Vicino", 1, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, "Speriamo vada");
insert into events(name, place, creationdate, startdate, stopdate, creator, description) values("Tutti al mare", 2, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 1, "Fa un po' freddo");

insert into groups(name) values("Ciccio");

insert into members(iduser, idgroup, accepted) values (3, 1, 1);
insert into members(iduser, idgroup, accepted) values (4, 1, 1);
insert into members(iduser, idgroup, accepted) values (5, 1, 1);
insert into members(iduser, idgroup, accepted) values (1, 1, 1);
insert into members(iduser, idgroup, accepted) values (2, 1, 1);
/* Test insertUser() */
call insertUser("Riccardo", "Sibani", "1994-09-24", 2, "....", "hashfunction(password+salt)", "riccardo@mail.com", @id);
select @id;

/* Test UserNearEvents() */
call UserNearEvents(5, 6);
select * from UserNearEvents;

/* Test login() */
call login("asdfasfd", "sgsfgsd", @out);
select @out;
