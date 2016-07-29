CREATE TABLE tblMFStageWorkOrder (
	intStageId INT NOT NULL identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,dtmPlannedDate DATETIME NULL
	,intPlannnedShiftId INT NULL
	,intOrderHeaderId INT NOT NULL
	,intConcurrencyId INT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,CONSTRAINT PK_tblMFStageWorkOrder_intStageId PRIMARY KEY (intStageId)
	,CONSTRAINT UQ_tblMFStageWorkOrder_intWorkOrderId_dtmPlannedDate_intPlannnedShiftId UNIQUE (
		intWorkOrderId
		,dtmPlannedDate
		,intPlannnedShiftId
		)
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY (intWorkOrderId) REFERENCES tblMFWorkOrder(intWorkOrderId)
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblMFShift_intPlannedShiftId] FOREIGN KEY (intPlannnedShiftId) REFERENCES tblMFShift(intShiftId)
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblWHOrderHeader_intOrderHeaderId] FOREIGN KEY (intOrderHeaderId) REFERENCES tblWHOrderHeader(intOrderHeaderId)
	)