CREATE PROCEDURE uspIPOptionMonthProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intOptionMonthStageId INT
		,@intOptionMonthId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strFutMarketName NVARCHAR(30)
		,@strCommodityCode NVARCHAR(50)
		,@strFutureMonth NVARCHAR(20)
		,@strOptionMonth NVARCHAR(20)
	DECLARE @intFutureMarketId INT
		,@intCommodityMarketId INT
		,@intFutureMonthId INT
		,@intLastModifiedUserId INT
		,@intNewOptionMonthId INT
		,@intOptionMonthRefId INT
	DECLARE @tblRKOptionsMonthStage TABLE (intOptionMonthStageId INT)

	INSERT INTO @tblRKOptionsMonthStage (intOptionMonthStageId)
	SELECT intOptionMonthStageId
	FROM tblRKOptionsMonthStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intOptionMonthStageId = MIN(intOptionMonthStageId)
	FROM @tblRKOptionsMonthStage

	IF @intOptionMonthStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKOptionsMonthStage t
	JOIN @tblRKOptionsMonthStage pt ON pt.intOptionMonthStageId = t.intOptionMonthStageId

	WHILE @intOptionMonthStageId > 0
	BEGIN
		SELECT @intOptionMonthId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL

		SELECT @intOptionMonthId = intOptionMonthId
			,@strHeaderXML = strHeaderXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblRKOptionsMonthStage
		WHERE intOptionMonthStageId = @intOptionMonthStageId

		BEGIN TRY
			SELECT @intOptionMonthRefId = @intOptionMonthId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strFutMarketName = NULL
				,@strCommodityCode = NULL
				,@strFutureMonth = NULL
				,@strOptionMonth = NULL
				,@intFutureMarketId = NULL

			SELECT @strFutMarketName = strFutMarketName
				,@strCommodityCode = strCommodityCode
				,@strFutureMonth = strFutureMonth
				,@strOptionMonth = strOptionMonth
			FROM OPENXML(@idoc, 'vyuIPGetOptionMonths/vyuIPGetOptionMonth', 2) WITH (
					strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
					,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
					,strOptionMonth NVARCHAR(20) Collate Latin1_General_CI_AS
					) x

			IF @strFutMarketName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblRKFutureMarket t
					WHERE t.strFutMarketName = @strFutMarketName
					)
			BEGIN
				SELECT @strErrorMessage = 'Future Market Name ' + @strFutMarketName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intFutureMarketId = t.intFutureMarketId
			FROM tblRKFutureMarket t
			WHERE t.strFutMarketName = @strFutMarketName

			IF @strCommodityCode IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICCommodity t
					WHERE t.strCommodityCode = @strCommodityCode
					)
			BEGIN
				SELECT @strErrorMessage = 'Commodity ' + @strCommodityCode + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strCommodityCode IS NOT NULL
				AND @intFutureMarketId IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICCommodity C
					JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityId = C.intCommodityId
						AND CMM.intFutureMarketId = @intFutureMarketId
					WHERE C.strCommodityCode = @strCommodityCode
					)
			BEGIN
				SELECT @strErrorMessage = 'Commodity Market ' + @strCommodityCode + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strFutureMonth IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblRKFuturesMonth t
					WHERE t.strFutureMonth = @strFutureMonth
					)
			BEGIN
				SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intFutureMarketId = NULL
				,@intCommodityMarketId = NULL
				,@intFutureMonthId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intFutureMarketId = t.intFutureMarketId
			FROM tblRKFutureMarket t
			WHERE t.strFutMarketName = @strFutMarketName

			SELECT @intCommodityMarketId = CMM.intCommodityMarketId
			FROM tblICCommodity C
			JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityId = C.intCommodityId
				AND CMM.intFutureMarketId = @intFutureMarketId
			WHERE C.strCommodityCode = @strCommodityCode

			SELECT @intFutureMonthId = t.intFutureMonthId
			FROM tblRKFuturesMonth t
			WHERE t.strFutureMonth = @strFutureMonth
				AND t.intFutureMarketId = @intFutureMarketId
				AND t.intCommodityMarketId = @intCommodityMarketId

			IF @intFutureMonthId IS NULL
			BEGIN
				SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

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

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblRKOptionsMonth
						WHERE intOptionMonthRefId = @intOptionMonthRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewOptionMonthId = @intOptionMonthRefId
					,@strOptionMonth = ''

				DELETE
				FROM tblRKOptionsMonth
				WHERE intOptionMonthRefId = @intOptionMonthRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKOptionsMonth (
					intConcurrencyId
					,intFutureMarketId
					,intCommodityMarketId
					,strOptionMonth
					,intYear
					,intFutureMonthId
					,ysnMonthExpired
					,dtmExpirationDate
					,strOptMonthSymbol
					,intOptionMonthRefId
					)
				SELECT 1
					,@intFutureMarketId
					,@intCommodityMarketId
					,strOptionMonth
					,intYear
					,@intFutureMonthId
					,ysnMonthExpired
					,dtmExpirationDate
					,strOptMonthSymbol
					,@intOptionMonthRefId
				FROM OPENXML(@idoc, 'vyuIPGetOptionMonths/vyuIPGetOptionMonth', 2) WITH (
						strOptionMonth NVARCHAR(20)
						,intYear INT
						,ysnMonthExpired BIT
						,dtmExpirationDate DATETIME
						,strOptMonthSymbol NVARCHAR(10)
						)

				SELECT @intNewOptionMonthId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKOptionsMonth
				SET intConcurrencyId = intConcurrencyId + 1
					,intFutureMarketId = @intFutureMarketId
					,intCommodityMarketId = @intCommodityMarketId
					,strOptionMonth = x.strOptionMonth
					,intYear = x.intYear
					,intFutureMonthId = @intFutureMonthId
					,ysnMonthExpired = x.ysnMonthExpired
					,dtmExpirationDate = x.dtmExpirationDate
					,strOptMonthSymbol = x.strOptMonthSymbol
				FROM OPENXML(@idoc, 'vyuIPGetOptionMonths/vyuIPGetOptionMonth', 2) WITH (
						strOptionMonth NVARCHAR(20)
						,intYear INT
						,ysnMonthExpired BIT
						,dtmExpirationDate DATETIME
						,strOptMonthSymbol NVARCHAR(10)
						) x
				WHERE tblRKOptionsMonth.intOptionMonthRefId = @intOptionMonthRefId
				
				SELECT @intNewOptionMonthId = intOptionMonthId
					,@strOptionMonth = strOptionMonth
				FROM tblRKOptionsMonth
				WHERE intOptionMonthRefId = @intOptionMonthRefId
			END

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblRKOptionsMonthStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intOptionMonthStageId = @intOptionMonthStageId

			-- Audit Log
			IF (@intNewOptionMonthId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewOptionMonthId
						,@screenName = 'RiskManagement.view.OptionsTradingMonths'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strOptionMonth
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewOptionMonthId
						,@screenName = 'RiskManagement.view.OptionsTradingMonths'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strOptionMonth
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

			UPDATE tblRKOptionsMonthStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intOptionMonthStageId = @intOptionMonthStageId
		END CATCH

		SELECT @intOptionMonthStageId = MIN(intOptionMonthStageId)
		FROM @tblRKOptionsMonthStage
		WHERE intOptionMonthStageId > @intOptionMonthStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKOptionsMonthStage t
	JOIN @tblRKOptionsMonthStage pt ON pt.intOptionMonthStageId = t.intOptionMonthStageId
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
