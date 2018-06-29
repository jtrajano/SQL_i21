CREATE TABLE dbo.tblMFAttributeDefaultValue (
	intAttributeDefaultValueId INT NOT NULL IDENTITY
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFAttributeDefaultValue_intConcurrencyId DEFAULT 0
	,intAttributeId INT NOT NULL
	,intAttributeTypeId INT
	,strAttributeDefaultValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strAttributeDisplayValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS

	,intCreatedUserId INT NULL
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFAttributeDefaultValue_dtmCreated DEFAULT GETDATE()
	,intLastModifiedUserId INT NULL
	,dtmLastModified DATETIME NULL CONSTRAINT DF_tblMFAttributeDefaultValue_dtmLastModified DEFAULT GETDATE()

	,CONSTRAINT PK_tblMFAttributeDefaultValue_intAttributeId PRIMARY KEY (intAttributeDefaultValueId)
	,CONSTRAINT FK_tblMFAttributeDefaultValue_tblMFAttribute_intAttributeId FOREIGN KEY (intAttributeId) REFERENCES tblMFAttribute(intAttributeId) ON DELETE CASCADE
	,CONSTRAINT FK_tblMFAttributeDefaultValue_tblMFAttributeType_intAttributeTypeId FOREIGN KEY (intAttributeTypeId) REFERENCES tblMFAttributeType(intAttributeTypeId)
	,CONSTRAINT UQ_tblMFAttributeDefaultValue_intAttributeId_intAttributeTypeId UNIQUE (
		intAttributeId
		,intAttributeTypeId
		)
	)
