CREATE TABLE tblMFDemandImport (
	intDemandImportId INT NOT NULL IDENTITY
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFDemandImport_intConcurrencyId DEFAULT 0
	,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS 
	,strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,strSubstituteItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmDemandDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6) 
	,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,intCreatedUserId int
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFDemandImport_dtmCreated DEFAULT GETDATE()
	)
