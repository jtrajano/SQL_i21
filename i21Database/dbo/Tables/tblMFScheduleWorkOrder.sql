CREATE TABLE [dbo].[tblMFScheduleWorkOrder] (
	intScheduleWorkOrderId INT NOT NULL identity(1, 1)
	,intScheduleId INT NOT NULL
	,intWorkOrderId INT NOT NULL
	,intDuration INT NULL
	,intExecutionOrder INT NOT NULL
	,intStatusId int NULL
	,intChangeoverDuration INT NULL
	,intSetupDuration INT NULL
	,dtmChangeoverStartDate DATETIME NULL
	,dtmChangeoverEndDate DATETIME NULL
	,dtmPlannedStartDate DATETIME NULL
	,dtmPlannedEndDate DATETIME NULL
	,intPlannedShiftId INT NULL
	,intNoOfSelectedMachine INT NOT NULL
	,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strNote NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strAdditionalComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
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
	,CONSTRAINT [FK_tblMFScheduleWorkOrder_tblMFWorkOrderStatus_intStatusId] FOREIGN KEY ([intStatusId]) REFERENCES [tblMFWorkOrderStatus]([intStatusId]) 
	)