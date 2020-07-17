CREATE PROCEDURE uspIPCoverageEntryProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intCoverageEntryStageId INT
		,@intCoverageEntryId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
		,@strTransactionType NVARCHAR(MAX)
	DECLARE @strBatchName NVARCHAR(50)
		,@dtmDate DATETIME
		,@strBook NVARCHAR(100)
		,@strSubBook NVARCHAR(100)
		,@strUnitMeasure NVARCHAR(50)
		,@strCommodityCode NVARCHAR(50)
	DECLARE @intBookId INT
		,@intSubBookId INT
		,@intUOMId INT
		,@intCommodityId INT
		,@intLastModifiedUserId INT
		,@intNewCoverageEntryId INT
		,@intCoverageEntryRefId INT
	DECLARE @strDetailXML NVARCHAR(MAX)
		,@intCoverageEntryDetailId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
		,@strAckHeaderXML NVARCHAR(MAX)
		,@strAckDetailXML NVARCHAR(MAX)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT

	SELECT @intCoverageEntryStageId = MIN(intCoverageEntryStageId)
	FROM tblRKCoverageEntryStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intCoverageEntryStageId > 0
	BEGIN
		SELECT @intCoverageEntryId = NULL
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

		SELECT @intCoverageEntryId = intCoverageEntryId
			,@strHeaderXML = strHeaderXML
			,@strDetailXML = strDetailXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strTransactionType = strTransactionType
			,@strUserName = strUserName
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblRKCoverageEntryStage
		WHERE intCoverageEntryStageId = @intCoverageEntryStageId

		-- To transfer acknowledgement to BU
		SELECT @intMultiCompanyId = @intCompanyId

		BEGIN TRY
			SELECT @intCoverageEntryRefId = @intCoverageEntryId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strBatchName = NULL
				,@dtmDate = NULL
				,@strBook = NULL
				,@strSubBook = NULL
				,@strUnitMeasure = NULL
				,@strCommodityCode = NULL

			SELECT @strBatchName = strBatchName
				,@dtmDate = dtmDate
				,@strBook = strBook
				,@strSubBook = strSubBook
				,@strUnitMeasure = strUnitMeasure
				,@strCommodityCode = strCommodityCode
			FROM OPENXML(@idoc, 'vyuIPGetCoverageEntrys/vyuIPGetCoverageEntry', 2) WITH (
					strBatchName NVARCHAR(50) Collate Latin1_General_CI_AS
					,dtmDate DATETIME
					,strBook NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(100) Collate Latin1_General_CI_AS
					,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
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

			IF @strUnitMeasure IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICUnitMeasure t
					WHERE t.strUnitMeasure = @strUnitMeasure
					)
			BEGIN
				SELECT @strErrorMessage = 'UOM ' + @strUnitMeasure + ' is not available.'

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

			SELECT @intBookId = NULL
				,@intSubBookId = NULL
				,@intUOMId = NULL
				,@intCommodityId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intBookId = t.intBookId
			FROM tblCTBook t
			WHERE t.strBook = @strBook

			SELECT @intSubBookId = t.intSubBookId
			FROM tblCTSubBook t
			WHERE t.strSubBook = @strSubBook

			SELECT @intUOMId = t.intUnitMeasureId
			FROM tblICUnitMeasure t
			WHERE t.strUnitMeasure = @strUnitMeasure

			SELECT @intCommodityId = t.intCommodityId
			FROM tblICCommodity t
			WHERE t.strCommodityCode = @strCommodityCode

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
						FROM tblRKCoverageEntry
						WHERE intCoverageEntryRefId = @intCoverageEntryRefId
							AND intBookId = @intBookId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewCoverageEntryId = intCoverageEntryId
					,@strBatchName = strBatchName
					,@dtmDate = dtmDate
				FROM tblRKCoverageEntry
				WHERE intCoverageEntryRefId = @intCoverageEntryRefId
					AND intBookId = @intBookId

				SELECT @strHeaderCondition = 'intCoverageEntryId = ' + LTRIM(@intNewCoverageEntryId)

				EXEC uspCTGetTableDataInXML 'vyuIPGetCoverageEntry'
					,@strHeaderCondition
					,@strAckHeaderXML OUTPUT

				EXEC uspCTGetTableDataInXML 'vyuIPGetCoverageEntryDetail'
					,@strHeaderCondition
					,@strAckDetailXML OUTPUT

				DELETE
				FROM tblRKCoverageEntry
				WHERE intCoverageEntryRefId = @intCoverageEntryRefId
					AND intBookId = @intBookId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKCoverageEntry (
					intConcurrencyId
					,strBatchName
					,dtmDate
					,intUOMId
					,intBookId
					,intSubBookId
					,intCommodityId
					,strUOMType
					,intDecimal
					,ysnPosted
					,intCoverageEntryRefId
					)
				SELECT 1
					,strBatchName
					,dtmDate
					,@intUOMId
					,@intBookId
					,@intSubBookId
					,@intCommodityId
					,strUOMType
					,intDecimal
					,ysnPosted
					,@intCoverageEntryRefId
				FROM OPENXML(@idoc, 'vyuIPGetCoverageEntrys/vyuIPGetCoverageEntry', 2) WITH (
						strBatchName NVARCHAR(50)
						,dtmDate DATETIME
						,strUOMType NVARCHAR(50)
						,intDecimal INT
						,ysnPosted BIT
						)

				SELECT @intNewCoverageEntryId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKCoverageEntry
				SET intConcurrencyId = intConcurrencyId + 1
					,strBatchName = x.strBatchName
					,dtmDate = x.dtmDate
					,intUOMId = @intUOMId
					,intBookId = @intBookId
					,intSubBookId = @intSubBookId
					,intCommodityId = @intCommodityId
					,strUOMType = x.strUOMType
					,intDecimal = x.intDecimal
					,ysnPosted = x.ysnPosted
				FROM OPENXML(@idoc, 'vyuIPGetCoverageEntrys/vyuIPGetCoverageEntry', 2) WITH (
						strBatchName NVARCHAR(50)
						,dtmDate DATETIME
						,strUOMType NVARCHAR(50)
						,intDecimal INT
						,ysnPosted BIT
						) x
				WHERE tblRKCoverageEntry.intCoverageEntryRefId = @intCoverageEntryRefId
					AND tblRKCoverageEntry.intBookId = @intBookId

				SELECT @intNewCoverageEntryId = intCoverageEntryId
					,@strBatchName = strBatchName
					,@dtmDate = dtmDate
				FROM tblRKCoverageEntry
				WHERE intCoverageEntryRefId = @intCoverageEntryRefId
					AND intBookId = @intBookId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Detail--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strDetailXML

			DECLARE @tblRKCoverageEntryDetail TABLE (intCoverageEntryDetailId INT)

			INSERT INTO @tblRKCoverageEntryDetail (intCoverageEntryDetailId)
			SELECT intCoverageEntryDetailId
			FROM OPENXML(@idoc, 'vyuIPGetCoverageEntryDetails/vyuIPGetCoverageEntryDetail', 2) WITH (intCoverageEntryDetailId INT)

			SELECT @intCoverageEntryDetailId = MIN(intCoverageEntryDetailId)
			FROM @tblRKCoverageEntryDetail

			DECLARE @strBook1 NVARCHAR(100)
				,@strSubBook1 NVARCHAR(100)
				,@strProductType NVARCHAR(50)
				,@intBookId1 INT
				,@intSubBookId1 INT
				,@intProductTypeId INT

			WHILE @intCoverageEntryDetailId IS NOT NULL
			BEGIN
				SELECT @strBook1 = NULL
					,@strSubBook1 = NULL
					,@strProductType = NULL

				SELECT @strBook1 = strBook
					,@strSubBook1 = strSubBook
					,@strProductType = strProductType
				FROM OPENXML(@idoc, 'vyuIPGetCoverageEntryDetails/vyuIPGetCoverageEntryDetail', 2) WITH (
						strBook NVARCHAR(100) Collate Latin1_General_CI_AS
						,strSubBook NVARCHAR(100) Collate Latin1_General_CI_AS
						,strProductType NVARCHAR(50) Collate Latin1_General_CI_AS
						,intCoverageEntryDetailId INT
						) SD
				WHERE intCoverageEntryDetailId = @intCoverageEntryDetailId

				IF @strBook1 IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTBook t
						WHERE t.strBook = @strBook1
						)
				BEGIN
					SELECT @strErrorMessage = 'Book detail ' + @strBook1 + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strSubBook1 IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTSubBook t
						WHERE t.strSubBook = @strSubBook1
						)
				BEGIN
					SELECT @strErrorMessage = 'Sub Book detail ' + @strSubBook1 + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strProductType IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICCommodityAttribute t
						WHERE t.strDescription = @strProductType
						)
				BEGIN
					SELECT @strErrorMessage = 'Product Type ' + @strProductType + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intBookId1 = NULL
					,@intSubBookId1 = NULL
					,@intProductTypeId = NULL

				SELECT @intBookId1 = t.intBookId
				FROM tblCTBook t
				WHERE t.strBook = @strBook1

				SELECT @intSubBookId1 = t.intSubBookId
				FROM tblCTSubBook t
				WHERE t.strSubBook = @strSubBook1

				SELECT @intProductTypeId = t.intCommodityAttributeId
				FROM tblICCommodityAttribute t
				WHERE t.strDescription = @strProductType

				IF NOT EXISTS (
						SELECT 1
						FROM tblRKCoverageEntryDetail
						WHERE intCoverageEntryId = @intNewCoverageEntryId
							AND intCoverageEntryDetailRefId = @intCoverageEntryDetailId
						)
				BEGIN
					INSERT INTO tblRKCoverageEntryDetail (
						intCoverageEntryId
						,intProductTypeId
						,intBookId
						,intSubBookId
						,dblOpenContract
						,dblInTransit
						,dblStock
						,dblOpenFutures
						,dblMonthsCovered
						,dblAveragePrice
						,dblOptionsCovered
						,dblTotalOption
						,dblFuturesM2M
						,dblM2MPlus10
						,dblM2MMinus10
						,intCoverageEntryDetailRefId
						,intConcurrencyId
						)
					SELECT @intNewCoverageEntryId
						,@intProductTypeId
						,@intBookId1
						,@intSubBookId1
						,dblOpenContract
						,dblInTransit
						,dblStock
						,dblOpenFutures
						,dblMonthsCovered
						,dblAveragePrice
						,dblOptionsCovered
						,dblTotalOption
						,dblFuturesM2M
						,dblM2MPlus10
						,dblM2MMinus10
						,@intCoverageEntryDetailId
						,1
					FROM OPENXML(@idoc, 'vyuIPGetCoverageEntryDetails/vyuIPGetCoverageEntryDetail', 2) WITH (
							dblOpenContract NUMERIC(18, 6)
							,dblInTransit NUMERIC(18, 6)
							,dblStock NUMERIC(18, 6)
							,dblOpenFutures NUMERIC(18, 6)
							,dblMonthsCovered NUMERIC(18, 6)
							,dblAveragePrice NUMERIC(18, 6)
							,dblOptionsCovered NUMERIC(18, 6)
							,dblTotalOption NUMERIC(18, 6)
							,dblFuturesM2M NUMERIC(18, 6)
							,dblM2MPlus10 NUMERIC(18, 6)
							,dblM2MMinus10 NUMERIC(18, 6)
							,intCoverageEntryDetailId INT
							) x
					WHERE x.intCoverageEntryDetailId = @intCoverageEntryDetailId
				END
				ELSE
				BEGIN
					UPDATE tblRKCoverageEntryDetail
					SET intConcurrencyId = intConcurrencyId + 1
						,intProductTypeId = @intProductTypeId
						,intBookId = @intBookId1
						,intSubBookId = @intSubBookId1
						,dblOpenContract = x.dblOpenContract
						,dblInTransit = x.dblInTransit
						,dblStock = x.dblStock
						,dblOpenFutures = x.dblOpenFutures
						,dblMonthsCovered = x.dblMonthsCovered
						,dblAveragePrice = x.dblAveragePrice
						,dblOptionsCovered = x.dblOptionsCovered
						,dblTotalOption = x.dblTotalOption
						,dblFuturesM2M = x.dblFuturesM2M
						,dblM2MPlus10 = x.dblM2MPlus10
						,dblM2MMinus10 = x.dblM2MMinus10
					FROM OPENXML(@idoc, 'vyuIPGetCoverageEntryDetails/vyuIPGetCoverageEntryDetail', 2) WITH (
							dblOpenContract NUMERIC(18, 6)
							,dblInTransit NUMERIC(18, 6)
							,dblStock NUMERIC(18, 6)
							,dblOpenFutures NUMERIC(18, 6)
							,dblMonthsCovered NUMERIC(18, 6)
							,dblAveragePrice NUMERIC(18, 6)
							,dblOptionsCovered NUMERIC(18, 6)
							,dblTotalOption NUMERIC(18, 6)
							,dblFuturesM2M NUMERIC(18, 6)
							,dblM2MPlus10 NUMERIC(18, 6)
							,dblM2MMinus10 NUMERIC(18, 6)
							,intCoverageEntryDetailId INT
							) x
					JOIN tblRKCoverageEntryDetail D ON D.intCoverageEntryDetailRefId = x.intCoverageEntryDetailId
						AND D.intCoverageEntryId = @intNewCoverageEntryId
					WHERE x.intCoverageEntryDetailId = @intCoverageEntryDetailId
				END

				SELECT @intCoverageEntryDetailId = MIN(intCoverageEntryDetailId)
				FROM @tblRKCoverageEntryDetail
				WHERE intCoverageEntryDetailId > @intCoverageEntryDetailId
			END

			DELETE
			FROM tblRKCoverageEntryDetail
			WHERE intCoverageEntryId = @intNewCoverageEntryId
				AND intCoverageEntryDetailRefId NOT IN (
					SELECT intCoverageEntryDetailId
					FROM @tblRKCoverageEntryDetail
					)

			SELECT @strHeaderCondition = 'intCoverageEntryId = ' + LTRIM(@intNewCoverageEntryId)

			EXEC uspCTGetTableDataInXML 'vyuIPGetCoverageEntry'
				,@strHeaderCondition
				,@strAckHeaderXML OUTPUT

			EXEC uspCTGetTableDataInXML 'vyuIPGetCoverageEntryDetail'
				,@strHeaderCondition
				,@strAckDetailXML OUTPUT

			ext:

			EXEC sp_xml_removedocument @idoc

			--SELECT @intCompanyRefId = intCompanyId
			--FROM tblRKCoverageEntry
			--WHERE intCoverageEntryId = @intNewCoverageEntryId
			--	AND intBookId = @intBookId
			-- Audit Log
			IF (@intNewCoverageEntryId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewCoverageEntryId
						,@screenName = 'RiskManagement.view.CoverageReport'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strBatchName
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewCoverageEntryId
						,@screenName = 'RiskManagement.view.CoverageReport'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strBatchName
				END
			END

			SELECT @intScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'RiskManagement.view.CoverageReport'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intNewCoverageEntryId
				AND intScreenId = @intScreenId

			DECLARE @strSQL NVARCHAR(MAX)
				,@strServerName NVARCHAR(50)
				,@strDatabaseName NVARCHAR(50)

			SELECT @strServerName = strServerName
				,@strDatabaseName = strDatabaseName
			FROM tblIPMultiCompany WITH (NOLOCK)
			WHERE intCompanyId = @intCompanyId

			SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblRKCoverageEntryAckStage (
				intCoverageEntryId
				,strAckBatchName
				,dtmAckDate
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
			SELECT @intNewCoverageEntryId
				,@strBatchName
				,@dtmDate
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
				,N'@intNewCoverageEntryId INT
					,@strBatchName NVARCHAR(50)
					,@dtmDate DATETIME
					,@strAckHeaderXML NVARCHAR(MAX)
					,@strAckDetailXML NVARCHAR(MAX)
					,@strRowState NVARCHAR(MAX)
					,@intMultiCompanyId INT
					,@strTransactionType NVARCHAR(MAX)
					,@intTransactionId INT
					,@intCompanyId INT
					,@intTransactionRefId INT
					,@intCompanyRefId INT'
				,@intNewCoverageEntryId
				,@strBatchName
				,@dtmDate
				,@strAckHeaderXML
				,@strAckDetailXML
				,@strRowState
				,@intMultiCompanyId
				,@strTransactionType
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId
			
			--IF @strRowState <> 'Delete'
			--BEGIN
			--	IF @intTransactionRefId IS NULL
			--	BEGIN
			--		SELECT @strErrorMessage = 'Current Transaction Id is not available. '

			--		RAISERROR (
			--					@strErrorMessage
			--					,16
			--					,1
			--					)
			--	END
			--	ELSE
			--	BEGIN
			--		EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
			--			,@referenceTransactionId = @intTransactionId
			--			,@referenceCompanyId = @intCompanyId
			--	END
			--END

			UPDATE tblRKCoverageEntryStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intCoverageEntryStageId = @intCoverageEntryStageId

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

			UPDATE tblRKCoverageEntryStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intCoverageEntryStageId = @intCoverageEntryStageId
		END CATCH

		SELECT @intCoverageEntryStageId = MIN(intCoverageEntryStageId)
		FROM tblRKCoverageEntryStage
		WHERE intCoverageEntryStageId > @intCoverageEntryStageId
			AND ISNULL(strFeedStatus, '') = ''
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
