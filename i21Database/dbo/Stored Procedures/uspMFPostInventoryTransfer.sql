CREATE PROCEDURE uspMFPostInventoryTransfer (
	@intInventoryTransferId INT
	,@intUserId INT
	,@strTransferNo NVARCHAR(50) OUTPUT
	)
AS
BEGIN TRY
	DECLARE @intTransactionCount INT
		,@strErrorMessage NVARCHAR(MAX)

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
