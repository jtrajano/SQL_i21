CREATE TABLE tblMFScheduleMachineDetail (
	intScheduleMachineDetailId INT NOT NULL identity(1, 1)
	,intScheduleWorkOrderDetailId INT NOT NULL
	,intWorkOrderId INT NOT NULL
	,intScheduleId INT NOT NULL
	,intCalendarMachineId INT NOT NULL
	,intCalendarDetailId INT NOT NULL
		,intConcurrencyId INT NOT NULL 
	,CONSTRAINT PK_tblMFScheduleMachineDetail_intScheduleMachineDetailId PRIMARY KEY (intScheduleMachineDetailId)
	,CONSTRAINT [FK_tblMFScheduleMachineDetail_tblMFScheduleWorkOrderDetail_intScheduleWorkOrderDetailId] FOREIGN KEY (intScheduleWorkOrderDetailId) REFERENCES tblMFScheduleWorkOrderDetail(intScheduleWorkOrderDetailId) ON DELETE CASCADE
	,CONSTRAINT [FK_tblMFScheduleMachineDetail_tblMFScheduleCalendarMachineDetail_intCalendarMachineId] FOREIGN KEY (intCalendarMachineId) REFERENCES tblMFScheduleCalendarMachineDetail(intCalendarMachineId)
	,CONSTRAINT [FK_tblMFScheduleMachinerDetail_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY (intWorkOrderId) REFERENCES [dbo].[tblMFWorkOrder](intWorkOrderId)
	,CONSTRAINT [FK_tblMFScheduleMachineDetail_tblMFScheduleCalendar_intCalendarDetailId] FOREIGN KEY (intCalendarDetailId) REFERENCES [dbo].[tblMFScheduleCalendarDetail](intCalendarDetailId)
	,CONSTRAINT [FK_tblMFScheduleMachineDetail_tblMFSchedule_intScheduleId] FOREIGN KEY (intScheduleId) REFERENCES [dbo].[tblMFSchedule](intScheduleId) 
	)