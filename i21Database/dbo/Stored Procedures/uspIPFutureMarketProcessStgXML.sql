CREATE PROCEDURE uspIPFutureMarketProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intFutureMarketStageId INT
		,@intFutureMarketId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strFutMarketName NVARCHAR(30)
	DECLARE @intLastModifiedUserId INT
		,@intNewFutureMarketId INT
		,@dblOldForecastPrice NUMERIC(18, 6)
		,@dblNewForecastPrice NUMERIC(18, 6)
	DECLARE @tblRKFutureMarketStage TABLE (intFutureMarketStageId INT)

	INSERT INTO @tblRKFutureMarketStage (intFutureMarketStageId)
	SELECT intFutureMarketStageId
	FROM tblRKFutureMarketStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutureMarketStageId = MIN(intFutureMarketStageId)
	FROM @tblRKFutureMarketStage

	IF @intFutureMarketStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKFutureMarketStage t
	JOIN @tblRKFutureMarketStage pt ON pt.intFutureMarketStageId = t.intFutureMarketStageId

	WHILE @intFutureMarketStageId > 0
	BEGIN
		SELECT @intFutureMarketId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@dblOldForecastPrice = NULL
			,@dblNewForecastPrice = NULL

		SELECT @intFutureMarketId = intFutureMarketId
			,@strHeaderXML = strHeaderXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
			,@dblNewForecastPrice = dblForecastPrice
		FROM tblRKFutureMarketStage
		WHERE intFutureMarketStageId = @intFutureMarketStageId

		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strFutMarketName = NULL

			SELECT @strFutMarketName = strFutMarketName
			FROM OPENXML(@idoc, 'vyuIPGetFutureMarkets/vyuIPGetFutureMarket', 2) WITH (
					strFutMarketName NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			SELECT @intLastModifiedUserId = NULL

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState = 'Modified'
			BEGIN
				SELECT @dblOldForecastPrice = dblForecastPrice
				FROM tblRKFutureMarket
				WHERE strFutMarketName = @strFutMarketName

				UPDATE tblRKFutureMarket
				SET intConcurrencyId = intConcurrencyId + 1
					,dblForecastPrice = @dblNewForecastPrice
				WHERE tblRKFutureMarket.strFutMarketName = @strFutMarketName

				SELECT @intNewFutureMarketId = intFutureMarketId
				FROM tblRKFutureMarket
				WHERE strFutMarketName = @strFutMarketName
			END

			EXEC sp_xml_removedocument @idoc

			UPDATE tblRKFutureMarketStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intFutureMarketStageId = @intFutureMarketStageId

			-- Audit Log
			IF (@intNewFutureMarketId > 0)
			BEGIN
				DECLARE @strDetails AS NVARCHAR(MAX)

				IF @strRowState = 'Modified'
				BEGIN
					SELECT @strDetails = ''

					IF (@dblOldForecastPrice <> @dblNewForecastPrice)
						SET @strDetails += '{"change":"dblForecastPrice","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dblOldForecastPrice, 0)) + '","to":"' + LTRIM(ISNULL(@dblNewForecastPrice, 0)) + '","leaf":true,"changeDescription":"Forecast Price from Inter Company"},'

					IF (LEN(@strDetails) > 1)
					BEGIN
						SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

						EXEC uspSMAuditLog @keyValue = @intNewFutureMarketId
							,@screenName = 'RiskManagement.view.FuturesMarket'
							,@entityId = @intLastModifiedUserId
							,@actionType = 'Updated'
							,@actionIcon = 'small-tree-modified'
							,@details = @strDetails
					END
				END
			END

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblRKFutureMarketStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intFutureMarketStageId = @intFutureMarketStageId
		END CATCH

		SELECT @intFutureMarketStageId = MIN(intFutureMarketStageId)
		FROM @tblRKFutureMarketStage
		WHERE intFutureMarketStageId > @intFutureMarketStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKFutureMarketStage t
	JOIN @tblRKFutureMarketStage pt ON pt.intFutureMarketStageId = t.intFutureMarketStageId
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
