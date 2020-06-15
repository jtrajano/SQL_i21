CREATE PROCEDURE uspIPItemProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intItemId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intItemPreStageId INT
		,@intCompanyId INT

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE dbo.tblICItem
	SET intCompanyId = @intCompanyId
	WHERE intCompanyId IS NULL

	DECLARE @tblICItemPreStage TABLE (intItemPreStageId INT)

	INSERT INTO @tblICItemPreStage (intItemPreStageId)
	SELECT intItemPreStageId
	FROM tblICItemPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblICItemPreStage
	SET strFeedStatus = 'In-Progress'
	WHERE intItemPreStageId IN (
			SELECT PS.intItemPreStageId
			FROM @tblICItemPreStage PS
			)


	SELECT @intItemPreStageId = MIN(intItemPreStageId)
	FROM @tblICItemPreStage

	WHILE @intItemPreStageId IS NOT NULL
	BEGIN
		SELECT @intItemId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intItemId = intItemId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblICItemPreStage
		WHERE intItemPreStageId = @intItemPreStageId

		EXEC uspIPItemPopulateStgXML @intItemId
			,@strRowState
			,@intUserId

		UPDATE tblICItemPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intItemPreStageId = @intItemPreStageId

		SELECT @intItemPreStageId = MIN(intItemPreStageId)
		FROM @tblICItemPreStage
		WHERE intItemPreStageId > @intItemPreStageId
	END
	UPDATE tblICItemPreStage
	SET strFeedStatus = NULL
	WHERE intItemPreStageId IN (
			SELECT PS.intItemPreStageId
			FROM @tblICItemPreStage PS
			)
	And IsNULL(strFeedStatus,'') = 'In-Progress'

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
