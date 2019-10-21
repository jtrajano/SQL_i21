CREATE TABLE tblMFStageWorkOrder (
	intStageId INT NOT NULL identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,intItemId int
	,dblPlannedQty Numeric(38,20) 
	,dtmPlannedDate DATETIME NULL
	,intPlannnedShiftId INT NULL
	,intOrderHeaderId INT NOT NULL
	,intConcurrencyId INT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,CONSTRAINT PK_tblMFStageWorkOrder_intStageId PRIMARY KEY (intStageId)
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY (intWorkOrderId) REFERENCES tblMFWorkOrder(intWorkOrderId)
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblMFShift_intPlannedShiftId] FOREIGN KEY (intPlannnedShiftId) REFERENCES tblMFShift(intShiftId)
	,CONSTRAINT [FK_tblMFStageWorkOrder_tblMFOrderHeader_intOrderHeaderId] FOREIGN KEY (intOrderHeaderId) REFERENCES tblMFOrderHeader(intOrderHeaderId) ON DELETE CASCADE
	)