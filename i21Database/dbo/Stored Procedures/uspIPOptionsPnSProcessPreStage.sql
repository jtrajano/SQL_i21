CREATE PROCEDURE uspIPOptionsPnSProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intOptionsMatchPnSHeaderId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intOptionsMatchPnSHeaderPreStageId INT
		,@strFromCompanyName NVARCHAR(150)
	DECLARE @tblRKOptionsMatchPnSHeaderPreStage TABLE (intOptionsMatchPnSHeaderPreStageId INT)

	INSERT INTO @tblRKOptionsMatchPnSHeaderPreStage (intOptionsMatchPnSHeaderPreStageId)
	SELECT intOptionsMatchPnSHeaderPreStageId
	FROM tblRKOptionsMatchPnSHeaderPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intOptionsMatchPnSHeaderPreStageId = MIN(intOptionsMatchPnSHeaderPreStageId)
	FROM @tblRKOptionsMatchPnSHeaderPreStage

	WHILE @intOptionsMatchPnSHeaderPreStageId IS NOT NULL
	BEGIN
		SELECT @intOptionsMatchPnSHeaderId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@intToCompanyId = NULL

		SELECT @intOptionsMatchPnSHeaderId = intOptionsMatchPnSHeaderId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKOptionsMatchPnSHeaderPreStage
		WHERE intOptionsMatchPnSHeaderPreStageId = @intOptionsMatchPnSHeaderPreStageId

		SELECT TOP 1 @strFromCompanyName = strName
		FROM tblIPMultiCompany
		WHERE ysnParent = 1

		DECLARE @ToCompanyList TABLE (intCompanyId INT)
		DECLARE @intCompanyId INT

		INSERT INTO @ToCompanyList (intCompanyId)
		SELECT DISTINCT MC.intCompanyId
		FROM tblRKOptionsMatchPnS M
		JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = M.intLFutOptTransactionId
		JOIN tblIPMultiCompany MC ON MC.intBookId = FOT.intBookId
			AND MC.ysnParent = 0
		WHERE M.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId

		INSERT INTO @ToCompanyList (intCompanyId)
		SELECT DISTINCT MC.intCompanyId
		FROM tblRKOptionsPnSExpired E
		JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = E.intFutOptTransactionId
		JOIN tblIPMultiCompany MC ON MC.intBookId = FOT.intBookId
			AND MC.ysnParent = 0
		WHERE E.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
			AND NOT EXISTS (
				SELECT 1
				FROM @ToCompanyList L
				WHERE L.intCompanyId = MC.intCompanyId
				)

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

			EXEC uspIPOptionsPnSPopulateStgXML @intOptionsMatchPnSHeaderId
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

		UPDATE tblRKOptionsMatchPnSHeaderPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intOptionsMatchPnSHeaderPreStageId = @intOptionsMatchPnSHeaderPreStageId

		SELECT @intOptionsMatchPnSHeaderPreStageId = MIN(intOptionsMatchPnSHeaderPreStageId)
		FROM @tblRKOptionsMatchPnSHeaderPreStage
		WHERE intOptionsMatchPnSHeaderPreStageId > @intOptionsMatchPnSHeaderPreStageId
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
