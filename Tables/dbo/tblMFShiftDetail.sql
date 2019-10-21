CREATE TABLE dbo.tblMFShiftDetail (
	intShiftDetailId INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_tblMFShiftDetail_intShiftDetailId PRIMARY KEY
	,intShiftId INT NOT NULL CONSTRAINT FK_tblMFShiftDetail_tblMFShift_intShiftId REFERENCES dbo.tblMFShift(intShiftId)
	,intShiftBreakTypeId INT CONSTRAINT FK_tblMFShiftDetail_tblMFShiftBreakType_intShiftBreakTypeId REFERENCES dbo.tblMFShiftBreakType(intShiftBreakTypeId)
	,dtmShiftBreakTypeStartTime DATETIME NOT NULL
	,dtmShiftBreakTypeEndTime DATETIME NOT NULL
	,intShiftBreakTypeDuration INT NOT NULL
	,intSequence INT
	,intCreatedUserId INT NOT NULL
	,dtmCreated DATETIME NOT NULL CONSTRAINT DF_tblMFShiftDetail_dtmCreated DEFAULT(getdate())
	,intLastModifiedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL CONSTRAINT DF_tblMFShiftDetail_dtmLastModified DEFAULT(getdate())
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFShiftDetail_intConcurrencyId DEFAULT((0))
	)