CREATE TABLE tblMFDemandImportError (
	intDemandImportErrorId INT NOT NULL IDENTITY
	,intDemandImportId INT NOT NULL 
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFDemandImportError_intConcurrencyId DEFAULT 0
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
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFDemandImportError_dtmCreated DEFAULT GETDATE()
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS 
	)
