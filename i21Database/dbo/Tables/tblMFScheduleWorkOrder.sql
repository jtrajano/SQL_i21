CREATE TABLE [dbo].[tblMFScheduleWorkOrder] (
	intScheduleWorkOrderId INT NOT NULL identity(1, 1)
	,intScheduleId INT NOT NULL
	,intWorkOrderId INT NOT NULL
	,intDuration INT NOT NULL
	,intExecutionOrder INT NOT NULL
	,intChangeoverDuration INT NOT NULL
	,intSetupDuration INT NOT NULL
	,dtmChangeoverStartDate DATETIME NOT NULL
	,dtmChangeoverEndDate DATETIME NOT NULL
	,dtmPlannedStartDate DATETIME NOT NULL
	,dtmPlannedEndDate DATETIME NOT NULL
	,intPlannedShiftId INT NOT NULL
	,intNoOfSelectedMachine INT NOT NULL
	,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	,strNote NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	,strAdditionalComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmEarliestStartDate DATETIME
	,ysnFrozen bit
	,intConcurrencyId INT
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleWorkOrder_intScheduleWorkOrderId PRIMARY KEY (intScheduleWorkOrderId)
	,CONSTRAINT [FK_tblMFScheduleWorkOrder_tblMFSchedule_intScheduleId] FOREIGN KEY (intScheduleId) REFERENCES [dbo].[tblMFSchedule](intScheduleId) ON DELETE CASCADE
	,CONSTRAINT [FK_tblMFScheduleWorkOrder_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY (intWorkOrderId) REFERENCES [dbo].[tblMFWorkOrder](intWorkOrderId)
	,CONSTRAINT [FK_tblMFScheduleWorkOrder_tblMFShift_intShiftId] FOREIGN KEY (intPlannedShiftId) REFERENCES [dbo].[tblMFShift](intShiftId)
	)