CREATE PROCEDURE uspIPM2MBasisProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intM2MBasisStageId INT
		,@intM2MBasisId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strCommodityCode NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strFutMarketName NVARCHAR(30)
		,@strFutureMonth NVARCHAR(20)
		,@strLocationName NVARCHAR(50)
		,@strMarketZoneCode NVARCHAR(20)
		,@strCurrency NVARCHAR(40)
		,@strPricingType NVARCHAR(50)
		,@strContractType NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
	--,@strM2MBasis NVARCHAR(20)
	DECLARE @intLastModifiedUserId INT
		,@intNewM2MBasisId INT
		,@intM2MBasisRefId INT
		,@dtmM2MBasisDate DATETIME
	DECLARE @strDetailXML NVARCHAR(MAX)
		,@intM2MBasisDetailId INT
	DECLARE @intCommodityId INT
		,@intItemId INT
		,@intFutureMarketId INT
		,@intFutureMonthId INT
		,@intCompanyLocationId INT
		,@intMarketZoneId INT
		,@intCurrencyId INT
		,@intPricingTypeId INT
		,@intContractTypeId INT
		,@intUnitMeasureId INT
	DECLARE @tblRKM2MBasisStage TABLE (intM2MBasisStageId INT)

	INSERT INTO @tblRKM2MBasisStage (intM2MBasisStageId)
	SELECT intM2MBasisStageId
	FROM tblRKM2MBasisStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intM2MBasisStageId = MIN(intM2MBasisStageId)
	FROM @tblRKM2MBasisStage

	IF @intM2MBasisStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKM2MBasisStage t
	JOIN @tblRKM2MBasisStage pt ON pt.intM2MBasisStageId = t.intM2MBasisStageId

	WHILE @intM2MBasisStageId > 0
	BEGIN
		SELECT @intM2MBasisId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL
			,@strDetailXML = NULL

		SELECT @intM2MBasisId = intM2MBasisId
			,@strHeaderXML = strHeaderXML
			,@strDetailXML = strBasisDetailXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblRKM2MBasisStage
		WHERE intM2MBasisStageId = @intM2MBasisStageId

		BEGIN TRY
			SELECT @intM2MBasisRefId = @intM2MBasisId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @dtmM2MBasisDate = NULL

			SELECT @dtmM2MBasisDate = dtmM2MBasisDate
			FROM OPENXML(@idoc, 'vyuIPGetM2MBasiss/vyuIPGetM2MBasis', 2) WITH (dtmM2MBasisDate DATETIME) x

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
						FROM tblRKM2MBasis
						WHERE intM2MBasisRefId = @intM2MBasisRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewM2MBasisId = @intM2MBasisRefId
					,@dtmM2MBasisDate = NULL

				DELETE
				FROM tblRKM2MBasis
				WHERE intM2MBasisRefId = @intM2MBasisRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKM2MBasis (
					dtmM2MBasisDate
					,strPricingType
					,intConcurrencyId
					,intM2MBasisRefId
					)
				SELECT dtmM2MBasisDate
					,strPricingType
					,1
					,@intM2MBasisRefId
				FROM OPENXML(@idoc, 'vyuIPGetM2MBasiss/vyuIPGetM2MBasis', 2) WITH (
						dtmM2MBasisDate DATETIME
						,strPricingType NVARCHAR(30)
						)

				SELECT @intNewM2MBasisId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKM2MBasis
				SET intConcurrencyId = intConcurrencyId + 1
					,dtmM2MBasisDate = x.dtmM2MBasisDate
					,strPricingType = x.strPricingType
				FROM OPENXML(@idoc, 'vyuIPGetM2MBasiss/vyuIPGetM2MBasis', 2) WITH (
						dtmM2MBasisDate DATETIME
						,strPricingType NVARCHAR(30)
						) x
				WHERE tblRKM2MBasis.intM2MBasisRefId = @intM2MBasisRefId

				SELECT @intNewM2MBasisId = intM2MBasisId
					,@dtmM2MBasisDate = dtmM2MBasisDate
				FROM tblRKM2MBasis
				WHERE intM2MBasisRefId = @intM2MBasisRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Detail--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strDetailXML

			DECLARE @tblRKM2MBasisDetail TABLE (intM2MBasisDetailId INT)

			INSERT INTO @tblRKM2MBasisDetail (intM2MBasisDetailId)
			SELECT intM2MBasisDetailId
			FROM OPENXML(@idoc, 'vyuIPGetM2MBasisDetails/vyuIPGetM2MBasisDetail', 2) WITH (intM2MBasisDetailId INT)

			SELECT @intM2MBasisDetailId = MIN(intM2MBasisDetailId)
			FROM @tblRKM2MBasisDetail

			WHILE @intM2MBasisDetailId IS NOT NULL
			BEGIN
				SELECT @strCommodityCode = NULL
					,@strItemNo = NULL
					,@strFutMarketName = NULL
					,@strFutureMonth = NULL
					,@strLocationName = NULL
					,@strMarketZoneCode = NULL
					,@strCurrency = NULL
					,@strPricingType = NULL
					,@strContractType = NULL
					,@strUnitMeasure = NULL

				SELECT @strCommodityCode = strCommodityCode
					,@strItemNo = strItemNo
					,@strFutMarketName = strFutMarketName
					,@strFutureMonth = strFutureMonth
					,@strLocationName = strLocationName
					,@strMarketZoneCode = strMarketZoneCode
					,@strCurrency = strCurrency
					,@strPricingType = strPricingType
					,@strContractType = strContractType
					,@strUnitMeasure = strUnitMeasure
				FROM OPENXML(@idoc, 'vyuIPGetM2MBasisDetails/vyuIPGetM2MBasisDetail', 2) WITH (
						strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
						,strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
						,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strMarketZoneCode NVARCHAR(20) Collate Latin1_General_CI_AS
						,strCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
						,strPricingType NVARCHAR(50) Collate Latin1_General_CI_AS
						,strContractType NVARCHAR(50) Collate Latin1_General_CI_AS
						,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,intM2MBasisDetailId INT
						) SD
				WHERE intM2MBasisDetailId = @intM2MBasisDetailId

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

				IF @strItemNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICItem t
						WHERE t.strItemNo = @strItemNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Item ' + @strItemNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

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

				IF @strLocationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCompanyLocation t
						WHERE t.strLocationName = @strLocationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Location ' + @strLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strMarketZoneCode IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblARMarketZone t
						WHERE t.strMarketZoneCode = @strMarketZoneCode
						)
				BEGIN
					SELECT @strErrorMessage = 'Market Zone ' + @strMarketZoneCode + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCurrency IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCurrency t
						WHERE t.strCurrency = @strCurrency
						)
				BEGIN
					SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPricingType IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTPricingType t
						WHERE t.strPricingType = @strPricingType
						)
				BEGIN
					SELECT @strErrorMessage = 'Pricing Type ' + @strPricingType + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strContractType IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTContractType t
						WHERE t.strContractType = @strContractType
						)
				BEGIN
					SELECT @strErrorMessage = 'Contract Type ' + @strContractType + ' is not available.'

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

				SELECT @intCommodityId = NULL
					,@intItemId = NULL
					,@intFutureMarketId = NULL
					,@intFutureMonthId = NULL
					,@intCompanyLocationId = NULL
					,@intMarketZoneId = NULL
					,@intCurrencyId = NULL
					,@intPricingTypeId = NULL
					,@intContractTypeId = NULL
					,@intUnitMeasureId = NULL

				SELECT @intCommodityId = t.intCommodityId
				FROM tblICCommodity t
				WHERE t.strCommodityCode = @strCommodityCode

				SELECT @intItemId = t.intItemId
				FROM tblICItem t
				WHERE t.strItemNo = @strItemNo

				SELECT @intFutureMarketId = t.intFutureMarketId
				FROM tblRKFutureMarket t
				WHERE t.strFutMarketName = @strFutMarketName

				SELECT @intFutureMonthId = t.intFutureMonthId
				FROM tblRKFuturesMonth t
				WHERE t.strFutureMonth = @strFutureMonth
					AND t.intFutureMarketId = @intFutureMarketId

				SELECT @intCompanyLocationId = t.intCompanyLocationId
				FROM tblSMCompanyLocation t
				WHERE t.strLocationName = @strLocationName

				SELECT @intMarketZoneId = t.intMarketZoneId
				FROM tblARMarketZone t
				WHERE t.strMarketZoneCode = @strMarketZoneCode

				SELECT @intCurrencyId = t.intCurrencyID
				FROM tblSMCurrency t
				WHERE t.strCurrency = @strCurrency

				SELECT @intPricingTypeId = t.intPricingTypeId
				FROM tblCTPricingType t
				WHERE t.strPricingType = @strPricingType

				SELECT @intContractTypeId = t.intContractTypeId
				FROM tblCTContractType t
				WHERE t.strContractType = @strContractType

				SELECT @intUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t
				WHERE t.strUnitMeasure = @strUnitMeasure

				IF NOT EXISTS (
						SELECT 1
						FROM tblRKM2MBasisDetail
						WHERE intM2MBasisDetailRefId = @intM2MBasisDetailId
						)
				BEGIN
					INSERT INTO tblRKM2MBasisDetail (
						intM2MBasisId
						,intConcurrencyId
						,intCommodityId
						,intItemId
						,strOriginDest
						,intFutureMarketId
						,intFutureMonthId
						,strPeriodTo
						,intCompanyLocationId
						,intMarketZoneId
						,intCurrencyId
						,intPricingTypeId
						,strContractInventory
						,intContractTypeId
						,dblCashOrFuture
						,dblRatio
						,dblBasisOrDiscount
						,intUnitMeasureId
						,strMarketValuation
						,intM2MBasisDetailRefId
						)
					SELECT @intNewM2MBasisId
						,1
						,@intCommodityId
						,@intItemId
						,strOriginDest
						,@intFutureMarketId
						,@intFutureMonthId
						,strPeriodTo
						,@intCompanyLocationId
						,@intMarketZoneId
						,@intCurrencyId
						,@intPricingTypeId
						,strContractInventory
						,@intContractTypeId
						,dblCashOrFuture
						,dblRatio
						,dblBasisOrDiscount
						,@intUnitMeasureId
						,strMarketValuation
						,@intM2MBasisDetailId
					FROM OPENXML(@idoc, 'vyuIPGetM2MBasisDetails/vyuIPGetM2MBasisDetail', 2) WITH (
							strOriginDest NVARCHAR(50)
							,strPeriodTo NVARCHAR(50)
							,strContractInventory NVARCHAR(50)
							,dblCashOrFuture NUMERIC(18, 6)
							,dblRatio NUMERIC(18, 6)
							,dblBasisOrDiscount NUMERIC(18, 6)
							,strMarketValuation NVARCHAR(250)
							,intM2MBasisDetailId INT
							) x
					WHERE x.intM2MBasisDetailId = @intM2MBasisDetailId
				END
				ELSE
				BEGIN
					UPDATE tblRKM2MBasisDetail
					SET intConcurrencyId = intConcurrencyId + 1
						,intCommodityId = @intCommodityId
						,intItemId = @intItemId
						,strOriginDest = x.strOriginDest
						,intFutureMarketId = @intFutureMarketId
						,intFutureMonthId = @intFutureMonthId
						,strPeriodTo = x.strPeriodTo
						,intCompanyLocationId = @intCompanyLocationId
						,intMarketZoneId = @intMarketZoneId
						,intCurrencyId = @intCurrencyId
						,intPricingTypeId = @intPricingTypeId
						,strContractInventory = x.strContractInventory
						,intContractTypeId = @intContractTypeId
						,dblCashOrFuture = x.dblCashOrFuture
						,dblRatio = x.dblRatio
						,dblBasisOrDiscount = x.dblBasisOrDiscount
						,intUnitMeasureId = @intUnitMeasureId
						,strMarketValuation = x.strMarketValuation
					FROM OPENXML(@idoc, 'vyuIPGetM2MBasisDetails/vyuIPGetM2MBasisDetail', 2) WITH (
							strOriginDest NVARCHAR(50)
							,strPeriodTo NVARCHAR(50)
							,strContractInventory NVARCHAR(50)
							,dblCashOrFuture NUMERIC(18, 6)
							,dblRatio NUMERIC(18, 6)
							,dblBasisOrDiscount NUMERIC(18, 6)
							,strMarketValuation NVARCHAR(250)
							,intM2MBasisDetailId INT
							) x
					JOIN tblRKM2MBasisDetail D ON D.intM2MBasisDetailRefId = x.intM2MBasisDetailId
						AND D.intM2MBasisId = @intNewM2MBasisId
					WHERE x.intM2MBasisDetailId = @intM2MBasisDetailId
				END

				SELECT @intM2MBasisDetailId = MIN(intM2MBasisDetailId)
				FROM @tblRKM2MBasisDetail
				WHERE intM2MBasisDetailId > @intM2MBasisDetailId
			END

			DELETE
			FROM tblRKM2MBasisDetail
			WHERE intM2MBasisId = @intNewM2MBasisId
				AND intM2MBasisDetailRefId NOT IN (
					SELECT intM2MBasisDetailId
					FROM @tblRKM2MBasisDetail
					)

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblRKM2MBasisStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intM2MBasisStageId = @intM2MBasisStageId

			-- Audit Log
			IF (@intNewM2MBasisId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewM2MBasisId
						,@screenName = 'RiskManagement.view.BasisEntry'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @dtmM2MBasisDate
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewM2MBasisId
						,@screenName = 'RiskManagement.view.BasisEntry'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @dtmM2MBasisDate
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

			UPDATE tblRKM2MBasisStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intM2MBasisStageId = @intM2MBasisStageId
		END CATCH

		SELECT @intM2MBasisStageId = MIN(intM2MBasisStageId)
		FROM @tblRKM2MBasisStage
		WHERE intM2MBasisStageId > @intM2MBasisStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKM2MBasisStage t
	JOIN @tblRKM2MBasisStage pt ON pt.intM2MBasisStageId = t.intM2MBasisStageId
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
