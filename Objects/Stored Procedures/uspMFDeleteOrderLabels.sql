CREATE PROCEDURE uspMFDeleteOrderLabels @strOrderManifestLabelId NVARCHAR(MAX)
	,@intUserId INT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)

	BEGIN TRAN

	UPDATE tblMFOrderManifestLabel
	SET ysnDeleted = 1
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE intOrderManifestLabelId IN (
			SELECT *
			FROM dbo.fnSplitString(@strOrderManifestLabelId, '^')
			)

	COMMIT TRAN
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
