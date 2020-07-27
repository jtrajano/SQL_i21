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
		,@intTransactionCount INT
	DECLARE @tblRKFutOptTransactionHeaderPreStage TABLE (intFutOptTransactionHeaderPreStageId INT)

	INSERT INTO @tblRKFutOptTransactionHeaderPreStage (intFutOptTransactionHeaderPreStageId)
	SELECT intFutOptTransactionHeaderPreStageId
	FROM tblRKFutOptTransactionHeaderPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutOptTransactionHeaderPreStageId = MIN(intFutOptTransactionHeaderPreStageId)
	FROM @tblRKFutOptTransactionHeaderPreStage

	IF @intFutOptTransactionHeaderPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKFutOptTransactionHeaderPreStage t
	JOIN @tblRKFutOptTransactionHeaderPreStage pt ON pt.intFutOptTransactionHeaderPreStageId = t.intFutOptTransactionHeaderPreStageId

	WHILE @intFutOptTransactionHeaderPreStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			SELECT @intFutOptTransactionHeaderId = NULL
				,@strRowState = NULL
				,@intUserId = NULL
				,@intToCompanyId = NULL

			SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
				,@strRowState = strRowState
				,@intUserId = intUserId
			FROM tblRKFutOptTransactionHeaderPreStage WITH (NOLOCK)
			WHERE intFutOptTransactionHeaderPreStageId = @intFutOptTransactionHeaderPreStageId

			SELECT TOP 1 @strFromCompanyName = strName
			FROM tblIPMultiCompany WITH (NOLOCK)
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
			INSERT INTO @ToCompanyList (
				intCompanyId
				,strNewRowState
				)
			SELECT DISTINCT MC.intCompanyId
				,CASE 
					WHEN EXISTS (
							SELECT 1
							FROM tblRKFutOptTransactionHeaderBook WITH (NOLOCK)
							WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
								AND intBookId = MC.intBookId
							)
						THEN 'Modified'
					ELSE 'Added'
					END
			FROM tblRKFutOptTransaction T WITH (NOLOCK)
			JOIN tblIPMultiCompany MC WITH (NOLOCK) ON MC.intBookId = T.intBookId
				AND MC.ysnParent = 0
			WHERE T.intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

			INSERT INTO @ToCompanyList (
				intCompanyId
				,strNewRowState
				)
			SELECT DISTINCT MC.intCompanyId
				,'Delete'
			FROM tblRKFutOptTransactionHeaderBook TB WITH (NOLOCK)
			JOIN tblIPMultiCompany MC WITH (NOLOCK) ON MC.intBookId = TB.intBookId
				AND MC.ysnParent = 0
			WHERE TB.intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
				AND NOT EXISTS (
					SELECT 1
					FROM tblRKFutOptTransaction WITH (NOLOCK)
					WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
						AND intBookId = TB.intBookId
					)
				AND NOT EXISTS (
					SELECT 1
					FROM @ToCompanyList
					WHERE intCompanyId = MC.intCompanyId
					)

			DELETE
			FROM tblRKFutOptTransactionHeaderBook
			WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

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
				FROM tblIPMultiCompany WITH (NOLOCK)
				WHERE intCompanyId = @intCompanyId

				EXEC uspIPFutOptTransactionPopulateStgXML @intFutOptTransactionHeaderId
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
					INSERT INTO tblRKFutOptTransactionHeaderBook (
						intFutOptTransactionHeaderId
						,intBookId
						)
					SELECT @intFutOptTransactionHeaderId
						,@intToBookId
				END

				SELECT @intCompanyId = MIN(intCompanyId)
				FROM @ToCompanyList
				WHERE intCompanyId > @intCompanyId
			END

			UPDATE tblRKFutOptTransactionHeaderPreStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intFutOptTransactionHeaderPreStageId = @intFutOptTransactionHeaderPreStageId

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblRKFutOptTransactionHeaderPreStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intFutOptTransactionHeaderPreStageId = @intFutOptTransactionHeaderPreStageId
		END CATCH

		SELECT @intFutOptTransactionHeaderPreStageId = MIN(intFutOptTransactionHeaderPreStageId)
		FROM @tblRKFutOptTransactionHeaderPreStage
		WHERE intFutOptTransactionHeaderPreStageId > @intFutOptTransactionHeaderPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKFutOptTransactionHeaderPreStage t
	JOIN @tblRKFutOptTransactionHeaderPreStage pt ON pt.intFutOptTransactionHeaderPreStageId = t.intFutOptTransactionHeaderPreStageId
		AND t.strFeedStatus = 'In-Progress'
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
