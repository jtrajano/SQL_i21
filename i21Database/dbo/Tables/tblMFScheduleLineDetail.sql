CREATE TABLE tblMFScheduleLineDetail (
	intScheduleLineDetailId INT NOT NULL identity(1, 1)
	,intScheduleLineId INT NOT NULL
	,dtmPlannedStartDate DATETIME NOT NULL
	,dtmPlannedEndDate DATETIME NOT NULL
	,intPlannedShiftId INT NOT NULL
	,intDuration INT NOT NULL
	,dblPlannedQty NUMERIC(18, 6) NOT NULL
	,intSequenceNo INT NOT NULL
	,intCalendarDetailId INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleLineDetail_intScheduleLineDetailId PRIMARY KEY (intScheduleLineDetailId)
	,CONSTRAINT UQ_tblMFScheduleLineDetail_intScheduleLineId_intPlannedShiftId UNIQUE (
		intScheduleLineId
		,intPlannedShiftId
		)
	,CONSTRAINT [FK_tblMFScheduleLineDetail_tblMFScheduleLine_intScheduleLineId] FOREIGN KEY (intScheduleLineId) REFERENCES tblMFScheduleLine(intScheduleLineId)
	,CONSTRAINT [FK_tblMFScheduleLineDetail_tblMFScheduleCalendar_intCalendarDetailId] FOREIGN KEY (intCalendarDetailId) REFERENCES tblMFScheduleCalendarDetail(intCalendarDetailId)
	,CONSTRAINT [FK_tblMFScheduleLineDetail_tblMFShift_intShiftId] FOREIGN KEY (intPlannedShiftId) REFERENCES tblMFShift(intShiftId)
	)