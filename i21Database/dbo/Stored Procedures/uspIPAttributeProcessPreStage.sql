CREATE PROCEDURE uspIPAttributeProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intAttributeId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intAttributePreStageId INT
	DECLARE @tblQMAttributePreStage TABLE (intAttributePreStageId INT)

	INSERT INTO @tblQMAttributePreStage (intAttributePreStageId)
	SELECT intAttributePreStageId
	FROM tblQMAttributePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intAttributePreStageId = MIN(intAttributePreStageId)
	FROM @tblQMAttributePreStage

	WHILE @intAttributePreStageId IS NOT NULL
	BEGIN
		SELECT @intAttributeId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intAttributeId = intAttributeId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMAttributePreStage
		WHERE intAttributePreStageId = @intAttributePreStageId

		EXEC uspIPAttributePopulateStgXML @intAttributeId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMAttributePreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intAttributePreStageId = @intAttributePreStageId

		SELECT @intAttributePreStageId = MIN(intAttributePreStageId)
		FROM @tblQMAttributePreStage
		WHERE intAttributePreStageId > @intAttributePreStageId
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
