CREATE PROCEDURE dbo.uspCTPriceContractProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intPriceContractStageId INT
	DECLARE @intPriceContractId INT
	DECLARE @strPriceContractNo NVARCHAR(MAX)
	DECLARE @strNewPriceContractNo NVARCHAR(MAX)
	DECLARE @strPriceContractXML NVARCHAR(MAX)
	DECLARE @strPriceFixationXML NVARCHAR(MAX)
	DECLARE @strPriceFixationDetailXML NVARCHAR(MAX)
	DECLARE @strReference NVARCHAR(MAX)
	DECLARE @strRowState NVARCHAR(MAX)
	DECLARE @strFeedStatus NVARCHAR(MAX)
	DECLARE @dtmFeedDate DATETIME
	DECLARE @strMessage NVARCHAR(MAX)
	DECLARE @intMultiCompanyId INT
	DECLARE @intEntityId INT
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @strTagRelaceXML NVARCHAR(MAX)
	DECLARE @NewPriceContractId INT
	DECLARE @NewPriceFixationId INT
	DECLARE @NewPriceFixationDetailId INT
	DECLARE @intPriceContractAcknowledgementStageId INT
	DECLARE @strPriceContractCondition NVARCHAR(MAX)
	DECLARE @strPriceFixationCondition NVARCHAR(MAX)
	DECLARE @strPriceFixationAllId NVARCHAR(MAX)
	DECLARE @strAckPriceContractXML NVARCHAR(MAX)
	DECLARE @strAckPriceFixationXML NVARCHAR(MAX)
	DECLARE @strAckPriceFixationDetailXML NVARCHAR(MAX)
	DECLARE @strHedgeXML NVARCHAR(MAX)
	DECLARE @TempPriceFixationId INT
	DECLARE @intPriceFixationId INT
	DECLARE @intContractHeaderId INT
	DECLARE @intContractDetailId INT
	DECLARE @intPriceFixationRefId INT
	DECLARE @idoc INT
	DECLARE @intNumber INT
		,@intCommodityUnitMeasureId INT
		,@intAgreedItemUOMId INT
		,@intCommodityUnitMeasureId2 INT
		,@intPriceFixationDetailId INT
		,@strItemNo NVARCHAR(50)
		,@intItemId INT
		,@intItemUOMId INT
		,@intFutureMarketId INT
		,@intFutureMonthId INT
		,@intHedgeFutureMonthId INT
		,@intBrokerId INT
		,@intBrokerageAccountId INT
		,@intPriceItemUOMId INT
		,@intPriceUnitMeasureId INT
		,@strPriceItemUOM NVARCHAR(50)
		,@config AS ApprovalConfigurationType
	DECLARE @intNewPriceContractId INT
		,@strFinalPriceUOM NVARCHAR(50)
		,@strAgreedItemUOM NVARCHAR(50)
	DECLARE @tblCTPriceFixationDetail TABLE (intPriceFixationDetailId INT)
	DECLARE @strQtyItemUOM NVARCHAR(50)
		,@strFutMarketName NVARCHAR(30)
		,@strFutureMonth NVARCHAR(20)
		,@strHedgeFutureMonth NVARCHAR(20)
		,@strBroker NVARCHAR(100)
		,@strAccountNumber NVARCHAR(50)
	DECLARE @tblCTPriceFixation AS TABLE (
		TempPriceFixationId INT IDENTITY(1, 1)
		,intPriceFixationId INT
		,intPriceContractId INT
		,intConcurrencyId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,intOriginalFutureMarketId INT
		,intOriginalFutureMonthId INT
		,dblOriginalBasis NUMERIC(18, 6)
		,dblTotalLots NUMERIC(18, 6)
		,dblLotsFixed NUMERIC(18, 6)
		,intLotsHedged INT
		,dblPolResult NUMERIC(18, 6)
		,dblPremiumPoints NUMERIC(18, 6)
		,ysnAAPrice BIT
		,ysnSettlementPrice BIT
		,ysnToBeAgreed BIT
		,dblSettlementPrice NUMERIC(18, 6)
		,dblAgreedAmount NUMERIC(18, 6)
		,intAgreedItemUOMId INT
		,dblPolPct NUMERIC(18, 6)
		,dblPriceWORollArb NUMERIC(18, 6)
		,dblRollArb NUMERIC(18, 6)
		,dblPolSummary NUMERIC(18, 6)
		,dblAdditionalCost NUMERIC(18, 6)
		,dblFinalPrice NUMERIC(18, 6)
		,intFinalPriceUOMId INT
		,ysnSplit BIT
		,intPriceFixationRefId INT
		)
	DECLARE @intTransactionCount INT
		,@strUnitMeasure NVARCHAR(50)
		,@strCurrency NVARCHAR(40)
		,@strCommodityCode NVARCHAR(50)
		,@strErrorMessage NVARCHAR(MAX)
		,@dtmCreated DATETIME
		,@dtmLastModified DATETIME
		,@strCreatedBy NVARCHAR(100)
		,@strLastModifiedBy NVARCHAR(100)
		,@intUnitMeasureId INT
		,@intCommodityId INT
		,@intCurrencyId INT
		,@intFinalPriceUOMId INT
		,@intCreatedById INT
		,@intLastModifiedById INT
		,@intTransactionId INT
		,@intCompanyId INT
		,@intContractScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@strDescription NVARCHAR(100)
		,@strApproverXML NVARCHAR(MAX)
		,@strSubmittedByXML NVARCHAR(MAX)
		,@strApprover NVARCHAR(100)
		,@intCurrentUserEntityId INT

	SELECT @intCompanyRefId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1


	SELECT @intPriceContractStageId = MIN(intPriceContractStageId)
	FROM tblCTPriceContractStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intPriceContractStageId > 0
	BEGIN
		SET @intPriceContractId = NULL
		SET @strPriceContractNo = NULL
		SET @strPriceContractXML = NULL
		SET @strPriceFixationXML = NULL
		SET @strPriceFixationDetailXML = NULL
		SET @strReference = NULL
		SET @strRowState = NULL
		SET @strFeedStatus = NULL
		SET @dtmFeedDate = NULL
		SET @strMessage = NULL
		SET @intMultiCompanyId = NULL
		SET @intEntityId = NULL
		SET @strTransactionType = NULL
		SET @intTransactionId = NULL
		SET @intCompanyId = NULL
		SET @strApproverXML = NULL

		SELECT @intPriceContractId = intPriceContractId
			,@strPriceContractNo = strPriceContractNo
			,@strPriceContractXML = strPriceContractXML
			,@strPriceFixationXML = strPriceFixationXML
			,@strPriceFixationDetailXML = strPriceFixationDetailXML
			,@strApproverXML = strApproverXML
			,@strSubmittedByXML=strSubmittedByXML
			,@strReference = strReference
			,@strRowState = strRowState
			,@strFeedStatus = strFeedStatus
			,@dtmFeedDate = dtmFeedDate
			,@strMessage = strMessage
			,@intMultiCompanyId = intMultiCompanyId
			,@intEntityId = intEntityId
			,@strTransactionType = strTransactionType
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblCTPriceContractStage
		WHERE intPriceContractStageId = @intPriceContractStageId

		IF @strTransactionType = 'Sales Price Fixation'
		BEGIN
			-------------------------PriceContract-----------------------------------------------------------
			EXEC uspCTGetStartingNumber 'Price Contract'
				,@strNewPriceContractNo OUTPUT

			SET @strPriceContractXML = REPLACE(@strPriceContractXML, @strPriceContractNo, @strNewPriceContractNo)
			SET @strPriceContractXML = REPLACE(@strPriceContractXML, 'intCompanyId>', 'CompanyId>')

			EXEC uspCTInsertINTOTableFromXML 'tblCTPriceContract'
				,@strPriceContractXML
				,@NewPriceContractId OUTPUT

			UPDATE tblCTPriceContract
			SET strPriceContractNo = @strNewPriceContractNo
				,intPriceContractRefId = @intPriceContractId
			WHERE intPriceContractId = @NewPriceContractId

			INSERT INTO tblCTPriceContractAcknowledgementStage (
				intAckPriceContractId
				,strAckPriceContracNo
				,dtmFeedDate
				,strMessage
				,strTransactionType
				,intMultiCompanyId
				)
			SELECT @NewPriceContractId
				,@strNewPriceContractNo
				,GETDATE()
				,'Success'
				,@strTransactionType
				,@intMultiCompanyId

			SELECT @intPriceContractAcknowledgementStageId = SCOPE_IDENTITY();

			---------------------------------------------PriceFixation------------------------------------------					
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strPriceFixationXML

			INSERT INTO @tblCTPriceFixation (
				intPriceFixationId
				,intPriceContractId
				,intConcurrencyId
				,intContractHeaderId
				,intContractDetailId
				,intOriginalFutureMarketId
				,intOriginalFutureMonthId
				,dblOriginalBasis
				,dblTotalLots
				,dblLotsFixed
				,intLotsHedged
				,dblPolResult
				,dblPremiumPoints
				,ysnAAPrice
				,ysnSettlementPrice
				,ysnToBeAgreed
				,dblSettlementPrice
				,dblAgreedAmount
				,intAgreedItemUOMId
				,dblPolPct
				,dblPriceWORollArb
				,dblRollArb
				,dblPolSummary
				,dblAdditionalCost
				,dblFinalPrice
				,intFinalPriceUOMId
				,ysnSplit
				,intPriceFixationRefId
				)
			SELECT intPriceFixationId
				,intPriceContractId
				,intConcurrencyId
				,intContractHeaderId
				,intContractDetailId
				,intOriginalFutureMarketId
				,intOriginalFutureMonthId
				,dblOriginalBasis
				,dblTotalLots
				,dblLotsFixed
				,intLotsHedged
				,dblPolResult
				,dblPremiumPoints
				,ysnAAPrice
				,ysnSettlementPrice
				,ysnToBeAgreed
				,dblSettlementPrice
				,dblAgreedAmount
				,intAgreedItemUOMId
				,dblPolPct
				,dblPriceWORollArb
				,dblRollArb
				,dblPolSummary
				,dblAdditionalCost
				,dblFinalPrice
				,intFinalPriceUOMId
				,ysnSplit
				,intPriceFixationRefId
			FROM OPENXML(@idoc, 'tblCTPriceFixations/tblCTPriceFixation', 2) WITH (
					intPriceFixationId INT
					,intPriceContractId INT
					,intConcurrencyId INT
					,intContractHeaderId INT
					,intContractDetailId INT
					,intOriginalFutureMarketId INT
					,intOriginalFutureMonthId INT
					,dblOriginalBasis NUMERIC(18, 6)
					,dblTotalLots NUMERIC(18, 6)
					,dblLotsFixed NUMERIC(18, 6)
					,intLotsHedged INT
					,dblPolResult NUMERIC(18, 6)
					,dblPremiumPoints NUMERIC(18, 6)
					,ysnAAPrice BIT
					,ysnSettlementPrice BIT
					,ysnToBeAgreed BIT
					,dblSettlementPrice NUMERIC(18, 6)
					,dblAgreedAmount NUMERIC(18, 6)
					,intAgreedItemUOMId INT
					,dblPolPct NUMERIC(18, 6)
					,dblPriceWORollArb NUMERIC(18, 6)
					,dblRollArb NUMERIC(18, 6)
					,dblPolSummary NUMERIC(18, 6)
					,dblAdditionalCost NUMERIC(18, 6)
					,dblFinalPrice NUMERIC(18, 6)
					,intFinalPriceUOMId INT
					,ysnSplit BIT
					,intPriceFixationRefId INT
					)

			SELECT @TempPriceFixationId = MIN(TempPriceFixationId)
			FROM @tblCTPriceFixation

			WHILE @TempPriceFixationId > 0
			BEGIN
				SET @intPriceFixationId = NULL
				SET @NewPriceFixationId = NULL
				SET @intContractHeaderId = NULL
				SET @intContractDetailId = NULL
				SET @intPriceFixationRefId = NULL

				SELECT @intPriceFixationId = intPriceFixationId
					,@intContractHeaderId = intContractHeaderId
					,@intContractDetailId = intContractDetailId
					,@intPriceFixationRefId = intPriceFixationRefId
				FROM @tblCTPriceFixation
				WHERE TempPriceFixationId = @TempPriceFixationId

				UPDATE tbl
				SET tbl.intContractHeaderId = CH.intContractHeaderId
					,tbl.intContractDetailId = CD.intContractDetailId
					,tbl.intPriceContractId = @NewPriceContractId
				FROM @tblCTPriceFixation tbl
				JOIN tblCTContractHeader CH ON CH.intContractHeaderRefId = tbl.intContractHeaderId
				JOIN tblCTContractDetail CD ON CD.intContractDetailRefId = tbl.intContractDetailId

				INSERT INTO tblCTPriceFixation (
					intPriceContractId
					,intConcurrencyId
					,intContractHeaderId
					,intContractDetailId
					,intOriginalFutureMarketId
					,intOriginalFutureMonthId
					,dblOriginalBasis
					,dblTotalLots
					,dblLotsFixed
					,intLotsHedged
					,dblPolResult
					,dblPremiumPoints
					,ysnAAPrice
					,ysnSettlementPrice
					,ysnToBeAgreed
					,dblSettlementPrice
					,dblAgreedAmount
					,intAgreedItemUOMId
					,dblPolPct
					,dblPriceWORollArb
					,dblRollArb
					,dblPolSummary
					,dblAdditionalCost
					,dblFinalPrice
					,intFinalPriceUOMId
					,ysnSplit
					,intPriceFixationRefId
					)
				SELECT intPriceContractId
					,intConcurrencyId
					,intContractHeaderId
					,intContractDetailId
					,intOriginalFutureMarketId
					,intOriginalFutureMonthId
					,dblOriginalBasis
					,dblTotalLots
					,dblLotsFixed
					,intLotsHedged
					,dblPolResult
					,dblPremiumPoints
					,ysnAAPrice
					,ysnSettlementPrice
					,ysnToBeAgreed
					,dblSettlementPrice
					,dblAgreedAmount
					,intAgreedItemUOMId
					,dblPolPct
					,dblPriceWORollArb
					,dblRollArb
					,dblPolSummary
					,dblAdditionalCost
					,dblFinalPrice
					,intFinalPriceUOMId
					,ysnSplit
					,intPriceFixationRefId
				FROM @tblCTPriceFixation
				WHERE TempPriceFixationId = @TempPriceFixationId

				SET @NewPriceFixationId = SCOPE_IDENTITY();

				UPDATE tblCTPriceFixation
				SET intPriceFixationRefId = @intPriceFixationId
				WHERE intPriceFixationId = @NewPriceFixationId

				SELECT @TempPriceFixationId = MIN(TempPriceFixationId)
				FROM @tblCTPriceFixation
				WHERE TempPriceFixationId > @TempPriceFixationId
			END

			---------------------------------------------PriceFixationDetail-----------------------------------------------
			DECLARE @tblPriceFixation AS TABLE (
				intRowNo INT IDENTITY
				,PriceFixationId INT
				,TradeNo NVARCHAR(20)
				)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strPriceFixationDetailXML

			INSERT INTO @tblPriceFixation (
				PriceFixationId
				,TradeNo
				)
			SELECT DISTINCT intPriceFixationId
				,strTradeNo
			FROM OPENXML(@idoc, 'tblCTPriceFixationDetails/tblCTPriceFixationDetail', 2) WITH (
					intPriceFixationId INT
					,strTradeNo NVARCHAR(20)
					)

			DECLARE @strFixationDetailXml NVARCHAR(max) = ''

			SELECT @strFixationDetailXml = @strFixationDetailXml + '<tags>' + '<toFind>&lt;intPriceFixationId&gt;' + LTRIM(t1.PriceFixationId) + '&lt;/intPriceFixationId&gt;</toFind>' + '<toReplace>&lt;intPriceFixationId&gt;' + LTRIM(t1.intPriceFixationId) + '&lt;/intPriceFixationId&gt;</toReplace>' + '</tags>' + '<tags>' + '<toFind>&lt;strTradeNo&gt;' + LTRIM(t1.TradeNo) + '&lt;/strTradeNo&gt;</toFind>' + '<toReplace>&lt;strTradeNo&gt;' + LTRIM(SN.strPrefix) + LTRIM(SN.intNumber + t1.intRowNo) + '&lt;/strTradeNo&gt;</toReplace>' + '</tags>'
			FROM (
				SELECT t.intRowNo
					,t.intPriceFixationId
					,td.PriceFixationId
					,td.TradeNo
				FROM (
					SELECT ROW_NUMBER() OVER (
							ORDER BY intPriceFixationId
							) intRowNo
						,*
					FROM tblCTPriceFixation cd
					WHERE cd.intPriceContractId = @NewPriceContractId
					) t
				JOIN @tblPriceFixation td ON t.intRowNo = td.intRowNo
				) t1
			JOIN tblSMStartingNumber SN ON 1 = 1
			WHERE SN.strTransactionType = N'Price Fixation Trade No'

			SELECT @intNumber = COUNT(1)
			FROM @tblPriceFixation

			UPDATE tblSMStartingNumber
			SET intNumber = intNumber + @intNumber + 1
			WHERE strTransactionType = N'Price Fixation Trade No'

			SET @strFixationDetailXml = '<root>' + @strFixationDetailXml + '</root>'
			SET @strPriceFixationDetailXML = REPLACE(@strPriceFixationDetailXML, 'intPriceFixationDetailId', 'intPriceFixationDetailRefId')

			EXEC uspCTInsertINTOTableFromXML 'tblCTPriceFixationDetail'
				,@strPriceFixationDetailXML
				,@NewPriceFixationDetailId OUTPUT
				,@strFixationDetailXml

			----------------------------------Hedge----------------------------------									
			EXEC uspCTSavePriceContract @NewPriceContractId
				,@strHedgeXML

			-----------------------------Acknowledgement-------------------------
			-------------------------PriceContract-----------------------------------------------------------
			SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@NewPriceContractId)

			EXEC uspCTGetTableDataInXML 'tblCTPriceContract'
				,@strPriceContractCondition
				,@strAckPriceContractXML OUTPUT

			UPDATE tblCTPriceContractAcknowledgementStage
			SET strAckPriceContractXML = @strAckPriceContractXML
			WHERE intPriceContractAcknowledgementStageId = @intPriceContractAcknowledgementStageId

			---------------------------------------------PriceFixation------------------------------------------
			SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@NewPriceContractId)

			EXEC uspCTGetTableDataInXML 'tblCTPriceFixation'
				,@strPriceContractCondition
				,@strAckPriceFixationXML OUTPUT

			UPDATE tblCTPriceContractAcknowledgementStage
			SET strAckPriceFixationXML = @strAckPriceFixationXML
			WHERE intPriceContractAcknowledgementStageId = @intPriceContractAcknowledgementStageId

			---------------------------------------------PriceFixationDetail-----------------------------------------------
			SELECT @strPriceFixationAllId = STUFF((
						SELECT DISTINCT ',' + LTRIM(intPriceFixationId)
						FROM tblCTPriceFixation
						WHERE intPriceContractId = @NewPriceContractId
						FOR XML PATH('')
						), 1, 1, '')

			SELECT @strPriceFixationCondition = 'intPriceFixationId IN (' + LTRIM(@strPriceFixationAllId) + ')'

			EXEC uspCTGetTableDataInXML 'tblCTPriceFixationDetail'
				,@strPriceFixationCondition
				,@strAckPriceFixationDetailXML OUTPUT

			SELECT @strPriceFixationCondition = 'intPriceFixationId IN (' + LTRIM(@strPriceFixationAllId) + ')'

			EXEC dbo.uspCTGetTableDataInXML 'tblCTPriceFixationDetail'
				,@strPriceFixationCondition
				,@strPriceFixationDetailXML OUTPUT
				,NULL
				,NULL

			UPDATE tblCTPriceContractAcknowledgementStage
			SET strAckPriceFixationDetailXML = @strAckPriceFixationDetailXML
			WHERE intPriceContractAcknowledgementStageId = @intPriceContractAcknowledgementStageId

			-----------------------------------------------------------------------------------------------------------------------------------------------------
			UPDATE tblCTPriceContractStage
			SET strFeedStatus = 'Processed'
			WHERE intPriceContractStageId = @intPriceContractStageId

			EXEC sp_xml_removedocument @idoc
		END

		IF @strTransactionType = 'Purchase Price Fixation'
		BEGIN
			BEGIN TRY
				SELECT @intTransactionCount = @@TRANCOUNT

				IF @intTransactionCount = 0
					BEGIN TRANSACTION

				IF @strRowState = 'Delete'
				BEGIN
					DELETE
					FROM tblCTPriceContract
					WHERE intPriceContractRefId = @intPriceContractId

					GOTO x
				END

				------------------Header------------------------------------------------------
				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strPriceContractXML

				SELECT @strUnitMeasure = NULL
					,@strCurrency = NULL
					,@strCommodityCode = NULL
					,@intPriceContractId = NULL
					,@strPriceContractNo = NULL
					,@dtmCreated = NULL
					,@dtmLastModified = NULL
					,@strCreatedBy = NULL
					,@strLastModifiedBy = NULL

				SELECT @strUnitMeasure = strUnitMeasure
					,@strCurrency = strCurrency
					,@strCommodityCode = strCommodityCode
					,@intPriceContractId = intPriceContractId
					,@strPriceContractNo = strPriceContractNo
					,@dtmCreated = dtmCreated
					,@dtmLastModified = dtmLastModified
					,@strCreatedBy = strCreatedBy
					,@strLastModifiedBy = strLastModifiedBy
				FROM OPENXML(@idoc, 'vyuIPPriceContracts/vyuIPPriceContract', 2) WITH (
						strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,strCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
						,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,dtmCreated DATETIME
						,dtmLastModified DATETIME
						,strCreatedBy NVARCHAR(50) Collate Latin1_General_CI_AS
						,strLastModifiedBy NVARCHAR(50) Collate Latin1_General_CI_AS
						,intPriceContractId INT
						,strPriceContractNo NVARCHAR(50) Collate Latin1_General_CI_AS
						) x

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure UM
				WHERE UM.strUnitMeasure = @strUnitMeasure

				SELECT @strErrorMessage = ''

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				SELECT @intCommodityId = intCommodityId
				FROM tblICCommodity Comm
				WHERE Comm.strCommodityCode = @strCommodityCode

				IF @strCommodityCode IS NOT NULL
					AND @intCommodityId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Commodity Code ' + @strCommodityCode + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Commodity Code ' + @strCommodityCode + ' is not available.'
					END
				END

				SELECT @intCurrencyId = NULL

				SELECT @intCurrencyId = C.intCurrencyID
				FROM tblSMCurrency C
				WHERE C.strCurrency = @strCurrency

				IF @strCurrency IS NOT NULL
					AND @intCurrencyId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Currency ' + @strCurrency + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intFinalPriceUOMId = intCommodityUnitMeasureId
				FROM tblICCommodityUnitMeasure
				WHERE intUnitMeasureId = @intUnitMeasureId
					AND intCommodityId = @intCommodityId

				SELECT @intCreatedById = EY.intEntityId
				FROM tblEMEntity EY
				JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
					AND ET.strType = 'User'
				WHERE EY.strName = @strCreatedBy
					AND EY.strEntityNo <> ''

				IF @intCreatedById IS NULL
				BEGIN
					IF EXISTS (
							SELECT 1
							FROM tblSMUserSecurity
							WHERE strUserName = 'irelyadmin'
							)
						SELECT TOP 1 @intCreatedById = intEntityId
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
					ELSE
						SELECT TOP 1 @intCreatedById = intEntityId
						FROM tblSMUserSecurity
				END

				SELECT @intLastModifiedById = EY.intEntityId
				FROM tblEMEntity EY
				JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
					AND ET.strType = 'User'
				WHERE EY.strName = @strLastModifiedBy
					AND EY.strEntityNo <> ''

				IF @intLastModifiedById IS NULL
				BEGIN
					IF EXISTS (
							SELECT 1
							FROM tblSMUserSecurity
							WHERE strUserName = 'irelyadmin'
							)
						SELECT TOP 1 @intLastModifiedById = intEntityId
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
					ELSE
						SELECT TOP 1 @intLastModifiedById = intEntityId
						FROM tblSMUserSecurity
				END

				SELECT @intNewPriceContractId = NULL

				SELECT @intNewPriceContractId = intPriceContractId
					,@strNewPriceContractNo = strPriceContractNo
				FROM tblCTPriceContract
				WHERE intPriceContractRefId = @intPriceContractId

				IF @intNewPriceContractId IS NULL
				BEGIN
					EXEC uspCTGetStartingNumber 'Price Contract'
						,@strNewPriceContractNo OUTPUT

					INSERT INTO tblCTPriceContract (
						strPriceContractNo
						,intCommodityId
						,intFinalPriceUOMId
						,intFinalCurrencyId
						,intCreatedById
						,dtmCreated
						,intLastModifiedById
						,dtmLastModified
						,intConcurrencyId
						,intPriceContractRefId
						,intCompanyId
						)
					SELECT @strNewPriceContractNo
						,@intCommodityId
						,@intFinalPriceUOMId
						,@intCurrencyId
						,@intCreatedById
						,@dtmCreated
						,@intLastModifiedById
						,@dtmLastModified
						,1 AS intConcurrencyId
						,@intPriceContractId
						,@intCompanyRefId
					SELECT @intNewPriceContractId = SCOPE_IDENTITY()

					SELECT @strDescription = 'Created from inter-company : ' + @strNewPriceContractNo

					EXEC uspSMAuditLog @keyValue = @intNewPriceContractId
						,@screenName = 'ContractManagement.view.PriceContracts'
						,@entityId = @intLastModifiedById
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @strDescription
						,@fromValue = ''
						,@toValue = @strNewPriceContractNo
				END
				ELSE
				BEGIN
					UPDATE tblCTPriceContract
					SET intCommodityId = @intCommodityId
						,intFinalPriceUOMId = @intFinalPriceUOMId
						,intFinalCurrencyId = @intCurrencyId
						,intCreatedById = @intCreatedById
						,dtmCreated = @dtmCreated
						,intLastModifiedById = @intLastModifiedById
						,dtmLastModified = @dtmLastModified
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intPriceContractRefId = @intPriceContractId
						AND intPriceContractId = @intNewPriceContractId
				END

				--SELECT @intCompanyRefId = intCompanyId
				--FROM tblCTPriceContract
				--WHERE intPriceContractId = @intNewPriceContractId

				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strPriceFixationXML

				DELETE
				FROM @tblCTPriceFixation

				INSERT INTO @tblCTPriceFixation (intPriceFixationId)
				SELECT intPriceFixationId
				FROM OPENXML(@idoc, 'vyuIPPriceFixations/vyuIPPriceFixation', 2) WITH (intPriceFixationId INT)

				SELECT @intPriceFixationId = MIN(intPriceFixationId)
				FROM @tblCTPriceFixation

				WHILE @intPriceFixationId IS NOT NULL
				BEGIN
					SELECT @strFinalPriceUOM = NULL
						,@strAgreedItemUOM = NULL
						,@strCommodityCode = NULL
						,@strFutMarketName = NULL
						,@strFutureMonth = NULL
						,@strErrorMessage = ''

					SELECT @strFinalPriceUOM = strFinalPriceUOM
						,@strAgreedItemUOM = strAgreedItemUOM
						,@strCommodityCode = strCommodityCode
						,@strFutMarketName = strFutMarketName
						,@strFutureMonth = strFutureMonth
					FROM OPENXML(@idoc, 'vyuIPPriceFixations/vyuIPPriceFixation', 2) WITH (
							strFinalPriceUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strAgreedItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
							,intPriceFixationId INT
							,strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
							,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
							)
					WHERE intPriceFixationId = @intPriceFixationId

					SELECT @intFinalPriceUOMId = NULL

					SELECT @intFinalPriceUOMId = intUnitMeasureId
					FROM tblICUnitMeasure UM
					WHERE UM.strUnitMeasure = @strFinalPriceUOM

					IF @strFinalPriceUOM IS NOT NULL
						AND @intUnitMeasureId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Final Price UOM ' + @strFinalPriceUOM + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Final Price UOM ' + @strFinalPriceUOM + ' is not available.'
						END
					END

					SELECT @intCommodityId = intCommodityId
					FROM tblICCommodity Comm
					WHERE Comm.strCommodityCode = @strCommodityCode

					IF @strCommodityCode IS NOT NULL
						AND @intCommodityId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Commodity Code ' + @strCommodityCode + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Commodity Code ' + @strCommodityCode + ' is not available.'
						END
					END

					SELECT @intCommodityUnitMeasureId = NULL

					SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
					FROM tblICCommodityUnitMeasure
					WHERE intUnitMeasureId = @intFinalPriceUOMId
						AND intCommodityId = @intCommodityId

					SELECT @intAgreedItemUOMId = NULL

					SELECT @intAgreedItemUOMId = intUnitMeasureId
					FROM tblICUnitMeasure UM
					WHERE UM.strUnitMeasure = @strAgreedItemUOM

					IF @strAgreedItemUOM IS NOT NULL
						AND @intAgreedItemUOMId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Agreed Item UOM ' + @strAgreedItemUOM + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Agreed Item UOM ' + @strAgreedItemUOM + ' is not available.'
						END
					END

					SELECT @intCommodityUnitMeasureId2 = NULL

					SELECT @intCommodityUnitMeasureId2 = intCommodityUnitMeasureId
					FROM tblICCommodityUnitMeasure
					WHERE intUnitMeasureId = @intAgreedItemUOMId
						AND intCommodityId = @intCommodityId

					IF NOT EXISTS (
							SELECT *
							FROM OPENXML(@idoc, 'vyuIPPriceFixations/vyuIPPriceFixation', 2) WITH (intContractHeaderId INT) x
							JOIN tblCTContractHeader CH ON x.intContractHeaderId = CH.intContractHeaderRefId
							)
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Contract is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Contract is not available.'
						END
					END

					SELECT @intFutureMarketId = intFutureMarketId
					FROM tblRKFutureMarket FM
					WHERE FM.strFutMarketName = @strFutMarketName

					IF @strFutMarketName IS NOT NULL
						AND @intFutureMarketId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Future Market Name ' + @strFutMarketName + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Future Market Name ' + @strFutMarketName + ' is not available.'
						END
					END

					SELECT @intFutureMonthId = MO.intFutureMonthId
					FROM tblRKFuturesMonth MO
					WHERE MO.strFutureMonth = @strFutureMonth

					IF @strFutureMonth IS NOT NULL
						AND @intFutureMonthId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Future Month ' + @strFutureMonth + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'
						END
					END

					IF @strErrorMessage <> ''
					BEGIN
						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					DELETE PF
					FROM tblCTPriceFixation PF
					WHERE PF.intPriceContractId = @intPriceContractId
						AND NOT EXISTS (
							SELECT *
							FROM OPENXML(@idoc, 'vyuIPPriceFixations/vyuIPPriceFixation', 2) WITH (intPriceFixationId INT) x
							WHERE PF.intPriceFixationRefId = x.intPriceFixationId
							)

					IF NOT EXISTS (
							SELECT *
							FROM tblCTPriceFixation
							WHERE intPriceFixationRefId = @intPriceFixationId
							)
					BEGIN
						INSERT INTO tblCTPriceFixation (
							intPriceContractId
							,intConcurrencyId
							,intContractHeaderId
							,intContractDetailId
							,intOriginalFutureMarketId
							,intOriginalFutureMonthId
							,dblOriginalBasis
							,dblTotalLots
							,dblLotsFixed
							,intLotsHedged
							,dblPolResult
							,dblPremiumPoints
							,ysnAAPrice
							,ysnSettlementPrice
							,ysnToBeAgreed
							,dblSettlementPrice
							,dblAgreedAmount
							,intAgreedItemUOMId
							,dblPolPct
							,dblPriceWORollArb
							,dblRollArb
							,dblPolSummary
							,dblAdditionalCost
							,dblFinalPrice
							,intFinalPriceUOMId
							,ysnSplit
							,intPriceFixationRefId
							)
						SELECT (
								SELECT TOP 1 PC.intPriceContractId
								FROM tblCTPriceContract PC
								WHERE PC.intPriceContractRefId = x.intPriceContractId
								) AS intPriceContractId
							,1 AS intConcurrencyId
							,(
								SELECT TOP 1 CH.intContractHeaderId
								FROM tblCTContractHeader CH
								WHERE CH.intContractHeaderRefId = x.intContractHeaderId
								) AS intContractHeaderId
							,(
								SELECT TOP 1 CD.intContractDetailId
								FROM tblCTContractDetail CD
								WHERE CD.intContractDetailRefId = x.intContractDetailId
								) AS intContractDetailId
							,@intFutureMarketId
							,@intFutureMonthId
							,dblOriginalBasis
							,dblTotalLots
							,dblLotsFixed
							,intLotsHedged
							,dblPolResult
							,dblPremiumPoints
							,ysnAAPrice
							,ysnSettlementPrice
							,ysnToBeAgreed
							,dblSettlementPrice
							,dblAgreedAmount
							,@intCommodityUnitMeasureId2
							,dblPolPct
							,dblPriceWORollArb
							,dblRollArb
							,dblPolSummary
							,dblAdditionalCost
							,dblFinalPrice
							,@intCommodityUnitMeasureId
							,ysnSplit
							,intPriceFixationId
						FROM OPENXML(@idoc, 'vyuIPPriceFixations/vyuIPPriceFixation', 2) WITH (
								intPriceFixationId INT
								,intPriceContractId INT
								,intConcurrencyId INT
								,intContractHeaderId INT
								,intContractDetailId INT
								,intOriginalFutureMarketId INT
								,intOriginalFutureMonthId INT
								,dblOriginalBasis NUMERIC(18, 6)
								,dblTotalLots NUMERIC(18, 6)
								,dblLotsFixed NUMERIC(18, 6)
								,intLotsHedged INT
								,dblPolResult NUMERIC(18, 6)
								,dblPremiumPoints NUMERIC(18, 6)
								,ysnAAPrice BIT
								,ysnSettlementPrice BIT
								,ysnToBeAgreed BIT
								,dblSettlementPrice NUMERIC(18, 6)
								,dblAgreedAmount NUMERIC(18, 6)
								,intAgreedItemUOMId INT
								,dblPolPct NUMERIC(18, 6)
								,dblPriceWORollArb NUMERIC(18, 6)
								,dblRollArb NUMERIC(18, 6)
								,dblPolSummary NUMERIC(18, 6)
								,dblAdditionalCost NUMERIC(18, 6)
								,dblFinalPrice NUMERIC(18, 6)
								,intFinalPriceUOMId INT
								,ysnSplit BIT
								,intPriceFixationRefId INT
								) x
						WHERE intPriceFixationId = @intPriceFixationId
					END
					ELSE
					BEGIN
						UPDATE PF
						SET intPriceContractId = (
								SELECT TOP 1 PC.intPriceContractId
								FROM tblCTPriceContract PC
								WHERE PC.intPriceContractRefId = x.intPriceContractId
								)
							,intConcurrencyId = PF.intConcurrencyId + 1
							,intContractHeaderId = (
								SELECT TOP 1 CH.intContractHeaderId
								FROM tblCTContractHeader CH
								WHERE CH.intContractHeaderRefId = x.intContractHeaderId
								)
							,intContractDetailId = (
								SELECT TOP 1 CD.intContractDetailId
								FROM tblCTContractDetail CD
								WHERE CD.intContractDetailRefId = x.intContractDetailId
								)
							--,intOriginalFutureMarketId
							--,intOriginalFutureMonthId
							,dblOriginalBasis = x.dblOriginalBasis
							,dblTotalLots = x.dblTotalLots
							,dblLotsFixed = x.dblLotsFixed
							,intLotsHedged = x.intLotsHedged
							,dblPolResult = x.dblPolResult
							,dblPremiumPoints = x.dblPremiumPoints
							,ysnAAPrice = x.ysnAAPrice
							,ysnSettlementPrice = x.ysnSettlementPrice
							,ysnToBeAgreed = x.ysnToBeAgreed
							,dblSettlementPrice = x.dblSettlementPrice
							,dblAgreedAmount = x.dblAgreedAmount
							,intAgreedItemUOMId = @intCommodityUnitMeasureId2
							,dblPolPct = x.dblPolPct
							,dblPriceWORollArb = x.dblPriceWORollArb
							,dblRollArb = x.dblRollArb
							,dblPolSummary = x.dblPolSummary
							,dblAdditionalCost = x.dblAdditionalCost
							,dblFinalPrice = x.dblFinalPrice
							,intFinalPriceUOMId = @intCommodityUnitMeasureId
							,ysnSplit = x.ysnSplit
						FROM tblCTPriceFixation PF
						JOIN OPENXML(@idoc, 'vyuIPPriceFixations/vyuIPPriceFixation', 2) WITH (
								intPriceFixationId INT
								,intPriceContractId INT
								,intConcurrencyId INT
								,intContractHeaderId INT
								,intContractDetailId INT
								,intOriginalFutureMarketId INT
								,intOriginalFutureMonthId INT
								,dblOriginalBasis NUMERIC(18, 6)
								,dblTotalLots NUMERIC(18, 6)
								,dblLotsFixed NUMERIC(18, 6)
								,intLotsHedged INT
								,dblPolResult NUMERIC(18, 6)
								,dblPremiumPoints NUMERIC(18, 6)
								,ysnAAPrice BIT
								,ysnSettlementPrice BIT
								,ysnToBeAgreed BIT
								,dblSettlementPrice NUMERIC(18, 6)
								,dblAgreedAmount NUMERIC(18, 6)
								,intAgreedItemUOMId INT
								,dblPolPct NUMERIC(18, 6)
								,dblPriceWORollArb NUMERIC(18, 6)
								,dblRollArb NUMERIC(18, 6)
								,dblPolSummary NUMERIC(18, 6)
								,dblAdditionalCost NUMERIC(18, 6)
								,dblFinalPrice NUMERIC(18, 6)
								,intFinalPriceUOMId INT
								,ysnSplit BIT
								,intPriceFixationRefId INT
								) x ON x.intPriceFixationId = PF.intPriceFixationRefId
						WHERE x.intPriceFixationId = @intPriceFixationId
					END

					SELECT @intPriceFixationId = MIN(intPriceFixationId)
					FROM @tblCTPriceFixation
					WHERE intPriceFixationId > @intPriceFixationId
				END

				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strPriceFixationDetailXML

				DELETE PFD
				FROM tblCTPriceFixationDetail PFD
				JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
				WHERE PF.intPriceContractId = @intPriceContractId
					AND NOT EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuIPPriceFixationDetails/vyuIPPriceFixationDetail', 2) WITH (intPriceFixationDetailId INT) x
						WHERE PFD.intPriceFixationDetailRefId = x.intPriceFixationDetailId
						)

				DELETE
				FROM @tblCTPriceFixationDetail

				INSERT INTO @tblCTPriceFixationDetail (intPriceFixationDetailId)
				SELECT intPriceFixationDetailId
				FROM OPENXML(@idoc, 'vyuIPPriceFixationDetails/vyuIPPriceFixationDetail', 2) WITH (intPriceFixationDetailId INT)

				SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
				FROM @tblCTPriceFixationDetail

				WHILE @intPriceFixationDetailId IS NOT NULL
				BEGIN
					SELECT @strQtyItemUOM = NULL
						,@strFutMarketName = NULL
						,@strFutureMonth = NULL
						,@strHedgeFutureMonth = NULL
						,@strBroker = NULL
						,@strAccountNumber = NULL
						,@strItemNo = NULL

					SELECT @strItemNo = strItemNo
						,@strQtyItemUOM = strQtyItemUOM
						,@strFutMarketName = strFutMarketName
						,@strFutureMonth = strFutureMonth
						,@strHedgeFutureMonth = strHedgeFutureMonth
						,@strBroker = strBroker
						,@strAccountNumber = strAccountNumber
						,@strPriceItemUOM = strPriceItemUOM
					FROM OPENXML(@idoc, 'vyuIPPriceFixationDetails/vyuIPPriceFixationDetail', 2) WITH (
							strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							,strQtyItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
							,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
							,strHedgeFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
							,strBroker NVARCHAR(100) Collate Latin1_General_CI_AS
							,strAccountNumber NVARCHAR(50) Collate Latin1_General_CI_AS
							,strPriceItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,intPriceFixationDetailId INT
							)
					WHERE intPriceFixationDetailId = @intPriceFixationDetailId

					SELECT @intItemId = NULL

					SELECT @intItemId = intItemId
					FROM tblICItem I
					WHERE I.strItemNo = @strItemNo

					IF @strItemNo IS NOT NULL
						AND @intItemId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Item ' + @strItemNo + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Item ' + @strItemNo + ' is not available.'
						END
					END

					SELECT @intUnitMeasureId = NULL

					SELECT @intUnitMeasureId = intUnitMeasureId
					FROM tblICUnitMeasure UM
					WHERE UM.strUnitMeasure = @strQtyItemUOM

					IF @strQtyItemUOM IS NOT NULL
						AND @intUnitMeasureId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Quantity UOM ' + @strFinalPriceUOM + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Quantity UOM ' + @strFinalPriceUOM + ' is not available.'
						END
					END

					SELECT @intUnitMeasureId = NULL

					SELECT @intPriceUnitMeasureId = intUnitMeasureId
					FROM tblICUnitMeasure UM
					WHERE UM.strUnitMeasure = @strPriceItemUOM

					IF @strPriceItemUOM IS NOT NULL
						AND @intPriceUnitMeasureId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Price UOM ' + @strPriceItemUOM + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Price UOM ' + @strPriceItemUOM + ' is not available.'
						END
					END

					SELECT @intFutureMarketId = NULL

					SELECT @intFutureMarketId = intFutureMarketId
					FROM tblRKFutureMarket FM
					WHERE FM.strFutMarketName = @strFutMarketName

					IF @strFutMarketName IS NOT NULL
						AND @intFutureMarketId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Future Market Name ' + @strFutMarketName + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Future Market Name ' + @strFutMarketName + ' is not available.'
						END
					END

					SELECT @intFutureMonthId = NULL

					SELECT @intFutureMonthId = MO.intFutureMonthId
					FROM tblRKFuturesMonth MO
					WHERE MO.strFutureMonth = @strFutureMonth

					IF @strFutureMonth IS NOT NULL
						AND @intFutureMonthId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Future Month ' + @strFutureMonth + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'
						END
					END

					SELECT @intHedgeFutureMonthId = MO.intFutureMonthId
					FROM tblRKFuturesMonth MO
					WHERE MO.strFutureMonth = @strHedgeFutureMonth

					IF @strHedgeFutureMonth IS NOT NULL
						AND @intHedgeFutureMonthId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Hedge Future Month ' + @strHedgeFutureMonth + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Hedge Future Month ' + @strHedgeFutureMonth + ' is not available.'
						END
					END

					SELECT @intBrokerId = Broker.intEntityId
					FROM tblEMEntity Broker
					WHERE Broker.strName = @strBroker

					IF @strBroker IS NOT NULL
						AND @intBrokerId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Broker ' + @strBroker + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Broker ' + @strBroker + ' is not available.'
						END
					END

					SELECT @intBrokerageAccountId = BrokerageAccount.intBrokerageAccountId
					FROM tblRKBrokerageAccount BrokerageAccount
					WHERE BrokerageAccount.strAccountNumber = @strAccountNumber

					IF @strAccountNumber IS NOT NULL
						AND @intBrokerageAccountId IS NULL
					BEGIN
						IF @strErrorMessage <> ''
						BEGIN
							SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Brokerage Account ' + @strAccountNumber + ' is not available.'
						END
						ELSE
						BEGIN
							SELECT @strErrorMessage = 'Brokerage Account ' + @strAccountNumber + ' is not available.'
						END
					END

					IF @strErrorMessage <> ''
					BEGIN
						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intItemUOMId = IU.intItemUOMId
					FROM tblICItemUOM IU
					WHERE IU.intItemId = @intItemId
						AND IU.intUnitMeasureId = @intUnitMeasureId

					SELECT @intPriceItemUOMId = CUM.intCommodityUnitMeasureId
					FROM tblICCommodityUnitMeasure CUM
					WHERE CUM.intUnitMeasureId = @intPriceUnitMeasureId

					IF NOT EXISTS (
							SELECT *
							FROM tblCTPriceFixationDetail
							WHERE intPriceFixationDetailRefId = @intPriceFixationDetailId
							)
					BEGIN
						INSERT INTO tblCTPriceFixationDetail (
							intPriceFixationId
							,intNumber
							,strTradeNo
							,strOrder
							,dtmFixationDate
							,dblQuantity
							,dblQuantityAppliedAndPriced
							,dblLoadAppliedAndPriced
							,dblLoadPriced
							,intQtyItemUOMId
							,dblNoOfLots
							,intFutureMarketId
							,intFutureMonthId
							,dblFixationPrice
							,dblFutures
							,dblBasis
							,dblPolRefPrice
							,dblPolPremium
							,dblCashPrice
							,intPricingUOMId
							,ysnHedge
							,ysnAA
							,dblHedgePrice
							,intHedgeFutureMonthId
							,intBrokerId
							,intBrokerageAccountId
							,intFutOptTransactionId
							,dblFinalPrice
							,strNotes
							,intPriceFixationDetailRefId
							,intBillId
							,intBillDetailId
							,intInvoiceId
							,intInvoiceDetailId
							,intConcurrencyId
							)
						SELECT (
								SELECT PF.intPriceFixationId
								FROM tblCTPriceFixation PF
								WHERE PF.intPriceFixationRefId = x.intPriceFixationId
								)
							,x.intNumber
							,x.strTradeNo
							,x.strOrder
							,x.dtmFixationDate
							,x.dblQuantity
							,x.dblQuantityAppliedAndPriced
							,x.dblLoadAppliedAndPriced
							,x.dblLoadPriced
							,@intItemUOMId
							,dblNoOfLots
							,@intFutureMarketId
							,@intFutureMonthId
							,x.dblFixationPrice
							,x.dblFutures
							,x.dblBasis
							,x.dblPolRefPrice
							,x.dblPolPremium
							,x.dblCashPrice
							,@intPriceItemUOMId
							,x.ysnHedge
							,x.ysnAA
							,x.dblHedgePrice
							,@intHedgeFutureMonthId
							,@intBrokerId
							,@intBrokerageAccountId
							,NULL intFutOptTransactionId
							,x.dblFinalPrice
							,x.strNotes
							,x.intPriceFixationDetailId
							,NULL intBillId
							,NULL intBillDetailId
							,NULL intInvoiceId
							,NULL intInvoiceDetailId
							,1 intConcurrencyId
						FROM OPENXML(@idoc, 'vyuIPPriceFixationDetails/vyuIPPriceFixationDetail', 2) WITH (
								[intPriceFixationDetailId] INT
								,[intPriceFixationId] INT
								,[intNumber] INT
								,[strTradeNo] NVARCHAR(20) COLLATE Latin1_General_CI_AS
								,[strOrder] NVARCHAR(20) COLLATE Latin1_General_CI_AS
								,[dtmFixationDate] DATETIME
								,[dblQuantity] NUMERIC(18, 6)
								,[dblQuantityAppliedAndPriced] NUMERIC(18, 6)
								,[dblLoadAppliedAndPriced] NUMERIC(18, 6)
								,[dblLoadPriced] NUMERIC(18, 6)
								,[intQtyItemUOMId] INT
								,[dblNoOfLots] NUMERIC(18, 6)
								,[intFutureMarketId] INT
								,[intFutureMonthId] INT
								,[dblFixationPrice] NUMERIC(18, 6)
								,[dblFutures] NUMERIC(18, 6)
								,[dblBasis] NUMERIC(18, 6)
								,[ysnHedge] BIT
								,[ysnAA] BIT
								,[dblHedgePrice] NUMERIC(18, 6)
								,[intHedgeFutureMonthId] INT
								,[intBrokerId] INT
								,[intBrokerageAccountId] INT
								,[intFutOptTransactionId] INT
								,[dblFinalPrice] NUMERIC(18, 6)
								,[strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS
								,[intPriceFixationDetailRefId] INT
								,[intBillId] INT
								,intBillDetailId INT
								,intInvoiceId INT
								,intInvoiceDetailId INT
								,intDailyAveragePriceDetailId INT
								,dblPolRefPrice NUMERIC(18, 6)
								,dblPolPremium NUMERIC(18, 6)
								,dblCashPrice NUMERIC(18, 6)
								) x
						WHERE intPriceFixationDetailId = @intPriceFixationDetailId
					END
					ELSE
					BEGIN
						UPDATE tblCTPriceFixationDetail
						SET intPriceFixationId = (
								SELECT PF.intPriceFixationId
								FROM tblCTPriceFixation PF
								WHERE PF.intPriceFixationRefId = x.intPriceFixationId
								)
							,intNumber = x.intNumber
							,strTradeNo = x.strTradeNo
							,strOrder = x.strOrder
							,dtmFixationDate = x.dtmFixationDate
							,dblQuantity = x.dblQuantity
							,dblQuantityAppliedAndPriced = x.dblQuantityAppliedAndPriced
							,dblLoadAppliedAndPriced = x.dblLoadAppliedAndPriced
							,dblLoadPriced = x.dblLoadPriced
							,intQtyItemUOMId = @intItemUOMId
							,dblNoOfLots = x.dblNoOfLots
							,intFutureMarketId = @intFutureMarketId
							,intFutureMonthId = @intFutureMonthId
							,dblFixationPrice = x.dblFixationPrice
							,dblFutures = x.dblFutures
							,dblBasis = x.dblBasis
							,dblPolRefPrice = x.dblPolRefPrice
							,dblPolPremium = x.dblPolPremium
							,dblCashPrice = x.dblCashPrice
							,intPricingUOMId = @intPriceItemUOMId
							,ysnHedge = x.ysnHedge
							,ysnAA = x.ysnAA
							,dblHedgePrice = x.dblHedgePrice
							,intHedgeFutureMonthId = @intHedgeFutureMonthId
							,intBrokerId = @intBrokerId
							,intBrokerageAccountId = @intBrokerageAccountId
							--,intFutOptTransactionId=intFutOptTransactionId
							,dblFinalPrice = x.dblFinalPrice
							,strNotes = x.strNotes
							--,intPriceFixationDetailRefId=intPriceFixationDetailRefId
							--,intBillId=intBillId
							--,intBillDetailId=intBillDetailId
							--,intInvoiceId=intInvoiceId
							--,intInvoiceDetailId=intInvoiceDetailId
							,intConcurrencyId = intConcurrencyId + 1
						FROM tblCTPriceFixationDetail PFD
						JOIN OPENXML(@idoc, 'vyuIPPriceFixationDetails/vyuIPPriceFixationDetail', 2) WITH (
								[intPriceFixationDetailId] INT
								,[intPriceFixationId] INT
								,[intNumber] INT
								,[strTradeNo] NVARCHAR(20) COLLATE Latin1_General_CI_AS
								,[strOrder] NVARCHAR(20) COLLATE Latin1_General_CI_AS
								,[dtmFixationDate] DATETIME
								,[dblQuantity] NUMERIC(18, 6)
								,[dblQuantityAppliedAndPriced] NUMERIC(18, 6)
								,[dblLoadAppliedAndPriced] NUMERIC(18, 6)
								,[dblLoadPriced] NUMERIC(18, 6)
								,[intQtyItemUOMId] INT
								,[dblNoOfLots] NUMERIC(18, 6)
								,[intFutureMarketId] INT
								,[intFutureMonthId] INT
								,[dblFixationPrice] NUMERIC(18, 6)
								,[dblFutures] NUMERIC(18, 6)
								,[dblBasis] NUMERIC(18, 6)
								,[ysnHedge] BIT
								,[ysnAA] BIT
								,[dblHedgePrice] NUMERIC(18, 6)
								,[intHedgeFutureMonthId] INT
								,[intBrokerId] INT
								,[intBrokerageAccountId] INT
								,[intFutOptTransactionId] INT
								,[dblFinalPrice] NUMERIC(18, 6)
								,[strNotes] NVARCHAR(100) COLLATE Latin1_General_CI_AS
								,[intPriceFixationDetailRefId] INT
								,[intBillId] INT
								,intBillDetailId INT
								,intInvoiceId INT
								,intInvoiceDetailId INT
								,intDailyAveragePriceDetailId INT
								,dblPolRefPrice NUMERIC(18, 6)
								,dblPolPremium NUMERIC(18, 6)
								,dblCashPrice NUMERIC(18, 6)
								) x ON x.intPriceFixationDetailId = PFD.intPriceFixationDetailRefId
						WHERE x.intPriceFixationDetailId = @intPriceFixationDetailId
					END

					SELECT @intPriceFixationDetailId = MIN(intPriceFixationDetailId)
					FROM @tblCTPriceFixationDetail
					WHERE intPriceFixationDetailId > @intPriceFixationDetailId
				END

				EXEC uspCTSavePriceContract @intNewPriceContractId
					,@strHedgeXML

				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strApproverXML

				SELECT @intPriceFixationId = NULL
					,@intContractHeaderId = NULL

				SELECT @intPriceFixationId = intPriceFixationId
					,@intContractHeaderId = intContractHeaderId
				FROM tblCTPriceFixation
				WHERE intPriceContractId = @intNewPriceContractId

				DELETE
				FROM tblCTIntrCompApproval
				WHERE intContractHeaderId = @intContractHeaderId
					AND intPriceFixationId = @intPriceFixationId
					AND ysnApproval=1

				INSERT INTO tblCTIntrCompApproval (
					intContractHeaderId
					,intPriceFixationId
					,strName
					,strUserName
					,strScreen
					,intConcurrencyId
					,ysnApproval
					)
				SELECT @intContractHeaderId
					,@intPriceFixationId
					,strName
					,strUserName
					,'Price Contract' strScreenName
					,1 AS intConcurrencyId
					,1
				FROM OPENXML(@idoc, 'vyuCTPriceContractApproverViews/vyuCTPriceContractApproverView', 2) WITH (
						strName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strUserName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strScreenName NVARCHAR(250) Collate Latin1_General_CI_AS
						) x

				EXEC sp_xml_removedocument @idoc

				
				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strSubmittedByXML
				DELETE
				FROM tblCTIntrCompApproval
				WHERE intContractHeaderId = @intContractHeaderId
					AND intPriceFixationId = @intPriceFixationId
					AND ysnApproval=0

				INSERT INTO tblCTIntrCompApproval (
					intContractHeaderId
					,intPriceFixationId
					,strName
					,strUserName
					,strScreen
					,intConcurrencyId
					,ysnApproval
					)
				SELECT @intContractHeaderId
					,@intPriceFixationId
					,strName
					,strUserName
					,'Price Contract' strScreenName
					,1 AS intConcurrencyId
					,0
				FROM OPENXML(@idoc, 'vyuIPPriceContractSubmittedByViews/vyuIPPriceContractSubmittedByView', 2) WITH (
						strName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strUserName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strScreenName NVARCHAR(250) Collate Latin1_General_CI_AS
						) x
				EXEC sp_xml_removedocument @idoc

				SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@intNewPriceContractId)

				EXEC uspCTGetTableDataInXML 'vyuIPPriceContractAck'
					,@strPriceContractCondition
					,@strAckPriceContractXML OUTPUT

				SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@intNewPriceContractId)

				EXEC uspCTGetTableDataInXML 'vyuIPPriceFixationAck'
					,@strPriceContractCondition
					,@strAckPriceFixationXML OUTPUT

				SELECT @strPriceFixationAllId = STUFF((
							SELECT DISTINCT ',' + LTRIM(intPriceFixationId)
							FROM tblCTPriceFixation
							WHERE intPriceContractId = @intNewPriceContractId
							FOR XML PATH('')
							), 1, 1, '')

				SELECT @strPriceFixationCondition = 'intPriceFixationId IN (' + LTRIM(@strPriceFixationAllId) + ')'

				EXEC dbo.uspCTGetTableDataInXML 'vyuIPPriceFixationDetailAck'
					,@strPriceFixationCondition
					,@strPriceFixationDetailXML OUTPUT
					,NULL
					,NULL

				INSERT INTO @config (
					strApprovalFor
					,strValue
					)
				SELECT 'Contract Type'
					,'Purchase'

				SELECT @strApprover = strApprover
				FROM tblIPMultiCompany
				WHERE intCompanyId = @intCompanyRefId

				SELECT @intCurrentUserEntityId = intEntityId
				FROM tblSMUserSecurity
				WHERE strUserName = @strApprover

				IF @intCurrentUserEntityId IS NULL
					SELECT @intCurrentUserEntityId = @intCreatedById

				EXEC uspSMSubmitTransaction @type = 'ContractManagement.view.PriceContracts'
					,@recordId = @intNewPriceContractId
					,@transactionNo = @strNewPriceContractNo
					,@transactionEntityId = @intEntityId
					,@currentUserEntityId = @intCurrentUserEntityId
					,@amount = 0
					,@approverConfiguration = @config

				x:

				SELECT @intContractScreenId = intScreenId
				FROM tblSMScreen
				WHERE strNamespace = 'ContractManagement.view.PriceContracts'

				SELECT @intTransactionRefId = intTransactionId
				FROM tblSMTransaction
				WHERE intRecordId = @intNewPriceContractId
					AND intScreenId = @intContractScreenId

				INSERT INTO tblCTPriceContractAcknowledgementStage (
					intAckPriceContractId
					,strAckPriceContracNo
					,dtmFeedDate
					,strMessage
					,strTransactionType
					,intMultiCompanyId
					,strAckPriceContractXML
					,strAckPriceFixationXML
					,strAckPriceFixationDetailXML
					,intTransactionId
					,intCompanyId
					,intTransactionRefId
					,intCompanyRefId
					)
				SELECT @intNewPriceContractId
					,@strNewPriceContractNo
					,GETDATE()
					,'Success'
					,@strTransactionType
					,@intMultiCompanyId
					,@strAckPriceContractXML
					,@strAckPriceFixationXML
					,@strAckPriceFixationDetailXML
					,@intTransactionId
					,@intCompanyId
					,@intTransactionRefId
					,@intCompanyRefId

				IF @strRowState <> 'Delete'
				BEGIN
					EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
						,@referenceTransactionId = @intTransactionId
						,@referenceCompanyId = @intCompanyId
				END

				UPDATE tblCTPriceContractStage
				SET strFeedStatus = 'Processed'
				WHERE intPriceContractStageId = @intPriceContractStageId

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

				UPDATE tblCTPriceContractStage
				SET strFeedStatus = 'Failed'
					,strMessage = @ErrMsg
				WHERE intPriceContractStageId = @intPriceContractStageId
			END CATCH
		END

		SELECT @intPriceContractStageId = MIN(intPriceContractStageId)
		FROM tblCTPriceContractStage
		WHERE intPriceContractStageId > @intPriceContractStageId
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
