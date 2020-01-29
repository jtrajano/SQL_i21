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
		,@intTransactionCount INT
	DECLARE @tblRKOptionsMatchPnSHeaderPreStage TABLE (intOptionsMatchPnSHeaderPreStageId INT)

	INSERT INTO @tblRKOptionsMatchPnSHeaderPreStage (intOptionsMatchPnSHeaderPreStageId)
	SELECT intOptionsMatchPnSHeaderPreStageId
	FROM tblRKOptionsMatchPnSHeaderPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intOptionsMatchPnSHeaderPreStageId = MIN(intOptionsMatchPnSHeaderPreStageId)
	FROM @tblRKOptionsMatchPnSHeaderPreStage

	WHILE @intOptionsMatchPnSHeaderPreStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

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

			DECLARE @ToCompanyList TABLE (
				intCompanyId INT
				,strNewRowState NVARCHAR(50)
				)
			DECLARE @intCompanyId INT
			DECLARE @strNewRowState NVARCHAR(50)

			DELETE
			FROM @ToCompanyList

			-- Doing the below logic to handle delete and changing the book
			-- Keep the insert queries in same order. First put added / modified then delete records
			INSERT INTO @ToCompanyList (
				intCompanyId
				,strNewRowState
				)
			SELECT DISTINCT MC.intCompanyId
				,CASE 
					WHEN EXISTS (
							SELECT 1
							FROM tblRKOptionsMatchPnSHeaderBook
							WHERE intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
								AND intBookId = MC.intBookId
							)
						THEN 'Modified'
					ELSE 'Added'
					END
			FROM tblRKOptionsMatchPnS M
			JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = M.intLFutOptTransactionId
			JOIN tblIPMultiCompany MC ON MC.intBookId = FOT.intBookId
				AND MC.ysnParent = 0
			WHERE M.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId

			INSERT INTO @ToCompanyList (
				intCompanyId
				,strNewRowState
				)
			SELECT DISTINCT MC.intCompanyId
				,CASE 
					WHEN EXISTS (
							SELECT 1
							FROM tblRKOptionsMatchPnSHeaderBook
							WHERE intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
								AND intBookId = MC.intBookId
							)
						THEN 'Modified'
					ELSE 'Added'
					END
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

			INSERT INTO @ToCompanyList (
				intCompanyId
				,strNewRowState
				)
			SELECT DISTINCT MC.intCompanyId
				,'Delete'
			FROM tblRKOptionsMatchPnSHeaderBook TB
			JOIN tblIPMultiCompany MC ON MC.intBookId = TB.intBookId
				AND MC.ysnParent = 0
			WHERE TB.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
				AND NOT EXISTS (
					SELECT 1
					FROM tblRKOptionsMatchPnS M
					JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = M.intLFutOptTransactionId
					WHERE M.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
						AND FOT.intBookId = TB.intBookId
					)
				AND NOT EXISTS (
					SELECT 1
					FROM @ToCompanyList
					WHERE intCompanyId = MC.intCompanyId
					)

			INSERT INTO @ToCompanyList (
				intCompanyId
				,strNewRowState
				)
			SELECT DISTINCT MC.intCompanyId
				,'Delete'
			FROM tblRKOptionsMatchPnSHeaderBook TB
			JOIN tblIPMultiCompany MC ON MC.intBookId = TB.intBookId
				AND MC.ysnParent = 0
			WHERE TB.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
				AND NOT EXISTS (
					SELECT 1
					FROM tblRKOptionsPnSExpired E
					JOIN tblRKFutOptTransaction FOT ON FOT.intFutOptTransactionId = E.intFutOptTransactionId
					WHERE E.intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId
						AND FOT.intBookId = TB.intBookId
					)
				AND NOT EXISTS (
					SELECT 1
					FROM @ToCompanyList
					WHERE intCompanyId = MC.intCompanyId
					)

			DELETE
			FROM tblRKOptionsMatchPnSHeaderBook
			WHERE intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId

			SELECT @intCompanyId = MIN(intCompanyId)
			FROM @ToCompanyList

			WHILE @intCompanyId IS NOT NULL
			BEGIN
				SELECT @intToBookId = NULL
					,@intToCompanyId = NULL
					,@strNewRowState = NULL

				SELECT @strNewRowState = strNewRowState
				FROM @ToCompanyList
				WHERE intCompanyId = @intCompanyId

				SELECT @intToBookId = intBookId
					,@intToCompanyId = intCompanyId
				FROM tblIPMultiCompany
				WHERE intCompanyId = @intCompanyId

				EXEC uspIPOptionsPnSPopulateStgXML @intOptionsMatchPnSHeaderId
					,@intToEntityId
					,@intCompanyLocationId
					,@strToTransactionType
					,@intToCompanyId
					,@strNewRowState
					,0
					,@intToBookId
					,@intUserId
					,@strFromCompanyName

				IF @strNewRowState <> 'Delete'
				BEGIN
					INSERT INTO tblRKOptionsMatchPnSHeaderBook (
						intOptionsMatchPnSHeaderId
						,intBookId
						)
					SELECT @intOptionsMatchPnSHeaderId
						,@intToBookId
				END

				SELECT @intCompanyId = MIN(intCompanyId)
				FROM @ToCompanyList
				WHERE intCompanyId > @intCompanyId
			END

			UPDATE tblRKOptionsMatchPnSHeaderPreStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intOptionsMatchPnSHeaderPreStageId = @intOptionsMatchPnSHeaderPreStageId

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblRKOptionsMatchPnSHeaderPreStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intOptionsMatchPnSHeaderPreStageId = @intOptionsMatchPnSHeaderPreStageId
		END CATCH

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
