DROP DATABASE IF EXISTS SCUOLA_MUSICA;
CREATE DATABASE SCUOLA_MUSICA;
USE SCUOLA_MUSICA; 

-- 1 Creazione delle tabelle 
CREATE TABLE Aula (
    ID_Aula INT PRIMARY KEY,
    Strumento_fisso BOOLEAN,
	Numero_posti INT
); 

CREATE TABLE Docente( 
	ID_Docente INT PRIMARY KEY,
	nome VARCHAR(60) NOT NULL,
	cognome VARCHAR(60) NOT NULL,
	specializzazione VARCHAR(60) NOT NULL, 
	compenso_orario DECIMAL(3,2)
); 

CREATE TABLE Lezione( 
	ID_lezione INT PRIMARY KEY,
	data_lezione DATETIME,
	ID_Aula INT,
	ID_Docente INT,
	fascia_oraria TIME, 
	FOREIGN KEY (ID_Aula) REFERENCES Aula(ID_Aula),
	FOREIGN KEY (ID_Docente) REFERENCES Docente(ID_Docente)
); 

CREATE TABLE Studente( 
	matricola INT PRIMARY KEY,
	nome VARCHAR(60) NOT NULL,
	cognome VARCHAR(60) NOT NULL,
	codice_fiscale VARCHAR(16) UNIQUE NOT NULL,
	livello INT
); 

CREATE TABLE Pagamento(
	ID_Pagamento INT PRIMARY KEY,
	data_pagamento DATE NOT NULL,
	data_scadenza DATE, 
	stato_pagamento BOOLEAN NOT NULL, 
	importo INT,
	matricola INT NOT NULL,
	FOREIGN KEY (matricola) REFERENCES Studente(matricola)
); 

CREATE TABLE Categoria_Strumento ( 
	categoria_strumento VARCHAR(60) PRIMARY KEY,
); 

CREATE TABLE Strumento( 
	ID_Strumento INT PRIMARY KEY,
	noleggiato BOOLEAN NOT NULL,
	categoria_strumento VARCHAR(60),
	FOREIGN KEY (categoria_strumento) REFERENCES Categoria_Strumento(categoria_strumento) 
);

CREATE TABLE Prodotto( 
	nome VARCHAR(128), 
	cod_prodotto INT PRIMARY KEY, 
	categoria_merceologica VARCHAR(128), 
	quantità INT
); 

CREATE TABLE Stipendio( 
	cod_pagamento INT PRIMARY KEY,
	data_mensilità DATE,
	importo DECIMAL(5,2),
	ID_Docente INT NOT NULL,
	FOREIGN KEY (ID_Docente) REFERENCES Docente(ID_Docente)
);	

CREATE TABLE Noleggio( 
	FK_matricola INT,
	FK_ID_strumento INT,
	data_inizio DATE,
	data_fine DATE CHECK (data_fine > data_inizio) NOT NULL,
	PRIMARY KEY (FK_matricola, FK_ID_strumento, data_inizio), 
	FOREIGN KEY (FK_matricola) REFERENCES Studente(matricola), 
	FOREIGN KEY (FK_ID_strumento) REFERENCES Strumento(ID_Strumento)
); 

CREATE TABLE Acquisto_Prodotto(
	FK_matricola INT NOT NULL, 
	FK_cod_prodotto INT NOT NULL,
	quantità INT NOT NULL,
	importo INT,
	PRIMARY KEY (FK_matricola, FK_cod_prodotto), 
	FOREIGN KEY (FK_matricola) REFERENCES Studente(matricola), 
	FOREIGN KEY (FK_cod_prodotto) REFERENCES Prodotto(cod_prodotto)
); 
	
CREATE TABLE Partecipazione_Lezioni( 
	FK_matricola INT NOT NULL, 
	FK_ID_lezione INT NOT NULL, 
	PRIMARY KEY (FK_matricola, FK_ID_lezione), 
	FOREIGN KEY (FK_matricola) REFERENCES Studente(matricola), 
	FOREIGN KEY (FK_ID_lezione) REFERENCES Lezione(ID_lezione)
); 

CREATE TABLE Workshop( 
	ID_workshop INT PRIMARY KEY, 
	data_workshop DATE, 
	numero_partecipanti INT
); 

CREATE TABLE Calendario_Workshop( 
	FK_ID_aula INT NOT NULL, 
	FK_iD_workshop INT NOT NULL, 
	data_workshop DATETIME NOT NULL, 
	fascia_oraria TIME,
	PRIMARY KEY (FK_ID_aula, FK_iD_workshop), 
	FOREIGN KEY (FK_ID_aula) REFERENCES Aula(ID_Aula), 
	FOREIGN KEY (FK_iD_workshop) REFERENCES Workshop(ID_workshop)
);

CREATE TABLE Partecipazione_docenti_WS( 
	FK_ID_Docente INT NOT NULL, 
	FK_iD_workshop INT NOT NULL,
	PRIMARY KEY (FK_ID_Docente, FK_iD_workshop), 
	FOREIGN KEY (FK_ID_Docente) REFERENCES Docente(ID_Docente), 
	FOREIGN KEY (FK_iD_workshop) REFERENCES Workshop(ID_workshop)
);

-- 2 creazione degli indici 

CREATE INDEX IDX_disp_lezione ON Lezione(data_lezione, fascia_oraria); 
CREATE INDEX IDX_disp_Workshop ON Calendario_Workshop(data_workshop, fascia_oraria); 
-- per velocizzare il join con l'aula
CREATE INDEX IDX_lezione_aula ON Lezione(ID_Aula); 
CREATE INDEX IDX_workshop_aula ON Calendario_Workshop(FK_ID_aula); 

CREATE INDEX IDX_check_pagamento ON Pagamento(data_scadenza, stato_pagamento); 
CREATE INDEX iDX_check_stipendio ON Lezione(ID_Docente, data_lezione); 

-- 3 Creazione dei trigger 
DELIMITER //

CREATE TRIGGER acquisto_fuori_giacenza 
BEFORE INSERT ON Acquisto_Prodotto
FOR EACH ROW
REFERENCING NEW AS N 
BEGIN
	DECLARE giacenza_prodotto NUMBER; 
	
	SELECT quantità INTO giacenza_prodotto
	FROM Prodotto P
	WHERE P.cod_prodotto = N.FK_cod_prodotto;
	
	IF N.importo < 0 OR N.quantità < 0 OR N.quantità > giacenza_prodotto THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'impossibile concludere l\'acquisto, il prodotto supera la giacenza in magazzino, l''importo è <0 oppure la quantità è <0'; 
	END IF; 
END // 

CREATE TRIGGER prenotazione_aula_lezione 
BEFORE INSERT ON Lezione
FOR EACH ROW
REFERENCING NEW AS N 
BEGIN
	IF EXISTS ( 
		SELECT 1 
		FROM Lezione L 
		WHERE L.ID_Aula = N.ID_Aula AND L.data_lezione = N.data_lezione AND L.fascia_oraria = N.fascia_oraria; 
	) 
	OR EXISTS ( 
		SELECT 1
		FROM Calendario_Workshop W 
		WHERE W.FK_ID_aula = N.ID_Aula AND W.data_workshop = N.data_lezione AND W.fascia_oraria = N.fascia_oraria; 
	) 
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'fascia oraria non disponibile per la prenotazione'; 
	END IF; 
END // 

CREATE TRIGGER prenotazione_aula_workshop 
BEFORE INSERT ON Calendario_Workshop
FOR EACH ROW
BEGIN
	IF EXISTS ( 
		SELECT 1 
		FROM Lezione L 
		WHERE L.ID_Aula = NEW.ID_Aula AND L.data_lezione = NEW.data_lezione AND L.fascia_oraria = NEW.fascia_oraria; 
	) 
	OR EXISTS ( 
		SELECT 1
		FROM Calendario_Workshop W 
		WHERE W.FK_ID_aula = NEW.ID_Aula AND W.data_workshop = NEW.data_lezione AND W.fascia_oraria = NEW.fascia_oraria; 
	) 
	THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'fascia oraria non disponibile per la prenotazione'; 
	END IF; 
END // 

CREATE TRIGGER prenotazione_strumento_fisso 
BEFORE INSERT ON Lezione
FOR EACH ROW
BEGIN
	DECLARE dotazione_strumento_fisso BOOLEAN; 
	DECLARE specializzazione_docente VARCHAR(60); 
	
	SELECT Strumento_fisso INTO dotazione_strumento_fisso
	FROM Aula A 
	WHERE NEW.ID_Aula = A.ID_Aula; 
	
	SELECT specializzazione INTO specializzazione_docente
	FROM Docente D
	WHERE NEW.ID_Docente = D.ID_Docente; 
	
	IF specializzazione_docente = 'batteria' OR specializzazione_docente = 'pianoforte' AND dotazione_strumento_fisso = FALSE THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Aula sprovvista di strumento fisso, impoossibile prenotare!' 
	END IF; 
END // 

CREATE TRIGGER noleggio_strumento 
BEFORE INSERT ON Noleggio 
FOR EACH ROW 
BEGIN
	DECLARE strumento_noleggiato BOOLEAN; 
	
	SELECT noleggiato INTO strumento_noleggiato 
	FROM Strumento S
	WHERE S.ID_Strumento = NEW.FK_ID_strumento; 
	
	IF strumento_noleggiato THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Lo strumento scelto è già stato noleggiato!' 
	END IF; 
END //

CREATE TRIGGER avanzamento_livello_studente 
BEFORE UPDATE ON Studente
FOR EACH ROW
BEGIN
	IF NEW.livello > OLD.livello + 1 THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Non è possibile saltare un livello per lo Studente' 
	END IF; 
END //
DELIMITER ;