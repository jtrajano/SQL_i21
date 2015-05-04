CREATE TABLE dbo.tblMFManufacturingProcessAttribute (
	intManufacturingProcessAttributeId INT identity(1, 1)
	,intManufacturingProcessId INT NOT NULL
	,intAttributeId INT NOT NULL
	,strAttributeValue  NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	,intLocationId INT NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL CONSTRAINT DF_tblMFManufacturingProcessAttribute_dtmLastModified DEFAULT(getdate())
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFManufacturingProcessAttribute_intConcurrencyId DEFAULT((0))
	,CONSTRAINT PK_tblMFManufacturingProcessAttribute_intAttributeId PRIMARY KEY (intManufacturingProcessAttributeId)
	,CONSTRAINT FK_tblMFPManufacturingrocessAttribute_tblSMCompanyLocation_intLocationId FOREIGN KEY (intLocationId) REFERENCES dbo.tblSMCompanyLocation(intCompanyLocationId)
	,CONSTRAINT FK_tblMFManufacturingProcessAttribute_tblMFAttribute_intAttributeId FOREIGN KEY (intAttributeId) REFERENCES dbo.tblMFAttribute(intAttributeId)
	,CONSTRAINT FK_tblMFManufacturingProcessAttribute_tblMFManufacturingProcess_intManufacturingProcessId FOREIGN KEY (intManufacturingProcessId) REFERENCES dbo.tblMFManufacturingProcess(intManufacturingProcessId)
	,CONSTRAINT UQ_tblMFManufacturingProcessAttribute_intManufacturingProcessId_intAttributeId_intLocationId UNIQUE (
		intManufacturingProcessId
		,intAttributeId
		,intLocationId
		)
	)