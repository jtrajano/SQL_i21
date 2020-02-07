CREATE PROCEDURE uspIPPropertyProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intPropertyId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intPropertyPreStageId INT
	DECLARE @tblQMPropertyPreStage TABLE (intPropertyPreStageId INT)

	INSERT INTO @tblQMPropertyPreStage (intPropertyPreStageId)
	SELECT intPropertyPreStageId
	FROM tblQMPropertyPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intPropertyPreStageId = MIN(intPropertyPreStageId)
	FROM @tblQMPropertyPreStage

	WHILE @intPropertyPreStageId IS NOT NULL
	BEGIN
		SELECT @intPropertyId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intPropertyId = intPropertyId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMPropertyPreStage
		WHERE intPropertyPreStageId = @intPropertyPreStageId

		EXEC uspIPPropertyPopulateStgXML @intPropertyId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMPropertyPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intPropertyPreStageId = @intPropertyPreStageId

		SELECT @intPropertyPreStageId = MIN(intPropertyPreStageId)
		FROM @tblQMPropertyPreStage
		WHERE intPropertyPreStageId > @intPropertyPreStageId
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
