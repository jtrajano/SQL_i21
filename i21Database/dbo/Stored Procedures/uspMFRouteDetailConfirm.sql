CREATE PROCEDURE uspMFRouteDetailConfirm (
	@intRouteOrderId INT
	,@intPickListDetailId INT = NULL
	,@intPickListId INT = NULL
	,@intSalesOrderId INT = NULL
	,@intSalesOrderDetailId INT = NULL
	,@intInventoryTransferId INT = NULL
	,@intInventoryTransferDetailId INT = NULL
	,@intItemId INT
	,@dblQuantity NUMERIC(18, 6)
	,@intItemUOMId INT
	,@intStorageLocationId INT
	,@intSubLocationId INT
	,@intUserId INT
	,@intLocationId INT
	)
AS
BEGIN
	DECLARE @intRouteId INT
		,@strOrderType NVARCHAR(30)
		,@strError NVARCHAR(50)
	DECLARE @dblSOLineItemQty NUMERIC(18, 6)
		,@dblSOScannedQty NUMERIC(18, 6)
	DECLARE @dblTOLineItemQty NUMERIC(18, 6)
		,@dblTOScannedQty NUMERIC(18, 6)

	SELECT @intRouteId = intRouteId
		,@strOrderType = strOrderType
	FROM tblLGRouteOrder
	WHERE intRouteOrderId = @intRouteOrderId

	IF ISNULL(@strOrderType, '') = 'Sales'
	BEGIN
		SELECT @dblSOLineItemQty = dblQtyOrdered - dblQtyShipped
		FROM dbo.tblSOSalesOrderDetail
		WHERE intSalesOrderDetailId = @intSalesOrderDetailId

		SELECT @dblSOScannedQty = dblQuantity
		FROM tblMFRouteOrderDetail
		WHERE intSalesOrderDetailId = @intSalesOrderDetailId

		IF @dblSOScannedQty IS NULL
			SELECT @dblSOScannedQty = 0

		IF @dblSOScannedQty + @dblQuantity > @dblSOLineItemQty
		BEGIN
			SELECT @strError = 'SCANNED QTY CANNOT BE MORE THAN SO DETAIL QTY.'

			RAISERROR (
					@strError
					,16
					,1
					)

			RETURN
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFRouteOrderDetail
				WHERE intPickListDetailId = @intPickListDetailId
				)
		BEGIN
			INSERT INTO dbo.tblMFRouteOrderDetail (
				intRouteId
				,intRouteOrderId
				,strOrderType
				,intSalesOrderId
				,intSalesOrderDetailId
				,intPickListDetailId
				,intPickListId
				,intInventoryTransferId
				,intInventoryTransferDetailId
				,intItemId
				,dblQuantity
				,intItemUOMId
				,intStorageLocationId
				,intSubLocationId
				,intUserId
				,ysnProcessed
				,intLocationId
				,ysnCompleted
				)
			SELECT @intRouteId
				,@intRouteOrderId
				,@strOrderType
				,@intSalesOrderId
				,@intSalesOrderDetailId
				,@intPickListDetailId
				,@intPickListId
				,@intInventoryTransferId
				,@intInventoryTransferDetailId
				,@intItemId
				,@dblQuantity
				,@intItemUOMId
				,@intStorageLocationId
				,@intSubLocationId
				,@intUserId
				,0 AS ysnProcessed
				,@intLocationId
				,0 AS ysnCompleted
		END
		ELSE
		BEGIN
			UPDATE tblMFRouteOrderDetail
			SET dblQuantity = dblQuantity + @dblQuantity
			WHERE intPickListDetailId = @intPickListDetailId
		END
	END

	IF ISNULL(@strOrderType, '') = 'Transfer'
	BEGIN
		SELECT @dblTOLineItemQty = dblQuantity
		FROM dbo.tblICInventoryTransferDetail
		WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId

		SELECT @dblTOScannedQty = dblQuantity
		FROM tblMFRouteOrderDetail
		WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId

		IF @dblTOScannedQty IS NULL
			SELECT @dblTOScannedQty = 0

		IF @dblTOScannedQty + @dblQuantity > @dblTOLineItemQty
		BEGIN
			SELECT @strError = 'SCANNED QTY CANNOT BE MORE THAN TO DETAIL QTY.'

			RAISERROR (
					@strError
					,16
					,1
					)

			RETURN
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFRouteOrderDetail
				WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId
				)
		BEGIN
			INSERT INTO dbo.tblMFRouteOrderDetail (
				intRouteId
				,intRouteOrderId
				,strOrderType
				,intSalesOrderId
				,intSalesOrderDetailId
				,intPickListDetailId
				,intPickListId
				,intInventoryTransferId
				,intInventoryTransferDetailId
				,intItemId
				,dblQuantity
				,intItemUOMId
				,intStorageLocationId
				,intSubLocationId
				,intUserId
				,ysnProcessed
				,intLocationId
				,ysnCompleted
				)
			SELECT @intRouteId
				,@intRouteOrderId
				,@strOrderType
				,@intSalesOrderId
				,@intSalesOrderDetailId
				,@intPickListDetailId
				,@intPickListId
				,@intInventoryTransferId
				,@intInventoryTransferDetailId
				,@intItemId
				,@dblQuantity
				,@intItemUOMId
				,@intStorageLocationId
				,@intSubLocationId
				,@intUserId
				,0 AS ysnProcessed
				,@intLocationId
				,0 AS ysnCompleted
		END
		ELSE
		BEGIN
			UPDATE tblMFRouteOrderDetail
			SET dblQuantity = dblQuantity + @dblQuantity
			WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId
		END
	END
END
