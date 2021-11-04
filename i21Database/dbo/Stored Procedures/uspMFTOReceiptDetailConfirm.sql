CREATE PROCEDURE uspMFTOReceiptDetailConfirm (
	@intInventoryTransferId INT
	,@intInventoryTransferDetailId INT
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
	DECLARE @dblTOLineItemQty NUMERIC(18, 6)
		,@dblTOScannedQty NUMERIC(18, 6)
		,@strError NVARCHAR(50)

	SELECT @dblTOLineItemQty = dblQuantity
	FROM dbo.tblICInventoryTransferDetail
	WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId

	SELECT @dblTOScannedQty = dblQuantity
	FROM tblMFTOReceiptDetail
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
			FROM dbo.tblMFTOReceiptDetail
			WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId
			)
	BEGIN
		INSERT INTO dbo.tblMFTOReceiptDetail (
			intInventoryTransferId
			,intInventoryTransferDetailId
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStorageLocationId
			,intSubLocationId
			,intUserId
			,ysnProcessed
			,intLocationId
			)
		SELECT @intInventoryTransferId
			,@intInventoryTransferDetailId
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
		UPDATE tblMFTOReceiptDetail
		SET dblQuantity = dblQuantity + @dblQuantity
		WHERE intInventoryTransferDetailId = @intInventoryTransferDetailId
	END
END
