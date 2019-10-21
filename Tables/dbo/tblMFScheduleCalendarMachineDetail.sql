CREATE TABLE tblMFScheduleCalendarMachineDetail (
	intCalendarMachineId INT NOT NULL identity(1, 1)
	,intCalendarDetailId INT NOT NULL
	,intMachineId INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleCalendarMachineDetail_intCalendarMachineId PRIMARY KEY (intCalendarMachineId)
	,CONSTRAINT UQ_tblMFScheduleCalendarMachineDetail_intCalendarDetailId_intMachineId UNIQUE (
		intCalendarDetailId
		,intMachineId
		)
	,CONSTRAINT [FK_tblMFScheduleCalendarMachineDetail_tblMFScheduleCalendarDetail_intCalendarDetailId] FOREIGN KEY (intCalendarDetailId) REFERENCES tblMFScheduleCalendarDetail(intCalendarDetailId) ON DELETE CASCADE
	)