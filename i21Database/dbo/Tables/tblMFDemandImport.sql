CREATE TABLE tblMFDemandImport (
	intDemandImportId INT NOT NULL IDENTITY
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFDemandImport_intConcurrencyId DEFAULT 0
	,strDemandNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmDate DATETIME NOT NULL
	,strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strSubstituteItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmDemandDate DATETIME NOT NULL
	,dblQuantity NUMERIC(18, 6) NOT NULL
	,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFDemandImport_dtmCreated DEFAULT GETDATE()
	)
