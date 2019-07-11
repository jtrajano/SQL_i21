﻿CREATE PROCEDURE [dbo].[uspCTContractProcessStgXML]
	--@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intContractStageId INT
	DECLARE @intContractHeaderId INT
	DECLARE @strCustomerContract NVARCHAR(MAX)
	DECLARE @strContractNumber NVARCHAR(MAX)
	DECLARE @strNewContractNumber NVARCHAR(MAX)
	DECLARE @strHeaderXML NVARCHAR(MAX)
	DECLARE @strDetailXML NVARCHAR(MAX)
	DECLARE @strCostXML NVARCHAR(MAX)
	DECLARE @strDocumentXML NVARCHAR(MAX)
		,@strAckCertificationXML NVARCHAR(MAX)
		,@strAckConditionXML NVARCHAR(MAX)
	DECLARE @strReference NVARCHAR(MAX)
	DECLARE @strRowState NVARCHAR(MAX)
	DECLARE @strFeedStatus NVARCHAR(MAX)
	DECLARE @dtmFeedDate DATETIME
	DECLARE @strMessage NVARCHAR(MAX)
	DECLARE @intMultiCompanyId INT
	DECLARE @intEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @strTagRelaceXML NVARCHAR(MAX)
	DECLARE @NewContractHeaderId INT
	DECLARE @NewContractDetailId INT
	DECLARE @NewContractCostId INT
	DECLARE @intContractAcknowledgementStageId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
	DECLARE @strCostCondition NVARCHAR(MAX)
	DECLARE @strContractDetailAllId NVARCHAR(MAX)
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strAckCostXML NVARCHAR(MAX)
	DECLARE @strAckDocumentXML NVARCHAR(MAX)
		,@strApproverXML NVARCHAR(MAX)
	DECLARE @intCreatedById INT
		,@config AS ApprovalConfigurationType
	DECLARE @idoc INT
		,@intTransactionCount INT
		,@intContractHeaderRefId INT
	DECLARE @SQL NVARCHAR(MAX)
		,@strTblXML NVARCHAR(MAX)
		,@intNewContractHeaderId INT
		,@intContractDetailId INT
		,@intUserId INT
	DECLARE @intRecordId INT
		,@intContractSeq INT
		,@strDetailCondition NVARCHAR(50)
		,@strConditionXML NVARCHAR(MAX)
		,@strCertificationXML NVARCHAR(MAX)
		,@intToBookId INT
	DECLARE @MyTableVar TABLE (intUserId INT);
	DECLARE @strSalespersonId NVARCHAR(3)
		,@strCommodityCode NVARCHAR(50)
		,@strHeaderUnitMeasure NVARCHAR(50)
		,@strCropYear NVARCHAR(30)
		,@strPosition NVARCHAR(100)
		,@strPricingType NVARCHAR(100)
		,@strCreatedBy NVARCHAR(100)
		,@strFreightTerm NVARCHAR(100)
		,@strTerm NVARCHAR(100)
		,@strGrade NVARCHAR(100)
		,@strWeight NVARCHAR(100)
		,@strInsuranceBy NVARCHAR(30)
		,@strAssociationName NVARCHAR(100)
		,@strInvoiceType NVARCHAR(30)
		,@strArbitration NVARCHAR(50)
		,@strErrorMessage NVARCHAR(MAX)
		,@intCommodityId INT
		,@intUnitMeasureId INT
		,@intSalespersonId INT
		,@intCropYearId INT
		,@intPositionId INT
		,@intPricingTypeId INT
		,@intFreightTermId INT
		,@intTermID INT
		,@intGradeId INT
		,@intWeightId INT
		,@intAssociationId INT
		,@intCityId INT
		,@intInsuranceById INT
		,@intInvoiceTypeId INT
		,@intCommodityUnitMeasureId INT
		,@strTextCode NVARCHAR(50)
		,@intContractTextId INT
	DECLARE @intItemId INT
		--,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@intStorageScheduleRuleId INT
		,@intContractStatusId INT
		,@intPriceUnitMeasureId INT
		,@intPriceItemUOMId INT
		,@intFutureMarketId INT
		,@intFutureMonthId INT
		--,@intPricingTypeId INT
		--,@intFreightTermId INT
		,@intCurrencyID INT
		,@intLoadingPointId INT
		,@intDestinationPointId INT
		,@intDestinationCityId INT
		,@intStorageLocationId INT
		,@intCompanyLocationSubLocationId INT
		--,@strPricingType NVARCHAR(100)
		,@strFutMarketName NVARCHAR(30)
		,@strFutureMonth NVARCHAR(20)
		,@strItemNo NVARCHAR(50)
		,@strItemUOM NVARCHAR(50)
		,@strScheduleDescription NVARCHAR(MAX)
		,@strContractStatus NVARCHAR(50)
		,@strPriceUOM NVARCHAR(50)
		--,@intContractSeq INT
		--,@strFreightTerm NVARCHAR(100)
		,@strCurrency NVARCHAR(40)
		,@strLoadingPoint NVARCHAR(50)
		,@strDestinationPoint NVARCHAR(50)
		,@strDestinationCity NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strVesselStorageLocationName NVARCHAR(50)
		,@strVesselSubLocationName NVARCHAR(50)
		,@strShippingTerm NVARCHAR(64)
		,@strShippingLine NVARCHAR(100)
		,@strShipper NVARCHAR(100)
		,@intShippingLineId INT
		,@intShipperId INT
		,@intShipToEntityId INT
		,@intShipToId INT
		,@strShipToName NVARCHAR(100)
		,@strShipToLocationName NVARCHAR(50)
		,@intPurchasingGroupId INT
		,@strPurchasingGroupName NVARCHAR(150)
		,@strInvoiceCurrency NVARCHAR(40)
		,@strFXPriceUOM NVARCHAR(50)
		,@intInvoiceCurrencyId INT
		,@intFXPriceUOMId INT
		,@intFXPriceItemUOMId INT
		,@strFromCurrency NVARCHAR(40)
		,@strToCurrency NVARCHAR(40)
		,@intCurrencyExchangeRateId INT
		,@intToCurrencyId INT
		,@intFromCurrencyId INT
		,@strCurrencyExchangeRateType NVARCHAR(20)
		,@intCurrencyExchangeRateTypeId INT
		,@strShipVia NVARCHAR(100)
		,@intShipViaId INT
		,@strProducer NVARCHAR(100)
		,@intProducerId INT
		,@strUOM NVARCHAR(50)
		,@strVendorName NVARCHAR(50)
		--,@strCurrencyExchangeRateType NVARCHAR(50)
		,@intContractCostId INT
		,@intVendorId INT
	--,@intCurrencyExchangeRateTypeId INT
	,@strCountry nvarchar(100),@intCountryId int

	DECLARE @tblCTContractCost TABLE (intContractCostId INT)

	SELECT @intContractStageId = MIN(intContractStageId)
	FROM tblCTContractStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intContractStageId > 0
	BEGIN
		SET @intContractHeaderId = NULL
		SET @strContractNumber = NULL
		SET @strHeaderXML = NULL
		SET @strDetailXML = NULL
		SET @strCostXML = NULL
		SET @strDocumentXML = NULL
		SET @strReference = NULL
		SET @strRowState = NULL
		SET @strFeedStatus = NULL
		SET @dtmFeedDate = NULL
		SET @strMessage = NULL
		SET @intMultiCompanyId = NULL
		SET @intEntityId = NULL
		SET @intCompanyLocationId = NULL
		SET @strTransactionType = NULL

		SELECT @strConditionXML = NULL
			,@strCertificationXML = NULL
			,@intToBookId = NULL

		SELECT @intContractHeaderId = intContractHeaderId
			,@strContractNumber = strContractNumber
			,@strCustomerContract = strContractNumber
			,@strHeaderXML = strHeaderXML
			,@strDetailXML = strDetailXML
			,@strCostXML = strCostXML
			,@strDocumentXML = strDocumentXML
			,@strConditionXML = strConditionXML
			,@strCertificationXML = strCertificationXML
			,@strApproverXML = strApproverXML
			,@strReference = strReference
			,@strRowState = strRowState
			,@strFeedStatus = strFeedStatus
			,@dtmFeedDate = dtmFeedDate
			,@strMessage = strMessage
			,@intMultiCompanyId = intMultiCompanyId
			,@intEntityId = intEntityId
			,@intCompanyLocationId = intCompanyLocationId
			,@strTransactionType = strTransactionType
			,@intToBookId = intToBookId
		FROM tblCTContractStage
		WHERE intContractStageId = @intContractStageId

		IF @strTransactionType = 'Sales Contract'
			AND @strRowState = 'Added'
		BEGIN
			------------------Header------------------------------------------------------
			EXEC uspCTGetStartingNumber 'SaleContract'
				,@strNewContractNumber OUTPUT

			SET @strHeaderXML = REPLACE(@strHeaderXML, @strContractNumber, @strNewContractNumber)
			SET @strHeaderXML = REPLACE(@strHeaderXML, 'intCompanyId>', 'CompanyId>')

			EXEC uspCTInsertINTOTableFromXML 'tblCTContractHeader'
				,@strHeaderXML
				,@NewContractHeaderId OUTPUT

			UPDATE tblCTContractHeader
			SET intContractTypeId = 2
				,intEntityId = @intEntityId
				,intContractHeaderRefId = @intContractHeaderId
				,dtmCreated = GETDATE()
				,strCustomerContract = @strCustomerContract
			WHERE intContractHeaderId = @NewContractHeaderId

			INSERT INTO tblCTContractAcknowledgementStage (
				intContractHeaderId
				,strContractAckNumber
				,dtmFeedDate
				,strMessage
				,strTransactionType
				,intMultiCompanyId
				)
			SELECT @NewContractHeaderId
				,@strNewContractNumber
				,GETDATE()
				,'Success'
				,@strTransactionType
				,@intMultiCompanyId

			SELECT @intContractAcknowledgementStageId = SCOPE_IDENTITY();

			SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)

			EXEC uspCTGetTableDataInXML 'tblCTContractHeader'
				,@strHeaderCondition
				,@strAckHeaderXML OUTPUT

			UPDATE tblCTContractAcknowledgementStage
			SET strAckHeaderXML = @strAckHeaderXML
			WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId

			-----------------------------------Detail-------------------------------------------
			SET @strTagRelaceXML = NULL
			SET @strTagRelaceXML = '<root>
																	<tags>
																		<toFind>&lt;intContractHeaderId&gt;' + LTRIM(@intContractHeaderId) + '&lt;/intContractHeaderId&gt;</toFind>
																		<toReplace>&lt;intContractHeaderId&gt;' + LTRIM(@NewContractHeaderId) + '&lt;/intContractHeaderId&gt;</toReplace>
																	</tags>
																</root>'
			SET @strDetailXML = REPLACE(@strDetailXML, 'intContractDetailId', 'intContractDetailRefId')

			EXEC uspCTInsertINTOTableFromXML 'tblCTContractDetail'
				,@strDetailXML
				,@NewContractDetailId OUTPUT
				,@strTagRelaceXML

			UPDATE tblCTContractDetail
			SET intCompanyLocationId = @intCompanyLocationId
				,dtmCreated = GETDATE()
			WHERE intContractHeaderId = @NewContractHeaderId

			SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)

			EXEC uspCTGetTableDataInXML 'tblCTContractDetail'
				,@strHeaderCondition
				,@strAckDetailXML OUTPUT

			UPDATE tblCTContractAcknowledgementStage
			SET strAckDetailXML = @strAckDetailXML
			WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId

			-----------------------------------------Cost-------------------------------------------
			DECLARE @tblDetailId AS TABLE (
				intRowNo INT IDENTITY
				,intDetailId INT
				)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strCostXML

			INSERT INTO @tblDetailId (intDetailId)
			SELECT DISTINCT intContractDetailId
			FROM OPENXML(@idoc, 'tblCTContractCosts/tblCTContractCost', 2) WITH (intContractDetailId INT)

			DECLARE @strCostReplaceXml NVARCHAR(max) = ''

			SELECT @strCostReplaceXml = @strCostReplaceXml + '<tags>' + '<toFind>&lt;intContractDetailId&gt;' + LTRIM(t1.intDetailId) + '&lt;/intContractDetailId&gt;</toFind>' + '<toReplace>&lt;intContractDetailId&gt;' + LTRIM(t1.intContractDetailId) + '&lt;/intContractDetailId&gt;</toReplace>' + '</tags>'
			FROM (
				SELECT t.intContractDetailId
					,td.intDetailId
				FROM (
					SELECT ROW_NUMBER() OVER (
							ORDER BY intContractDetailId
							) intRowNo
						,*
					FROM tblCTContractDetail cd
					WHERE cd.intContractHeaderId = @NewContractHeaderId
					) t
				JOIN @tblDetailId td ON t.intRowNo = td.intRowNo
				) t1

			SET @strCostReplaceXml = '<root>' + @strCostReplaceXml + '</root>'
			SET @strCostXML = REPLACE(@strCostXML, 'intContractCostId', 'intContractCostRefId')

			EXEC uspCTInsertINTOTableFromXML 'tblCTContractCost'
				,@strCostXML
				,@NewContractCostId OUTPUT
				,@strCostReplaceXml

			SELECT @strContractDetailAllId = STUFF((
						SELECT DISTINCT ',' + LTRIM(intContractDetailId)
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @NewContractHeaderId
						FOR XML PATH('')
						), 1, 1, '')

			SELECT @strCostCondition = 'intContractDetailId IN (' + LTRIM(@strContractDetailAllId) + ')'

			EXEC uspCTGetTableDataInXML 'tblCTContractCost'
				,@strCostCondition
				,@strAckCostXML OUTPUT

			UPDATE tblCTContractAcknowledgementStage
			SET strAckCostXML = @strAckCostXML
			WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId

			------------------------------------------------------------Document-----------------------------------------------------
			SET @strTagRelaceXML = NULL
			SET @strTagRelaceXML = '<root>
																	<tags>
																		<toFind>&lt;intContractHeaderId&gt;' + LTRIM(@intContractHeaderId) + '&lt;/intContractHeaderId&gt;</toFind>
																		<toReplace>&lt;intContractHeaderId&gt;' + LTRIM(@NewContractHeaderId) + '&lt;/intContractHeaderId&gt;</toReplace>
																	</tags>
																</root>'
			SET @strDocumentXML = REPLACE(@strDocumentXML, 'intContractDocumentId', 'intContractDocumentRefId')

			EXEC uspCTInsertINTOTableFromXML 'tblCTContractDocument'
				,@strDocumentXML
				,@NewContractDetailId OUTPUT
				,@strTagRelaceXML

			EXEC uspCTGetTableDataInXML 'tblCTContractDocument'
				,@strHeaderCondition
				,@strAckDocumentXML OUTPUT

			UPDATE tblCTContractAcknowledgementStage
			SET strAckDocumentXML = @strAckDocumentXML
			WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId

			----------------------------CALL Stored procedure for APPROVAL -----------------------------------------------------------
			SELECT @intCreatedById = intCreatedById
			FROM tblCTContractHeader
			WHERE intContractHeaderId = @NewContractHeaderId

			INSERT INTO @config (
				strApprovalFor
				,strValue
				)
			SELECT 'Contract Type'
				,'Sale'

			EXEC uspSMSubmitTransaction @type = 'ContractManagement.view.Contract'
				,@recordId = @NewContractHeaderId
				,@transactionNo = @strNewContractNumber
				,@transactionEntityId = @intEntityId
				,@currentUserEntityId = @intCreatedById
				,@amount = 0
				,@approverConfiguration = @config

			--------------------------------------------------------------------------------------------------------------------------
			UPDATE tblCTContractStage
			SET strFeedStatus = 'Processed'
			WHERE intContractStageId = @intContractStageId
		END

		IF @strTransactionType = 'Purchase Contract'
		BEGIN
			BEGIN TRY
				SELECT @intContractHeaderRefId = @intContractHeaderId

				SELECT @intTransactionCount = @@TRANCOUNT

				IF @intTransactionCount = 0
					BEGIN TRANSACTION

				------------------Header------------------------------------------------------
				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strHeaderXML

				IF OBJECT_ID('tempdb..#tmpContractHeader') IS NOT NULL
					DROP TABLE #tmpContractHeader

				SELECT *
				INTO #tmpContractHeader
				FROM tblCTContractHeader
				WHERE 1 = 2

				SELECT @SQL = STUFF((
							SELECT ' ALTER TABLE #tmpContractHeader ALTER COLUMN ' + COLUMN_NAME + ' ' + DATA_TYPE + CASE 
									WHEN DATA_TYPE LIKE '%varchar'
										THEN '(' + LTRIM(CHARACTER_MAXIMUM_LENGTH) + ')'
									WHEN DATA_TYPE = 'numeric'
										THEN '(' + LTRIM(NUMERIC_PRECISION) + ',' + LTRIM(NUMERIC_SCALE) + ')'
									ELSE ''
									END + ' NULL'
							FROM tempdb.INFORMATION_SCHEMA.COLUMNS
							WHERE TABLE_NAME LIKE '#tmpContractHeader%'
								AND IS_NULLABLE = 'NO'
								AND COLUMN_NAME <> 'intContractHeaderId'
							FOR XML path('')
							), 1, 1, '')

				EXEC sp_executesql @SQL

				IF OBJECT_ID('tempdb..#tmpContractDetail') IS NOT NULL
					DROP TABLE #tmpContractDetail

				SELECT *
				INTO #tmpContractDetail
				FROM tblCTContractDetail
				WHERE 1 = 2

				IF OBJECT_ID('tempdb..#tmpDeletedContractDetail') IS NOT NULL
					DROP TABLE #tmpDeletedContractDetail

				SELECT *
				INTO #tmpDeletedContractDetail
				FROM tblCTContractDetail
				WHERE 1 = 2

				IF OBJECT_ID('tempdb..#tmpContractCost') IS NOT NULL
					DROP TABLE #tmpContractCost

				SELECT *
				INTO #tmpContractCost
				FROM tblCTContractCost
				WHERE 1 = 2

				SELECT @SQL = STUFF((
							SELECT ' ALTER TABLE #tmpContractDetail ALTER COLUMN ' + COLUMN_NAME + ' ' + DATA_TYPE + CASE 
									WHEN DATA_TYPE LIKE '%varchar'
										THEN '(' + LTRIM(CHARACTER_MAXIMUM_LENGTH) + ')'
									WHEN DATA_TYPE = 'numeric'
										THEN '(' + LTRIM(NUMERIC_PRECISION) + ',' + LTRIM(NUMERIC_SCALE) + ')'
									ELSE ''
									END + ' NULL'
							FROM tempdb.INFORMATION_SCHEMA.COLUMNS
							WHERE TABLE_NAME LIKE '#tmpContractDetail%'
								AND IS_NULLABLE = 'NO'
								AND COLUMN_NAME <> 'intContractDetailId'
							FOR XML path('')
							), 1, 1, '')

				EXEC sp_executesql @SQL

				DELETE
				FROM @MyTableVar

				SELECT @strSalespersonId = NULL
					,@strCommodityCode = NULL
					,@strHeaderUnitMeasure = NULL
					,@strCropYear = NULL
					,@strPosition = NULL
					,@strPricingType = NULL
					,@strCreatedBy = NULL
					,@strFreightTerm = NULL
					,@strTerm = NULL
					,@strGrade = NULL
					,@strWeight = NULL
					,@strInsuranceBy = NULL
					,@strAssociationName = NULL
					,@strInvoiceType = NULL
					,@strArbitration = NULL
					,@strTextCode = NULL
					,@strCountry=NULL

				SELECT @strSalespersonId = strSalespersonId
					,@strCommodityCode = strCommodityCode
					,@strHeaderUnitMeasure = strHeaderUnitMeasure
					,@strCropYear = strCropYear
					,@strPosition = strPosition
					,@strPricingType = strPricingType
					,@strCreatedBy = strCreatedBy
					,@strFreightTerm = strFreightTerm
					,@strTerm = strTerm
					,@strGrade = strGrade
					,@strWeight = strWeight
					,@strInsuranceBy = strInsuranceBy
					,@strAssociationName = strAssociationName
					,@strInvoiceType = strInvoiceType
					,@strArbitration = strArbitration
					,@strTextCode = strTextCode
					,@strCountry=strCountry
				FROM OPENXML(@idoc, 'vyuCTContractHeaderViews/vyuCTContractHeaderView', 2) WITH (
						strSalespersonId NVARCHAR(3) Collate Latin1_General_CI_AS
						,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strHeaderUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,strCropYear NVARCHAR(30) Collate Latin1_General_CI_AS
						,strPosition NVARCHAR(100) Collate Latin1_General_CI_AS
						,strPricingType NVARCHAR(100) Collate Latin1_General_CI_AS
						,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
						,strFreightTerm NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTerm NVARCHAR(100) Collate Latin1_General_CI_AS
						,strGrade NVARCHAR(100) Collate Latin1_General_CI_AS
						,strWeight NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInsuranceBy NVARCHAR(30) Collate Latin1_General_CI_AS
						,strAssociationName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInvoiceType NVARCHAR(30) Collate Latin1_General_CI_AS
						,strArbitration NVARCHAR(50) Collate Latin1_General_CI_AS
						,strTextCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strCountry NVARCHAR(100) Collate Latin1_General_CI_AS
						) x

				IF @strCommodityCode IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICCommodity C
						WHERE C.strCommodityCode = @strCommodityCode
						)
				BEGIN
					SELECT @strErrorMessage = 'Commodity ' + @strCommodityCode + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strHeaderUnitMeasure IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure U2
						WHERE U2.strUnitMeasure = @strHeaderUnitMeasure
						)
				BEGIN
					SELECT @strErrorMessage = 'Unit Measure ' + @strHeaderUnitMeasure + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strSalespersonId IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblARSalesperson SP
						WHERE SP.strSalespersonId = @strSalespersonId
						)
				BEGIN
					SELECT @strErrorMessage = 'Sales person ' + @strSalespersonId + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCropYear IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTCropYear YR
						WHERE YR.strCropYear = @strCropYear
						)
				BEGIN
					SELECT @strErrorMessage = 'Crop Year ' + @strCropYear + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPosition IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTPosition PO
						WHERE PO.strPosition = @strPosition
						)
				BEGIN
					SELECT @strErrorMessage = 'Position ' + @strPosition + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPricingType IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTPricingType PT
						WHERE PT.strPricingType = @strPricingType
						)
				BEGIN
					SELECT @strErrorMessage = 'Pricing Type ' + @strPricingType + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCreatedBy IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblEMEntity CE
						JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
						WHERE ET1.strType = 'User'
							AND CE.strName = @strCreatedBy
							AND CE.strEntityNo <> ''
						)
				BEGIN
					SELECT @strErrorMessage = 'User ' + @strCreatedBy + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strFreightTerm IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMFreightTerms FT
						WHERE FT.strFreightTerm = @strFreightTerm
						)
				BEGIN
					SELECT @strErrorMessage = 'Freight Terms ' + @strFreightTerm + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strTerm IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMTerm T
						WHERE T.strTerm = @strTerm
						)
				BEGIN
					SELECT @strErrorMessage = 'Term ' + @strTerm + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strGrade IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTWeightGrade W1
						WHERE W1.strWeightGradeDesc = @strGrade
						)
				BEGIN
					SELECT @strErrorMessage = 'Weight Grade ' + @strGrade + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strWeight IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTWeightGrade W2
						WHERE W2.strWeightGradeDesc = @strWeight
						)
				BEGIN
					SELECT @strErrorMessage = 'Weight Grade ' + @strWeight + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strAssociationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTAssociation AN
						WHERE AN.strName = @strAssociationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Association ' + @strAssociationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strArbitration IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCity AB
						WHERE AB.strCity = @strArbitration
						)
				BEGIN
					SELECT @strErrorMessage = 'City ' + @strArbitration + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END
				SELECT @intCountryId=NULL
				SELECT @intCountryId=intCountryID
						FROM tblSMCountry C
						WHERE C.strCountry = @strCountry

						If @strCountry is not null and @intCountryId is null
						BEGIN
					SELECT @strErrorMessage = 'Country ' + @strCountry + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCommodityId = NULL

				SELECT @intUnitMeasureId = NULL

				SELECT @intSalespersonId = NULL

				SELECT @intCropYearId = NULL

				SELECT @intPositionId = NULL

				SELECT @intPricingTypeId = NULL

				SELECT @intInsuranceById = NULL

				SELECT @intInvoiceTypeId = NULL

				SELECT @intUserId = NULL

				SELECT @intFreightTermId = NULL

				SELECT @intTermID = NULL

				SELECT @intGradeId = NULL

				SELECT @intWeightId = NULL

				SELECT @intAssociationId = NULL

				SELECT @intCityId = NULL

				SELECT @intCommodityUnitMeasureId = NULL

				SELECT @intCommodityId = intCommodityId
				FROM tblICCommodity C
				WHERE C.strCommodityCode = @strCommodityCode

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure U2
				WHERE U2.strUnitMeasure = @strHeaderUnitMeasure

				SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
				FROM tblICCommodityUnitMeasure CM
				WHERE CM.intUnitMeasureId = @intUnitMeasureId
					AND CM.intCommodityId = @intCommodityId

				SELECT @intSalespersonId = intEntityId
				FROM tblARSalesperson SP
				WHERE SP.strSalespersonId = @strSalespersonId

				SELECT @intCropYearId = intCropYearId
				FROM tblCTCropYear YR
				WHERE YR.strCropYear = @strCropYear

				SELECT @intPositionId = intPositionId
				FROM tblCTPosition PO
				WHERE PO.strPosition = @strPosition

				SELECT @intPricingTypeId = intPricingTypeId
				FROM tblCTPricingType PT
				WHERE PT.strPricingType = @strPricingType

				SELECT @intInsuranceById = intInsuranceById
				FROM tblCTInsuranceBy IB
				WHERE IB.strInsuranceBy = @strInsuranceBy

				SELECT @intInvoiceTypeId = intInvoiceTypeId
				FROM tblCTInvoiceType IT
				WHERE IT.strInvoiceType = @strInvoiceType

				SELECT @intUserId = CE.intEntityId
				FROM tblEMEntity CE
				JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
				WHERE ET1.strType = 'User'
					AND CE.strName = @strCreatedBy
					AND CE.strEntityNo <> ''

				SELECT @intFreightTermId = intFreightTermId
				FROM tblSMFreightTerms FT
				WHERE FT.strFreightTerm = @strFreightTerm

				SELECT @intTermID = intTermID
				FROM tblSMTerm T
				WHERE T.strTerm = @strTerm

				SELECT @intGradeId = intWeightGradeId
				FROM tblCTWeightGrade W1
				WHERE W1.strWeightGradeDesc = @strGrade

				SELECT @intWeightId = intWeightGradeId
				FROM tblCTWeightGrade W2
				WHERE W2.strWeightGradeDesc = @strWeight

				SELECT @intAssociationId = intAssociationId
				FROM tblCTAssociation AN
				WHERE AN.strName = @strAssociationName

				SELECT @intCityId = intCityId
				FROM tblSMCity AB
				WHERE AB.strCity = @strArbitration

				IF NOT EXISTS (
						SELECT *
						FROM tblCTContractText CT
						WHERE CT.strTextCode = @strTextCode
						)
					AND @strTextCode <> ''
				BEGIN
					INSERT INTO tblCTContractText (
						strTextCode
						,strTextDescription
						,intConcurrencyId
						,intContractPriceType
						,intContractType
						,ysnActive
						)
					SELECT @strTextCode
						,@strTextCode
						,1
						,@intPricingTypeId
						,(
							SELECT TOP 1 intContractTypeId
							FROM tblCTContractType
							WHERE strContractType = 'Purchase'
							)
						,1
				END

				SELECT @intContractTextId = intContractTextId
				FROM tblCTContractText CT
				WHERE CT.strTextCode = @strTextCode

				IF @strRowState <> 'Delete'
				BEGIN
					IF NOT EXISTS (
							SELECT *
							FROM tblCTContractHeader
							WHERE intContractHeaderRefId = @intContractHeaderRefId
							)
					BEGIN
						SELECT @strRowState = 'Added'

						EXEC uspCTGetStartingNumber 'PurchaseContract'
							,@strNewContractNumber OUTPUT
					END
					ELSE
					BEGIN
						SELECT @strRowState = 'Modified'

						SELECT @strNewContractNumber = strContractNumber
						FROM tblCTContractHeader
						WHERE intContractHeaderRefId = @intContractHeaderRefId
					END
				END

				INSERT INTO #tmpContractHeader (
					intContractTypeId
					,intEntityId
					,dtmContractDate
					,intCommodityId
					,intCommodityUOMId
					,dblQuantity
					,intSalespersonId
					,ysnSigned
					,dtmSigned
					,strContractNumber
					,ysnPrinted
					,intCropYearId
					,intPositionId
					,intPricingTypeId
					,intCreatedById
					,dtmCreated
					,intConcurrencyId
					,strCustomerContract
					,intContractHeaderRefId
					,intFreightTermId
					,intTermId
					,intContractTextId
					,intGradeId
					,intWeightId
					,intInsuranceById
					,intBookId
					,strInternalComment
					,strPrintableRemarks
					,dblTolerancePct
					,dblProvisionalInvoicePct
					,ysnSubstituteItem
					,ysnUnlimitedQuantity
					,ysnMaxPrice
					,ysnProvisional
					,ysnLoad
					,intNoOfLoad
					,dblQuantityPerLoad
					,ysnCategory
					,ysnMultiplePriceFixation
					,dblFutures
					,dblNoOfLots
					,ysnClaimsToProducer
					,ysnRiskToProducer
					,ysnExported
					,dtmExported
					,ysnMailSent
					,ysnBrokerage
					,strAmendmentLog
					,ysnBestPriceOnly
					,strReportTo
					,intAssociationId
					,intInvoiceTypeId
					,intArbitrationId
					,intCountryId
					,ysnReceivedSignedFixationLetter
					)
				OUTPUT INSERTED.intEntityId
				INTO @MyTableVar
				SELECT 1 AS intContractTypeId
					,@intEntityId
					,dtmContractDate
					,@intCommodityId
					,@intCommodityUnitMeasureId
					,dblHeaderQuantity
					,@intSalespersonId
					,ysnSigned
					,dtmSigned
					,@strNewContractNumber
					,ysnPrinted
					,@intCropYearId
					,@intPositionId
					,@intPricingTypeId
					,@intUserId
					,GETDATE()
					,1 intConcurrencyId
					,@strCustomerContract
					,@intContractHeaderRefId
					,@intFreightTermId
					,@intTermID
					,@intContractTextId
					,@intGradeId
					,@intWeightId
					,@intInsuranceById
					,@intToBookId
					,strInternalComment
					,strPrintableRemarks
					,dblTolerancePct
					,dblProvisionalInvoicePct
					,ysnSubstituteItem
					,ysnUnlimitedQuantity
					,ysnMaxPrice
					,ysnProvisional
					,ysnLoad
					,intNoOfLoad
					,dblQuantityPerLoad
					,ysnCategory
					,ysnMultiplePriceFixation
					,dblFutures
					,dblNoOfLots
					,ysnClaimsToProducer
					,ysnRiskToProducer
					,ysnExported
					,dtmExported
					,ysnMailSent
					,ysnBrokerage
					,strAmendmentLog
					,ysnBestPriceOnly
					,strReportTo
					,@intAssociationId
					,@intInvoiceTypeId
					,@intCityId
					,@intCountryId
					,IsNULL(ysnReceivedSignedFixationLetter,0)
				FROM OPENXML(@idoc, 'vyuCTContractHeaderViews/vyuCTContractHeaderView', 2) WITH (
						strEntityName NVARCHAR(100) Collate Latin1_General_CI_AS
						,dtmContractDate DATETIME
						,dblHeaderQuantity NUMERIC(18, 6)
						,strSalespersonId NVARCHAR(3) Collate Latin1_General_CI_AS
						,ysnSigned BIT
						,dtmSigned DATETIME
						,ysnPrinted BIT
						,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strHeaderUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,strCropYear NVARCHAR(30) Collate Latin1_General_CI_AS
						,strPosition NVARCHAR(100) Collate Latin1_General_CI_AS
						,strPricingType NVARCHAR(100) Collate Latin1_General_CI_AS
						,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
						,strFreightTerm NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTerm NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTextCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strGrade NVARCHAR(100) Collate Latin1_General_CI_AS
						,strWeight NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInsuranceBy NVARCHAR(30) Collate Latin1_General_CI_AS
						,strInternalComment NVARCHAR(MAX) Collate Latin1_General_CI_AS
						,strPrintableRemarks NVARCHAR(MAX) Collate Latin1_General_CI_AS
						,dblTolerancePct NUMERIC(18, 6)
						,dblProvisionalInvoicePct NUMERIC(18, 6)
						,ysnSubstituteItem BIT
						,ysnUnlimitedQuantity BIT
						,ysnMaxPrice BIT
						,ysnProvisional BIT
						,ysnLoad BIT
						,intNoOfLoad INT
						,dblQuantityPerLoad NUMERIC(18, 6)
						,ysnCategory BIT
						,ysnMultiplePriceFixation BIT
						,dblFutures NUMERIC(18, 6)
						,dblNoOfLots NUMERIC(18, 6)
						,ysnClaimsToProducer BIT
						,ysnRiskToProducer BIT
						,ysnExported BIT
						,dtmExported DATETIME
						,ysnMailSent BIT
						,ysnBrokerage BIT
						,strAmendmentLog NVARCHAR(MAX) Collate Latin1_General_CI_AS
						,ysnBestPriceOnly BIT
						,strReportTo NVARCHAR(10) Collate Latin1_General_CI_AS
						,strAssociationName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInvoiceType NVARCHAR(30) Collate Latin1_General_CI_AS
						,strArbitration NVARCHAR(50) Collate Latin1_General_CI_AS
						,ysnReceivedSignedFixationLetter BIT
						) x

				EXEC uspCTGetTableDataInXML '#tmpContractHeader'
					,NULL
					,@strTblXML OUTPUT
					,'tblCTContractHeader'

				EXEC uspCTValidateContractHeader @strTblXML
					,@strRowState

				IF @strRowState = 'Delete'
				BEGIN
					DELETE
					FROM tblCTContractHeader
					WHERE intContractHeaderRefId = @intContractHeaderRefId

					GOTO ext
				END

				IF @strRowState = 'Added'
				BEGIN
					EXEC uspCTInsertINTOTableFromXML 'tblCTContractHeader'
						,@strTblXML
						,@intNewContractHeaderId OUTPUT
				END

				IF @strRowState = 'Modified'
				BEGIN
					UPDATE CH
					SET CH.intContractTypeId = CH1.intContractTypeId
						,CH.intEntityId = CH1.intEntityId
						,CH.dtmContractDate = CH1.dtmContractDate
						,CH.intCommodityId = CH1.intCommodityId
						,CH.intCommodityUOMId = CH1.intCommodityUOMId
						,CH.dblQuantity = CH1.dblQuantity
						,CH.intSalespersonId = CH1.intSalespersonId
						,CH.ysnSigned = CH1.ysnSigned
						,CH.ysnPrinted = CH1.ysnPrinted
						,CH.intCropYearId = CH1.intCropYearId
						,CH.intPositionId = CH1.intPositionId
						,CH.intPricingTypeId = CH1.intPricingTypeId
						,CH.intCreatedById = CH1.intCreatedById
						,CH.dtmCreated = CH1.dtmCreated
						,CH.intConcurrencyId = CH.intConcurrencyId + 1
						,CH.strCustomerContract = CH1.strCustomerContract
						,CH.intContractHeaderRefId = CH1.intContractHeaderRefId
						,CH.intFreightTermId = CH1.intFreightTermId
						,CH.intTermId = CH1.intTermId
						,CH.intContractTextId = CH1.intContractTextId
						,CH.intGradeId = CH1.intGradeId
						,CH.intWeightId = CH1.intWeightId
						,CH.intInsuranceById = CH1.intInsuranceById
						,CH.intBookId = CH1.intBookId
						,CH.strInternalComment = CH1.strInternalComment
						,CH.strPrintableRemarks = CH1.strPrintableRemarks
						,CH.dblTolerancePct = CH1.dblTolerancePct
						,CH.dblProvisionalInvoicePct = CH1.dblProvisionalInvoicePct
						,CH.ysnSubstituteItem = CH1.ysnSubstituteItem
						,CH.ysnUnlimitedQuantity = CH1.ysnUnlimitedQuantity
						,CH.ysnMaxPrice = CH1.ysnMaxPrice
						,CH.ysnProvisional = CH1.ysnProvisional
						,CH.ysnLoad = CH1.ysnLoad
						,CH.intNoOfLoad = CH1.intNoOfLoad
						,CH.dblQuantityPerLoad = CH1.dblQuantityPerLoad
						,CH.ysnCategory = CH1.ysnCategory
						,CH.ysnMultiplePriceFixation = CH1.ysnMultiplePriceFixation
						,CH.dblFutures = CH1.dblFutures
						,CH.dblNoOfLots = CH1.dblNoOfLots
						,CH.ysnClaimsToProducer = CH1.ysnClaimsToProducer
						,CH.ysnRiskToProducer = CH1.ysnRiskToProducer
						,CH.ysnExported = CH1.ysnExported
						,CH.dtmExported = CH1.dtmExported
						,CH.ysnMailSent = CH1.ysnMailSent
						,CH.ysnBrokerage = CH1.ysnBrokerage
						,CH.strAmendmentLog = CH1.strAmendmentLog
						,CH.ysnBestPriceOnly = CH1.ysnBestPriceOnly
						,CH.strReportTo = CH1.strReportTo
						,CH.intAssociationId = CH1.intAssociationId
						,CH.intInvoiceTypeId = CH1.intInvoiceTypeId
						,CH.intArbitrationId = CH1.intArbitrationId
						,CH.intCountryId = CH1.intCountryId
					FROM tblCTContractHeader CH
					JOIN #tmpContractHeader CH1 ON CH.intContractHeaderRefId = CH1.intContractHeaderRefId
					WHERE CH.intContractHeaderRefId = @intContractHeaderRefId

					SELECT @intNewContractHeaderId = intContractHeaderId
					FROM tblCTContractHeader
					WHERE intContractHeaderRefId = @intContractHeaderRefId
				END

				SELECT @intUserId = intUserId
				FROM @MyTableVar

				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strDetailXML

				DECLARE @tblCTContractDetail TABLE (intContractSeq INT)

				INSERT INTO @tblCTContractDetail (intContractSeq)
				SELECT intContractSeq
				FROM OPENXML(@idoc, 'vyuIPContractDetailViews/vyuIPContractDetailView', 2) WITH (intContractSeq INT)

				SELECT @intContractSeq = MIN(intContractSeq)
				FROM @tblCTContractDetail

				WHILE @intContractSeq IS NOT NULL
				BEGIN
					SELECT @strPricingType = NULL
						,@strFutMarketName = NULL
						,@strFutureMonth = NULL
						,@strItemNo = NULL
						,@strItemUOM = NULL
						,@strScheduleDescription = NULL
						,@strContractStatus = NULL
						,@strPriceUOM = NULL
						,@strFreightTerm = NULL
						,@strCurrency = NULL
						,@strLoadingPoint = NULL
						,@strDestinationPoint = NULL
						,@strDestinationCity = NULL
						,@strStorageLocationName = NULL
						,@strSubLocationName = NULL
						,@strVesselStorageLocationName = NULL
						,@strVesselSubLocationName = NULL
						,@strShippingTerm = NULL
						,@strShippingLine = NULL
						,@strShipper = NULL
						,@strShipToName = NULL
						,@strShipToLocationName = NULL
						,@strPurchasingGroupName = NULL
						,@strInvoiceCurrency = NULL
						,@strFXPriceUOM = NULL
						,@strFromCurrency = NULL
						,@strToCurrency = NULL
						,@strCurrencyExchangeRateType = NULL
						,@strShipVia = NULL
						,@strProducer = NULL

					SELECT @strPricingType = strPricingType
						,@strFutMarketName = strFutMarketName
						,@strFutureMonth = strFutureMonth
						,@strItemNo = strItemNo
						,@strItemUOM = strItemUOM
						,@strScheduleDescription = strScheduleDescription
						,@strContractStatus = strContractStatus
						,@strPriceUOM = strPriceUOM
						,@strFreightTerm = strFreightTerm
						,@strCurrency = strCurrency
						,@strLoadingPoint = strLoadingPoint
						,@strDestinationPoint = strDestinationPoint
						,@strDestinationCity = strDestinationCity
						--,@strStorageLocationName = strStorageLocationName
						--,@strSubLocationName = strSubLocationName
						,@strVesselStorageLocationName = strVesselStorageLocationName
						,@strVesselSubLocationName = strVesselSubLocationName
						,@strShippingTerm = strShippingTerm
						,@strShippingLine = strShippingLine
						,@strShipper = strShipper
						,@strShipToName = strShipToName
						,@strShipToLocationName = strShipToLocationName
						,@strPurchasingGroupName = strPurchasingGroupName
						,@strInvoiceCurrency = strInvoiceCurrency
						,@strFXPriceUOM = strFXPriceUOM
						,@strFromCurrency = strFromCurrency
						,@strToCurrency = strToCurrency
						,@strCurrencyExchangeRateType = strCurrencyExchangeRateType
						,@strShipVia = strShipVia
						,@strProducer = strProducer
					FROM OPENXML(@idoc, 'vyuIPContractDetailViews/vyuIPContractDetailView', 2) WITH (
							strPricingType NVARCHAR(100) Collate Latin1_General_CI_AS
							,strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
							,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
							,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							,strItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strScheduleDescription NVARCHAR(MAX) Collate Latin1_General_CI_AS
							,strContractStatus NVARCHAR(50) Collate Latin1_General_CI_AS
							,strPriceUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,intContractSeq INT
							,strFreightTerm NVARCHAR(100) Collate Latin1_General_CI_AS
							,strCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
							,strLoadingPoint NVARCHAR(50) Collate Latin1_General_CI_AS
							,strDestinationPoint NVARCHAR(50) Collate Latin1_General_CI_AS
							,strDestinationCity NVARCHAR(50) Collate Latin1_General_CI_AS
							--,strStorageLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							--,strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strVesselStorageLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strVesselSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strShippingTerm NVARCHAR(64) Collate Latin1_General_CI_AS
							,strShippingLine NVARCHAR(100) Collate Latin1_General_CI_AS
							,strShipper NVARCHAR(100) Collate Latin1_General_CI_AS
							,strShipToName NVARCHAR(100) Collate Latin1_General_CI_AS
							,strShipToLocationName NVARCHAR(100) Collate Latin1_General_CI_AS
							,strPurchasingGroupName NVARCHAR(150) Collate Latin1_General_CI_AS
							,strInvoiceCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
							,strFXPriceUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strFromCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
							,strToCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
							,strCurrencyExchangeRateType NVARCHAR(20) Collate Latin1_General_CI_AS
							,strShipVia NVARCHAR(100) Collate Latin1_General_CI_AS
							,strProducer NVARCHAR(100) Collate Latin1_General_CI_AS
							) x
					WHERE intContractSeq = @intContractSeq

					IF @strItemNo IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblICItem I
							WHERE I.strItemNo = @strItemNo
							)
					BEGIN
						SELECT @strErrorMessage = 'Item ' + @strItemNo + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strItemUOM IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblICUnitMeasure U1
							WHERE U1.strUnitMeasure = @strItemUOM
							)
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strItemNo + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strScheduleDescription IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblGRStorageScheduleRule SR
							WHERE SR.strScheduleDescription = @strScheduleDescription
							)
					BEGIN
						SELECT @strErrorMessage = 'Schedule Description ' + @strScheduleDescription + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strPriceUOM IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblICUnitMeasure U2
							WHERE U2.strUnitMeasure = @strPriceUOM
							)
					BEGIN
						SELECT @strErrorMessage = 'Price UOM ' + @strPriceUOM + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strFutMarketName IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblRKFutureMarket FM
							WHERE FM.strFutMarketName = @strFutMarketName
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
							FROM tblRKFuturesMonth MO
							WHERE MO.strFutureMonth = @strFutureMonth
							)
					BEGIN
						SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strPricingType IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblCTPricingType PT
							WHERE PT.strPricingType = @strPricingType
							)
					BEGIN
						SELECT @strErrorMessage = 'Price type ' + @strPricingType + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strFreightTerm IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblSMFreightTerms FT
							WHERE FT.strFreightTerm = @strFreightTerm
							)
					BEGIN
						SELECT @strErrorMessage = 'Freight Term  ' + @strFreightTerm + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strCurrency IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblSMCurrency CU
							WHERE CU.strCurrency = @strCurrency
							)
					BEGIN
						SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strLoadingPoint IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblSMCity LP
							WHERE LP.strCity = @strLoadingPoint
							)
					BEGIN
						SELECT @strErrorMessage = 'Loading Point ' + @strLoadingPoint + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strDestinationPoint IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblSMCity DP
							WHERE DP.strCity = @strDestinationPoint
							)
					BEGIN
						SELECT @strErrorMessage = 'Destination Point ' + @strDestinationPoint + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strDestinationCity IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblSMCity DC
							WHERE DC.strCity = @strDestinationCity
							)
					BEGIN
						SELECT @strErrorMessage = 'Destination City ' + @strDestinationCity + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					--IF @strStorageLocationName IS NOT NULL
					--	AND NOT EXISTS (
					--		SELECT 1
					--		FROM tblICStorageLocation SL
					--		WHERE SL.strName = @strStorageLocationName
					--		)
					--BEGIN
					--	SELECT @strErrorMessage = 'Storage Location Name ' + @strStorageLocationName + ' is not available.'
					--	RAISERROR (
					--			@strErrorMessage
					--			,16
					--			,1
					--			)
					--END
					--IF @strSubLocationName IS NOT NULL
					--	AND NOT EXISTS (
					--		SELECT 1
					--		FROM tblSMCompanyLocationSubLocation SB
					--		WHERE SB.strSubLocationName = @strSubLocationName
					--		)
					--BEGIN
					--	SELECT @strErrorMessage = 'Sub Location Name ' + @strSubLocationName + ' is not available.'
					--	RAISERROR (
					--			@strErrorMessage
					--			,16
					--			,1
					--			)
					--END
					IF @strVesselStorageLocationName IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblICStorageLocation SL
							WHERE SL.strName = @strVesselStorageLocationName
							)
					BEGIN
						SELECT @strErrorMessage = 'Storage Location Name ' + @strVesselStorageLocationName + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strVesselSubLocationName IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblSMCompanyLocationSubLocation SB
							WHERE SB.strSubLocationName = @strVesselSubLocationName
							)
					BEGIN
						SELECT @strErrorMessage = 'Sub Location Name ' + @strVesselSubLocationName + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strShippingLine IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblEMEntity ShippingLine
							JOIN tblEMEntityType ET ON ET.intEntityId = ShippingLine.intEntityId
								AND ET.strType = 'Shipping Line'
							WHERE ShippingLine.strName = @strShippingLine
							)
					BEGIN
						SELECT @strErrorMessage = 'Shipping Line ' + @strShippingLine + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					IF @strShipper IS NOT NULL
						AND NOT EXISTS (
							SELECT 1
							FROM tblEMEntity ShippingLine
							JOIN tblEMEntityType ET ON ET.intEntityId = ShippingLine.intEntityId
								AND ET.strType IN (
									'Vendor'
									,'Futures Broker'
									)
							WHERE ShippingLine.strName = @strShipper
							)
					BEGIN
						SELECT @strErrorMessage = 'Shipper ' + @strShipper + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intShipToEntityId = NULL

					SELECT @intShipToId = NULL

					SELECT @intPurchasingGroupId = NULL

					SELECT @intShipToEntityId = Customer.intEntityId
					FROM tblEMEntity Customer
					JOIN tblEMEntityType ET ON ET.intEntityId = Customer.intEntityId
						AND ET.strType = 'Customer'
					WHERE Customer.strName = @strShipToName

					SELECT @intShipToId = intEntityLocationId
					FROM tblEMEntityLocation
					WHERE strLocationName = @strShipToLocationName
						AND intEntityId = @intShipToEntityId

					IF @strShipToLocationName IS NOT NULL
						AND @intShipToId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Ship To ' + @strShipToLocationName + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intPurchasingGroupId = intPurchasingGroupId
					FROM tblSMPurchasingGroup
					WHERE strName = @strPurchasingGroupName

					IF @strPurchasingGroupName IS NOT NULL
						AND @intPurchasingGroupId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Purchasing Group ' + @strPurchasingGroupName + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intShipViaId = NULL

					SELECT @intShipViaId = intEntityId
					FROM tblEMEntity
					WHERE strName = @strShipVia

					IF @strShipVia IS NOT NULL
						AND @intShipViaId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Ship Via ' + @strShipVia + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intInvoiceCurrencyId = NULL

					SELECT @intInvoiceCurrencyId = intCurrencyID
					FROM tblSMCurrency
					WHERE strCurrency = @strInvoiceCurrency

					IF @strInvoiceCurrency IS NOT NULL
						AND @intInvoiceCurrencyId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Invoice Currency ' + @strInvoiceCurrency + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intFromCurrencyId = NULL

					SELECT @intFromCurrencyId = intCurrencyID
					FROM tblSMCurrency
					WHERE strCurrency = @strFromCurrency

					IF @strFromCurrency IS NOT NULL
						AND @intFromCurrencyId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Currency ' + @strFromCurrency + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intToCurrencyId = NULL

					SELECT @intToCurrencyId = intCurrencyID
					FROM tblSMCurrency
					WHERE strCurrency = @strToCurrency

					IF @strToCurrency IS NOT NULL
						AND @intToCurrencyId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Currency ' + @strToCurrency + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intCurrencyExchangeRateId = NULL

					SELECT @intCurrencyExchangeRateId = intCurrencyExchangeRateId
					FROM tblSMCurrencyExchangeRate
					WHERE intFromCurrencyId = @intFromCurrencyId
						AND intToCurrencyId = @intToCurrencyId

					IF @strFromCurrency IS NOT NULL
						AND @strToCurrency IS NOT NULL
						AND @intCurrencyExchangeRateId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Currency pair from ' + @strFromCurrency + ' to ' + @strToCurrency + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intProducerId = NULL

					SELECT @intProducerId = Producer.intEntityId
					FROM tblEMEntity Producer
					JOIN tblEMEntityType ET ON ET.intEntityId = Producer.intEntityId
						AND ET.strType = 'Producer'
					WHERE Producer.strName = @strProducer

					IF @strProducer IS NOT NULL
						AND @intProducerId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Producer ' + @strProducer + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intItemId = NULL

					SELECT @intUnitMeasureId = NULL

					SELECT @intItemUOMId = NULL

					SELECT @intStorageScheduleRuleId = NULL

					SELECT @intContractStatusId = NULL

					SELECT @intPriceUnitMeasureId = NULL

					SELECT @intPriceItemUOMId = NULL

					SELECT @intFutureMarketId = NULL

					SELECT @intFutureMonthId = NULL

					SELECT @intPricingTypeId = NULL

					SELECT @intFreightTermId = NULL

					SELECT @intCurrencyID = NULL

					SELECT @intLoadingPointId = NULL

					SELECT @intDestinationPointId = NULL

					SELECT @intDestinationCityId = NULL

					SELECT @intStorageLocationId = NULL

					SELECT @intCompanyLocationSubLocationId = NULL

					SELECT @intShippingLineId = NULL

					SELECT @intShipperId = NULL

					SELECT @intItemId = intItemId
					FROM tblICItem I
					WHERE I.strItemNo = @strItemNo

					SELECT @intUnitMeasureId = intUnitMeasureId
					FROM tblICUnitMeasure U1
					WHERE U1.strUnitMeasure = @strItemUOM

					SELECT @intItemUOMId = intItemUOMId
					FROM tblICItemUOM IU
					WHERE IU.intItemId = @intItemId
						AND IU.intUnitMeasureId = @intUnitMeasureId

					SELECT @intFXPriceUOMId = NULL

					SELECT @intFXPriceUOMId = intUnitMeasureId
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = @strFXPriceUOM

					SELECT @intFXPriceItemUOMId = NULL

					SELECT @intFXPriceItemUOMId = intItemUOMId
					FROM tblICItemUOM
					WHERE intItemId = @intItemId
						AND intUnitMeasureId = @intFXPriceUOMId

					IF @strFXPriceUOM IS NOT NULL
						AND @intFXPriceItemUOMId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'FX Price UOM ' + @strFXPriceUOM + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intCurrencyExchangeRateTypeId = NULL

					SELECT @intCurrencyExchangeRateTypeId = intCurrencyExchangeRateTypeId
					FROM tblSMCurrencyExchangeRateType
					WHERE strCurrencyExchangeRateType = @strCurrencyExchangeRateType

					IF @strCurrencyExchangeRateType IS NOT NULL
						AND @intCurrencyExchangeRateTypeId IS NULL
					BEGIN
						SELECT @strErrorMessage = 'Rate Type ' + @strCurrencyExchangeRateType + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END

					SELECT @intStorageScheduleRuleId = intStorageScheduleRuleId
					FROM tblGRStorageScheduleRule SR
					WHERE SR.strScheduleDescription = @strScheduleDescription

					SELECT @intContractStatusId = intContractStatusId
					FROM tblCTContractStatus CS
					WHERE CS.strContractStatus = @strContractStatus

					SELECT @intPriceUnitMeasureId = intUnitMeasureId
					FROM tblICUnitMeasure U2
					WHERE U2.strUnitMeasure = @strPriceUOM

					SELECT @intPriceItemUOMId = intItemUOMId
					FROM tblICItemUOM PU
					WHERE PU.intItemId = @intItemId
						AND PU.intUnitMeasureId = @intPriceUnitMeasureId

					SELECT @intFutureMarketId = intFutureMarketId
					FROM tblRKFutureMarket FM
					WHERE FM.strFutMarketName = @strFutMarketName

					SELECT @intFutureMonthId = intFutureMonthId
					FROM tblRKFuturesMonth MO
					WHERE MO.strFutureMonth = @strFutureMonth

					SELECT @intPricingTypeId = intPricingTypeId
					FROM tblCTPricingType PT
					WHERE PT.strPricingType = @strPricingType

					SELECT @intFreightTermId = intFreightTermId
					FROM tblSMFreightTerms FT
					WHERE FT.strFreightTerm = @strFreightTerm

					SELECT @intCurrencyID = intCurrencyID
					FROM tblSMCurrency CU
					WHERE CU.strCurrency = @strCurrency

					SELECT @intLoadingPointId = intCityId
					FROM tblSMCity LP
					WHERE LP.strCity = @strLoadingPoint

					SELECT @intDestinationPointId = intCityId
					FROM tblSMCity DP
					WHERE DP.strCity = @strDestinationPoint

					SELECT @intDestinationCityId = intCityId
					FROM tblSMCity DC
					WHERE DC.strCity = @strDestinationCity

					SELECT @intStorageLocationId = intStorageLocationId
					FROM tblICStorageLocation SL
					WHERE SL.strName = @strVesselStorageLocationName

					SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
					FROM tblSMCompanyLocationSubLocation SB
					WHERE SB.strSubLocationName = @strVesselSubLocationName

					SELECT @intShippingLineId = ShippingLine.intEntityId
					FROM tblEMEntity ShippingLine
					JOIN tblEMEntityType ET ON ET.intEntityId = ShippingLine.intEntityId
						AND ET.strType = 'Shipping Line'
					WHERE ShippingLine.strName = @strShippingLine

					SELECT @intShipperId = Shipper.intEntityId
					FROM tblEMEntity Shipper
					JOIN tblEMEntityType ET ON ET.intEntityId = Shipper.intEntityId
						AND ET.strType IN (
							'Vendor'
							,'Futures Broker'
							)
					WHERE Shipper.strName = @strShipper

					INSERT INTO #tmpContractDetail (
						intContractHeaderId
						,intItemId
						,intItemUOMId
						,intContractSeq
						,intStorageScheduleRuleId
						,dtmEndDate
						,dblQuantity
						,dblOriginalQty
						,intContractStatusId
						,dblBalance
						,dtmStartDate
						,intPriceItemUOMId
						,dtmCreated
						,intConcurrencyId
						,intCreatedById
						,intFutureMarketId
						,intFutureMonthId
						,dblFutures
						,dblBasis
						,dblCashPrice
						,strRemark
						,intPricingTypeId
						,dblTotalCost
						,intCurrencyId
						,intUnitMeasureId
						,dblNetWeight
						,intNetWeightUOMId
						,dtmM2MDate
						,intCompanyLocationId
						,intContractDetailRefId
						,intFreightTermId
						,strItemSpecification
						,intDiscountTypeId
						,intBookId
						,intLoadingPortId
						,intDestinationPortId
						,intDestinationCityId
						,strVessel
						,strLoadingPointType
						,strDestinationPointType
						,intStorageLocationId
						,intSubLocationId
						,strGrade
						,strGarden
						,intUnitsPerLayer
						,intLayersPerPallet
						,dtmEventStartDate
						,dtmPlannedAvailabilityDate
						,dtmUpdatedAvailabilityDate
						,intContainerTypeId
						,intNumberOfContainers
						,strPackingDescription
						,dblYield
						,intShippingLineId
						,intShipperId
						,strShippingTerm
						,dblNoOfLots
						,intShipToId
						,intPurchasingGroupId
						,intInvoiceCurrencyId
						,dtmFXValidFrom
						,dtmFXValidTo
						,dblRate
						,dblFXPrice
						,ysnUseFXPrice
						,intFXPriceUOMId
						,strFXRemarks
						,dblAssumedFX
						,intCurrencyExchangeRateId
						,intRateTypeId
						,ysnInvoice
						,ysnProvisionalInvoice
						,ysnQuantityFinal
						,ysnClaimsToProducer
						,ysnRiskToProducer
						,ysnBackToBack
						,intProducerId
						,intShipViaId
						,strInvoiceNo
						,ysnProvisionalPNL
						,ysnFinalPNL
						)
					SELECT @intNewContractHeaderId
						,@intItemId
						,@intItemUOMId
						,x.intContractSeq
						,@intStorageScheduleRuleId
						,x.dtmEndDate
						,x.dblDetailQuantity
						,x.dblOriginalQty
						,@intContractStatusId
						,x.dblBalance
						,x.dtmStartDate
						,@intPriceItemUOMId
						,GETDATE() AS dtmCreated
						,1 AS intConcurrencyId
						,@intUserId intCreatedById
						,@intFutureMarketId
						,@intFutureMonthId
						,x.dblFutures
						,x.dblBasis
						,x.dblCashPrice
						,x.strRemark
						,@intPricingTypeId
						,x.dblTotalCost
						,@intCurrencyID
						,@intUnitMeasureId
						,x.dblAvailableNetWeight
						,@intItemUOMId
						,GETDATE()
						,@intCompanyLocationId
						,intContractDetailId
						,@intFreightTermId
						,x.strItemSpecification
						,x.intDiscountTypeId
						,@intToBookId
						,@intLoadingPointId
						,@intDestinationPointId
						,@intDestinationCityId
						,strVessel
						,strLoadingPointType
						,strDestinationPointType
						,@intStorageLocationId
						,@intCompanyLocationSubLocationId
						,x.strItemGrade
						,x.strGarden
						,x.intUnitsPerLayer
						,x.intLayersPerPallet
						,x.dtmEventStartDate
						,x.dtmPlannedAvailabilityDate
						,x.dtmUpdatedAvailabilityDate
						,x.intContainerTypeId
						,x.intNumberOfContainers
						,x.strPackingDescription
						,x.dblYield
						,@intShippingLineId
						,@intShipperId
						,strShippingTerm
						,x.dblNoOfLots
						,@intShipToId
						,@intPurchasingGroupId
						,@intInvoiceCurrencyId
						,x.dtmFXValidFrom
						,x.dtmFXValidTo
						,x.dblRate
						,x.dblFXPrice
						,x.ysnUseFXPrice
						,@intFXPriceItemUOMId
						,x.strFXRemarks
						,x.dblAssumedFX
						,x.intCurrencyExchangeRateId
						,@intCurrencyExchangeRateTypeId
						,ysnInvoice
						,ysnProvisionalInvoice
						,ysnQuantityFinal
						,ysnClaimsToProducer
						,ysnRiskToProducer
						,ysnBackToBack
						,@intProducerId
						,@intShipViaId
						,x.strInvoiceNo
						,IsNULL(ysnProvisionalPNL,0)
						,IsNULL(ysnFinalPNL,0)
					FROM OPENXML(@idoc, 'vyuIPContractDetailViews/vyuIPContractDetailView', 2) WITH (
							strEntityName NVARCHAR(100) Collate Latin1_General_CI_AS
							,dtmContractDate DATETIME
							,dblHeaderQuantity NUMERIC(18, 6)
							,strSalespersonId NVARCHAR(3) Collate Latin1_General_CI_AS
							,ysnSigned BIT
							,ysnPrinted BIT
							,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
							,strHeaderUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCropYear NVARCHAR(30) Collate Latin1_General_CI_AS
							,strPosition NVARCHAR(100) Collate Latin1_General_CI_AS
							,strPricingType NVARCHAR(100) Collate Latin1_General_CI_AS
							,strCreatedBy NVARCHAR(100) Collate Latin1_General_CI_AS
							,strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
							,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
							,dblFutures NUMERIC(18, 6)
							,dblBasis NUMERIC(18, 6)
							,dblCashPrice NUMERIC(18, 6)
							,strRemark NVARCHAR(MAX) Collate Latin1_General_CI_AS
							,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							,strItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strScheduleDescription NVARCHAR(MAX) Collate Latin1_General_CI_AS
							,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strContractStatus NVARCHAR(50) Collate Latin1_General_CI_AS
							,strPriceUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,intContractSeq INT
							,dtmEndDate DATETIME
							,dblDetailQuantity NUMERIC(18, 6)
							,dblOriginalQty NUMERIC(18, 6)
							,dblBalance NUMERIC(18, 6)
							,dtmStartDate DATETIME
							,dblTotalCost NUMERIC(18, 6)
							,dblAvailableNetWeight NUMERIC(18, 6)
							,intContractDetailId INT
							,strFreightTerm NVARCHAR(100) Collate Latin1_General_CI_AS
							,strItemSpecification NVARCHAR(MAX) Collate Latin1_General_CI_AS
							,strCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
							,intDiscountTypeId INT
							,strLoadingPoint NVARCHAR(50) Collate Latin1_General_CI_AS
							,strDestinationPoint NVARCHAR(50) Collate Latin1_General_CI_AS
							,strDestinationCity NVARCHAR(50) Collate Latin1_General_CI_AS
							,strVessel NVARCHAR(64) Collate Latin1_General_CI_AS
							,strLoadingPointType NVARCHAR(50) Collate Latin1_General_CI_AS
							,strDestinationPointType NVARCHAR(50) Collate Latin1_General_CI_AS
							--,strStorageLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							--,strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strGarden NVARCHAR(128) Collate Latin1_General_CI_AS
							,strItemGrade NVARCHAR(128) Collate Latin1_General_CI_AS
							,intUnitsPerLayer INT
							,intLayersPerPallet INT
							,dtmEventStartDate DATETIME
							,dtmPlannedAvailabilityDate DATETIME
							,dtmUpdatedAvailabilityDate DATETIME
							,intContainerTypeId INT
							,intNumberOfContainers INT
							,strPackingDescription NVARCHAR(100) Collate Latin1_General_CI_AS
							,dblYield NUMERIC(18, 6)
							,strShippingTerm NVARCHAR(64) Collate Latin1_General_CI_AS
							,dblNoOfLots NUMERIC(18, 6)
							--,intInvoiceCurrencyId
							,dtmFXValidFrom DATETIME
							,dtmFXValidTo DATETIME
							,dblRate NUMERIC(18, 6)
							,dblFXPrice NUMERIC(18, 6)
							,ysnUseFXPrice BIT
							--,intFXPriceUOMId
							,strFXRemarks NVARCHAR(64) Collate Latin1_General_CI_AS
							,dblAssumedFX NUMERIC(18, 6)
							,intCurrencyExchangeRateId INT
							,ysnInvoice BIT
							,ysnProvisionalInvoice BIT
							,ysnQuantityFinal BIT
							,ysnClaimsToProducer BIT
							,ysnRiskToProducer BIT
							,ysnBackToBack BIT
							,strInvoiceNo NVARCHAR(100) Collate Latin1_General_CI_AS
							,ysnProvisionalPNL BIT
							,ysnFinalPNL BIT
							) x
					WHERE intContractSeq = @intContractSeq

					SELECT @intContractSeq = MIN(intContractSeq)
					FROM @tblCTContractDetail
					WHERE intContractSeq > @intContractSeq
				END

				SET IDENTITY_INSERT #tmpDeletedContractDetail ON

				INSERT INTO #tmpDeletedContractDetail (
					intContractDetailId
					,intSplitFromId
					,intParentDetailId
					,ysnSlice
					,intConcurrencyId
					,intContractHeaderId
					,intContractStatusId
					,intContractSeq
					,intCompanyLocationId
					,intShipToId
					,dtmStartDate
					,dtmEndDate
					,intFreightTermId
					,intShipViaId
					,intItemContractId
					,intItemId
					,strItemSpecification
					,intCategoryId
					,dblQuantity
					,intItemUOMId
					,dblOriginalQty
					,dblBalance
					,dblIntransitQty
					,dblScheduleQty
					,dblBalanceLoad
					,dblScheduleLoad
					,dblShippingInstructionQty
					,dblNetWeight
					,intNetWeightUOMId
					,intUnitMeasureId
					,intCategoryUOMId
					,intNoOfLoad
					,dblQuantityPerLoad
					,intIndexId
					,dblAdjustment
					,intAdjItemUOMId
					,intPricingTypeId
					,intFutureMarketId
					,intFutureMonthId
					,dblFutures
					,dblBasis
					,dblOriginalBasis
					,dblConvertedBasis
					,intBasisCurrencyId
					,intBasisUOMId
					,dblRatio
					,dblCashPrice
					,dblTotalCost
					,intCurrencyId
					,intPriceItemUOMId
					,dblNoOfLots
					,dtmLCDate
					,dtmLastPricingDate
					,dblConvertedPrice
					,intConvPriceCurrencyId
					,intConvPriceUOMId
					,intMarketZoneId
					,intDiscountTypeId
					,intDiscountId
					,intDiscountScheduleId
					,intDiscountScheduleCodeId
					,intStorageScheduleRuleId
					,intContractOptHeaderId
					,strBuyerSeller
					,intBillTo
					,intFreightRateId
					,strFobBasis
					,intRailGradeId
					,strRailRemark
					,strLoadingPointType
					,intLoadingPortId
					,strDestinationPointType
					,intDestinationPortId
					,strShippingTerm
					,intShippingLineId
					,strVessel
					,intDestinationCityId
					,intShipperId
					,strRemark
					,intSubLocationId
					,intStorageLocationId
					,intPurchasingGroupId
					,intFarmFieldId
					,intSplitId
					,strGrade
					,strGarden
					,strVendorLotID
					,strInvoiceNo
					,strReference
					,strERPPONumber
					,strERPItemNumber
					,strERPBatchNumber
					,intUnitsPerLayer
					,intLayersPerPallet
					,dtmEventStartDate
					,dtmPlannedAvailabilityDate
					,dtmUpdatedAvailabilityDate
					,dtmM2MDate
					,intBookId
					,intSubBookId
					,intContainerTypeId
					,intNumberOfContainers
					,intInvoiceCurrencyId
					,dtmFXValidFrom
					,dtmFXValidTo
					,dblRate
					,dblFXPrice
					,ysnUseFXPrice
					,intFXPriceUOMId
					,strFXRemarks
					,dblAssumedFX
					,strFixationBy
					,strPackingDescription
					,dblYield
					,intCurrencyExchangeRateId
					,intRateTypeId
					,intCreatedById
					,dtmCreated
					,intLastModifiedById
					,dtmLastModified
					,ysnInvoice
					,ysnProvisionalInvoice
					,ysnQuantityFinal
					,intProducerId
					,ysnClaimsToProducer
					,ysnRiskToProducer
					,ysnBackToBack
					,dblAllocatedQty
					,dblReservedQty
					,dblAllocationAdjQty
					,dblInvoicedQty
					,ysnPriceChanged
					,intContractDetailRefId
					,ysnStockSale
					,strCertifications
					,ysnSplit
					)
				SELECT intContractDetailId
					,intSplitFromId
					,intParentDetailId
					,ysnSlice
					,intConcurrencyId
					,intContractHeaderId
					,intContractStatusId
					,intContractSeq
					,intCompanyLocationId
					,intShipToId
					,dtmStartDate
					,dtmEndDate
					,intFreightTermId
					,intShipViaId
					,intItemContractId
					,intItemId
					,strItemSpecification
					,intCategoryId
					,dblQuantity
					,intItemUOMId
					,dblOriginalQty
					,dblBalance
					,dblIntransitQty
					,dblScheduleQty
					,dblBalanceLoad
					,dblScheduleLoad
					,dblShippingInstructionQty
					,dblNetWeight
					,intNetWeightUOMId
					,intUnitMeasureId
					,intCategoryUOMId
					,intNoOfLoad
					,dblQuantityPerLoad
					,intIndexId
					,dblAdjustment
					,intAdjItemUOMId
					,intPricingTypeId
					,intFutureMarketId
					,intFutureMonthId
					,dblFutures
					,dblBasis
					,dblOriginalBasis
					,dblConvertedBasis
					,intBasisCurrencyId
					,intBasisUOMId
					,dblRatio
					,dblCashPrice
					,dblTotalCost
					,intCurrencyId
					,intPriceItemUOMId
					,dblNoOfLots
					,dtmLCDate
					,dtmLastPricingDate
					,dblConvertedPrice
					,intConvPriceCurrencyId
					,intConvPriceUOMId
					,intMarketZoneId
					,intDiscountTypeId
					,intDiscountId
					,intDiscountScheduleId
					,intDiscountScheduleCodeId
					,intStorageScheduleRuleId
					,intContractOptHeaderId
					,strBuyerSeller
					,intBillTo
					,intFreightRateId
					,strFobBasis
					,intRailGradeId
					,strRailRemark
					,strLoadingPointType
					,intLoadingPortId
					,strDestinationPointType
					,intDestinationPortId
					,strShippingTerm
					,intShippingLineId
					,strVessel
					,intDestinationCityId
					,intShipperId
					,strRemark
					,intSubLocationId
					,intStorageLocationId
					,intPurchasingGroupId
					,intFarmFieldId
					,intSplitId
					,strGrade
					,strGarden
					,strVendorLotID
					,strInvoiceNo
					,strReference
					,strERPPONumber
					,strERPItemNumber
					,strERPBatchNumber
					,intUnitsPerLayer
					,intLayersPerPallet
					,dtmEventStartDate
					,dtmPlannedAvailabilityDate
					,dtmUpdatedAvailabilityDate
					,dtmM2MDate
					,intBookId
					,intSubBookId
					,intContainerTypeId
					,intNumberOfContainers
					,intInvoiceCurrencyId
					,dtmFXValidFrom
					,dtmFXValidTo
					,dblRate
					,dblFXPrice
					,ysnUseFXPrice
					,intFXPriceUOMId
					,strFXRemarks
					,dblAssumedFX
					,strFixationBy
					,strPackingDescription
					,dblYield
					,intCurrencyExchangeRateId
					,intRateTypeId
					,intCreatedById
					,dtmCreated
					,intLastModifiedById
					,dtmLastModified
					,ysnInvoice
					,ysnProvisionalInvoice
					,ysnQuantityFinal
					,intProducerId
					,ysnClaimsToProducer
					,ysnRiskToProducer
					,ysnBackToBack
					,dblAllocatedQty
					,dblReservedQty
					,dblAllocationAdjQty
					,dblInvoicedQty
					,ysnPriceChanged
					,intContractDetailRefId
					,ysnStockSale
					,strCertifications
					,ysnSplit
				FROM tblCTContractDetail CD
				WHERE CD.intContractHeaderId = @intNewContractHeaderId
					AND NOT EXISTS (
						SELECT *
						FROM #tmpContractDetail CD2
						WHERE CD2.intContractSeq = CD.intContractSeq
						)

				SET IDENTITY_INSERT #tmpDeletedContractDetail OFF

				SELECT @intRecordId = NULL
					,@intContractSeq = NULL

				SELECT @intRecordId = min(intContractDetailId)
				FROM #tmpDeletedContractDetail

				WHILE @intRecordId IS NOT NULL
				BEGIN
					SELECT @intContractSeq = NULL

					SELECT @intContractSeq = intContractSeq
					FROM #tmpDeletedContractDetail
					WHERE intContractDetailId = @intRecordId

					SELECT @strTblXML = NULL

					SELECT @strDetailCondition = 'intContractDetailId = ' + LTRIM(@intRecordId)

					EXEC uspCTGetTableDataInXML '#tmpDeletedContractDetail'
						,@strDetailCondition
						,@strTblXML OUTPUT
						,'tblCTContractDetail'

					EXEC uspCTValidateContractDetail @strTblXML
						,'Delete'

					DELETE
					FROM tblCTContractDetail
					WHERE intContractSeq = @intContractSeq
						AND intContractHeaderId = @intNewContractHeaderId

					SELECT @intRecordId = min(intContractDetailId)
					FROM #tmpDeletedContractDetail
					WHERE intContractDetailId > @intRecordId
				END

				SELECT @intRecordId = NULL
					,@intContractSeq = NULL

				SELECT @intRecordId = min(intContractDetailId)
				FROM #tmpContractDetail

				WHILE @intRecordId IS NOT NULL
				BEGIN
					SELECT @intContractSeq = NULL

					SELECT @intContractSeq = intContractSeq
					FROM #tmpContractDetail
					WHERE intContractDetailId = @intRecordId

					SELECT @strTblXML = NULL

					SELECT @strDetailCondition = 'intContractDetailId = ' + LTRIM(@intRecordId)

					EXEC uspCTGetTableDataInXML '#tmpContractDetail'
						,@strDetailCondition
						,@strTblXML OUTPUT
						,'tblCTContractDetail'

					IF NOT EXISTS (
							SELECT *
							FROM tblCTContractDetail
							WHERE intContractHeaderId = @intNewContractHeaderId
								AND intContractSeq = @intContractSeq
							)
					BEGIN
						EXEC uspCTValidateContractDetail @strTblXML
							,'Added'

						EXEC uspCTInsertINTOTableFromXML 'tblCTContractDetail'
							,@strTblXML
							,@intContractDetailId OUTPUT
					END
					ELSE
					BEGIN
						EXEC uspCTValidateContractDetail @strTblXML
							,'Modified'

						UPDATE CD
						SET ysnSlice = CD1.ysnSlice
							,intConcurrencyId = CD.intConcurrencyId + 1
							,intContractStatusId = CD1.intContractStatusId
							,intCompanyLocationId = CD1.intCompanyLocationId
							,intShipToId = CD1.intShipToId
							,dtmStartDate = CD1.dtmStartDate
							,dtmEndDate = CD1.dtmEndDate
							,intFreightTermId = CD1.intFreightTermId
							,intShipViaId = CD1.intShipViaId
							,intItemContractId = CD1.intItemContractId
							,intItemId = CD1.intItemId
							,strItemSpecification = CD1.strItemSpecification
							,intCategoryId = CD1.intCategoryId
							,dblQuantity = CD1.dblQuantity
							,intItemUOMId = CD1.intItemUOMId
							,dblOriginalQty = CD1.dblOriginalQty
							,dblBalance = CD1.dblBalance
							,dblIntransitQty = CD1.dblIntransitQty
							,dblScheduleQty = CD1.dblScheduleQty
							,dblBalanceLoad = CD1.dblBalanceLoad
							,dblScheduleLoad = CD1.dblScheduleLoad
							,dblShippingInstructionQty = CD1.dblShippingInstructionQty
							,dblNetWeight = CD1.dblNetWeight
							,intNetWeightUOMId = CD1.intNetWeightUOMId
							,intUnitMeasureId = CD1.intUnitMeasureId
							,intCategoryUOMId = CD1.intCategoryUOMId
							,intNoOfLoad = CD1.intNoOfLoad
							,dblQuantityPerLoad = CD1.dblQuantityPerLoad
							,intIndexId = CD1.intIndexId
							,dblAdjustment = CD1.dblAdjustment
							,intAdjItemUOMId = CD1.intAdjItemUOMId
							,intPricingTypeId = CD1.intPricingTypeId
							,intFutureMarketId = CD1.intFutureMarketId
							,intFutureMonthId = CD1.intFutureMonthId
							,dblFutures = CD1.dblFutures
							,dblBasis = CD1.dblBasis
							,dblOriginalBasis = CD1.dblOriginalBasis
							,dblConvertedBasis = CD1.dblConvertedBasis
							,intBasisCurrencyId = CD1.intBasisCurrencyId
							,intBasisUOMId = CD1.intBasisUOMId
							,dblRatio = CD1.dblRatio
							,dblCashPrice = CD1.dblCashPrice
							,dblTotalCost = CD1.dblTotalCost
							,intCurrencyId = CD1.intCurrencyId
							,intPriceItemUOMId = CD1.intPriceItemUOMId
							,dblNoOfLots = CD1.dblNoOfLots
							,dtmLCDate = CD1.dtmLCDate
							,dtmLastPricingDate = CD1.dtmLastPricingDate
							,dblConvertedPrice = CD1.dblConvertedPrice
							,intConvPriceCurrencyId = CD1.intConvPriceCurrencyId
							,intConvPriceUOMId = CD1.intConvPriceUOMId
							,intMarketZoneId = CD1.intMarketZoneId
							,intDiscountTypeId = CD1.intDiscountTypeId
							,intDiscountId = CD1.intDiscountId
							,intDiscountScheduleId = CD1.intDiscountScheduleId
							,intDiscountScheduleCodeId = CD1.intDiscountScheduleCodeId
							,intStorageScheduleRuleId = CD1.intStorageScheduleRuleId
							,intContractOptHeaderId = CD1.intContractOptHeaderId
							,strBuyerSeller = CD1.strBuyerSeller
							,intBillTo = CD1.intBillTo
							,intFreightRateId = CD1.intFreightRateId
							,strFobBasis = CD1.strFobBasis
							,intRailGradeId = CD1.intRailGradeId
							,strRailRemark = CD1.strRailRemark
							,strLoadingPointType = CD1.strLoadingPointType
							,intLoadingPortId = CD1.intLoadingPortId
							,strDestinationPointType = CD1.strDestinationPointType
							,intDestinationPortId = CD1.intDestinationPortId
							--,strShippingTerm = CD1.strShippingTerm
							--,intShippingLineId = CD1.intShippingLineId
							,strVessel = CD1.strVessel
							,intDestinationCityId = CD1.intDestinationCityId
							--,intShipperId = CD1.intShipperId
							,strRemark = CD1.strRemark
							,intSubLocationId = CD1.intSubLocationId
							,intStorageLocationId = CD1.intStorageLocationId
							,intPurchasingGroupId = CD1.intPurchasingGroupId
							,intFarmFieldId = CD1.intFarmFieldId
							,intSplitId = CD1.intSplitId
							,strGrade = CD1.strGrade
							,strGarden = CD1.strGarden
							,strVendorLotID = CD1.strVendorLotID
							,strInvoiceNo = CD1.strInvoiceNo
							,strReference = CD1.strReference
							,intUnitsPerLayer = CD1.intUnitsPerLayer
							,intLayersPerPallet = CD1.intLayersPerPallet
							,dtmEventStartDate = CD1.dtmEventStartDate
							,dtmPlannedAvailabilityDate = CD1.dtmPlannedAvailabilityDate
							,dtmUpdatedAvailabilityDate = CD1.dtmUpdatedAvailabilityDate
							,dtmM2MDate = CD1.dtmM2MDate
							,intBookId = CD1.intBookId
							,intSubBookId = CD1.intSubBookId
							,intContainerTypeId = CD1.intContainerTypeId
							,intNumberOfContainers = CD1.intNumberOfContainers
							,intInvoiceCurrencyId = CD1.intInvoiceCurrencyId
							,dtmFXValidFrom = CD1.dtmFXValidFrom
							,dtmFXValidTo = CD1.dtmFXValidTo
							,dblRate = CD1.dblRate
							,dblFXPrice = CD1.dblFXPrice
							,ysnUseFXPrice = CD1.ysnUseFXPrice
							,intFXPriceUOMId = CD1.intFXPriceUOMId
							,strFXRemarks = CD1.strFXRemarks
							,dblAssumedFX = CD1.dblAssumedFX
							,strFixationBy = CD1.strFixationBy
							,strPackingDescription = CD1.strPackingDescription
							,dblYield = CD1.dblYield
							,intCurrencyExchangeRateId = CD1.intCurrencyExchangeRateId
							,intRateTypeId = CD1.intRateTypeId
							,intLastModifiedById = CD1.intLastModifiedById
							,dtmLastModified = GETDATE()
							,ysnInvoice = CD1.ysnInvoice
							,ysnProvisionalInvoice = CD1.ysnProvisionalInvoice
							,ysnQuantityFinal = CD1.ysnQuantityFinal
							,intProducerId = CD1.intProducerId
							,ysnClaimsToProducer = CD1.ysnClaimsToProducer
							,ysnRiskToProducer = CD1.ysnRiskToProducer
							,ysnBackToBack = CD1.ysnBackToBack
							,dblAllocatedQty = CD1.dblAllocatedQty
							,dblReservedQty = CD1.dblReservedQty
							,dblAllocationAdjQty = CD1.dblAllocationAdjQty
							,dblInvoicedQty = CD1.dblInvoicedQty
							,ysnPriceChanged = CD1.ysnPriceChanged
							,ysnStockSale = CD1.ysnStockSale
							,strCertifications = CD1.strCertifications
							,ysnSplit = CD1.ysnSplit
							,intShippingLineId = CD1.intShippingLineId
							,intShipperId = CD1.intShipperId
							,strShippingTerm = CD1.strShippingTerm
						FROM tblCTContractDetail CD
						JOIN #tmpContractDetail CD1 ON CD.intContractSeq = CD1.intContractSeq
						WHERE CD.intContractHeaderId = @intNewContractHeaderId
							AND CD.intContractSeq = @intContractSeq

						SELECT @intContractDetailId = intContractDetailId
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @intNewContractHeaderId
							AND intContractSeq = @intContractSeq
					END

					EXEC uspCTCreateDetailHistory NULL
						,@intContractDetailId

					SELECT @intRecordId = min(intContractDetailId)
					FROM #tmpContractDetail
					WHERE intContractDetailId > @intRecordId
				END

				-----------------------------------Detail-------------------------------------------
				------------------------------------Cost--------------------------------------------
				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strCostXML

				DELETE
				FROM @tblCTContractCost

				INSERT INTO @tblCTContractCost (intContractCostId)
				SELECT intContractCostId
				FROM OPENXML(@idoc, 'vyuCTContractCostViews/vyuCTContractCostView', 2) WITH (intContractCostId INT)

				SELECT @intContractCostId = MIN(intContractCostId)
				FROM @tblCTContractCost

				WHILE @intContractCostId IS NOT NULL
				BEGIN
					SELECT @strItemNo = NULL
						,@strUOM = NULL
						,@strCurrency = NULL
						,@strVendorName = NULL
						,@strCurrencyExchangeRateType = NULL

					SELECT @strItemNo = strItemNo
						,@strUOM = strUOM
						,@strCurrency = strCurrency
						,@strVendorName = strVendorName
						,@strCurrencyExchangeRateType = strCurrencyExchangeRateType
					FROM OPENXML(@idoc, 'vyuCTContractCostViews/vyuCTContractCostView', 2) WITH (
							strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							,strUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
							,strVendorName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCurrencyExchangeRateType NVARCHAR(50) Collate Latin1_General_CI_AS
							,intContractCostId INT
							) CC
					WHERE intContractCostId = @intContractCostId

					SELECT @intItemId = NULL

					SELECT @intUnitMeasureId = NULL

					SELECT @intItemUOMId = NULL

					SELECT @intCurrencyID = NULL

					--SELECT @intMainCurrencyID = intCurrencyID
					--FROM tblSMCurrency MY
					--WHERE MY.intCurrencyID = @intMainCurrencyId
					SELECT @intVendorId = NULL

					SELECT @intCurrencyExchangeRateTypeId = NULL

					SELECT @intItemId = intItemId
					FROM tblICItem IM
					WHERE IM.strItemNo = @strItemNo

					SELECT @intUnitMeasureId = intUnitMeasureId
					FROM tblICUnitMeasure UM
					WHERE UM.strUnitMeasure = @strUOM

					SELECT @intItemUOMId = intItemUOMId
					FROM tblICItemUOM IU
					WHERE IU.intItemId = @intItemId
						AND IU.intUnitMeasureId = @intUnitMeasureId

					SELECT @intCurrencyID = intCurrencyID --,@intMainCurrencyId=intMainCurrencyId
					FROM tblSMCurrency CY
					WHERE CY.strCurrency = @strCurrency

					--SELECT @intMainCurrencyID = intCurrencyID
					--FROM tblSMCurrency MY
					--WHERE MY.intCurrencyID = @intMainCurrencyId
					SELECT @intVendorId = EY.intEntityId
					FROM tblEMEntity EY
					JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
						AND ET.strType = 'Vendor'
					WHERE EY.strName = @strVendorName
						AND EY.strEntityNo <> ''

					SELECT @intCurrencyExchangeRateTypeId = intCurrencyExchangeRateTypeId
					FROM tblSMCurrencyExchangeRateType RT
					WHERE RT.strCurrencyExchangeRateType = @strCurrencyExchangeRateType

					INSERT INTO #tmpContractCost (
						intItemId
						,intVendorId
						,strCostMethod
						,intCurrencyId
						,dblRate
						,intItemUOMId
						,intRateTypeId
						,dblFX
						,ysnAccrue
						,ysnMTM
						,ysnPrice
						,ysnAdditionalCost
						,ysnBasis
						,ysnReceivable
						,strParty
						,strPaidBy
						,dtmDueDate
						,strReference
						,ysn15DaysFromShipment
						,strRemarks
						,strStatus
						,strCostStatus
						,dblReqstdAmount
						,dblRcvdPaidAmount
						,dblActualAmount
						,dblAccruedAmount
						,dblRemainingPercent
						,dtmAccrualDate
						,strAPAR
						,strPayToReceiveFrom
						,strReferenceNo
						,intContractCostRefId
						,intContractDetailId
						,intConcurrencyId
						)
					SELECT @intItemId
						,@intVendorId
						,strCostMethod
						,@intCurrencyID
						,dblRate
						,@intItemUOMId
						,@intCurrencyExchangeRateTypeId
						,dblFX
						,CC.ysnAccrue
						,CC.ysnMTM
						,CC.ysnPrice
						,ysnAdditionalCost
						,ysnBasis
						,ysnReceivable
						,strParty
						,strPaidBy
						,dtmDueDate
						,strReference
						,ysn15DaysFromShipment
						,strRemarks
						,CC.strStatus
						,strCostStatus
						,dblReqstdAmount
						,dblRcvdPaidAmount
						,dblActualAmount
						,dblAccruedAmount
						,dblRemainingPercent
						,dtmAccrualDate
						,strAPAR
						,strPayToReceiveFrom
						,strReferenceNo
						,intContractCostId
						,intContractDetailId
						,1
					FROM OPENXML(@idoc, 'vyuCTContractCostViews/vyuCTContractCostView', 2) WITH (
							strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
							,strUOM NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
							,strVendorName NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCurrencyExchangeRateType NVARCHAR(50) Collate Latin1_General_CI_AS
							,dblRate NUMERIC(18, 6)
							,dblFX NUMERIC(18, 6)
							,ysnAccrue BIT
							,ysnMTM BIT
							,ysnPrice BIT
							,ysnAdditionalCost BIT
							,ysnBasis BIT
							,ysnReceivable BIT
							,strParty NVARCHAR(100) Collate Latin1_General_CI_AS
							,strPaidBy NVARCHAR(100) Collate Latin1_General_CI_AS
							,dtmDueDate DATETIME
							,strReference NVARCHAR(200) Collate Latin1_General_CI_AS
							,ysn15DaysFromShipment BIT
							,strRemarks NVARCHAR(MAX) Collate Latin1_General_CI_AS
							,strStatus NVARCHAR(50) Collate Latin1_General_CI_AS
							,strCostStatus NVARCHAR(50) Collate Latin1_General_CI_AS
							,dblReqstdAmount NUMERIC(18, 6)
							,dblRcvdPaidAmount NUMERIC(18, 6)
							,dblActualAmount NUMERIC(18, 6)
							,dblAccruedAmount NUMERIC(18, 6)
							,dblRemainingPercent NUMERIC(18, 6)
							,dtmAccrualDate DATETIME
							,strAPAR NVARCHAR(100) Collate Latin1_General_CI_AS
							,strPayToReceiveFrom NVARCHAR(100) Collate Latin1_General_CI_AS
							,strReferenceNo NVARCHAR(200) Collate Latin1_General_CI_AS
							,intContractCostId INT
							,intContractDetailId INT
							,strCostMethod NVARCHAR(50) Collate Latin1_General_CI_AS
							) CC
					WHERE intContractCostId = @intContractCostId

					SELECT @intContractCostId = MIN(intContractCostId)
					FROM @tblCTContractCost
					WHERE intContractCostId > @intContractCostId
				END

				INSERT INTO tblCTContractCost (
					intConcurrencyId
					,intPrevConcurrencyId
					,intContractDetailId
					,intItemId
					,intVendorId
					,strCostMethod
					,intCurrencyId
					,dblRate
					,intItemUOMId
					,intRateTypeId
					,dblFX
					,ysnAccrue
					,ysnMTM
					,ysnPrice
					,ysnAdditionalCost
					,ysnBasis
					,ysnReceivable
					,strParty
					,strPaidBy
					,dtmDueDate
					,strReference
					,ysn15DaysFromShipment
					,strRemarks
					,strStatus
					,strCostStatus
					,dblReqstdAmount
					,dblRcvdPaidAmount
					,dblActualAmount
					,dblAccruedAmount
					,dblRemainingPercent
					,dtmAccrualDate
					,strAPAR
					,strPayToReceiveFrom
					,strReferenceNo
					,intContractCostRefId
					)
				SELECT 1 AS intConcurrencyId
					,0 AS intPrevConcurrencyId
					,(
						SELECT TOP 1 CD.intContractDetailId
						FROM tblCTContractDetail CD
						WHERE CD.intContractHeaderId = @intNewContractHeaderId
							AND CD.intContractDetailRefId = x.intContractDetailId
						) AS intContractDetailId
					,intItemId
					,intVendorId
					,strCostMethod
					,intCurrencyId
					,dblRate
					,intItemUOMId
					,intRateTypeId
					,dblFX
					,ysnAccrue
					,ysnMTM
					,ysnPrice
					,ysnAdditionalCost
					,ysnBasis
					,ysnReceivable
					,strParty
					,strPaidBy
					,dtmDueDate
					,strReference
					,ysn15DaysFromShipment
					,strRemarks
					,strStatus
					,strCostStatus
					,dblReqstdAmount
					,dblRcvdPaidAmount
					,dblActualAmount
					,dblAccruedAmount
					,dblRemainingPercent
					,dtmAccrualDate
					,strAPAR
					,strPayToReceiveFrom
					,strReferenceNo
					,intContractCostRefId
				FROM #tmpContractCost x
				WHERE NOT EXISTS (
						SELECT *
						FROM tblCTContractCost CC
						JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
						WHERE CD.intContractHeaderId = @intNewContractHeaderId
							AND CC.intContractCostRefId = x.intContractCostRefId
						)

				UPDATE CC
				SET intConcurrencyId = CC.intConcurrencyId + 1
					,intPrevConcurrencyId = CC.intPrevConcurrencyId + 1
					,intItemId = x.intItemId
					,intVendorId = x.intVendorId
					,strCostMethod = x.strCostMethod
					,intCurrencyId = x.intCurrencyId
					,dblRate = x.dblRate
					,intItemUOMId = x.intItemUOMId
					,intRateTypeId = x.intRateTypeId
					,dblFX = x.dblFX
					,ysnAccrue = x.ysnAccrue
					,ysnMTM = x.ysnMTM
					,ysnPrice = x.ysnPrice
					,ysnAdditionalCost = x.ysnAdditionalCost
					,ysnBasis = x.ysnBasis
					,ysnReceivable = x.ysnReceivable
					,strParty = x.strParty
					,strPaidBy = x.strPaidBy
					,dtmDueDate = x.dtmDueDate
					,strReference = x.strReference
					,ysn15DaysFromShipment = x.ysn15DaysFromShipment
					,strRemarks = x.strRemarks
					,strStatus = x.strStatus
					,strCostStatus = x.strCostStatus
					,dblReqstdAmount = x.dblReqstdAmount
					,dblRcvdPaidAmount = x.dblRcvdPaidAmount
					,dblActualAmount = x.dblActualAmount
					,dblAccruedAmount = x.dblAccruedAmount
					,dblRemainingPercent = x.dblRemainingPercent
					,dtmAccrualDate = x.dtmAccrualDate
					,strAPAR = x.strAPAR
					,strPayToReceiveFrom = x.strPayToReceiveFrom
					,strReferenceNo = x.strReferenceNo
				FROM #tmpContractCost x
				JOIN tblCTContractCost CC ON CC.intContractCostRefId = x.intContractCostRefId

				DELETE CC
				FROM tblCTContractCost CC
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
				WHERE CD.intContractHeaderId = @intNewContractHeaderId
					AND NOT EXISTS (
						SELECT *
						FROM #tmpContractCost x
						WHERE CC.intContractCostRefId = x.intContractCostRefId
						)

				------------------------------------------------------------Document-----------------------------------------------------
				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strDocumentXML

				IF EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuCTContractDocumentViews/vyuCTContractDocumentView', 2) WITH (
								intContractDocumentId INT
								,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
								) x
						LEFT JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
						WHERE D.strDocumentName IS NULL
						)
				BEGIN
					SELECT @strErrorMessage = 'Document Name ' + x.strDocumentName + ' is not available.'
					FROM OPENXML(@idoc, 'vyuCTContractDocumentViews/vyuCTContractDocumentView', 2) WITH (
							intContractDocumentId INT
							,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
					WHERE D.strDocumentName IS NULL

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				INSERT INTO tblCTContractDocument (
					intContractHeaderId
					,intDocumentId
					,intConcurrencyId
					,intContractDocumentRefId
					)
				SELECT @intNewContractHeaderId
					,D.intDocumentId
					,1
					,x.intContractDocumentId
				FROM OPENXML(@idoc, 'vyuCTContractDocumentViews/vyuCTContractDocumentView', 2) WITH (
						intContractDocumentId INT
						,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
				WHERE NOT EXISTS (
						SELECT *
						FROM tblCTContractDocument CD
						WHERE CD.intContractHeaderId = @intNewContractHeaderId
							AND CD.intContractDocumentRefId = x.intContractDocumentId
						)

				UPDATE CD
				SET intDocumentId = D.intDocumentId
				FROM OPENXML(@idoc, 'vyuCTContractDocumentViews/vyuCTContractDocumentView', 2) WITH (
						intContractDocumentId INT
						,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
				JOIN tblCTContractDocument CD ON CD.intContractHeaderId = @intNewContractHeaderId
					AND CD.intContractDocumentRefId = x.intContractDocumentId

				DELETE CD
				FROM tblCTContractDocument CD
				WHERE CD.intContractHeaderId = @intNewContractHeaderId
					AND NOT EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuCTContractDocumentViews/vyuCTContractDocumentView', 2) WITH (intContractDocumentId INT) x
						WHERE CD.intContractDocumentRefId = x.intContractDocumentId
						)

				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strCertificationXML

				IF EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuCTContractCertifications/vyuCTContractCertification', 2) WITH (strProducer NVARCHAR(50) Collate Latin1_General_CI_AS) x
						LEFT JOIN tblEMEntity PR ON PR.strName = x.strProducer
						WHERE PR.strName IS NULL
							AND x.strProducer IS NOT NULL
						)
				BEGIN
					SELECT @strErrorMessage = 'Producer ' + x.strProducer + ' is not available.'
					FROM OPENXML(@idoc, 'vyuCTContractCertifications/vyuCTContractCertification', 2) WITH (strProducer NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblEMEntity PR ON PR.strName = x.strProducer
						AND x.strProducer IS NOT NULL
					WHERE PR.strName IS NULL

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuCTContractCertifications/vyuCTContractCertification', 2) WITH (strCertificationName NVARCHAR(100) Collate Latin1_General_CI_AS) x
						LEFT JOIN tblICCertification CF ON CF.strCertificationName = x.strCertificationName
						WHERE CF.strCertificationName IS NULL
						)
				BEGIN
					SELECT @strErrorMessage = 'Certification ' + x.strCertificationName + ' is not available.'
					FROM OPENXML(@idoc, 'vyuCTContractCertifications/vyuCTContractCertification', 2) WITH (strCertificationName NVARCHAR(100) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblICCertification CF ON CF.strCertificationName = x.strCertificationName
					WHERE CF.strCertificationName IS NULL

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				DELETE CT
				FROM tblCTContractCertification CT
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = CT.intContractDetailId
				WHERE CD.intContractHeaderId = @intNewContractHeaderId

				INSERT INTO tblCTContractCertification (
					intContractDetailId
					,intCertificationId
					,strCertificationId
					,strTrackingNumber
					,intProducerId
					,dblQuantity
					,intConcurrencyId
					)
				SELECT (
						SELECT TOP 1 CD.intContractDetailId
						FROM tblCTContractDetail CD
						WHERE CD.intContractDetailRefId = x.intContractDetailId
							AND CD.intContractHeaderId = @intNewContractHeaderId
						)
					,CF.intCertificationId
					,x.strCertificationId
					,x.strTrackingNumber
					,PR.intEntityId
					,x.dblQuantity
					,1 AS intConcurrencyId
				FROM OPENXML(@idoc, 'vyuCTContractCertifications/vyuCTContractCertification', 2) WITH (
						strProducer NVARCHAR(50) Collate Latin1_General_CI_AS
						,strCertificationName NVARCHAR(100) Collate Latin1_General_CI_AS
						,intContractDetailId INT
						,strCertificationId NVARCHAR(50)
						,strTrackingNumber NVARCHAR(50)
						,dblQuantity NUMERIC(18, 6)
						) x
				LEFT JOIN tblEMEntity PR ON PR.strName = x.strProducer
				LEFT JOIN tblICCertification CF ON CF.strCertificationName = x.strCertificationName

				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strConditionXML

				IF EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuCTContractConditionViews/vyuCTContractConditionView', 2) WITH (strConditionName NVARCHAR(200) Collate Latin1_General_CI_AS) x
						LEFT JOIN tblCTCondition C ON C.strConditionName = x.strConditionName
						WHERE C.strConditionName IS NULL
						)
				BEGIN
					SELECT @strErrorMessage = 'Condition ' + x.strConditionName + ' is not available.'
					FROM OPENXML(@idoc, 'vyuCTContractConditionViews/vyuCTContractConditionView', 2) WITH (strConditionName NVARCHAR(200) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblCTCondition C ON C.strConditionName = x.strConditionName
					WHERE C.strConditionName IS NULL

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				DELETE
				FROM tblCTContractCondition
				WHERE intContractHeaderId = @intNewContractHeaderId

				INSERT INTO tblCTContractCondition (
					intContractHeaderId
					,intConditionId
					,intConcurrencyId
					)
				SELECT @intNewContractHeaderId
					,C.intConditionId
					,1 AS intConcurrencyId
				FROM OPENXML(@idoc, 'vyuCTContractConditionViews/vyuCTContractConditionView', 2) WITH (strConditionName NVARCHAR(200) Collate Latin1_General_CI_AS) x
				JOIN tblCTCondition C ON C.strConditionName = x.strConditionName

				DELETE
				FROM tblCTIntrCompApproval
				WHERE intContractHeaderId = @intNewContractHeaderId

				INSERT INTO tblCTIntrCompApproval (
					intContractHeaderId
					,strName
					,strUserName
					,strScreen
					,intConcurrencyId
					)
				SELECT @intNewContractHeaderId
					,strName
					,strUserName
					,strScreen
					,1 AS intConcurrencyId
				FROM OPENXML(@idoc, 'vyuCTContractApproverViews/vyuCTContractApproverView', 2) WITH (
						strName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strUserName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strScreen NVARCHAR(250) Collate Latin1_General_CI_AS
						) x

				SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@intNewContractHeaderId)

				EXEC uspCTGetTableDataInXML 'tblCTContractHeader'
					,@strHeaderCondition
					,@strAckHeaderXML OUTPUT

				EXEC uspCTGetTableDataInXML 'tblCTContractDetail'
					,@strHeaderCondition
					,@strAckDetailXML OUTPUT

				SELECT @strContractDetailAllId = STUFF((
							SELECT DISTINCT ',' + LTRIM(intContractDetailId)
							FROM tblCTContractDetail
							WHERE intContractHeaderId = @NewContractHeaderId
							FOR XML PATH('')
							), 1, 1, '')

				SELECT @strCostCondition = 'intContractDetailId IN (' + LTRIM(@strContractDetailAllId) + ')'

				EXEC uspCTGetTableDataInXML 'tblCTContractCost'
					,@strCostCondition
					,@strAckCostXML OUTPUT

				EXEC uspCTGetTableDataInXML 'tblCTContractDocument'
					,@strHeaderCondition
					,@strAckDocumentXML OUTPUT

				EXEC uspCTGetTableDataInXML 'tblCTContractCertification'
					,@strCostCondition
					,@strAckCertificationXML OUTPUT

				EXEC uspCTGetTableDataInXML 'tblCTContractCondition'
					,@strHeaderCondition
					,@strAckConditionXML OUTPUT

				INSERT INTO tblCTContractAcknowledgementStage (
					intContractHeaderId
					,strContractAckNumber
					,dtmFeedDate
					,strMessage
					,strTransactionType
					,intMultiCompanyId
					,strAckHeaderXML
					,strAckDetailXML
					,strAckCostXML
					,strAckDocumentXML
					,strAckCertificationXML
					,strAckConditionXML
					)
				SELECT @NewContractHeaderId
					,@strNewContractNumber
					,GETDATE()
					,'Success'
					,@strTransactionType
					,@intMultiCompanyId
					,@strAckHeaderXML
					,@strAckDetailXML
					,@strAckCostXML
					,@strAckDocumentXML
					,@strAckCertificationXML
					,@strAckConditionXML

				SELECT @intContractAcknowledgementStageId = SCOPE_IDENTITY();

				----------------------------CALL Stored procedure for APPROVAL -----------------------------------------------------------
				SELECT @intCreatedById = intCreatedById
				FROM tblCTContractHeader
				WHERE intContractHeaderId = @intNewContractHeaderId

				INSERT INTO @config (
					strApprovalFor
					,strValue
					)
				SELECT 'Contract Type'
					,'Purchase'

				EXEC uspSMSubmitTransaction @type = 'ContractManagement.view.Contract'
					,@recordId = @intNewContractHeaderId
					,@transactionNo = @strNewContractNumber
					,@transactionEntityId = @intEntityId
					,@currentUserEntityId = @intCreatedById
					,@amount = 0
					,@approverConfiguration = @config

				--------------------------------------------------------------------------------------------------------------------------
				EXEC sp_xml_removedocument @idoc

				ext:

				UPDATE tblCTContractStage
				SET strFeedStatus = 'Processed'
				WHERE intContractStageId = @intContractStageId

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

				UPDATE tblCTContractStage
				SET strFeedStatus = 'Failed'
					,strMessage = @ErrMsg
				WHERE intContractStageId = @intContractStageId
			END CATCH
		END

		SELECT @intContractStageId = MIN(intContractStageId)
		FROM tblCTContractStage
		WHERE intContractStageId > @intContractStageId
			AND ISNULL(strFeedStatus, '') = ''
			--AND strRowState = 'Added'
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
