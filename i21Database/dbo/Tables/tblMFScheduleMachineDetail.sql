﻿CREATE TABLE tblMFScheduleMachineDetail (
	intScheduleMachineDetailId INT NOT NULL identity(1, 1)
	,intScheduleLineDetailId INT NOT NULL
	,intCalendarMachineId INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleMachineDetail_intScheduleMachineDetailId PRIMARY KEY (intScheduleMachineDetailId)
	,CONSTRAINT [FK_tblMFScheduleMachineDetail_tblMFScheduleLineDetail_intScheduleLineDetailId] FOREIGN KEY (intScheduleLineDetailId) REFERENCES tblMFScheduleLineDetail(intScheduleLineDetailId)
	,CONSTRAINT [FK_tblMFScheduleMachineDetail_tblMFScheduleCalendarMachineDetail_intCalendarMachineId] FOREIGN KEY (intCalendarMachineId) REFERENCES tblMFScheduleCalendarMachineDetail(intCalendarMachineId)
	)