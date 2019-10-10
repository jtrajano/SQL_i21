CREATE PROCEDURE uspIPInterCompanyPreStageItem @intItemId INT
	,@strRowState NVARCHAR(50)
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM dbo.tblICItemPreStage
	WHERE strFeedStatus IS NULL
		AND intItemId = @intItemId

	INSERT INTO dbo.tblICItemPreStage (
		intItemId
		,strRowState
		,intUserId
		)
	SELECT @intItemId
		,@strRowState
		,@intUserId

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

