CREATE PROCEDURE uspIPListProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intListId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intListPreStageId INT
	DECLARE @tblQMListPreStage TABLE (intListPreStageId INT)

	INSERT INTO @tblQMListPreStage (intListPreStageId)
	SELECT intListPreStageId
	FROM tblQMListPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intListPreStageId = MIN(intListPreStageId)
	FROM @tblQMListPreStage

	WHILE @intListPreStageId IS NOT NULL
	BEGIN
		SELECT @intListId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intListId = intListId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMListPreStage
		WHERE intListPreStageId = @intListPreStageId

		EXEC uspIPListPopulateStgXML @intListId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMListPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intListPreStageId = @intListPreStageId

		SELECT @intListPreStageId = MIN(intListPreStageId)
		FROM @tblQMListPreStage
		WHERE intListPreStageId > @intListPreStageId
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
