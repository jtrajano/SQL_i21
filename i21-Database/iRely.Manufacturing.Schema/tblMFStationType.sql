CREATE TABLE tblMFStationType (
	intStationTypeId INT CONSTRAINT PK_tblMFStationType_intStationTypeID PRIMARY KEY
	,strStationTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	)