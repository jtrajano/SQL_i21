CREATE PROCEDURE uspIPFutureMonthProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intFutureMonthStageId INT
		,@intFutureMonthId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strFutMarketName NVARCHAR(30)
		,@strCommodityCode NVARCHAR(50)
		,@strFutureMonth NVARCHAR(20)
	DECLARE @intFutureMarketId INT
		,@intCommodityMarketId INT
		,@intLastModifiedUserId INT
		,@intNewFutureMonthId INT
		,@intFutureMonthRefId INT
	DECLARE @tblRKFuturesMonthStage TABLE (intFutureMonthStageId INT)

	INSERT INTO @tblRKFuturesMonthStage (intFutureMonthStageId)
	SELECT intFutureMonthStageId
	FROM tblRKFuturesMonthStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutureMonthStageId = MIN(intFutureMonthStageId)
	FROM @tblRKFuturesMonthStage

	IF @intFutureMonthStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKFuturesMonthStage t
	JOIN @tblRKFuturesMonthStage pt ON pt.intFutureMonthStageId = t.intFutureMonthStageId

	WHILE @intFutureMonthStageId > 0
	BEGIN
		SELECT @intFutureMonthId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL

		SELECT @intFutureMonthId = intFutureMonthId
			,@strHeaderXML = strHeaderXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblRKFuturesMonthStage
		WHERE intFutureMonthStageId = @intFutureMonthStageId

		BEGIN TRY
			SELECT @intFutureMonthRefId = @intFutureMonthId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strFutMarketName = NULL
				,@strCommodityCode = NULL
				,@strFutureMonth = NULL
				,@intFutureMarketId = NULL

			SELECT @strFutMarketName = strFutMarketName
				,@strCommodityCode = strCommodityCode
				,@strFutureMonth = strFutureMonth
			FROM OPENXML(@idoc, 'vyuIPGetFutureMonths/vyuIPGetFutureMonth', 2) WITH (
					strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
					,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
					,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
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

			SELECT @intFutureMarketId = NULL
				,@intCommodityMarketId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intFutureMarketId = t.intFutureMarketId
			FROM tblRKFutureMarket t
			WHERE t.strFutMarketName = @strFutMarketName

			SELECT @intCommodityMarketId = CMM.intCommodityMarketId
			FROM tblICCommodity C
			JOIN tblRKCommodityMarketMapping CMM ON CMM.intCommodityId = C.intCommodityId
				AND CMM.intFutureMarketId = @intFutureMarketId
			WHERE C.strCommodityCode = @strCommodityCode

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
						FROM tblRKFuturesMonth
						WHERE intFutureMonthRefId = @intFutureMonthRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewFutureMonthId = @intFutureMonthRefId
					,@strFutureMonth = ''

				DELETE
				FROM tblRKFuturesMonth
				WHERE intFutureMonthRefId = @intFutureMonthRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKFuturesMonth (
					intConcurrencyId
					,strFutureMonth
					,intFutureMarketId
					,intCommodityMarketId
					,dtmFutureMonthsDate
					,strSymbol
					,intYear
					,dtmFirstNoticeDate
					,dtmLastNoticeDate
					,dtmLastTradingDate
					,dtmSpotDate
					,ysnExpired
					,intFutureMonthRefId
					)
				SELECT 1
					,strFutureMonth
					,@intFutureMarketId
					,@intCommodityMarketId
					,dtmFutureMonthsDate
					,strSymbol
					,intYear
					,dtmFirstNoticeDate
					,dtmLastNoticeDate
					,dtmLastTradingDate
					,dtmSpotDate
					,ysnExpired
					,@intFutureMonthRefId
				FROM OPENXML(@idoc, 'vyuIPGetFutureMonths/vyuIPGetFutureMonth', 2) WITH (
						strFutureMonth NVARCHAR(20)
						,dtmFutureMonthsDate DATETIME
						,strSymbol NVARCHAR(4)
						,intYear INT
						,dtmFirstNoticeDate DATETIME
						,dtmLastNoticeDate DATETIME
						,dtmLastTradingDate DATETIME
						,dtmSpotDate DATETIME
						,ysnExpired BIT
						)

				SELECT @intNewFutureMonthId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKFuturesMonth
				SET intConcurrencyId = intConcurrencyId + 1
					,strFutureMonth = x.strFutureMonth
					,intFutureMarketId = @intFutureMarketId
					,intCommodityMarketId = @intCommodityMarketId
					,dtmFutureMonthsDate = x.dtmFutureMonthsDate
					,strSymbol = x.strSymbol
					,intYear = x.intYear
					,dtmFirstNoticeDate = x.dtmFirstNoticeDate
					,dtmLastNoticeDate = x.dtmLastNoticeDate
					,dtmLastTradingDate = x.dtmLastTradingDate
					,dtmSpotDate = x.dtmSpotDate
					,ysnExpired = x.ysnExpired
				FROM OPENXML(@idoc, 'vyuIPGetFutureMonths/vyuIPGetFutureMonth', 2) WITH (
						strFutureMonth NVARCHAR(20)
						,dtmFutureMonthsDate DATETIME
						,strSymbol NVARCHAR(4)
						,intYear INT
						,dtmFirstNoticeDate DATETIME
						,dtmLastNoticeDate DATETIME
						,dtmLastTradingDate DATETIME
						,dtmSpotDate DATETIME
						,ysnExpired BIT
						) x
				WHERE tblRKFuturesMonth.intFutureMonthRefId = @intFutureMonthRefId

				SELECT @intNewFutureMonthId = intFutureMonthId
					,@strFutureMonth = strFutureMonth
				FROM tblRKFuturesMonth
				WHERE intFutureMonthRefId = @intFutureMonthRefId
			END

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblRKFuturesMonthStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intFutureMonthStageId = @intFutureMonthStageId

			-- Audit Log
			IF (@intNewFutureMonthId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewFutureMonthId
						,@screenName = 'RiskManagement.view.FuturesTradingMonths'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strFutureMonth
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewFutureMonthId
						,@screenName = 'RiskManagement.view.FuturesTradingMonths'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strFutureMonth
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

			UPDATE tblRKFuturesMonthStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intFutureMonthStageId = @intFutureMonthStageId
		END CATCH

		SELECT @intFutureMonthStageId = MIN(intFutureMonthStageId)
		FROM @tblRKFuturesMonthStage
		WHERE intFutureMonthStageId > @intFutureMonthStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKFuturesMonthStage t
	JOIN @tblRKFuturesMonthStage pt ON pt.intFutureMonthStageId = t.intFutureMonthStageId
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
