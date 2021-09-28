/******************** ADATBÁZIS LÉTREHOZÁSA ********************/

CREATE DATABASE HikeData CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HikeData', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\HikeData.mdf' , SIZE = 81920KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'HikeData_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\HikeData_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO



/******************** TÁBLÁK LÉTREHOZÁSA ********************/

USE HikeData
GO

DROP TABLE IF EXISTS dbo.DictFirstName
DROP TABLE IF EXISTS dbo.DictRegion
DROP TABLE IF EXISTS dbo.DictCup
DROP TABLE IF EXISTS dbo.DictUser
DROP TABLE IF EXISTS dbo.Distance
DROP TABLE IF EXISTS dbo.Hike
DROP TABLE IF EXISTS dbo.Location
DROP TABLE IF EXISTS dbo.Organizer
DROP TABLE IF EXISTS dbo.Racer
DROP TABLE IF EXISTS dbo.Region
DROP TABLE IF EXISTS dbo.Result
GO

CREATE TABLE dbo.DictRegion (
	RegionID			tinyint				NOT NULL IDENTITY (1,1),
	RegionName			varchar(40)			NOT NULL,
	CONSTRAINT PK_DictRegion_RegionID PRIMARY KEY (RegionID))
GO

CREATE TABLE dbo.DictCup (
	CupID				tinyint				NOT NULL IDENTITY (1,1),
	CupName				varchar(50)			NOT NULL,
	MinHikes			tinyint				NULL,
	WebSite				varchar(80)			NULL,
	CONSTRAINT PK_DictCup_CupID PRIMARY KEY (CupID))
GO

CREATE TABLE dbo.DictUser (
	UserID				int					NOT NULL IDENTITY (1,1),
	UserName			varchar(50)			NOT NULL,
	UserLogin			varchar(100)		NULL,
	AdminRole			bit					NOT NULL,
	OrgRole				bit					NOT NULL,
	UserRole			bit					NOT NULL,
	AppRole				bit					NOT NULL,
	IsActive			bit					NOT NULL,
	CONSTRAINT PK_DictUser_UserID PRIMARY KEY (UserID))
GO

CREATE TABLE dbo.Hike (
	HikeID				int					NOT NULL IDENTITY (1,1),
	HikeName			varchar(100)		NOT NULL,
	StartDate			date				NOT NULL,
	EndDate				date				NULL,
	OrganizerID			smallint			NOT NULL,
	CupID				tinyint				NULL,
	CONSTRAINT PK_Hike_HikeID PRIMARY KEY (HikeID))
GO

CREATE TABLE dbo.Region (
	HikeID				int					NOT NULL,
	RegionID			tinyint				NOT NULL,
	CONSTRAINT PK_Region_HikeID_RegionID PRIMARY KEY (HikeID, RegionID))
GO

CREATE TABLE dbo.Distance (
	DistanceID			int					NOT NULL IDENTITY (1,1),
	HikeID				int					NOT NULL,
	DistanceName		varchar(100)		NOT NULL,
	Distance			decimal(5,2)		NOT NULL,
	Elevation			smallint			NULL,
	LevelTime			smallint			NULL,
	Price				smallint			NULL,
	StartOpen			datetime2			NOT NULL,
	StartClose			datetime2			NULL,
	FinishClose			datetime2			NULL,
	IsDay				bit					NOT NULL,
	IsNight				bit					NOT NULL,
	LocationID			int					NOT NULL,
	CONSTRAINT PK_Distance_DistanceID PRIMARY KEY (DistanceID))
GO

CREATE TABLE dbo.Location (
	LocationID			int					NOT NULL IDENTITY (1,1),
	StartName			varchar(100)		NOT NULL,
	StartGPS			geography			NULL,
	FinishName			varchar(100)		NULL,
	FinishGPS			geography			NULL,
	CONSTRAINT PK_Location_LocationID PRIMARY KEY (LocationID))
GO

CREATE TABLE dbo.Organizer (
	OrganizerID			smallint			NOT NULL IDENTITY (1,1),
	OrganizerName		varchar(100)		NOT NULL,
	Website				varchar(80)			NULL,
	CONSTRAINT PK_Organizer_OrganizerID PRIMARY KEY (OrganizerID))
GO

CREATE TABLE dbo.Racer (
	RacerID				int					NOT NULL IDENTITY (1,1),
	LastName			varchar(40)			NOT NULL,
	FirstName			varchar(40)			NOT NULL,
	PersonName	AS CONCAT(LastName + ' ', FirstName),
	Gender				tinyint				NULL,
	BirthDate			date				NULL,		
	PostalCode			varchar(10)			NULL,
	City				varchar(40)			NOT NULL,
	Address				varchar(100)		NOT NULL,
	PhoneNumber			varchar(20)			NULL,
	Email				varchar(80)			NULL,
	CONSTRAINT PK_Racer_RacerID PRIMARY KEY (RacerID))
GO

CREATE TABLE dbo.Result (
	DistanceID			int					NOT NULL,
	RacerID				int					NOT NULL,
	StartTime			datetime2			NOT NULL,
	FinishTime			datetime2			NULL,
	CompletionTime	AS DATEDIFF(mi, StartTime, Finishtime),
	CONSTRAINT PK_Result_DistanceID_RacerID PRIMARY KEY (DistanceID, RacerID))
GO

CREATE TABLE dbo.DictFirstName (
	FirstName			varchar(40)			NOT NULL,
	Gender				tinyint				NOT NULL,
	CONSTRAINT PK_DictFirstName_FirstName PRIMARY KEY (FirstName))



/******************** MEGSZORÍTÁSOK ********************/

USE HikeData
GO

--FOREIGN KEY constraint:
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS FK_Distance_Hike_HikeID
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS FK_Distance_Location_LocationID
ALTER TABLE dbo.Hike DROP CONSTRAINT IF EXISTS FK_Hike_Organizer_OrganizerID
ALTER TABLE dbo.Hike DROP CONSTRAINT IF EXISTS FK_Hike_DictCup_CupID
ALTER TABLE dbo.Region DROP CONSTRAINT IF EXISTS FK_Region_DictRegion_RegionID
ALTER TABLE dbo.Region DROP CONSTRAINT IF EXISTS FK_Region_Hike_HikeID
ALTER TABLE dbo.Result DROP CONSTRAINT IF EXISTS FK_Result_Distance_DistanceID
ALTER TABLE dbo.Result DROP CONSTRAINT IF EXISTS FK_Result_Racer_RacerID

ALTER TABLE dbo.Distance ADD CONSTRAINT FK_Distance_Hike_HikeID FOREIGN KEY (HikeID) REFERENCES dbo.Hike (HikeID)
ALTER TABLE dbo.Distance ADD CONSTRAINT FK_Distance_Location_LocationID FOREIGN KEY (LocationID) REFERENCES dbo.Location (LocationID)

ALTER TABLE dbo.Hike ADD CONSTRAINT  FK_Hike_Organizer_OrganizerID FOREIGN KEY (OrganizerID) REFERENCES dbo.Organizer (OrganizerID)
ALTER TABLE dbo.Hike ADD CONSTRAINT FK_Hike_DictCup_CupID FOREIGN KEY (CupID) REFERENCES dbo.DictCup (CupID)

ALTER TABLE dbo.Region ADD CONSTRAINT FK_Region_DictRegion_RegionID FOREIGN KEY (RegionID) REFERENCES dbo.DictRegion (RegionID)
ALTER TABLE dbo.Region ADD CONSTRAINT FK_Region_Hike_HikeID FOREIGN KEY (HikeID) REFERENCES dbo.Hike (HikeID)

ALTER TABLE dbo.Result ADD CONSTRAINT FK_Result_Distance_DistanceID FOREIGN KEY (DistanceID) REFERENCES dbo.Distance (DistanceID) ON DELETE CASCADE
ALTER TABLE dbo.Result ADD CONSTRAINT FK_Result_Racer_RacerID FOREIGN KEY (RacerID) REFERENCES dbo.Racer (RacerID) ON DELETE CASCADE
GO

--DEFAULT constraint:
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS DF_Distance_Elevation
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS DF_Distance_IsDay
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS DF_Distance_IsNight

ALTER TABLE dbo.Distance ADD CONSTRAINT DF_Distance_IsDay DEFAULT 1 FOR IsDay
ALTER TABLE dbo.Distance ADD CONSTRAINT DF_Distance_IsNight DEFAULT 0 FOR IsNight

--CHECK constraint:
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS CK_Distance_Distance
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS CK_Distance_Elevation
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS CK_Distance_LevelTime
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS CK_Distance_Price
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS CK_Distance_StartClose
ALTER TABLE dbo.Distance DROP CONSTRAINT IF EXISTS CK_Distance_FinishClose
ALTER TABLE dbo.DictCup DROP CONSTRAINT IF EXISTS CK_DictCup_MinHikes
ALTER TABLE dbo.Result DROP CONSTRAINT IF EXISTS CK_Result_FinishTime
ALTER TABLE dbo.Hike DROP CONSTRAINT IF EXISTS CK_Hike_EndDate
ALTER TABLE dbo.Racer DROP CONSTRAINT IF EXISTS CK_Racer_BirthDate
ALTER TABLE dbo.Racer DROP CONSTRAINT IF EXISTS CK_Racer_Gender
ALTER TABLE dbo.DictFirstName DROP CONSTRAINT IF EXISTS CK_DictFirstName_Gender

ALTER TABLE dbo.Distance ADD CONSTRAINT CK_Distance_Distance CHECK (Distance > 0)
ALTER TABLE dbo.Distance ADD CONSTRAINT CK_Distance_Elevation CHECK (Elevation >= 0)
ALTER TABLE dbo.Distance ADD CONSTRAINT CK_Distance_LevelTime CHECK (LevelTime > 0)
ALTER TABLE dbo.Distance ADD CONSTRAINT CK_Distance_Price CHECK (Price >= 0)
ALTER TABLE dbo.Distance ADD CONSTRAINT	CK_Distance_StartClose CHECK (StartClose > StartOpen)
ALTER TABLE dbo.Distance ADD CONSTRAINT CK_Distance_FinishClose CHECK (FinishClose > StartOpen AND FinishClose > StartClose)
ALTER TABLE dbo.DictCup ADD CONSTRAINT CK_DictCup_MinHikes CHECK (MinHikes > 0)
ALTER TABLE dbo.Result ADD CONSTRAINT CK_Result_FinishTime CHECK (FinishTime > StartTime)
ALTER TABLE dbo.Hike ADD CONSTRAINT CK_Hike_EndDate CHECK (EndDate >= StartDate)
ALTER TABLE dbo.Racer ADD CONSTRAINT CK_Racer_BirthDate CHECK (BirthDate < SYSDATETIME())
ALTER TABLE dbo.Racer ADD CONSTRAINT CK_Racer_Gender CHECK (Gender IN (1,2))
ALTER TABLE dbo.DictFirstName ADD CONSTRAINT CK_DictFirstName_Gender CHECK (Gender IN (1,2))
GO



/******************** SÉMÁK LÉTREHOZÁSA ********************/

USE HikeData
GO
CREATE SCHEMA Rapp AUTHORIZATION dbo
GO
CREATE SCHEMA pbi AUTHORIZATION dbo
GO



/******************** LOGINOK, USEREK, JOGOSULTSÁGOK ********************/

USE master
GO
CREATE LOGIN HDAdmin WITH PASSWORD=N'Pa55w.rd', DEFAULT_DATABASE=HikeData, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
ALTER SERVER ROLE bulkadmin ADD MEMBER HDAdmin
GO
USE HikeData
GO
CREATE USER HDAdmin FOR LOGIN HDAdmin
ALTER ROLE db_owner ADD MEMBER HDAdmin
GO


USE master
GO
CREATE LOGIN HDOrg WITH PASSWORD=N'Pa55w.rd', DEFAULT_DATABASE=HikeData, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
ALTER SERVER ROLE bulkadmin ADD MEMBER HDOrg
GO
USE HikeData
GO
CREATE USER HDOrg FOR LOGIN HDOrg


USE master
GO
CREATE LOGIN HDUser WITH PASSWORD=N'Pa55w.rd', DEFAULT_DATABASE=HikeData, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE HikeData
GO
CREATE USER HDUser FOR LOGIN HDUser
ALTER USER HDUser WITH DEFAULT_SCHEMA=Rapp
GO
GRANT SELECT ON SCHEMA::Rapp TO HDUser
GRANT EXECUTE ON SCHEMA::Rapp TO HDUser
GO


USE master
GO
CREATE LOGIN HDAnalytic WITH PASSWORD=N'Pa55w.rd', DEFAULT_DATABASE=HikeData, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE HikeData
GO
CREATE USER HDAnalytic FOR LOGIN HDAnalytic
ALTER USER HDAnalytic WITH DEFAULT_SCHEMA=pbi
GO
GRANT SELECT ON SCHEMA::pbi TO HDAnalytic
GO


CREATE ROLE Organizer AUTHORIZATION dbo
GRANT DELETE ON SCHEMA::dbo TO Organizer
GRANT EXECUTE ON SCHEMA::dbo TO Organizer
GRANT INSERT ON SCHEMA::dbo TO Organizer
GRANT SELECT ON SCHEMA::dbo TO Organizer
GRANT UPDATE ON SCHEMA::dbo TO Organizer

DENY DELETE ON dbo.DictFirstName TO Organizer
DENY UPDATE ON dbo.DictFirstName TO Organizer
DENY DELETE ON dbo.DictUser TO Organizer
DENY DELETE ON dbo.DictRegion TO Organizer
DENY UPDATE ON dbo.DictRegion TO Organizer
GO

ALTER ROLE Organizer ADD MEMBER HDOrg
GO



/******************** NÉZETEK LÉTREHOZÁSA ********************/

CREATE OR ALTER VIEW pbi.GetHikeByRegion AS
SELECT R.RegionID, DR.RegionName,
	COUNT(DISTINCT IIF(D.IsDay = 1 AND D.IsNight = 0, D.DistanceID, NULL)) DayDistance,
	COUNT(IIF(D.IsDay = 1 AND D.IsNight = 0, Re.RacerID, NULL)) RacerOnDay,
	COUNT(DISTINCT IIF(D.IsDay = 0 AND D.IsNight = 1, D.DistanceID, NULL)) NightDistance,
	COUNT(IIF(D.IsDay = 0 AND D.IsNight = 1, Re.RacerID, NULL)) RacerOnNight,
	COUNT(DISTINCT IIF(D.IsDay = 1 AND D.IsNight = 1, D.DistanceID, NULL)) LongDistance,
	COUNT(IIF(D.IsDay = 1 AND D.IsNight = 1, Re.RacerID, NULL)) RacerOnLong,
	COUNT(DISTINCT H.HikeID) NoOfHike,
	COUNT(DISTINCT D.DistanceID) NoOfDistance,
	COUNT(1) TotalRacer
FROM Hike H
INNER JOIN Distance D ON H.HikeID = D.HikeID
INNER JOIN Region R ON H.HikeID = R.HikeID
INNER JOIN DictRegion DR ON R.RegionID = DR.RegionID
INNER JOIN Result Re ON D.DistanceID = Re.DistanceID
GROUP BY R.RegionID, DR.RegionName
GO

SELECT * FROM pbi.GetHikeByRegion ORDER BY 11 DESC
GO


CREATE OR ALTER VIEW Rapp.GetRacerPerformance AS
SELECT Ra.RacerID, Ra.PersonName RacerName,
	SUM(IIF(D.IsDay = 1 AND D.IsNight = 0, D.Distance, 0)) DayHikeKm,
	SUM(IIF(D.IsDay = 1 AND D.IsNight = 0, D.Elevation, 0)) DayHikeElevation,
	SUM(IIF(D.IsDay = 0 AND D.IsNight = 1, D.Distance, 0)) NightHikeKm,
	SUM(IIF(D.IsDay = 0 AND D.IsNight = 1, D.Elevation, 0)) NightHikeElevation,
	SUM(IIF(D.IsDay = 1 AND D.IsNight = 1, D.Distance, 0)) LongHikeKm,
	SUM(IIF(D.IsDay = 1 AND D.IsNight = 1, D.Elevation, 0)) LongHikeElevation,
	SUM(D.Distance) TotalKm,
	SUM(D.Elevation) TotalElevation,
	COUNT(1) NoOfDistance
FROM dbo.Hike H
INNER JOIN dbo.Distance D ON H.HikeID = D.HikeID
INNER JOIN dbo.Result Re ON D.DistanceID = Re.DistanceID
INNER JOIN dbo.Racer Ra ON Re.RacerID = Ra.RacerID
GROUP BY Ra.RacerID, Ra.PersonName
GO

SELECT * FROM Rapp.GetRacerPerformance ORDER BY 9 DESC, 10 DESC
GO


CREATE OR ALTER VIEW dbo.GetOrganizerRevenue AS
SELECT O.OrganizerName,
	COUNT(DISTINCT IIF(D.IsDay = 1 AND D.IsNight = 0, D.DistanceID, NULL)) DayDistance,
	COUNT(IIF(D.IsDay = 1 AND D.IsNight = 0, Re.RacerID, NULL)) RacerOnDay,
	SUM(IIF(D.IsDay = 1 AND D.IsNight = 0, D.Price, 0)) DayHikeRevenue,
	COUNT(DISTINCT IIF(D.IsDay = 0 AND D.IsNight = 1, D.DistanceID, NULL)) NightDistance,
	COUNT(IIF(D.IsDay = 0 AND D.IsNight = 1, Re.RacerID, NULL)) RacerOnNight,
	SUM(IIF(D.IsDay = 0 AND D.IsNight = 1, D.Price, 0)) NightHikeRevenue,
	COUNT(DISTINCT IIF(D.IsDay = 1 AND D.IsNight = 1, D.DistanceID, NULL)) LongDistance,
	COUNT(IIF(D.IsDay = 1 AND D.IsNight = 1, Re.RacerID, NULL)) RacerOnLong,
	SUM(IIF(D.IsDay = 1 AND D.IsNight = 1, D.Price, 0)) LongHikeRevenue,
	COUNT(DISTINCT H.HikeID) NoOfHikes,
	COUNT(DISTINCT D.DistanceID) NoOfDistance,
	COUNT(DISTINCT Re.RacerID) TotalRacer,
	SUM(D.Price) Revenue
FROM Hike H
INNER JOIN Organizer O ON H.OrganizerID = O.OrganizerID
INNER JOIN Distance D ON H.HikeID = D.HikeID
INNER JOIN Result Re ON D.DistanceID = Re.DistanceID
INNER JOIN Racer Ra ON Re.RacerID = Ra.RacerID
GROUP BY O.OrganizerName
GO

SELECT * FROM dbo.GetOrganizerRevenue ORDER BY 14 DESC
GO


CREATE OR ALTER VIEW dbo.GetCompletedRate AS
SELECT H.HikeID, H.HikeName, D.DistanceID, D.DistanceName,
	COUNT(IIF(Ra.Gender = 1, Ra.RacerID, NULL)) NoOfMale,
	COUNT(IIF(Ra.Gender = 1 AND D.LevelTime >= Re.CompletionTime OR D.LevelTime IS NULL, Re.RacerID, NULL)) MaleCompleted,
	COUNT(IIF(Ra.Gender = 1 AND D.LevelTime < Re.CompletionTime, Re.RacerID, NULL)) MaleUnCompleted,
	COUNT(IIF(Ra.Gender = 2, Ra.RacerID, NULL)) NoOfFemale,
	COUNT(IIF(Ra.Gender = 2 AND D.LevelTime >= Re.CompletionTime OR D.LevelTime IS NULL, Re.RacerID, NULL)) FemaleCompleted,
	COUNT(IIF(Ra.Gender = 2 AND D.LevelTime < Re.CompletionTime, Re.RacerID, NULL)) FemaleUnCompleted,
	COUNT(1) TotalRacer,
	COUNT(IIF(D.LevelTime >= Re.CompletionTime OR D.LevelTime IS NULL, Re.RacerID, NULL)) TotalCompleted,
	COUNT(IIF(D.LevelTime < Re.CompletionTime, Re.RacerID, NULL)) TotalUnCompleted,
	AVG(DATEDIFF(YEAR, Ra.BirthDate, SYSDATETIME()))  AvgAge,
	FORMAT(COUNT(IIF(D.LevelTime >= Re.CompletionTime OR D.LevelTime IS NULL, Re.RacerID, NULL))
		/ CAST(COUNT(1) AS decimal), 'N', 'hu-hu') CompletedPercent
FROM dbo.Hike H
INNER JOIN dbo.Distance D ON H.HikeID = D.HikeID
INNER JOIN dbo.Result Re ON D.DistanceID = Re.DistanceID
INNER JOIN Racer Ra ON Re.RacerID = Ra.RacerID
GROUP BY H.HikeID, H.HikeName, D.DistanceID, D.DistanceName
GO

SELECT * FROM dbo.GetCompletedRate ORDER BY 15
GO



/******************** FÜGGVÉNYEK LÉTREHOZÁSA ********************/

CREATE OR ALTER FUNCTION dbo.GenderDetect
	(@S varchar(100))
RETURNS tinyint
AS
BEGIN
	DECLARE @Gender tinyint
	IF @S = 'René' SET @Gender = 1
	ELSE IF @S IN ('Antigoné', 'Ariadné', 'Aténé', 'ené', 'Dafné', 'Röné') SET @Gender = 2
	ELSE IF RIGHT(@S,3) = 'éné'
		SELECT @Gender = 2 FROM DictFirstName WHERE FirstName = LEFT(@S,LEN(@S)-3)+'e' AND Gender = 1
	ELSE IF RIGHT(@S,3) = 'áné'
		SELECT @Gender = 2 FROM DictFirstName WHERE FirstName = LEFT(@S,LEN(@S)-3)+'a' AND Gender = 1
	ELSE IF RIGHT(@S,2) = 'né'
		SELECT @Gender = 2 FROM DictFirstName WHERE FirstName = LEFT(@S,LEN(@S)-2) AND Gender = 1
	ELSE 
		SELECT @Gender = Gender FROM DictFirstName WHERE FirstName = @S
	RETURN @Gender
END
GO


CREATE OR ALTER FUNCTION Rapp.GetRacerResult (
	@RacerName varchar(100),
	@BirthDate date)
RETURNS TABLE WITH SCHEMABINDING
AS RETURN
(SELECT H.StartDate HikeDate, O.OrganizerName, H.HikeName, D.DistanceName, D.Distance, D.Elevation,
	COALESCE(CAST(D.LevelTime AS varchar(4)), 'Nincs meghatározva') LevelTime,
	Re.StartTime, Re.FinishTime, Re.CompletionTime,
	IIF(D.Leveltime >= Re.CompletionTime OR D.LevelTime IS NULL, 'Szintidõn belül teljesített', 'Nem teljesített') Completed,
	COALESCE(C.CupName, 'Nem tartozik kupába') CupName
FROM dbo.Hike H
INNER JOIN dbo.Organizer O ON H.OrganizerID = O.OrganizerID
LEFT JOIN dbo.DictCup C ON H.CupID = C.CupID
INNER JOIN dbo.Distance D ON H.HikeID = D.HikeID
INNER JOIN dbo.Result Re ON D.DistanceID = Re.DistanceID
INNER JOIN dbo.Racer Ra ON Re.RacerID = Ra.RacerID
WHERE @RacerName = Ra.PersonName AND @BirthDate = Ra.BirthDate)
GO

SELECT * FROM Rapp.GetRacerResult ('Szabó Rozália', '19710112')
GO



/******************** TÁROLT ELJÁRÁSOK LÉTREHOZÁSA ********************/

CREATE OR ALTER PROCEDURE dbo.InsertHike
	@HikeName varchar(100),
	@StartDate date,
	@EndDate date = NULL,
	@OrganizerID smallint,
	@CupID tinyint = NULL
AS
	SET NOCOUNT ON

	IF @HikeName IS NULL OR @StartDate IS NULL OR @OrganizerID IS NULL
	RETURN 1

	ELSE IF @OrganizerID NOT IN (SELECT OrganizerID FROM Organizer) OR @CupID NOT IN (SELECT CupID FROM DictCup)
	RETURN 2

	ELSE IF @StartDate > @EndDate
	RETURN 3

	ELSE
	INSERT dbo.Hike (HikeName, StartDate, EndDate, OrganizerID, CupID)
	VALUES (@HikeName, @StartDate, @EndDate, @OrganizerID, @CupID)
GO


CREATE OR ALTER PROCEDURE dbo.InsertDistance
	@HikeID int,
	@DistanceName varchar(100),
	@Distance decimal(5,2),
	@Elevation smallint = NULL,
	@LevelTime smallint = NULL,
	@Price smallint = NULL,
	@StartOpen datetime2,
	@StartClose datetime2 = NULL,
	@FinishClose datetime2 = NULL,
	@IsDay bit = 1,
	@IsNight bit = 0,
	@LocationID int
AS
	SET NOCOUNT ON

	IF @HikeID IS NULL OR @DistanceName IS NULL OR @Distance IS NULL OR @StartOpen IS NULL OR
		@IsDay IS NULL OR @IsNight IS NULL OR @LocationID IS NULL
	RETURN 1

	ELSE IF @HikeID NOT IN (SELECT HikeID FROM dbo.Hike) OR @LocationID NOT IN (SELECT LocationID FROM dbo.Location)
	RETURN 2

	ELSE IF @Distance <= 0 OR @Elevation < 0 OR @LevelTime <= 0 OR @Price <= 0
	RETURN 3

	ELSE IF @StartOpen > @StartClose OR
		@StartOpen > @FinishClose OR
		@StartClose > @FinishClose
	RETURN 4

	ELSE
	INSERT dbo.Distance (HikeID, DistanceName, Distance, Elevation, LevelTime, Price, StartOpen, StartClose, FinishClose, IsDay, IsNight, LocationID)
	VALUES (@HikeID, @DistanceName, @Distance, @Elevation, @LevelTime, @Price, @StartOpen, @StartClose, @FinishClose, @IsDay, @IsNight, @LocationID)
GO


CREATE OR ALTER PROCEDURE dbo.InsertRacer
	@LastName varchar(40),
	@FirstName varchar(40),
	@Gender tinyint = NULL,
	@BirthDate date = NULL,
	@PostalCode varchar(10) = NULL,
	@City varchar(40),
	@Address varchar(100),
	@PhoneNumber varchar(20) = NULL,
	@Email varchar(80) = NULL
AS
	SET NOCOUNT ON

	IF @LastName IS NULL OR @FirstName IS NULL OR @City IS NULL OR @Address IS NULL
	RETURN 1

	ELSE IF @Gender NOT IN (1,2)
		OR @Gender <> (SELECT dbo.GenderDetect(@FirstName)) 
	RETURN 2

	ELSE IF @BirthDate > SYSDATETIME()
	RETURN 3

	ELSE
	INSERT dbo.Racer (FirstName, LastName, Gender, BirthDate, PostalCode, City, Address, PhoneNumber, Email)
	VALUES (@FirstName, @LastName, @Gender, @BirthDate, @PostalCode, @City, @Address, @PhoneNumber, @Email)
GO


CREATE OR ALTER PROCEDURE Rapp.GetDayOrNightDistance
	@IsDay bit,
	@IsNight bit
AS
	SET NOCOUNT ON

	IF @IsDay IS NULL OR @IsNight IS NULL
	RETURN 1

	ELSE IF @IsDay = 0 AND @IsNight = 0
	RETURN 2

	ELSE
		SELECT H.HikeName, D.DistanceName, D.Distance, D.Elevation,
			COALESCE(CAST(D.LevelTime AS varchar(4)), 'Nincs meghatározva') LevelTime,
			COALESCE(CAST(D.Price AS varchar(4)), 'Ingyenes táv') Price, D.StartOpen,
			COALESCE(CAST(D.StartClose AS char(19)), 'Tömegrajtos táv') StartClose,
			COALESCE(CAST(D.FinishClose AS char(19)), 'Nincs meghatározva') FinishClose,
			L.StartName, geography::STGeomFromText(L.StartGPS.STAsText(), 4326).ToString() StartGPS,
			COALESCE(L.FinishName, 'Körtúra') FinishName,
			geography::STGeomFromText(COALESCE(L.FinishGPS, L.StartGPS).STAsText(), 4326).ToString() FinishGPS,
			STRING_AGG(DR.RegionName, ', ') RegionName
		FROM dbo.Hike H
		INNER JOIN dbo.Distance D ON H.HikeID = D.HikeID
		LEFT JOIN dbo.DictCup C ON H.CupID = C.CupID
		INNER JOIN dbo.Region R ON H.HikeID = R.HikeID
		INNER JOIN dbo.DictRegion DR ON R.RegionID = DR.RegionID
		INNER JOIN dbo.Location L ON D.LocationID = L.LocationID
		WHERE @IsDay = D.IsDay AND @IsNight = D.IsNight
		GROUP BY H.HikeName, D.DistanceName, D.Distance, D.Elevation,
			COALESCE(CAST(D.LevelTime AS varchar(4)), 'Nincs meghatározva'), COALESCE(CAST(D.Price AS varchar(4)), 'Ingyenes táv'), D.StartOpen,
			COALESCE(CAST(D.StartClose AS char(19)), 'Tömegrajtos táv'), COALESCE(CAST(D.FinishClose AS char(19)), 'Nincs meghatározva'),
			L.StartName, COALESCE(L.FinishName, 'Körtúra'), L.StartGPS.STAsText(), COALESCE(L.FinishGPS, L.StartGPS).STAsText()
GO

EXEC Rapp.GetDayOrNightDistance 1, 1


/******************** TRIGGER LÉTREHOZÁSA ********************/

CREATE OR ALTER TRIGGER trgInsertOrUpdateResult ON dbo.Result FOR INSERT, UPDATE
AS 
	IF EXISTS 
		(SELECT I.StartTime, I.FinishTime, D.StartOpen, D.StartClose, D.FinishClose
		FROM inserted I
		INNER JOIN dbo.Distance D ON I.DistanceID = D.DistanceID
		WHERE (I.StartTime < D.StartOpen OR I.StartTime > D.StartClose OR I.StartTime > D.FinishClose) OR
			(I.FinishTime < D.StartOpen OR I.FinishTime > D.FinishClose))
		BEGIN
			RAISERROR ('StartTime or FinishTime is outside of the accepted range', 16, 1)
			ROLLBACK TRAN
			RETURN
		END
GO



/******************** INDEXEK LÉTREHOZÁSA ********************/

DROP INDEX IF EXISTS IX_Racer_PersonName ON dbo.Racer
DROP INDEX IF EXISTS AK_Organizer_OrganizerName ON dbo.Organizer
DROP INDEX IF EXISTS AK_DictRegion_RegionName ON dbo.DictRegion

CREATE NONCLUSTERED INDEX IX_Racer_PersonName ON dbo.Racer (PersonName)
CREATE UNIQUE NONCLUSTERED INDEX AK_Organizer_OrganizerName ON dbo.Organizer (OrganizerName)
CREATE UNIQUE NONCLUSTERED INDEX AK_DictRegion_RegionName ON dbo.DictRegion (RegionName)



/******************** MENTÉSI STRATÉGIA ********************/

USE msdb
GO
CREATE USER HDAdmin FOR LOGIN HDAdmin
ALTER ROLE SQLAgentUserRole ADD MEMBER HDAdmin
GO

--Teljes mentés: Minden nap hajnali 2-kor fut le
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'HikeData Full Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HDAdmin', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'HikeData Full Backup', @server_name = N'DESKTOP-L2K60I5'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'HikeData Full Backup', @step_name=N'HikeData Full Backup - Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [HikeData] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\HikeDataFullBackup.bak'' WITH NOFORMAT, NOINIT,  NAME = N''HikeData-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'HikeData Full Backup', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HDAdmin', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'HikeData Full Backup', @name=N'Full Backup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210816, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO


--Differenciális mentés: Minden nap 10-kor, 14-kor és 18-kor fut le
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'HikeData Diff Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HDAdmin', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'HikeData Diff Backup', @server_name = N'DESKTOP-L2K60I5'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'HikeData Diff Backup', @step_name=N'HikeData Diff Backup - Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [HikeData] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\HikeDataDiffBackup.bak'' WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  NAME = N''HikeData-Diff Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'HikeData Diff Backup', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HDAdmin', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'HikeData Diff Backup', @name=N'Diff Backup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=4, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210816, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
		@active_end_time=185959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

--Log mentés: Minden nap 8 és 19 óra között fut le óránként
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'HikeData Log Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HDAdmin', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'HikeData Log Backup', @server_name = N'DESKTOP-L2K60I5'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'HikeData Log Backup', @step_name=N'HikeData Log Backup - Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP LOG [HikeData] TO  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\HikeDataLogBackup.bak'' WITH NOFORMAT, NOINIT,  NAME = N''HikeData-Log Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'HikeData Log Backup', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'HDAdmin', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'HikeData Log Backup', @name=N'Log Backup 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210816, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=90000, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'HikeData Log Backup', @name=N'Log Backup 2', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210816, 
		@active_end_date=99991231, 
		@active_start_time=110000, 
		@active_end_time=130000, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'HikeData Log Backup', @name=N'Log Backup 3', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210816, 
		@active_end_date=99991231, 
		@active_start_time=150000, 
		@active_end_time=170000, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'HikeData Log Backup', @name=N'Log Backup 4', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210816, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO