CREATE TABLE dbo.tblMFWorkOrderProducedSKU (
	intWorkOrderProducedSKUId INT IDENTITY(1, 1) NOT NULL
	,intWorkOrderId INT NOT NULL
	,intItemId INT NOT NULL
	,intLotId INT NOT NULL
	,intSKUId INT NOT NULL
	,intContainerId INT NOT NULL
	,dblQuantity NUMERIC(38, 20) NOT NULL
	,intItemUOMId INT NOT NULL
	,dblIssuedQuantity NUMERIC(38, 20) NOT NULL
	,intItemIssuedUOMId INT NOT NULL
	,intBatchId INT NOT NULL
	,intShiftId INT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,CONSTRAINT PK_tblMFWorkOrderProducedSKU_intWorkOrderProducedSKUId PRIMARY KEY (intWorkOrderProducedSKUId)
	,CONSTRAINT FK_tblMFWorkOrderProducedSKU_tblICItem_inItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	,CONSTRAINT FK_tblMFWorkOrderProducedSKU_tblICItemUOM_intItemUOMId FOREIGN KEY (intItemUOMId) REFERENCES dbo.tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFWorkOrderProducedSKU_tblICItemUOM_intIssuedItemUOMId FOREIGN KEY (intItemIssuedUOMId) REFERENCES dbo.tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFWorkOrderProducedSKU_tblICLot_inLotId FOREIGN KEY (intLotId) REFERENCES dbo.tblICLot(intLotId)
	,CONSTRAINT FK_tblMFWorkOrderProducedSKU_tblMFShift_intShiftId FOREIGN KEY (intShiftId) REFERENCES dbo.tblMFShift(intShiftId)
	,CONSTRAINT FK_tblMFWorkOrderProducedSKU_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId) ON DELETE CASCADE
	)

