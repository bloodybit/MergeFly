/* login */
/* updatePosition */
/* getUser */
  call login('mail@mail.com', 'HASHEDPASS', 44.49000, 11.36000); -- ok
  call login('mail@mail.com', 'HASHEDPASS', 0.0000, 0.00000);
  call login('mail@mail.com', 'HASHEDPASS', null, null); -- ok

/* insertUser TODO */
  call insertUser('Ippolito', 'Nievo', '1945-10-10', 0, 'percorso/del/file', 'hash(pwd)', 'email@notduplicated.com', @last_id); -- ok
  select @last_id;
  -- control duplicate
  call insertUser('Ippolito', 'Nievo', '1945-10-10', 0, 'percorso/del/file', 'hash(pwd)', 'email@notduplicated.com', @last_id);

/* userNearEvents */
  call userNearEvents(1, 44.49, 11.36, 100); -- ok
  call userNearEvents(1, null, null, 100); -- ok

  call updatePosition(1, null, null); -- can't update with a null position
  call userNearEvents(6, null, null, 100); -- user with no position: no position no party

/* getUserEvents */
  call getUserEvents(1, 'next'); -- ok
  call getUserEvents(1, 'past'); -- ok
  call getUserEvents(1, 'all'); -- ok
  -- no related events
  call getUserEvents(6, 'all'); -- ok: no results

/* searchEvents */
  call searchEvents(1, 'a'); -- ok
  call searchEvents(3, 'a'); -- ok: different partecipations

/* suggestedEvents TODO*/

/* suggestedPlaces */
  call suggestedPlaces(44.00, 11.00, 100); -- ok
  call suggestedPlaces(44.00, 11.00, 38.2); -- ok

/* updateUser */
  call insertUser('Sarai', 'Cancellato', '1995-10-10', 0, 'percorso/foto', 'hash(pwd)', 'ti@cancello.com', @last_id); -- ok
  call updateUser(@last_id, 'NomeCambiato', 'Cancellato', '1995-10-10', 'percorso/foto','ti@cancello.com'); -- ok

/* upggradeUser */
  call upgradeUser(@last_id); -- ok
  call upgradeUser(@last_id); -- ok: Throws an signal "You are already premium"
  call upgradeUser(-1); -- ok: Throws an signal "User error"

/* changePassword */
  call changePassword(@last_id, "hash(pwd)", "hash(new_pwd)"); -- ok

/* deleteUser */
  call deleteUser(@last_id); -- ok: no dependencies because it's like an update

/* damnatioMemoriae*/
  call damnatioMemoriae(@last_id); -- ok: no dependencies
  call damnatioMemoriae(5) -- ERROR! we need to handle dependencies

/* getEvents */
  -- ok

/* getEvent */
  call getEvent(1, 1); -- TODO: check categories

/* addEvent */
  call addEvent('Kung Fu fighting', 'that kid was fast as lightning', 1, current_timestamp, current_timestamp, 4, 'public'); -- ok
  call addEvent('Private workshop', 'japan karaoke', 3, current_timestamp, current_timestamp, 4, 'private'); -- ok: error the user is not allowed

/* updateEvent */

/* addPlace */

/* createCategory */
  call createCategory("new category", "prova di una categoria", "black"); -- ok

/* getCategories */
  call getCategories(); -- ok

/* updateCategory */
  call updateCategory("new category", "new cat updated", "update", "newcol" ); -- ok
  call updateCategory("new cat updated", "new cat updated", "update", "newcol"); -- ok
  call updateCategory("new cat updated", "new cat updated", "update", "newcol"); -- it must update al category name in every event TODO

/* getUserDocs */
  call getUserDocs(1);

/* getUserDoc */
  call getUserDoc(1);

/* createDoc */
  call createDoc(1, "new document", 4, '1');

/* updateDocName */
  call updateDocName(1, 1, "Name updated");

/* updateDocVisibility */
  call updateDocVisibility(1, 1, "0");

/* getDocContent */

/* createNote */
call createNote('text', 'content', 'description', @lastid); -- ok
select @lastid;

/* createNode */
call createNode(1,1,'Bel titolo'); -- ok

/* addNoteToDoc */
call addNoteToDoc('code', 'code content', 'code desc', 1, 'addNoteToDoc'); -- ok

/* getGroupMembers */
call getGroupMembers(1);  -- ok
/* getEventPartecipants */
call getEventPartecipants(1);   -- ok
/* createGroup */
call createGroup('Group1', '/img/', 'Group1 description', 1);  -- ok
/* addMember */
call addMember(2, 1);   -- ok
/* acceptMembership */
call acceptMembership(2, 1);  -- ok
/* getUserGroups */
call getUserGroups(1); -- ok
-----------------------
/* updateGroup */
call updateGroup(2, 'Group1MODIFIED', 'img/', 'Group1MODIFIED2');   -- ok
/* getGroupInfo */
call getGroupInfo(2); -- ok
/* getPlace */
call getPlace(1);   -- ok
/* addPartecipant */
addPartecipant(1, 2);
addPartecipant(5, 2);                                             --------------------------------- NOOOOOOOOOOOOOOOO
/* updatePartecipationStatus */
call updatePartecipationStatus()--------------------------------- NOOOOOOOOOOOOOOOON CAPISCO
/* addNote */ -- NO
call addNote('link', 'www.google.com', "Google's Website");       -- ok
/* getNote */ -- ??
call getNote(1);      -- ok
/* updateNote */ -- ??
call updateNote(1, 'link', 'www.google.it', 'Sito di Google');
/* searchUser */
call searchUser('ani');     -- ok
/* searchGroup */
call searchGroup('1');    -- ok
/* addGroupToEvent */
call addGroupToEvent(2, 7);   -- ok
