CREATE PROCEDURE uspMFPostInventoryTransfer (
	@intInventoryTransferId INT
	,@intUserId INT
	,@strTransferNo NVARCHAR(50) OUTPUT
	)
AS
BEGIN TRY
	DECLARE @intTransactionCount INT
		,@strErrorMessage NVARCHAR(MAX)
		,@strBatchId NVARCHAR(50)
	DECLARE @tblMFTODetail TABLE (
		intInventoryTransferId INT
		,intInventoryTransferDetailId INT
		,intItemId INT
		,dblQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,intStorageLocationId INT
		,intSubLocationId INT
		,intUserId INT
		,ysnProcessed INT
		,intLocationId INT
		)

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.tblICInventoryTransfer
			WHERE intInventoryTransferId = @intInventoryTransferId
				AND intStatusId = 1
			)
	BEGIN
		RAISERROR (
				'Inventory Transfer is already in In-Transit / Closed status.'
				,16
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFTODetail
			WHERE intInventoryTransferId = @intInventoryTransferId
				AND ysnProcessed = 0
			)
	BEGIN
		RAISERROR (
				'There is no record to post the Inventory Transfer.'
				,16
				,1
				)

		RETURN
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @strErrorMessage = ''

	SELECT @strTransferNo = strTransferNo
	FROM tblICInventoryTransfer
	WHERE intInventoryTransferId = @intInventoryTransferId

	INSERT INTO @tblMFTODetail (
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
	SELECT intInventoryTransferId
		,intInventoryTransferDetailId
		,intItemId
		,SUM(dblQuantity)
		,intItemUOMId
		,intStorageLocationId
		,intSubLocationId
		,intUserId
		,ysnProcessed
		,intLocationId
	FROM dbo.tblMFTODetail
	WHERE intInventoryTransferId = @intInventoryTransferId
		AND ysnProcessed = 0
	GROUP BY intInventoryTransferId
		,intInventoryTransferDetailId
		,intItemId
		,intItemUOMId
		,intStorageLocationId
		,intSubLocationId
		,intUserId
		,ysnProcessed
		,intLocationId

	UPDATE ITD
	SET dblQuantity = TOD.dblQuantity
	FROM tblICInventoryTransferDetail ITD
	JOIN @tblMFTODetail TOD ON ITD.intInventoryTransferId = TOD.intInventoryTransferId

	EXEC dbo.uspICPostInventoryTransfer @ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strTransferNo
		,@intEntityUserSecurityId = @intUserId
		,@strBatchId = @strBatchId OUTPUT

	UPDATE tblMFTODetail
	SET ysnProcessed = 1
	WHERE intInventoryTransferId = @intInventoryTransferId

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrorMessage = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrorMessage
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
