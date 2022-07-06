CREATE TABLE dbo.tblMFPODetail (
	intDetailId INT IDENTITY(1, 1) NOT NULL
	,intPurchaseId INT
	,intPurchaseDetailId INT
	,intItemId INT
	,dblQuantity NUMERIC(18, 6)
	,intItemUOMId INT
	,intStorageLocationId INT
	,intSubLocationId INT
	,intUserId INT NULL
	,dtmDate DATETIME
	,ysnProcessed BIT
	,intInventoryReceiptId INT
	,intLocationId INT
	)