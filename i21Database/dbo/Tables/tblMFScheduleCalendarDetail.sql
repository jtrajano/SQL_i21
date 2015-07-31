
CREATE TABLE tblMFScheduleCalendarDetail (
	intCalendarDetailId INT NOT NULL identity(1, 1)
	,intCalendarId INT NOT NULL
	,dtmCalendarDate DATETIME NOT NULL
	,dtmShiftStartTime DATETIME NOT NULL
	,dtmShiftEndTime DATETIME NOT NULL
	,intDuration INT NOT NULL
	,intShiftId INT NOT NULL
	,intNoOfMachine INT NOT NULL
	,ysnHoliday BIT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFScheduleCalendarDetail_intCalendarDetailId PRIMARY KEY (intCalendarDetailId)
	,CONSTRAINT UQ_tblMFScheduleCalendarDetail_intCalendarId_dtmCalendarDate_intShiftId UNIQUE (
		intCalendarId
		,dtmCalendarDate
		,intShiftId
		)
	,CONSTRAINT [FK_tblMFScheduleCalendarDetail_tblMFShift_intShiftId] FOREIGN KEY (intShiftId) REFERENCES tblMFShift(intShiftId)
	)
