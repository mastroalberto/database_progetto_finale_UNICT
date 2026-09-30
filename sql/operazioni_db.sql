USE SCUOLA_MUSICA; 

-- [OP1] Registrazione nuovo allievo nella scuola 
INSERT INTO Studente(matricola, nome, cognome, codice_fiscale, livello)
VALUES (893092, 'Giovanni', 'Crescenzi', 'gvncrsn04p18c351k', 2); 

-- [OP2] Calcolo stipendi mensili docenti
SELECT 
	L.ID_Docente, 
	D.nome, 
	D.cognome, 
	MONTH(L.data_lezione) AS mese, 
	YEAR(L.data_lezione) AS Anno, 
	COUNT(L.ID_Lezione) AS numero_lezioni, 
	(COUNT(L.ID_Lezione) * D.compenso_orario) AS stipendio_mensile
FROM Lezione L 
JOIN Docente D ON L.ID_Docente = D.ID_Docente
GROUP BY 
	L.ID_Docente,
	D.nome, 
	D.cognome, 
	YEAR(L.data_lezione), 
	MONTH(L.data_lezione); 

-- [OP3] Registrazione di una nuova lezione 
INSERT INTO Lezione(ID_Lezione, data_lezione, ID_Aula, ID_Docente, fascia_oraria) 
VALUES (28939, '18-12-2025', 18, 4898, '18:00:00'); 

-- [OP4-5] Acquisto di accessori
INSERT INTO Acquisto_prodotto(FK_matricola, FK_cod_prodotto, quantità)
VALUES (893092, 181911, 3); 

-- [OP5] Aggiornamento prodotti magazzino
DELIMITER //
CREATE TRIGGER aggiornamento_quantità_magazzino 
AFTER INSERT ON Acquisto_prodotto 
FOR EACH ROW 
BEGIN 
	UPDATE Prodotto 
	SET quantità = quantità - NEW.quantità
	WHERE cod_prodotto = NEW.FK_cod_prodotto; 
END //

-- [OP6] Registrazione di nuovi workshop
INSERT INTO Workshop(ID_Workshop, data_workshop, numero_partecipanti) 
VALUES (1928, '19-10-2026', 12); 

-- [OP7] prenotazione aule 
INSERT INTO Lezione(ID_Lezione, data_lezione, ID_Aula, ID_Docente, fascia_oraria) 
VALUES (12493, '24-03-2026', 12, 4898, '15:00:00'); 
-- o in alternativa per il workshop 
INSERT INTO Calendario_Workshop(FK_ID_Aula, FK_ID_Workshop, data_workshop, fascia_oraria) 
VALUES(14, 19109, '07-02-2026', '19:00:00'); 

-- [OP8] Noleggio strumenti forniti dalla scuola 
INSERT INTO Noleggio(FK_matricola, FK_ID_Strumento, data_inizio, data_fine) 
VALUES (18930, 48930, '19-02-2026', '20-03-2027'); 

-- [OP9] Controllo pagamenti delle lezioni 
CREATE VIEW lista_pagamenti_in_ritardo 
SELECT S.nome, S.cognome, S.matricola, P.ID_pagamento, P.data_scadenza, P.stato_pagamento, P.importo
FROM Studente S Join Pagamento P on S.matricola = P.matricola
WHERE P.stato = 'non pagato' and P.data_scadenza < CURRENT_DATE(); 

-- [OP10] Verifica di disponibilità di tutte le aule in una fascia oraria 
DELIMITER //
CREATE PROCEDURE verifica_disponibiltà_aula (IN param_data, IN param_fascia_oraria) 
BEGIN 
	SELECT A.ID_Aula
	FROM Aula A 
	WHERE A.ID_Aula NOT IN ( 
		SELECT ID_Aula 
		FROM Lezione 
		WHERE data_lezione = param_data AND fascia_oraria = param_fascia_oraria; 
	) 
	AND NOT IN ( 
		SELECT ID_Aula
		FROM Calendario_Workshop 
		WHERE data_workshop = param_data AND fascia_oraria = param_fascia_oraria; 
	) 
END //

CALL verifica_disponibiltà_aula('28-11-2026', '15:00:00'); 
