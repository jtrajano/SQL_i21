CREATE TABLE [dbo].[tblMFScheduleWorkOrderDetail] (
	intScheduleWorkOrderDetailId INT NOT NULL identity(1, 1)
	,intScheduleWorkOrderId INT NOT NULL
	,dtmPlannedStartDate DATETIME NOT NULL
	,dtmPlannedEndDate DATETIME NOT NULL
	,intPlannedShiftId INT NOT NULL
	,intDuration INT NOT NULL
	,dblPlannedQty NUMERIC(18, 6) NOT NULL
	,intSequenceNo INT NOT NULL
	,intCalendarDetailId INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleLineDetail_intScheduleLineDetailId PRIMARY KEY (intScheduleWorkOrderDetailId)
	,CONSTRAINT UQ_tblMFScheduleLineDetail_intScheduleLineId_intPlannedShiftId UNIQUE (
		intScheduleWorkOrderId
		,intPlannedShiftId
		)
	,CONSTRAINT [FK_tblMFScheduleWorkOrderDetail_tblMFScheduleWorkOrder_intScheduleWorkOrderId] FOREIGN KEY (intScheduleWorkOrderId) REFERENCES [dbo].[tblMFScheduleWorkOrder](intScheduleWorkOrderId)
	,CONSTRAINT [FK_tblMFScheduleWorkOrderDetail_tblMFScheduleCalendar_intCalendarDetailId] FOREIGN KEY (intCalendarDetailId) REFERENCES [dbo].[tblMFScheduleCalendarDetail](intCalendarDetailId)
	,CONSTRAINT [FK_tblMFScheduleWorkOrderDetail_tblMFShift_intShiftId] FOREIGN KEY (intPlannedShiftId) REFERENCES [dbo].[tblMFShift](intShiftId)
	)