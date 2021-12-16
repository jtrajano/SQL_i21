CREATE PROCEDURE uspMFPODetailConfirm (
	@intPurchaseId int
	,@intPurchaseDetailId INT
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
	DECLARE @dblPOLineItemQty NUMERIC(18, 6)
		,@dblPOScannedQty NUMERIC(18, 6)
		,@strError NVARCHAR(50)

	IF @intStorageLocationId = 0
		SELECT @intStorageLocationId = NULL

	IF @intSubLocationId = 0
		SELECT @intSubLocationId = NULL

	SELECT @dblPOLineItemQty = dblQtyOrdered - dblQtyReceived
	FROM dbo.tblPOPurchaseDetail
	WHERE intPurchaseDetailId = @intPurchaseDetailId

	SELECT @dblPOScannedQty = dblQuantity
	FROM tblMFPODetail
	WHERE intPurchaseDetailId = @intPurchaseDetailId

	IF @dblPOScannedQty IS NULL
		SELECT @dblPOScannedQty = 0

	IF @dblPOScannedQty + @dblQuantity > @dblPOLineItemQty
	BEGIN
		SELECT @strError = 'SCANNED QTY CANNOT BE MORE THAN PO DETAIL QTY.'

		RAISERROR (
				@strError
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFPODetail
			WHERE intPurchaseDetailId = @intPurchaseDetailId
			)
	BEGIN
		INSERT INTO dbo.tblMFPODetail (
			intPurchaseId
			,intPurchaseDetailId
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStorageLocationId
			,intSubLocationId
			,intUserId
			,ysnProcessed
			,intLocationId
			)
		SELECT
			@intPurchaseId 
			,@intPurchaseDetailId
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
		UPDATE tblMFPODetail
		SET dblQuantity = dblQuantity + @dblQuantity
		WHERE intPurchaseDetailId = @intPurchaseDetailId
	END
END