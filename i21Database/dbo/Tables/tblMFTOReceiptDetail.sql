CREATE TABLE dbo.tblMFTOReceiptDetail (
	intDetailId INT IDENTITY(1, 1) NOT NULL
	,intInventoryTransferId INT
	,intInventoryTransferDetailId INT
	,intItemId INT
	,dblQuantity NUMERIC(18, 6)
	,intItemUOMId INT
	,intStorageLocationId INT
	,intSubLocationId INT
	,intUserId INT NULL
	,dtmDate DATETIME Constraint DF_tblMFTOReceiptDetail_dtmDate Default GETDATE()
	,ysnProcessed BIT
	,intInventoryReceiptId INT
	,intLocationId INT
	)