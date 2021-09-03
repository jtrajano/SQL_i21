CREATE PROCEDURE uspMFRoutePostInventoryTransfer (
	@intRouteId INT
	,@intInventoryTransferId INT
	,@intUserId INT
	,@strTransferNo NVARCHAR(50) OUTPUT
	)
AS
BEGIN TRY
	DECLARE @intTransactionCount INT
		,@strErrorMessage NVARCHAR(MAX)

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
			FROM dbo.tblMFRouteOrderDetail
			WHERE intInventoryTransferId = @intInventoryTransferId
				AND ysnProcessed = 0
				AND intRouteId = @intRouteId
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

	UPDATE tblMFRouteOrderDetail
	SET ysnProcessed = 1
		,ysnCompleted = 1
	WHERE intInventoryTransferId = @intInventoryTransferId
		AND intRouteId = @intRouteId

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
