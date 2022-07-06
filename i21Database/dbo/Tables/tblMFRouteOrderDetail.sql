CREATE TABLE dbo.tblMFRouteOrderDetail (
	intDetailId INT IDENTITY(1, 1) NOT NULL
	,intRouteId INT
	,intRouteOrderId INT
	,strOrderType NVARCHAR(30) COLLATE Latin1_General_CI_AS

	,intSalesOrderId INT
	,intSalesOrderDetailId INT
	,intPickListDetailId INT
	,intPickListId INT
	,intInventoryTransferId INT
	,intInventoryTransferDetailId INT

	,intItemId INT
	,dblQuantity NUMERIC(18, 6)
	,intItemUOMId INT
	,intStorageLocationId INT
	,intSubLocationId INT
	,intUserId INT
	,dtmDate DATETIME CONSTRAINT [DF_tblMFRouteOrderDetail_dtmDate] DEFAULT GETDATE()
	,ysnProcessed BIT
	,intLocationId INT

	,intInventoryShipmentId INT
	,ysnCompleted BIT
	)