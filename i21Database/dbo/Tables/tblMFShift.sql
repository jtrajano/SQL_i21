CREATE TABLE dbo.tblMFShift (
	intShiftId INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_tblMFShift_intShiftId PRIMARY KEY
	,strShiftName NVARCHAR(50) NOT NULL CONSTRAINT UQ_tblMFShift_strShiftName UNIQUE
	,dtmShiftStartTime DATETIME NOT NULL
	,dtmShiftEndTime DATETIME NOT NULL
	,intDuration INT NOT NULL
	,intStartOffset INT NOT NULL
	,intEndOffset INT NOT NULL
	,intShiftSequence INT NOT NULL
	,intLocationId INT NOT NULL CONSTRAINT FK_tblMFShift_tblSMCompanyLocation_intCompanyLocationId_intLocationId REFERENCES dbo.tblSMCompanyLocation(intCompanyLocationId)
	,intCreatedUserId INT NOT NULL
	,dtmCreated DATETIME NOT NULL CONSTRAINT DF_tblMFShift_dtmCreated DEFAULT(getdate())
	,intLastModifiedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL CONSTRAINT DF_tblMFShift_dtmLastModified DEFAULT(getdate())
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFShift_intConcurrencyId DEFAULT((0))
	)