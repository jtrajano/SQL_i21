CREATE TABLE dbo.tblMFYield (
	intYieldId INT IDENTITY(1, 1) NOT NULL
	,intManufacturingProcessId INT NULL
	,strInputFormula NVARCHAR(MAX) NULL
	,strOutputFormula NVARCHAR(MAX) NULL
	,strYieldFormula NVARCHAR(MAX) NULL
	,intCreatedUserId INT NULL
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFYield_dtmCreated DEFAULT GetDate()
	,intLastModifiedUserId INT NULL
	,dtmLastModified DATETIME NULL CONSTRAINT DF_tblMFYield_dtmLastModified DEFAULT GetDate()
	,intConcurrencyId INT NULL DEFAULT((0))
	,CONSTRAINT PK_tblMFYield_intYieldId PRIMARY KEY (intYieldId)
	,CONSTRAINT UQ_tblMFYield_tblMFManufacturingProcess UNIQUE (intManufacturingProcessId)
	,CONSTRAINT FK_tblMFYield_tblMFManufacturingProcess FOREIGN KEY (intManufacturingProcessId) REFERENCES tblMFManufacturingProcess(intManufacturingProcessId) ON DELETE CASCADE
	)