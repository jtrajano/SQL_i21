CREATE PROCEDURE uspIPDailyAveragePriceProcessStgXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intDailyAveragePriceStageId INT
		,@intDailyAveragePriceId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
		,@strTransactionType NVARCHAR(MAX)
	DECLARE @strBook NVARCHAR(100)
		,@strSubBook NVARCHAR(100)
		,@strAverageNo NVARCHAR(50)
	DECLARE @intBookId INT
		,@intSubBookId INT
		,@intLastModifiedUserId INT
		,@intNewDailyAveragePriceId INT
		,@intDailyAveragePriceRefId INT
	DECLARE @strDetailXML NVARCHAR(MAX)
		,@intDailyAveragePriceDetailId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
		,@strAckHeaderXML NVARCHAR(MAX)
		,@strAckDetailXML NVARCHAR(MAX)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT

	SELECT @intDailyAveragePriceStageId = MIN(intDailyAveragePriceStageId)
	FROM tblRKDailyAveragePriceStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

	WHILE @intDailyAveragePriceStageId > 0
	BEGIN
		SELECT @intDailyAveragePriceId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strTransactionType = NULL
			,@strUserName = NULL
			,@strDetailXML = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intScreenId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @intDailyAveragePriceId = intDailyAveragePriceId
			,@strHeaderXML = strHeaderXML
			,@strDetailXML = strDetailXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strTransactionType = strTransactionType
			,@strUserName = strUserName
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblRKDailyAveragePriceStage
		WHERE intDailyAveragePriceStageId = @intDailyAveragePriceStageId

		BEGIN TRY
			SELECT @intDailyAveragePriceRefId = @intDailyAveragePriceId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strBook = NULL
				,@strSubBook = NULL
				,@strAverageNo = NULL

			SELECT @strBook = strBook
				,@strSubBook = strSubBook
				,@strAverageNo = strAverageNo
			FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePrices/vyuIPGetDailyAveragePrice', 2) WITH (
					strBook NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(100) Collate Latin1_General_CI_AS
					,strAverageNo NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			IF ISNULL(@strBook, '') = ''
			BEGIN
				SELECT @strErrorMessage = 'Book ' + @strBook + ' cannot be empty.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END
			
			IF @strBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTBook t
					WHERE t.strBook = @strBook
					)
			BEGIN
				SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strSubBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTSubBook t
					WHERE t.strSubBook = @strSubBook
					)
			BEGIN
				SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intBookId = NULL
				,@intSubBookId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intBookId = t.intBookId
			FROM tblCTBook t
			WHERE t.strBook = @strBook

			SELECT @intSubBookId = t.intSubBookId
			FROM tblCTSubBook t
			WHERE t.strSubBook = @strSubBook

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
						FROM tblRKDailyAveragePrice
						WHERE intDailyAveragePriceRefId = @intDailyAveragePriceRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewDailyAveragePriceId = intDailyAveragePriceId
					,@strAverageNo = strAverageNo
				FROM tblRKDailyAveragePrice
				WHERE intDailyAveragePriceRefId = @intDailyAveragePriceRefId

				SELECT @strHeaderCondition = 'intDailyAveragePriceId = ' + LTRIM(@intNewDailyAveragePriceId)

				EXEC uspCTGetTableDataInXML 'vyuIPGetDailyAveragePrice'
					,@strHeaderCondition
					,@strAckHeaderXML OUTPUT

				EXEC uspCTGetTableDataInXML 'vyuIPGetDailyAveragePriceDetail'
					,@strHeaderCondition
					,@strAckDetailXML OUTPUT

				DELETE
				FROM tblRKDailyAveragePrice
				WHERE intDailyAveragePriceRefId = @intDailyAveragePriceRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKDailyAveragePrice (
					intConcurrencyId
					,strAverageNo
					,dtmDate
					,intBookId
					,intSubBookId
					,ysnPosted
					,intDailyAveragePriceRefId
					)
				SELECT 1
					,strAverageNo
					,dtmDate
					,@intBookId
					,@intSubBookId
					,ysnPosted
					,@intDailyAveragePriceRefId
				FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePrices/vyuIPGetDailyAveragePrice', 2) WITH (
						strAverageNo NVARCHAR(50)
						,dtmDate DATETIME
						,ysnPosted BIT
						)

				SELECT @intNewDailyAveragePriceId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKDailyAveragePrice
				SET intConcurrencyId = intConcurrencyId + 1
					,strAverageNo = x.strAverageNo
					,dtmDate = x.dtmDate
					,intBookId = @intBookId
					,intSubBookId = @intSubBookId
					,ysnPosted = x.ysnPosted
				FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePrices/vyuIPGetDailyAveragePrice', 2) WITH (
						strAverageNo NVARCHAR(50)
						,dtmDate DATETIME
						,ysnPosted BIT
						) x
				WHERE tblRKDailyAveragePrice.intDailyAveragePriceRefId = @intDailyAveragePriceRefId

				SELECT @intNewDailyAveragePriceId = intDailyAveragePriceId
					,@strAverageNo = strAverageNo
				FROM tblRKDailyAveragePrice
				WHERE intDailyAveragePriceRefId = @intDailyAveragePriceRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Detail--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strDetailXML

			DECLARE @tblRKDailyAveragePriceDetail TABLE (intDailyAveragePriceDetailId INT)

			INSERT INTO @tblRKDailyAveragePriceDetail (intDailyAveragePriceDetailId)
			SELECT intDailyAveragePriceDetailId
			FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePriceDetails/vyuIPGetDailyAveragePriceDetail', 2) WITH (intDailyAveragePriceDetailId INT)

			SELECT @intDailyAveragePriceDetailId = MIN(intDailyAveragePriceDetailId)
			FROM @tblRKDailyAveragePriceDetail

			DECLARE @strFutMarketName NVARCHAR(30)
					,@strFutureMonth NVARCHAR(20)
					,@strCommodityCode NVARCHAR(50)
					,@strName NVARCHAR(100)
					,@intFutureMarketId INT
					,@intCommodityId INT
					,@intFutureMonthId INT
					,@intBrokerId INT

			WHILE @intDailyAveragePriceDetailId IS NOT NULL
			BEGIN
				SELECT @strFutMarketName = NULL
					,@strFutureMonth = NULL
					,@strCommodityCode = NULL
					,@strName = NULL
					,@intFutureMarketId = NULL

				SELECT @strFutMarketName = strFutMarketName
					,@strFutureMonth = strFutureMonth
					,@strCommodityCode = strCommodityCode
					,@strName = strName
				FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePriceDetails/vyuIPGetDailyAveragePriceDetail', 2) WITH (
						strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
						,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intDailyAveragePriceDetailId INT
						) SD
				WHERE intDailyAveragePriceDetailId = @intDailyAveragePriceDetailId

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

				IF @strName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblEMEntity t
						WHERE t.strName = @strName
						)
				BEGIN
					SELECT @strErrorMessage = 'Broker ' + @strName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intFutureMarketId = NULL
					,@intCommodityId = NULL
					,@intFutureMonthId = NULL
					,@intBrokerId = NULL

				SELECT @intFutureMarketId = t.intFutureMarketId
				FROM tblRKFutureMarket t
				WHERE t.strFutMarketName = @strFutMarketName

				SELECT @intCommodityId = t.intCommodityId
				FROM tblICCommodity t
				WHERE t.strCommodityCode = @strCommodityCode

				SELECT @intBrokerId = t.intEntityId
				FROM tblEMEntity t
				WHERE t.strName = @strName

				SELECT @intFutureMonthId = t.intFutureMonthId
				FROM tblRKFuturesMonth t
				WHERE t.strFutureMonth = @strFutureMonth
					AND t.intFutureMarketId = @intFutureMarketId

				IF @intFutureMonthId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblRKDailyAveragePriceDetail
						WHERE intDailyAveragePriceId = @intNewDailyAveragePriceId
							AND intDailyAveragePriceDetailRefId = @intDailyAveragePriceDetailId
						)
				BEGIN
					INSERT INTO tblRKDailyAveragePriceDetail (
						intDailyAveragePriceId
						,intFutureMarketId
						,intCommodityId
						,intFutureMonthId
						,dblNoOfLots
						,dblAverageLongPrice
						,dblSwitchPL
						,dblOptionsPL
						,dblNetLongAvg
						,dblSettlementPrice
						,intBrokerId
						,intConcurrencyId
						,intDailyAveragePriceDetailRefId
						)
					SELECT @intNewDailyAveragePriceId
						,@intFutureMarketId
						,@intCommodityId
						,@intFutureMonthId
						,dblNoOfLots
						,dblAverageLongPrice
						,dblSwitchPL
						,dblOptionsPL
						,dblNetLongAvg
						,dblSettlementPrice
						,@intBrokerId
						,1
						,@intDailyAveragePriceDetailId
					FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePriceDetails/vyuIPGetDailyAveragePriceDetail', 2) WITH (
							dblNoOfLots NUMERIC(18, 6)
							,dblAverageLongPrice NUMERIC(18, 6)
							,dblSwitchPL NUMERIC(18, 6)
							,dblOptionsPL NUMERIC(18, 6)
							,dblNetLongAvg NUMERIC(18, 6)
							,dblSettlementPrice NUMERIC(18, 6)
							,intDailyAveragePriceDetailId INT
							) x
					WHERE x.intDailyAveragePriceDetailId = @intDailyAveragePriceDetailId
				END
				ELSE
				BEGIN
					UPDATE tblRKDailyAveragePriceDetail
					SET intConcurrencyId = intConcurrencyId + 1
						,intFutureMarketId = @intFutureMarketId
						,intCommodityId = @intCommodityId
						,intFutureMonthId = @intFutureMonthId
						,dblNoOfLots = x.dblNoOfLots
						,dblAverageLongPrice = x.dblAverageLongPrice
						,dblSwitchPL = x.dblSwitchPL
						,dblOptionsPL = x.dblOptionsPL
						,dblNetLongAvg = x.dblNetLongAvg
						,dblSettlementPrice = x.dblSettlementPrice
						,intBrokerId = @intBrokerId
					FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePriceDetails/vyuIPGetDailyAveragePriceDetail', 2) WITH (
							dblNoOfLots NUMERIC(18, 6)
							,dblAverageLongPrice NUMERIC(18, 6)
							,dblSwitchPL NUMERIC(18, 6)
							,dblOptionsPL NUMERIC(18, 6)
							,dblNetLongAvg NUMERIC(18, 6)
							,dblSettlementPrice NUMERIC(18, 6)
							,intDailyAveragePriceDetailId INT
							) x
					JOIN tblRKDailyAveragePriceDetail D ON D.intDailyAveragePriceDetailRefId = x.intDailyAveragePriceDetailId
						AND D.intDailyAveragePriceId = @intNewDailyAveragePriceId
					WHERE x.intDailyAveragePriceDetailId = @intDailyAveragePriceDetailId
				END

				SELECT @intDailyAveragePriceDetailId = MIN(intDailyAveragePriceDetailId)
				FROM @tblRKDailyAveragePriceDetail
				WHERE intDailyAveragePriceDetailId > @intDailyAveragePriceDetailId
			END

			DELETE
			FROM tblRKDailyAveragePriceDetail
			WHERE intDailyAveragePriceId = @intNewDailyAveragePriceId
				AND intDailyAveragePriceDetailRefId NOT IN (
					SELECT intDailyAveragePriceDetailId
					FROM @tblRKDailyAveragePriceDetail
					)

			SELECT @strHeaderCondition = 'intDailyAveragePriceId = ' + LTRIM(@intNewDailyAveragePriceId)

			EXEC uspCTGetTableDataInXML 'vyuIPGetDailyAveragePrice'
				,@strHeaderCondition
				,@strAckHeaderXML OUTPUT

			EXEC uspCTGetTableDataInXML 'vyuIPGetDailyAveragePriceDetail'
				,@strHeaderCondition
				,@strAckDetailXML OUTPUT

			ext:

			EXEC sp_xml_removedocument @idoc

			SELECT @intCompanyRefId = intCompanyId
			FROM tblRKDailyAveragePrice
			WHERE intDailyAveragePriceId = @intNewDailyAveragePriceId

			-- Audit Log
			IF (@intNewDailyAveragePriceId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewDailyAveragePriceId
						,@screenName = 'RiskManagement.view.DailyAveragePrice'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strAverageNo
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewDailyAveragePriceId
						,@screenName = 'RiskManagement.view.DailyAveragePrice'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strAverageNo
				END
			END

			SELECT @intScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'RiskManagement.view.DailyAveragePrice'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intNewDailyAveragePriceId
				AND intScreenId = @intScreenId

			DECLARE @strSQL NVARCHAR(MAX)
				,@strServerName NVARCHAR(50)
				,@strDatabaseName NVARCHAR(50)

			SELECT @strServerName = strServerName
				,@strDatabaseName = strDatabaseName
			FROM tblIPMultiCompany WITH (NOLOCK)
			WHERE intCompanyId = @intCompanyId

			SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKDailyAveragePriceAckStage (
				intDailyAveragePriceId
				,strAckAverageNo
				,strAckHeaderXML
				,strAckDetailXML
				,strRowState
				,dtmFeedDate
				,strMessage
				,intMultiCompanyId
				,strTransactionType
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intNewDailyAveragePriceId
				,@strAverageNo
				,@strAckHeaderXML
				,@strAckDetailXML
				,@strRowState
				,GETDATE()
				,''Success''
				,@intMultiCompanyId
				,@strTransactionType
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId'

			EXEC sp_executesql @strSQL
				,N'@intNewDailyAveragePriceId INT
					,@strAverageNo NVARCHAR(50)
					,@strAckHeaderXML NVARCHAR(MAX)
					,@strAckDetailXML NVARCHAR(MAX)
					,@strRowState NVARCHAR(MAX)
					,@intMultiCompanyId INT
					,@strTransactionType NVARCHAR(MAX)
					,@intTransactionId INT
					,@intCompanyId INT
					,@intTransactionRefId INT
					,@intCompanyRefId INT'
				,@intNewDailyAveragePriceId
				,@strAverageNo
				,@strAckHeaderXML
				,@strAckDetailXML
				,@strRowState
				,@intMultiCompanyId
				,@strTransactionType
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId

			IF @strRowState <> 'Delete'
			BEGIN
				IF @intTransactionRefId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Current Transaction Id is not available. '

					RAISERROR (
								@strErrorMessage
								,16
								,1
								)
				END
				ELSE
				BEGIN
					EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
						,@referenceTransactionId = @intTransactionId
						,@referenceCompanyId = @intCompanyId
				END
			END

			UPDATE tblRKDailyAveragePriceStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intDailyAveragePriceStageId = @intDailyAveragePriceStageId

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

			UPDATE tblRKDailyAveragePriceStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intDailyAveragePriceStageId = @intDailyAveragePriceStageId
		END CATCH

		SELECT @intDailyAveragePriceStageId = MIN(intDailyAveragePriceStageId)
		FROM tblRKDailyAveragePriceStage
		WHERE intDailyAveragePriceStageId > @intDailyAveragePriceStageId
			AND ISNULL(strFeedStatus, '') = ''
			AND intMultiCompanyId = @intToCompanyId
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
