CREATE PROCEDURE uspMFWorkOrderFeed @intWorkOrderId INT
	,@intUserId INT
	,@intStatusId INT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)

	Insert into dbo.tblMFWorkOrderPreStage(intWorkOrderId,intWorkOrderStatusId,intUserId)
	Select @intWorkOrderId,@intStatusId,@intUserId
	
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
