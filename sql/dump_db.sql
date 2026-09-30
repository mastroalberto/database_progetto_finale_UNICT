USE SCUOLA_MUSICA;

-- 1. Popolamento tabella Aula
INSERT INTO Aula (ID_Aula, Strumento_fisso, Numero_posti) VALUES
(1, TRUE, 10),
(2, TRUE, 5),
(3, FALSE, 15),
(4, FALSE, 8),
(5, TRUE, 20),
(6, FALSE, 12);

-- 2. Popolamento tabella Docente
INSERT INTO Docente (ID_Docente, nome, cognome, specializzazione, compenso_orario) VALUES
(1, 'Marco', 'Rossi', 'pianoforte', 25.00),
(2, 'Laura', 'Bianchi', 'batteria', 22.50),
(3, 'Giuseppe', 'Verdi', 'chitarra', 20.00),
(4, 'Elena', 'Neri', 'violino', 28.00),
(5, 'Alessandro', 'Gialli', 'canto', 24.00),
(6, 'Sofia', 'Marroni', 'basso', 21.50);

-- 3. Popolamento tabella Studente
INSERT INTO Studente (matricola, nome, cognome, codice_fiscale, livello) VALUES
(1001, 'Luca', 'Moretti', 'MRTLCA01A01H501U', 1),
(1002, 'Chiara', 'Ferrari', 'FRRCHR02B42F205X', 2),
(1003, 'Matteo', 'Esposito', 'SPSMTT00C15F839Y', 1),
(1004, 'Sara', 'Romano', 'RMNSRA03D50L219Z', 3),
(1005, 'Davide', 'Colombo', 'CLMDVD99E20F205W', 2),
(1006, 'Giulia', 'Ricci', 'RCCGLI04H60H501V', 1);

-- 4. Popolamento tabella Categoria_Strumento
INSERT INTO Categoria_Strumento (categoria_strumento) VALUES
('Pianoforti e Tastiere'),
('Percussioni'),
('Chitarre'),
('Archi'),
('Fiati'),
('Bassi');

-- 5. Popolamento tabella Strumento
-- Nota: gli strumenti che verranno inseriti in Noleggio sono impostati a FALSE
-- perché il trigger "noleggio_strumento" blocca il noleggio se noleggiato = TRUE
INSERT INTO Strumento (ID_Strumento, noleggiato, categoria_strumento) VALUES
(101, FALSE, 'Chitarre'),
(102, FALSE, 'Archi'),
(103, FALSE, 'Fiati'),
(104, FALSE, 'Bassi'),
(105, FALSE, 'Pianoforti e Tastiere'),
(106, FALSE, 'Percussioni');

-- 6. Popolamento tabella Prodotto
INSERT INTO Prodotto (nome, cod_prodotto, categoria_merceologica, quantità) VALUES
('Muta corde chitarra acustica', 501, 'Accessori Chitarra', 50),
('Bacchette batteria 5A', 502, 'Accessori Batteria', 35),
('Spartiti Musica Classica Vol. 1', 503, 'Libri e Spartiti', 20),
('Plettri assortiti (confezione 10pz)', 504, 'Accessori Chitarra', 100),
('Colofonia per violino', 505, 'Accessori Archi', 15),
('Metronomo digitale', 506, 'Elettronica', 25);

-- 7. Popolamento tabella Workshop
INSERT INTO Workshop (ID_workshop, data_workshop, numero_partecipanti) VALUES
(1, '2025-05-10', 15),
(2, '2025-05-17', 10),
(3, '2025-05-24', 20),
(4, '2025-06-07', 12),
(5, '2025-06-14', 8),
(6, '2025-06-21', 18);

-- 8. Popolamento tabella Lezione
-- Nota: i docenti 1 (pianoforte) e 2 (batteria) sono associati ad aule con Strumento_fisso = TRUE (aule 1, 2, 5)
INSERT INTO Lezione (ID_lezione, data_lezione, ID_Aula, ID_Docente, fascia_oraria) VALUES
(1, '2025-04-10 00:00:00', 1, 1, '14:00:00'),
(2, '2025-04-10 00:00:00', 2, 2, '15:00:00'),
(3, '2025-04-11 00:00:00', 3, 3, '16:00:00'),
(4, '2025-04-11 00:00:00', 4, 4, '17:00:00'),
(5, '2025-04-12 00:00:00', 5, 5, '10:00:00'),
(6, '2025-04-12 00:00:00', 6, 6, '11:00:00');

-- 9. Popolamento tabella Pagamento
INSERT INTO Pagamento (ID_Pagamento, data_pagamento, data_scadenza, stato_pagamento, importo, matricola) VALUES
(1, '2025-03-01', '2025-03-10', TRUE, 120, 1001),
(2, '2025-03-05', '2025-03-10', TRUE, 150, 1002),
(3, '2025-03-12', '2025-03-10', FALSE, 120, 1003),
(4, '2025-03-08', '2025-03-15', TRUE, 180, 1004),
(5, '2025-03-14', '2025-03-15', TRUE, 150, 1005),
(6, '2025-03-20', '2025-03-15', FALSE, 120, 1006);

-- 10. Popolamento tabella Stipendio
INSERT INTO Stipendio (cod_pagamento, data_mensilità, importo, ID_Docente) VALUES
(1, '2025-03-31', 850.00, 1),
(2, '2025-03-31', 720.50, 2),
(3, '2025-03-31', 640.00, 3),
(4, '2025-03-31', 910.00, 4),
(5, '2025-03-31', 780.00, 5),
(6, '2025-03-31', 690.50, 6);

-- 11. Popolamento tabella Noleggio
INSERT INTO Noleggio (FK_matricola, FK_ID_strumento, data_inizio, data_fine) VALUES
(1001, 101, '2025-04-01', '2025-06-30'),
(1002, 102, '2025-04-02', '2025-07-02'),
(1003, 103, '2025-04-05', '2025-05-05'),
(1004, 104, '2025-04-10', '2025-08-10'),
(1005, 105, '2025-04-12', '2025-06-12'),
(1006, 106, '2025-04-15', '2025-07-15');

-- 12. Popolamento tabella Acquisto_Prodotto
INSERT INTO Acquisto_Prodotto (FK_matricola, FK_cod_prodotto, quantità) VALUES
(1001, 501, 2),
(1002, 502, 1),
(1003, 503, 1),
(1004, 504, 3),
(1005, 505, 1),
(1006, 506, 1);

-- 13. Popolamento tabella Partecipazione_Lezioni
INSERT INTO Partecipazione_Lezioni (FK_matricola, FK_ID_lezione) VALUES
(1001, 1),
(1002, 2),
(1003, 3),
(1004, 4),
(1005, 5),
(1006, 6);

-- 14. Popolamento tabella Calendario_Workshop
INSERT INTO Calendario_Workshop (FK_ID_aula, FK_iD_workshop, data_workshop, fascia_oraria) VALUES
(1, 1, '2025-05-10 00:00:00', '10:00:00'),
(2, 2, '2025-05-17 00:00:00', '15:00:00'),
(3, 3, '2025-05-24 00:00:00', '11:00:00'),
(4, 4, '2025-06-07 00:00:00', '16:00:00'),
(5, 5, '2025-06-14 00:00:00', '09:30:00'),
(6, 6, '2025-06-21 00:00:00', '14:30:00');

-- 15. Popolamento tabella Partecipazione_docenti_WS
INSERT INTO Partecipazione_docenti_WS (FK_ID_Docente, FK_iD_workshop) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6);