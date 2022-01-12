CREATE TABLE dbo.tblMFWODetail (
	intDetailId INT IDENTITY(1, 1) NOT NULL
	,intProducedItemId INT
	,intItemId INT
	,dblQuantity NUMERIC(18, 6)
	,dblLowerToleranceQty NUMERIC(18, 6)
	,dblUpperToleranceQty NUMERIC(18, 6)
	,intItemUOMId INT
	,intStorageLocationId INT
	,intSubLocationId INT
	,intTransactionTypeId INT
	,intUserId INT NULL
	,dtmDate DATETIME
	,ysnProcessed BIT
	,intWorkOrderId INT
	,intLocationId INT
	)