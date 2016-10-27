CREATE TABLE dbo.tblMFInventoryAdjustment (
	intAdjustmentId INT identity(1, 1)
	,dtmDate DATETIME NOT NULL
	,intTransactionTypeId INT NOT NULL
	,intItemId INT NOT NULL
	,intSourceLotId INT NOT NULL
	,intDestinationLotId INT
	,dblQty NUMERIC(38, 20)
	,intItemUOMId INT
	,intOldItemId INT
	,dtmOldExpiryDate DATETIME
	,dtmNewExpiryDate DATETIME
	,intOldLotStatusId INT
	,intNewLotStatusId INT
	,intUserId INT NOT NULL
	,intLocationId int NOT NULL
	,dtmBusinessDate Datetime
	,intBusinessShiftId int
	,strNote NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strReason NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
	,intInventoryAdjustmentId int
	,CONSTRAINT PK_tblMFInventoryAdjustment PRIMARY KEY (intAdjustmentId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItem_intOldItemId FOREIGN KEY (intOldItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItemUOM_intItemUOMId FOREIGN KEY (intItemUOMId) REFERENCES tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICLotStatus_intOldLotStatusId FOREIGN KEY (intOldLotStatusId) REFERENCES tblICLotStatus(intLotStatusId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICLotStatus_intNewLotStatusId FOREIGN KEY (intNewLotStatusId) REFERENCES tblICLotStatus(intLotStatusId)
	)


