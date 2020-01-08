CREATE PROCEDURE uspIPFutOptTransactionProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intFutOptTransactionHeaderId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intFutOptTransactionHeaderPreStageId INT
		,@strFromCompanyName NVARCHAR(150)
	DECLARE @tblRKFutOptTransactionHeaderPreStage TABLE (intFutOptTransactionHeaderPreStageId INT)

	INSERT INTO @tblRKFutOptTransactionHeaderPreStage (intFutOptTransactionHeaderPreStageId)
	SELECT intFutOptTransactionHeaderPreStageId
	FROM tblRKFutOptTransactionHeaderPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutOptTransactionHeaderPreStageId = MIN(intFutOptTransactionHeaderPreStageId)
	FROM @tblRKFutOptTransactionHeaderPreStage

	WHILE @intFutOptTransactionHeaderPreStageId IS NOT NULL
	BEGIN
		SELECT @intFutOptTransactionHeaderId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@intToCompanyId = NULL

		SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKFutOptTransactionHeaderPreStage
		WHERE intFutOptTransactionHeaderPreStageId = @intFutOptTransactionHeaderPreStageId

		SELECT TOP 1 @strFromCompanyName = strName
		FROM tblIPMultiCompany
		WHERE ysnParent = 1

		DECLARE @ToCompanyList TABLE (intCompanyId INT)
		DECLARE @intCompanyId INT

		INSERT INTO @ToCompanyList (intCompanyId)
		SELECT DISTINCT MC.intCompanyId
		FROM tblRKFutOptTransaction T
		JOIN tblIPMultiCompany MC ON MC.intBookId = T.intBookId
			AND MC.ysnParent = 0
		WHERE T.intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

		SELECT @intCompanyId = MIN(intCompanyId)
		FROM @ToCompanyList

		WHILE @intCompanyId IS NOT NULL
		BEGIN
			SELECT @intToBookId = NULL
				,@intToCompanyId = NULL

			SELECT @intToBookId = intBookId
				,@intToCompanyId = intCompanyId
			FROM tblIPMultiCompany
			WHERE intCompanyId = @intCompanyId

			EXEC uspIPFutOptTransactionPopulateStgXML @intFutOptTransactionHeaderId
				,@intToEntityId
				,@intCompanyLocationId
				,@strToTransactionType
				,@intToCompanyId
				,@strRowState
				,0
				,@intToBookId
				,@intUserId
				,@strFromCompanyName

			SELECT @intCompanyId = MIN(intCompanyId)
			FROM @ToCompanyList
			WHERE intCompanyId > @intCompanyId
		END

		UPDATE tblRKFutOptTransactionHeaderPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intFutOptTransactionHeaderPreStageId = @intFutOptTransactionHeaderPreStageId

		SELECT @intFutOptTransactionHeaderPreStageId = MIN(intFutOptTransactionHeaderPreStageId)
		FROM @tblRKFutOptTransactionHeaderPreStage
		WHERE intFutOptTransactionHeaderPreStageId > @intFutOptTransactionHeaderPreStageId
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
