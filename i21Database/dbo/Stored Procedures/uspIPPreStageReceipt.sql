CREATE PROCEDURE uspIPPreStageReceipt (
	@intInventoryReceiptId INT
	,@intUserId INT
	,@ysnPosted BIT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblIPInvPostedReceipt
	WHERE intInventoryReceiptId = @intInventoryReceiptId
		AND intStatusId IS NULL

	IF @ysnPosted = 1
	BEGIN
		INSERT INTO dbo.tblIPInvPostedReceipt (
			intInventoryReceiptId
			,intUserId
			,ysnPosted
			,intStatusId
			)
		SELECT @intInventoryReceiptId
			,@intUserId
			,@ysnPosted
			,NULL
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
