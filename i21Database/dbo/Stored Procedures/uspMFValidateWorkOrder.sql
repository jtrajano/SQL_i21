CREATE PROCEDURE uspMFValidateWorkOrder @intWorkOrderId INT
	,@intNewStatusId INT
	,@intStatusId INT = NULL
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
