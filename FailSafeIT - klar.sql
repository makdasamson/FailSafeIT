-- FailSafe IT
-- Skriptet raderar och återskapar den lokala testdatabasen FailSafeIT.

USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'FailSafeIT')
BEGIN
    ALTER DATABASE FailSafeIT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FailSafeIT;
END;
GO

CREATE DATABASE FailSafeIT;
GO

USE FailSafeIT;
GO

CREATE TABLE Kund (
    KundID INT IDENTITY(1,1) PRIMARY KEY,
    Organisationsnummer VARCHAR(11) NOT NULL UNIQUE,
    Företagsnamn NVARCHAR(100) NOT NULL,
    Epost NVARCHAR(254) NOT NULL,
    Telefonnummer VARCHAR(25) NOT NULL
);

CREATE TABLE Konsult (
    KonsultID INT IDENTITY(1,1) PRIMARY KEY,
    Personnummer VARCHAR(13) NOT NULL UNIQUE,
    Namn NVARCHAR(100) NOT NULL,
    Timpris DECIMAL(18,2) NOT NULL,
    Specialitet NVARCHAR(100) NOT NULL
);

CREATE TABLE Uppdrag (
    UppdragID INT IDENTITY(1,1) PRIMARY KEY,
    KundID INT NOT NULL,
    KonsultID INT NOT NULL,
    Startdatum DATE NOT NULL,
    Slutdatum DATE NOT NULL,
    Rollbeskrivning NVARCHAR(200) NOT NULL,
    CONSTRAINT FK_Uppdrag_Kund
        FOREIGN KEY (KundID) REFERENCES Kund(KundID),
    CONSTRAINT FK_Uppdrag_Konsult
        FOREIGN KEY (KonsultID) REFERENCES Konsult(KonsultID)
);

-- Testdata
INSERT INTO Kund (Organisationsnummer, Företagsnamn, Epost, Telefonnummer)
VALUES
    ('559900-1001', N'Salong Norr AB', 'kontakt@salongnorr.example', '08-000 00 01'),
    ('559900-1002', N'Kvarnbacka Bokhandel AB', 'kontakt@kvarnbacka.example', '08-000 00 02'),
    ('559900-1003', N'Myrvik Buss AB', 'kontakt@myrvik.example', '08-000 00 03'),
    ('559900-1005', N'Klintens Cykelverkstad AB', 'kontakt@klinten.example', '08-000 00 04');

INSERT INTO Konsult (Personnummer, Namn, Timpris, Specialitet)
VALUES
    ('19910412-1011', N'Samira Ek', 1450, N'Cybersecurity'),
    ('19880623-2022', N'Noel Strand', 1300, N'DevOps'),
    ('19950715-3033', N'Mira Holm', 1050, N'C# Developer');

INSERT INTO Uppdrag (KundID, KonsultID, Startdatum, Slutdatum, Rollbeskrivning)
VALUES
    (1, 3, '2026-11-03', '2026-12-11', N'Bygga en funktion för bokning av bioplatser'),
    (1, 1, '2026-11-09', '2026-11-27', N'Granska inloggningen i biljettsystemet'),
    (2, 2, '2026-11-02', '2026-12-04', N'Automatisera publiceringen av webbutiken'),
    (3, 2, '2026-09-21', '2026-10-16', N'Testa reservrutiner för tidtabellssystemet'),
    (2, 3, '2027-01-18', '2027-02-19', N'Bygga en funktion för att reservera böcker');

-- A: Konsulter med timpris över 1200 kr.
SELECT Namn, Timpris
FROM Konsult
WHERE Timpris > 1200
ORDER BY Timpris DESC;

-- B: Alla uppdrag med kundens företagsnamn och konsultens namn.
SELECT k.Företagsnamn, ko.Namn, u.Startdatum, u.Slutdatum
FROM Uppdrag AS u
INNER JOIN Kund AS k ON u.KundID = k.KundID
INNER JOIN Konsult AS ko ON u.KonsultID = ko.KonsultID
ORDER BY u.UppdragID;

-- C: Antal uppdrag som pågår idag. LEFT JOIN tar även med kunder med 0.
DECLARE @Idag DATE = CAST(GETDATE() AS DATE);

SELECT k.Företagsnamn, COUNT(u.UppdragID) AS AntalAktivaUppdrag
FROM Kund AS k
LEFT JOIN Uppdrag AS u
    ON k.KundID = u.KundID
    AND u.Startdatum <= @Idag
    AND u.Slutdatum >= @Idag
GROUP BY k.KundID, k.Företagsnamn
ORDER BY k.KundID;

-- D: Uppdatera Mira Holms timpris och kontrollera resultatet.
UPDATE Konsult
SET Timpris = 1250
WHERE KonsultID = 3;

SELECT Namn, Timpris
FROM Konsult
WHERE KonsultID = 3;

-- E: Ta bort Klintens Cykelverkstad om kunden saknar uppdrag.
-- Även avslutade och framtida uppdrag behåller sin koppling till kunden.
DELETE FROM Kund
WHERE KundID = 4
    AND NOT EXISTS (
        SELECT 1
        FROM Uppdrag
        WHERE Uppdrag.KundID = Kund.KundID
    );

SELECT KundID, Företagsnamn
FROM Kund
ORDER BY KundID;