
CREATE TABLE dbo.tblMFSODetail (
	intDetailId INT IDENTITY(1, 1) NOT NULL
	,intSalesOrderId INT
	,intSalesOrderDetailId INT
	,intPickListDetailId INT
	,intPickListId INT
	,intItemId INT
	,dblQuantity NUMERIC(18, 6)
	,intItemUOMId INT
	,intStorageLocationId INT
	,intSubLocationId INT
	,intUserId INT NULL
	,dtmDate DATETIME CONSTRAINT [DF_tblMFSODetail_dtmDate] Default GetDate()
	,ysnProcessed BIT
	,intInventoryShipmentId INT
	,intLocationId INT
	)