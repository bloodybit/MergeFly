
INSERT INTO `users` (`id`, `name`, `lastname`, `born`, `subscriptiondate`, `type`, `image_profile`, `latitude`, `longitude`, `password`, `mail`, `deleted`) VALUES
(1, 'Filippo', 'Boiani', '1993-10-28', '2016-02-29 22:26:13', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail1.com', '0'),
(2, 'Riccardo', 'Sibani', '1994-09-24', '2016-02-29 22:34:38', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail2.com', '0'),
(3, 'Ludovico', 'Loreti', '1992-11-11', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'ludo@vico.it', '0'),
(4, 'Antonio', 'Messina', '1899-05-15', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail4.com', '0'),
(5, 'Andrea', 'Dipre', '1960-02-09', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail5.com', '0'),
(6, 'Marco', 'Giuliano', '1978-06-20', '2016-02-29 22:08:42', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail6.com', '0'),
(7, 'Salvatore', 'Aranzulla', '1983-12-31', '2016-03-9 12:08:42', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail7.com', '0'),
(8, 'Steve', 'Jobs', '1957-08-05', '2016-03-9 12:12:42', 'basic', NULL, '44.48407585', '11.23867035', '21232f297a57a5a743894a0e4a801fc3', 'mail@mail8.com', '0')
;
-- PASSWORD : admin (che con md5 diventa: 21232f297a57a5a743894a0e4a801fc3)

INSERT INTO `categories` (`name`, `description`, `colour`) VALUES
('Lesson', 'A lesson is a structured period of time where learning is intended to occur. It involves one or more students (also called pupils or learners in some circumstances) being taught by a teacher or instructor.', '#388DD1'),
('Meeting', 'In a meeting, two or more people come together to discuss one or more topics, often in a formal setting.', '#FF9800'),
('Press Conference', 'Convention, meeting of a, usually large, group of individuals and companies in a certain field. Academic conference, in science and academic, a formal event where researchers present results, workshops, and other activities.', '#8D6E63'),
('Product Launch', 'A product launch is when a company decides to launch a new product in the market. It can be an existing product which is already in the market or it can be a completed new innovative product which the company has made.', '#F44336'),
('Seminar', 'Educational events for the training of managers and employees. Most seminars are not comparable with boring lectures. Interactivity is core!', '#9C27B0'),
('Shareholders Meeting', 'Meeting of the shareholders of a corporation, held at least annually, to elect members to the board of directors and hear reports on the business'' financial situation as well as new policy initiatives from the corporation''s management. In larger corporations, many shareholders vote via proxy.', '#3F51B5'),
('Workshop', 'A seminar, discussion group, or the like, that emphasizes exchange of ideas and the demonstration and application of techniques, skills, etc..', '#4CAF50')
;

INSERT INTO `places` (`id`, `latitude`, `longitude`, `name`, `address`, `cap`, `city`, `nation`) VALUES
(1, '44.4964631', '11.345818099999974', 'Tim Wcap', 'Via Guglielmo Oberdan, 22', "40126", 'Bologna', 'Italy'),
(2, '44.4675576', '11.346709799999985', 'Bologna Business School', 'Via degli Scalini, 18,', '40136', 'Bologna', 'Italy'),
(3, '44.490995', '11.335101', 'Palazzo re Enzo', 'Piazza del Nettuno 1', "40124", 'Bologna', 'Italy'),
(4, '44.501280', '11.340165', 'Villa Antani', 'Piazza di Villa Antani 27', '40125', 'Bologna', 'Italy'),
(5, '44.496260', '11.343770', 'Palazzo del Monte', 'Via del Monte, 6', '40126', 'Bologna', 'Italy'),
(6, '44.490260', '11.348748', 'Casa di Jerry Cala', 'Via De Chiari, 6', '40124', 'Bologna', 'Italy'),
(7, '44.493577', '11.342823', 'Basilica di San Petronio', 'Piazza Maggiore, 1', '40124', 'Bologna', 'Italy'),
(8, '44.490066', '11.357298', 'Porta Maggiore', 'Piazza di Porta Maggiore', '40125', 'Bologna', 'Italy'),
(9, '44.4960999', '11.354332', 'Facolta di Scienze Matematiche, Fisiche e Naturali', 'Piazza di Porta San Donato', '40126', 'Bologna', 'Italy'),
(10, '45.4640976', '9.191926500000022', 'Duomo di Milano', 'Piazza Duomo 1', '20123', 'Milano', 'Italy'),
(11, '43.722952', '10.396596999999929', 'Torre di Pisa', 'Piazza dei miracoli', '56126', 'Pisa', 'Italy'),
(12, '44.4881095', '11.328420499999993', 'Universita degli studi di Bologna, Facolta di Ingegneria', 'Viale del Risorgimento, 2', '40136', 'Bologna', 'Italy'),
(13, '44.4791000', '11.11.2981', 'Santuario della Madonna di San Luca', 'Via di San Luca, 36', '40135', 'Bologna', 'Italy')
;

INSERT INTO `events` (`id`, `name`, `place_id`, `creationdate`, `startdate`, `stopdate`, `creator_id`, `type`, `description`, `category_name`) VALUES
(1, 'Innovation and Project Management. Basis For Success', 2, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Per sostenere la globalizzazione e un mercato sempre piu veloce.', 'Workshop'),
(2, 'Salto dalla torre', 11, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Bello da morire! ', 'Meeting'),
(3, 'Rob0t Festival', 3, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'Pompo nelle casse', 'Lesson'),
(4, 'Visita alla Madonna', 13, '2016-02-29 22:08:42', '2016-02-29 22:08:42', '2016-02-29 22:08:42', 1, 'public', 'The Sanctuary of the Madonna of San Luca is a basilica church in Bologna, northern Italy, sited atop a forested hill, Colle or Monte della Guardia, some 300 metres above the city plain, just southwest of the historical centre of the city', 'Lesson')
;


INSERT INTO `groups` (`id`, `name`, `creationdate`, `image`, `description`) VALUES
(1, 'Young innovators', '2016-02-29 23:42:33', NULL, 'Innovation is a new idea, or more-effective device or process. Innovation can be viewed as the application of better solutions that meet new requirements, unarticulated needs, or existing market needs.');

INSERT INTO `members` (`user_id`, `group_id`, `accepted`, `role`, `joindate`) VALUES
(1, 1, 1, 'admin', '2016-02-29 23:45:11'),
(2, 1, 1, 'normal', '2016-02-29 23:45:12'),
(3, 1, 1, 'normal', '2016-02-29 23:44:29'),
(4, 1, 1, 'normal', '2016-02-29 23:45:11'),
(5, 1, 1, 'normal', '2016-02-29 23:45:11');

INSERT INTO `partecipations` (`event_id`, `user_id`, `status`) VALUES
(1, 1, 'accepted'),
(3, 1, 'accepted'),
(1, 2, 'accepted'),
(1, 3, 'waiting'),
(1, 4, 'accepted'),
(1, 5, 'waiting')
;

INSERT INTO documents(creator_id, name, event_id) VALUES
(1, 'Documento Workshop e innovazione', 1),
(2, 'Saltare da 80 metri fa male', 2),
(3, 'Report della festa migliore al mondo', 3);




-- who creates an event is a partecipant!
-- check ho creates documents and notes!
-- category name as primary key? -- ok
