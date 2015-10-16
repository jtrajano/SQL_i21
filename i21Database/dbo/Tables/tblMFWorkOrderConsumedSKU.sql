CREATE TABLE dbo.tblMFWorkOrderConsumedSKU (
	intWorkOrderConsumedSKUId INT IDENTITY(1, 1) NOT NULL
	,intWorkOrderId INT NOT NULL
	,intItemId INT NOT NULL
	,intLotId INT NOT NULL
	,intSKUId NUMERIC(18, 6) NOT NULL
	,intContainerId INT NOT NULL
	,dblQuantity NUMERIC(18, 6) NOT NULL
	,intItemUOMId INT NOT NULL
	,dblIssuedQuantity NUMERIC(18, 6) NOT NULL
	,intItemIssuedUOMId INT NOT NULL
	,intBatchId INT NOT NULL
	,intShiftId INT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,CONSTRAINT PK_tblMFWorkOrderConsumedSKU_intWorkOrderConsumedSKUId PRIMARY KEY (intWorkOrderConsumedSKUId)
	,CONSTRAINT FK_tblMFWorkOrderConsumedSKU_tblICItem_inItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	,CONSTRAINT FK_tblMFWorkOrderConsumedSKU_tblICItemUOM_intItemUOMId FOREIGN KEY (intItemUOMId) REFERENCES dbo.tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFWorkOrderConsumedSKU_tblICItemUOM_intIssuedItemUOMId FOREIGN KEY (intItemIssuedUOMId) REFERENCES dbo.tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFWorkOrderConsumedSKU_tblICLot_inLotId FOREIGN KEY (intLotId) REFERENCES dbo.tblICLot(intLotId)
	,CONSTRAINT FK_tblMFWorkOrderConsumedSKU_tblMFShift_intShiftId FOREIGN KEY (intShiftId) REFERENCES dbo.tblMFShift(intShiftId)
	,CONSTRAINT FK_tblMFWorkOrderConsumedSKU_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId) ON DELETE CASCADE
	)
