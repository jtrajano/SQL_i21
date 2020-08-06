CREATE PROCEDURE uspIPSettlementPriceProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intFutureSettlementPriceStageId INT
		,@intFutureSettlementPriceId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strFutMarketName NVARCHAR(30)
		,@strCommodityCode NVARCHAR(50)
		,@intFutureMarketId INT
		,@intCommodityMarketId INT
		,@intCommodityId INT
	DECLARE @intLastModifiedUserId INT
		,@intNewFutureSettlementPriceId INT
		,@intFutureSettlementPriceRefId INT
		,@dtmPriceDate DATETIME
	DECLARE @strFutSettlementPriceXML NVARCHAR(MAX)
		,@intFutSettlementPriceMonthId INT
	DECLARE @strFutureMonth NVARCHAR(20)
		,@intFutureMonthId INT
	DECLARE @strOptSettlementPriceXML NVARCHAR(MAX)
		,@intOptSettlementPriceMonthId INT
	DECLARE @strOptionMonth NVARCHAR(20)
		,@intOptionMonthId INT
	DECLARE @tblRKFuturesSettlementPriceStage TABLE (intFutureSettlementPriceStageId INT)

	INSERT INTO @tblRKFuturesSettlementPriceStage (intFutureSettlementPriceStageId)
	SELECT intFutureSettlementPriceStageId
	FROM tblRKFuturesSettlementPriceStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutureSettlementPriceStageId = MIN(intFutureSettlementPriceStageId)
	FROM @tblRKFuturesSettlementPriceStage

	IF @intFutureSettlementPriceStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKFuturesSettlementPriceStage t
	JOIN @tblRKFuturesSettlementPriceStage pt ON pt.intFutureSettlementPriceStageId = t.intFutureSettlementPriceStageId

	WHILE @intFutureSettlementPriceStageId > 0
	BEGIN
		SELECT @intFutureSettlementPriceId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strFutSettlementPriceXML = NULL
			,@strOptSettlementPriceXML = NULL

		SELECT @intFutureSettlementPriceId = intFutureSettlementPriceId
			,@strHeaderXML = strHeaderXML
			,@strFutSettlementPriceXML = strFutSettlementPriceXML
			,@strOptSettlementPriceXML = strOptSettlementPriceXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblRKFuturesSettlementPriceStage
		WHERE intFutureSettlementPriceStageId = @intFutureSettlementPriceStageId

		BEGIN TRY
			SELECT @intFutureSettlementPriceRefId = @intFutureSettlementPriceId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @dtmPriceDate = NULL
				,@strFutMarketName = NULL
				,@strCommodityCode = NULL
				,@intFutureMarketId = NULL
				,@intCommodityMarketId = NULL
				,@intCommodityId = NULL

			SELECT @dtmPriceDate = dtmPriceDate
				,@strFutMarketName = strFutMarketName
				,@strCommodityCode = strCommodityCode
			FROM OPENXML(@idoc, 'vyuIPGetFuturesSettlementPrices/vyuIPGetFuturesSettlementPrice', 2) WITH (
					dtmPriceDate DATETIME
					,strFutMarketName NVARCHAR(30)
					,strCommodityCode NVARCHAR(50)
					) x

			IF @strFutMarketName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblRKFutureMarket t
					WHERE t.strFutMarketName = @strFutMarketName
					)
			BEGIN
				SELECT @strErrorMessage = 'Futures Market ' + @strFutMarketName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

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

			SELECT @intCommodityId = t.intCommodityId
			FROM tblICCommodity t
			WHERE t.strCommodityCode = @strCommodityCode

			SELECT @intFutureMarketId = t.intFutureMarketId
			FROM tblRKFutureMarket t
			WHERE t.strFutMarketName = @strFutMarketName

			SELECT @intCommodityMarketId = t.intCommodityMarketId
			FROM tblRKCommodityMarketMapping t
			WHERE t.intFutureMarketId = @intFutureMarketId
				AND t.intCommodityId = @intCommodityId

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
						FROM tblRKFuturesSettlementPrice
						WHERE intFutureSettlementPriceRefId = @intFutureSettlementPriceRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewFutureSettlementPriceId = @intFutureSettlementPriceRefId
					,@dtmPriceDate = @dtmPriceDate
					,@strFutMarketName = @strFutMarketName

				DELETE
				FROM tblRKFuturesSettlementPrice
				WHERE intFutureSettlementPriceRefId = @intFutureSettlementPriceRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKFuturesSettlementPrice (
					intFutureMarketId
					,intCommodityMarketId
					,dtmPriceDate
					,strPricingType
					,intConcurrencyId
					,intFutureSettlementPriceRefId
					)
				SELECT @intFutureMarketId
					,@intCommodityMarketId
					,@dtmPriceDate
					,strPricingType
					,1
					,@intFutureSettlementPriceRefId
				FROM OPENXML(@idoc, 'vyuIPGetFuturesSettlementPrices/vyuIPGetFuturesSettlementPrice', 2) WITH (strPricingType NVARCHAR(30))

				SELECT @intNewFutureSettlementPriceId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKFuturesSettlementPrice
				SET intConcurrencyId = intConcurrencyId + 1
					,intFutureMarketId = @intFutureMarketId
					,intCommodityMarketId = @intCommodityMarketId
					,dtmPriceDate = @dtmPriceDate
					,strPricingType = x.strPricingType
				FROM OPENXML(@idoc, 'vyuIPGetFuturesSettlementPrices/vyuIPGetFuturesSettlementPrice', 2) WITH (strPricingType NVARCHAR(30)) x
				WHERE tblRKFuturesSettlementPrice.intFutureSettlementPriceRefId = @intFutureSettlementPriceRefId

				SELECT @intNewFutureSettlementPriceId = intFutureSettlementPriceId
					,@dtmPriceDate = dtmPriceDate
				FROM tblRKFuturesSettlementPrice
				WHERE intFutureSettlementPriceRefId = @intFutureSettlementPriceRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Future Settlement Price--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strFutSettlementPriceXML

			DECLARE @tblRKFuturesSettlementPriceDetail TABLE (intFutSettlementPriceMonthId INT)

			INSERT INTO @tblRKFuturesSettlementPriceDetail (intFutSettlementPriceMonthId)
			SELECT intFutSettlementPriceMonthId
			FROM OPENXML(@idoc, 'vyuIPGetFutSettlementPriceMarketMaps/vyuIPGetFutSettlementPriceMarketMap', 2) WITH (intFutSettlementPriceMonthId INT)

			SELECT @intFutSettlementPriceMonthId = MIN(intFutSettlementPriceMonthId)
			FROM @tblRKFuturesSettlementPriceDetail

			WHILE @intFutSettlementPriceMonthId IS NOT NULL
			BEGIN
				SELECT @strFutureMonth = NULL

				SELECT @strFutureMonth = strFutureMonth
				FROM OPENXML(@idoc, 'vyuIPGetFutSettlementPriceMarketMaps/vyuIPGetFutSettlementPriceMarketMap', 2) WITH (
						strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,intFutSettlementPriceMonthId INT
						) SD
				WHERE intFutSettlementPriceMonthId = @intFutSettlementPriceMonthId

				IF @strFutureMonth IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFuturesMonth t
						WHERE t.strFutureMonth = @strFutureMonth
						)
				BEGIN
					SELECT @strErrorMessage = 'Futures Month ' + @strFutureMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intFutureMonthId = NULL

				SELECT @intFutureMonthId = t.intFutureMonthId
				FROM tblRKFuturesMonth t
				WHERE t.strFutureMonth = @strFutureMonth
					AND t.intFutureMarketId = @intFutureMarketId

				IF NOT EXISTS (
						SELECT 1
						FROM tblRKFutSettlementPriceMarketMap
						WHERE intFutureSettlementPriceId = @intNewFutureSettlementPriceId
							AND intFutSettlementPriceMonthRefId = @intFutSettlementPriceMonthId
						)
				BEGIN
					INSERT INTO tblRKFutSettlementPriceMarketMap (
						intConcurrencyId
						,intFutureSettlementPriceId
						,intFutureMonthId
						,dblLastSettle
						,dblLow
						,dblHigh
						,dblOpen
						,strComments
						,ysnImported
						,intFutSettlementPriceMonthRefId
						)
					SELECT 1
						,@intNewFutureSettlementPriceId
						,@intFutureMonthId
						,dblLastSettle
						,dblLow
						,dblHigh
						,dblOpen
						,strComments
						,ysnImported
						,@intFutSettlementPriceMonthId
					FROM OPENXML(@idoc, 'vyuIPGetFutSettlementPriceMarketMaps/vyuIPGetFutSettlementPriceMarketMap', 2) WITH (
							dblLastSettle NUMERIC(18, 6)
							,dblLow NUMERIC(18, 6)
							,dblHigh NUMERIC(18, 6)
							,dblOpen NUMERIC(18, 6)
							,strComments NVARCHAR(MAX)
							,ysnImported BIT
							,intFutSettlementPriceMonthId INT
							) x
					WHERE x.intFutSettlementPriceMonthId = @intFutSettlementPriceMonthId
				END
				ELSE
				BEGIN
					UPDATE tblRKFutSettlementPriceMarketMap
					SET intConcurrencyId = intConcurrencyId + 1
						,intFutureMonthId = @intFutureMonthId
						,dblLastSettle = x.dblLastSettle
						,dblLow = x.dblLow
						,dblHigh = x.dblHigh
						,dblOpen = x.dblOpen
						,strComments = x.strComments
						,ysnImported = x.ysnImported
					FROM OPENXML(@idoc, 'vyuIPGetFutSettlementPriceMarketMaps/vyuIPGetFutSettlementPriceMarketMap', 2) WITH (
							dblLastSettle NUMERIC(18, 6)
							,dblLow NUMERIC(18, 6)
							,dblHigh NUMERIC(18, 6)
							,dblOpen NUMERIC(18, 6)
							,strComments NVARCHAR(MAX)
							,ysnImported BIT
							,intFutSettlementPriceMonthId INT
							) x
					JOIN tblRKFutSettlementPriceMarketMap D ON D.intFutSettlementPriceMonthRefId = x.intFutSettlementPriceMonthId
						AND D.intFutureSettlementPriceId = @intNewFutureSettlementPriceId
					WHERE x.intFutSettlementPriceMonthId = @intFutSettlementPriceMonthId
				END

				SELECT @intFutSettlementPriceMonthId = MIN(intFutSettlementPriceMonthId)
				FROM @tblRKFuturesSettlementPriceDetail
				WHERE intFutSettlementPriceMonthId > @intFutSettlementPriceMonthId
			END

			DELETE
			FROM tblRKFutSettlementPriceMarketMap
			WHERE intFutureSettlementPriceId = @intNewFutureSettlementPriceId
				AND intFutSettlementPriceMonthRefId NOT IN (
					SELECT intFutSettlementPriceMonthId
					FROM @tblRKFuturesSettlementPriceDetail
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Option Settlement Price--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strOptSettlementPriceXML

			DECLARE @tblRKOptionsSettlementPriceDetail TABLE (intOptSettlementPriceMonthId INT)

			INSERT INTO @tblRKOptionsSettlementPriceDetail (intOptSettlementPriceMonthId)
			SELECT intOptSettlementPriceMonthId
			FROM OPENXML(@idoc, 'vyuIPGetOptSettlementPriceMarketMaps/vyuIPGetOptSettlementPriceMarketMap', 2) WITH (intOptSettlementPriceMonthId INT)

			SELECT @intOptSettlementPriceMonthId = MIN(intOptSettlementPriceMonthId)
			FROM @tblRKOptionsSettlementPriceDetail

			WHILE @intOptSettlementPriceMonthId IS NOT NULL
			BEGIN
				SELECT @strOptionMonth = NULL

				SELECT @strOptionMonth = strOptionMonth
				FROM OPENXML(@idoc, 'vyuIPGetOptSettlementPriceMarketMaps/vyuIPGetOptSettlementPriceMarketMap', 2) WITH (
						strOptionMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,intOptSettlementPriceMonthId INT
						) SD
				WHERE intOptSettlementPriceMonthId = @intOptSettlementPriceMonthId

				IF @strOptionMonth IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKOptionsMonth t
						WHERE t.strOptionMonth = @strOptionMonth
						)
				BEGIN
					SELECT @strErrorMessage = 'Options Month ' + @strOptionMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intOptionMonthId = NULL

				SELECT @intOptionMonthId = t.intOptionMonthId
				FROM tblRKOptionsMonth t
				WHERE t.strOptionMonth = @strOptionMonth
					AND t.intFutureMarketId = @intFutureMarketId

				IF NOT EXISTS (
						SELECT 1
						FROM tblRKOptSettlementPriceMarketMap
						WHERE intOptSettlementPriceMonthRefId = @intOptSettlementPriceMonthId
						)
				BEGIN
					INSERT INTO tblRKOptSettlementPriceMarketMap (
						intConcurrencyId
						,intFutureSettlementPriceId
						,intOptionMonthId
						,dblStrike
						,intTypeId
						,dblSettle
						,dblDelta
						,strComments
						,ysnImported
						,intOptSettlementPriceMonthRefId
						)
					SELECT 1
						,@intNewFutureSettlementPriceId
						,@intOptionMonthId
						,dblStrike
						,intTypeId
						,dblSettle
						,dblDelta
						,strComments
						,ysnImported
						,@intOptSettlementPriceMonthId
					FROM OPENXML(@idoc, 'vyuIPGetOptSettlementPriceMarketMaps/vyuIPGetOptSettlementPriceMarketMap', 2) WITH (
							dblStrike NUMERIC(18, 6)
							,intTypeId INT
							,dblSettle NUMERIC(18, 6)
							,dblDelta NUMERIC(18, 6)
							,strComments NVARCHAR(MAX)
							,ysnImported BIT
							,intOptSettlementPriceMonthId INT
							) x
					WHERE x.intOptSettlementPriceMonthId = @intOptSettlementPriceMonthId
				END
				ELSE
				BEGIN
					UPDATE tblRKOptSettlementPriceMarketMap
					SET intConcurrencyId = intConcurrencyId + 1
						,intOptionMonthId = @intOptionMonthId
						,dblStrike = x.dblStrike
						,intTypeId = x.intTypeId
						,dblSettle = x.dblSettle
						,dblDelta = x.dblDelta
						,strComments = x.strComments
						,ysnImported = x.ysnImported
					FROM OPENXML(@idoc, 'vyuIPGetOptSettlementPriceMarketMaps/vyuIPGetOptSettlementPriceMarketMap', 2) WITH (
							dblStrike NUMERIC(18, 6)
							,intTypeId INT
							,dblSettle NUMERIC(18, 6)
							,dblDelta NUMERIC(18, 6)
							,strComments NVARCHAR(MAX)
							,ysnImported BIT
							,intOptSettlementPriceMonthId INT
							) x
					JOIN tblRKOptSettlementPriceMarketMap D ON D.intOptSettlementPriceMonthRefId = x.intOptSettlementPriceMonthId
						AND D.intFutureSettlementPriceId = @intNewFutureSettlementPriceId
					WHERE x.intOptSettlementPriceMonthId = @intOptSettlementPriceMonthId
				END

				SELECT @intOptSettlementPriceMonthId = MIN(intOptSettlementPriceMonthId)
				FROM @tblRKOptionsSettlementPriceDetail
				WHERE intOptSettlementPriceMonthId > @intOptSettlementPriceMonthId
			END

			DELETE
			FROM tblRKOptSettlementPriceMarketMap
			WHERE intFutureSettlementPriceId = @intNewFutureSettlementPriceId
				AND intOptSettlementPriceMonthRefId NOT IN (
					SELECT intOptSettlementPriceMonthId
					FROM @tblRKOptionsSettlementPriceDetail
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblRKFuturesSettlementPriceStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intFutureSettlementPriceStageId = @intFutureSettlementPriceStageId

			-- Audit Log
			IF (@intNewFutureSettlementPriceId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)
					,@strToValue NVARCHAR(255)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '
						,@strToValue = @strFutMarketName + ' - ' + CONVERT(NVARCHAR, @dtmPriceDate)

					EXEC uspSMAuditLog @keyValue = @intNewFutureSettlementPriceId
						,@screenName = 'RiskManagement.view.FuturesOptionsSettlementPrices'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strToValue
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '
						,@strToValue = @strFutMarketName + ' - ' + CONVERT(NVARCHAR, @dtmPriceDate)

					EXEC uspSMAuditLog @keyValue = @intNewFutureSettlementPriceId
						,@screenName = 'RiskManagement.view.FuturesOptionsSettlementPrices'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strToValue
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

			UPDATE tblRKFuturesSettlementPriceStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intFutureSettlementPriceStageId = @intFutureSettlementPriceStageId
		END CATCH

		SELECT @intFutureSettlementPriceStageId = MIN(intFutureSettlementPriceStageId)
		FROM @tblRKFuturesSettlementPriceStage
		WHERE intFutureSettlementPriceStageId > @intFutureSettlementPriceStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKFuturesSettlementPriceStage t
	JOIN @tblRKFuturesSettlementPriceStage pt ON pt.intFutureSettlementPriceStageId = t.intFutureSettlementPriceStageId
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
