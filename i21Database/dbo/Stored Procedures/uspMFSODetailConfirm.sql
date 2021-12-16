CREATE PROCEDURE uspMFSODetailConfirm (
	@intPickListDetailId INT
	,@intPickListId INT
	,@intSalesOrderId INT
	,@intSalesOrderDetailId INT
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
	DECLARE @dblSOLineItemQty NUMERIC(18, 6)
		,@dblSOScannedQty NUMERIC(18, 6)
		,@strError NVARCHAR(50)

	IF @intStorageLocationId = 0
		SELECT @intStorageLocationId = NULL

	IF @intSubLocationId = 0
		SELECT @intSubLocationId = NULL

	SELECT @dblSOLineItemQty = dblQtyOrdered - dblQtyShipped
	FROM dbo.tblSOSalesOrderDetail
	WHERE intSalesOrderDetailId = @intSalesOrderDetailId

	SELECT @dblSOScannedQty = dblQuantity
	FROM tblMFSODetail
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
			FROM dbo.tblMFSODetail
			WHERE intPickListDetailId = @intPickListDetailId
			)
	BEGIN
		INSERT INTO dbo.tblMFSODetail (
			intSalesOrderId
			,intSalesOrderDetailId
			,intPickListDetailId
			,intPickListId
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStorageLocationId
			,intSubLocationId
			,intUserId
			,ysnProcessed
			,intLocationId
			)
		SELECT @intSalesOrderId
			,@intSalesOrderDetailId
			,@intPickListDetailId
			,@intPickListId
			,@intItemId
			,@dblQuantity
			,@intItemUOMId
			,@intStorageLocationId
			,@intSubLocationId
			,@intUserId
			,0 AS ysnProcessed
			,@intLocationId
	END
	ELSE
	BEGIN
		UPDATE tblMFSODetail
		SET dblQuantity = dblQuantity + @dblQuantity
		WHERE intPickListDetailId = @intPickListDetailId
	END
END