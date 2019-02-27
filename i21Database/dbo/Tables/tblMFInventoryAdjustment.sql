CREATE TABLE dbo.tblMFInventoryAdjustment (
	intAdjustmentId INT identity(1, 1)
	,dtmDate DATETIME NOT NULL
	,intTransactionTypeId INT NOT NULL
	,intItemId INT NOT NULL
	,intStorageLocationId int NULL
	,intSourceLotId INT NULL
	,intDestinationStorageLocationId int NULL
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
	,intOldItemOwnerId INT
	,intNewItemOwnerId INT
	,strOldLotAlias nvarchar(50)
	,strNewLotAlias nvarchar(50)
	,strOldVendorLotNumber nvarchar(50)
	,strNewVendorLotNumber nvarchar(50)
	,intWorkOrderInputLotId INT 
	,intWorkOrderProducedLotId INT 
	,intWorkOrderId INT 
	,intWorkOrderConsumedLotId INT
	,dtmDateCreated Datetime CONSTRAINT DF_tblMFInventoryAdjustment_dtmDateCreated Default (GETDATE())
	,CONSTRAINT PK_tblMFInventoryAdjustment PRIMARY KEY (intAdjustmentId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItem_intOldItemId FOREIGN KEY (intOldItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItemUOM_intItemUOMId FOREIGN KEY (intItemUOMId) REFERENCES tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICLotStatus_intOldLotStatusId FOREIGN KEY (intOldLotStatusId) REFERENCES tblICLotStatus(intLotStatusId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICLotStatus_intNewLotStatusId FOREIGN KEY (intNewLotStatusId) REFERENCES tblICLotStatus(intLotStatusId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItemOwner_intOldItemOwnerId FOREIGN KEY (intOldItemOwnerId) REFERENCES tblICItemOwner(intItemOwnerId)
	,CONSTRAINT FK_tblMFInventoryAdjustment_tblICItemOwner_intNewItemOwnerId FOREIGN KEY (intNewItemOwnerId) REFERENCES tblICItemOwner(intItemOwnerId)
	)
Go
CREATE NONCLUSTERED INDEX IX_tblMFInventoryAdjustment_dtmDate ON [dbo].[tblMFInventoryAdjustment]
(
	[dtmDateCreated] DESC
)
INCLUDE ( 	[intTransactionTypeId],
	[intItemId],
	[intStorageLocationId],
	[intSourceLotId],
	[intDestinationStorageLocationId],
	[intDestinationLotId],
	[dblQty],
	[intItemUOMId],
	[intOldItemId],
	[dtmOldExpiryDate],
	[dtmNewExpiryDate],
	[intOldLotStatusId],
	[intNewLotStatusId],
	[intUserId],
	[dtmBusinessDate],
	[intBusinessShiftId],
	[strNote],
	[strReason],
	[intOldItemOwnerId],
	[intNewItemOwnerId],
	[intWorkOrderInputLotId],
	[intWorkOrderProducedLotId],
	[intWorkOrderId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
Go


