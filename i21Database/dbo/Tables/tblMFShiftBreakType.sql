CREATE TABLE dbo.tblMFShiftBreakType (
	intShiftBreakTypeId INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_tblMFShiftBreakType_intShiftBreakTypeId PRIMARY KEY
	,strShiftBreakTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT UQ_tblMFShiftBreakType_strShiftBreakTypeName UNIQUE
	,intCreatedUserId INT NOT NULL
	,dtmCreated DATETIME NOT NULL CONSTRAINT DF_tblMFShiftBreakType_dtmCreated DEFAULT(getdate())
	,intLastModifiedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL CONSTRAINT DF_tblMFShiftBreakType_dtmLastModified DEFAULT(getdate())
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFShiftBreakType_intConcurrencyId DEFAULT((0))
	)