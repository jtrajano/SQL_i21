CREATE TABLE tblMFAdditionalBasisImport (
	intAdditionalBasisImportId INT NOT NULL IDENTITY
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFAdditionalBasisImport_intConcurrencyId DEFAULT 0
	,dtmAdditionalBasisDate DATETIME
	,strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,strOtherChargeItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblBasis NUMERIC(18, 6) 
	,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	,intCreatedUserId int
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFAdditionalBasisImport_dtmCreated DEFAULT GETDATE()
	)
