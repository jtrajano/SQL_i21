CREATE PROCEDURE uspMFLotSplitOnHandHeld @intOrderHeaderId INT
	,@intUserId INT
	,@intTaskId INT = NULL
	,@ysnLoad BIT = 0
	,@strNewLotNumber NVARCHAR(50) = ''
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
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
