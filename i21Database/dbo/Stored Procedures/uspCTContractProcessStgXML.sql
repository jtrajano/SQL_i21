CREATE PROCEDURE [dbo].[uspCTContractProcessStgXML]
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
				EXEC uspCTGetStartingNumber 'PurchaseContract'
					,@strNewContractNumber OUTPUT

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

				IF NOT EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuCTContractHeaderViews/vyuCTContractHeaderView', 2) WITH (strTextCode NVARCHAR(50) Collate Latin1_General_CI_AS) x
						JOIN tblCTContractText CT ON CT.strTextCode = x.strTextCode
						)
				BEGIN
					INSERT INTO tblCTContractText (
						strTextCode
						,strTextDescription
						,intConcurrencyId
						,intContractPriceType
						,intContractType
						,ysnActive
						)
					SELECT x.strTextCode
						,x.strTextCode
						,1
						,intPricingTypeId
						,(
							SELECT TOP 1 intContractTypeId
							FROM tblCTContractType
							WHERE strContractType = 'Purchase'
							)
						,1
					FROM OPENXML(@idoc, 'vyuCTContractHeaderViews/vyuCTContractHeaderView', 2) WITH (
							strTextCode NVARCHAR(50) Collate Latin1_General_CI_AS
							,strPricingType NVARCHAR(100) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblCTPricingType PT ON PT.strPricingType = x.strPricingType
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
					)
				OUTPUT INSERTED.intEntityId
				INTO @MyTableVar
				SELECT 1 AS intContractTypeId
					,@intEntityId
					,dtmContractDate
					,C.intCommodityId
					,CM.intCommodityUnitMeasureId
					,dblHeaderQuantity
					,SP.intEntityId
					,ysnSigned
					,dtmSigned
					,@strNewContractNumber
					,ysnPrinted
					,YR.intCropYearId
					,PO.intPositionId
					,PT.intPricingTypeId
					,CE.intEntityId
					,GETDATE()
					,1 intConcurrencyId
					,@strCustomerContract
					,@intContractHeaderRefId
					,FT.intFreightTermId
					,T.intTermID
					,CT.intContractTextId
					,W1.intWeightGradeId
					,W2.intWeightGradeId
					,IB.intInsuranceById
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
					,AN.intAssociationId
					,IT.intInvoiceTypeId
					,AB.intCityId
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
						) x
				LEFT JOIN tblICCommodity C ON C.strCommodityCode = x.strCommodityCode
				LEFT JOIN tblICUnitMeasure U2 ON U2.strUnitMeasure = x.strHeaderUnitMeasure
				LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intUnitMeasureId = U2.intUnitMeasureId
					AND CM.intCommodityId = C.intCommodityId
				LEFT JOIN tblARSalesperson SP ON SP.strSalespersonId = x.strSalespersonId
				LEFT JOIN tblCTCropYear YR ON YR.strCropYear = x.strCropYear
				LEFT JOIN tblCTPosition PO ON PO.strPosition = x.strPosition
				LEFT JOIN tblCTPricingType PT ON PT.strPricingType = x.strPricingType
				LEFT JOIN tblEMEntity CE ON CE.strName = x.strCreatedBy
					AND CE.strEntityNo <> ''
				JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
					AND ET1.strType = 'User'
				LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = x.strFreightTerm
				LEFT JOIN tblSMTerm T ON T.strTerm = x.strTerm
				LEFT JOIN tblCTContractText CT ON CT.strTextCode = x.strTextCode
				LEFT JOIN tblCTWeightGrade W1 ON W1.strWeightGradeDesc = x.strGrade
				LEFT JOIN tblCTWeightGrade W2 ON W2.strWeightGradeDesc = x.strWeight
				LEFT JOIN tblCTInsuranceBy IB ON IB.strInsuranceBy = x.strInsuranceBy
				LEFT JOIN tblCTAssociation AN ON AN.strName = x.strAssociationName
				LEFT JOIN tblCTInvoiceType IT ON IT.strInvoiceType = x.strInvoiceType
				LEFT JOIN tblSMCity AB ON AB.strCity = x.strArbitration

				EXEC uspCTGetTableDataInXML '#tmpContractHeader'
					,NULL
					,@strTblXML OUTPUT
					,'tblCTContractHeader'

				IF NOT EXISTS (
						SELECT *
						FROM tblCTContractHeader
						WHERE intContractHeaderRefId = @intContractHeaderRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'

				EXEC uspCTValidateContractHeader @strTblXML
					,@strRowState

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
						,CH.strContractNumber = CH1.strContractNumber
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

				INSERT INTO #tmpContractDetail (
					intContractHeaderId
					,intItemId
					,intItemUOMId
					,intContractSeq
					,intStorageScheduleRuleId
					,dtmEndDate
					,dblQuantity
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
					,dblOriginalQty
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
					)
				SELECT @intNewContractHeaderId
					,I.intItemId
					,IU.intItemUOMId
					,x.intContractSeq
					,SR.intStorageScheduleRuleId
					,x.dtmEndDate
					,x.dblOriginalQty
					,CS.intContractStatusId
					,x.dblBalance
					,x.dtmStartDate
					,PU.intItemUOMId
					,GETDATE() AS dtmCreated
					,1 AS intConcurrencyId
					,@intUserId intCreatedById
					,FM.intFutureMarketId
					,MO.intFutureMonthId
					,x.dblFutures
					,x.dblBasis
					,x.dblCashPrice
					,x.strRemark
					,PT.intPricingTypeId
					,x.dblTotalCost
					,CU.intCurrencyID
					,U1.intUnitMeasureId
					,x.dblAvailableNetWeight
					,IU.intItemUOMId
					,GETDATE()
					,@intCompanyLocationId
					,intContractDetailId
					,FT.intFreightTermId
					,x.strItemSpecification
					,x.dblOriginalQty
					,x.intDiscountTypeId
					,@intToBookId
					,LP.intCityId
					,DP.intCityId
					,DC.intCityId
					,strVessel
					,strLoadingPointType
					,strDestinationPointType
					,SL.intStorageLocationId
					,SB.intCompanyLocationSubLocationId
					,x.strGrade
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
				FROM OPENXML(@idoc, 'vyuCTContractDetailViews/vyuCTContractDetailView', 2) WITH (
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
						,strStorageLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strGarden NVARCHAR(128) Collate Latin1_General_CI_AS
						,strGrade NVARCHAR(128) Collate Latin1_General_CI_AS
						,intUnitsPerLayer INT
						,intLayersPerPallet INT
						,dtmEventStartDate DATETIME
						,dtmPlannedAvailabilityDate DATETIME
						,dtmUpdatedAvailabilityDate DATETIME
						,intContainerTypeId INT
						,intNumberOfContainers INT
						,strPackingDescription nvarchar(100)Collate Latin1_General_CI_AS
						,dblYield NUMERIC(18, 6)
						) x
				JOIN tblICItem I ON I.strItemNo = x.strItemNo
				JOIN tblICUnitMeasure U1 ON U1.strUnitMeasure = x.strItemUOM
				JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
					AND U1.intUnitMeasureId = IU.intUnitMeasureId
				LEFT JOIN tblGRStorageScheduleRule SR ON SR.strScheduleDescription = x.strScheduleDescription
				LEFT JOIN tblCTContractStatus CS ON CS.strContractStatus = x.strContractStatus
				LEFT JOIN tblICUnitMeasure U2 ON U2.strUnitMeasure = x.strPriceUOM
				LEFT JOIN tblICItemUOM PU ON PU.intItemId = I.intItemId
					AND U2.intUnitMeasureId = IU.intUnitMeasureId
				LEFT JOIN tblRKFutureMarket FM ON FM.strFutMarketName = x.strFutMarketName
				LEFT JOIN tblRKFuturesMonth MO ON MO.strFutureMonth = x.strFutureMonth
				LEFT JOIN tblCTPricingType PT ON PT.strPricingType = x.strPricingType
				LEFT JOIN tblSMFreightTerms FT ON FT.strFreightTerm = x.strFreightTerm
				LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strCurrency
				LEFT JOIN tblSMCity LP ON LP.strCity = x.strLoadingPoint
				LEFT JOIN tblSMCity DP ON DP.strCity = x.strDestinationPoint
				LEFT JOIN tblSMCity DC ON DC.strCity = x.strDestinationCity
				LEFT JOIN tblICStorageLocation SL ON SL.strName = x.strStorageLocationName
				LEFT JOIN tblSMCompanyLocationSubLocation SB ON SB.strSubLocationName = x.strSubLocationName

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
						SET intItemId = CD1.intItemId
							,intItemUOMId = CD1.intItemUOMId
							,intStorageScheduleRuleId = CD1.intStorageScheduleRuleId
							,dtmEndDate = CD1.dtmEndDate
							,dblQuantity = CD1.dblQuantity
							,intContractStatusId = CD1.intContractStatusId
							,dblBalance = CD1.dblBalance
							,dtmStartDate = CD1.dtmStartDate
							,intPriceItemUOMId = CD1.intPriceItemUOMId
							--,dtmCreated=CD1.dtmCreated
							,intConcurrencyId = CD.intConcurrencyId + 1
							--,intCreatedById=CD1.intCreatedById
							,intFutureMarketId = CD1.intFutureMarketId
							,intFutureMonthId = CD1.intFutureMonthId
							,dblFutures = CD1.dblFutures
							,dblBasis = CD1.dblBasis
							,dblCashPrice = CD1.dblCashPrice
							,strRemark = CD1.strRemark
							,intPricingTypeId = CD1.intPricingTypeId
							,dblTotalCost = CD1.dblTotalCost
							,intCurrencyId = CD1.intCurrencyId
							,intUnitMeasureId = CD1.intUnitMeasureId
							,dblNetWeight = CD1.dblNetWeight
							,intNetWeightUOMId = CD1.intNetWeightUOMId
							,dtmM2MDate = CD1.dtmM2MDate
							,intCompanyLocationId = CD1.intCompanyLocationId
						FROM tblCTContractDetail CD
						JOIN #tmpContractDetail CD1 ON CD.intContractSeq = CD1.intContractSeq
						WHERE CD.intContractHeaderId = @intContractHeaderId

						SELECT @intContractDetailId = intContractDetailId
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @intContractHeaderId
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
				SELECT IM.intItemId
					,EY.intEntityId
					,strCostMethod
					,CY.intCurrencyID
					,dblRate
					,IU.intItemUOMId
					,RT.intCurrencyExchangeRateTypeId
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
						) CC
				JOIN tblICItem IM ON IM.strItemNo = CC.strItemNo
				LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = CC.strUOM
				LEFT JOIN tblICItemUOM IU ON IU.intItemId = IM.intItemId
					AND UM.intUnitMeasureId = IU.intUnitMeasureId
				LEFT JOIN tblSMCurrency CY ON CY.strCurrency = CC.strCurrency
				LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
				LEFT JOIN tblEMEntity EY ON EY.strName = CC.strVendorName
				LEFT JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
					AND ET.strType = 'Vendor'
				LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.strCurrencyExchangeRateType = CC.strCurrencyExchangeRateType

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
							AND CC.intContractCostRefId = x.intContractCostId
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
				JOIN tblCTContractCost CC ON CC.intContractCostRefId = x.intContractCostId

				DELETE CC
				FROM tblCTContractCost CC
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
				WHERE CD.intContractHeaderId = @intNewContractHeaderId
					AND NOT EXISTS (
						SELECT *
						FROM #tmpContractCost x
						WHERE CC.intContractCostRefId = x.intContractCostId
						)

				/*DECLARE @idoc INT
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
			WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId*/
				------------------------------------------------------------Document-----------------------------------------------------
				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strDocumentXML

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
				LEFT JOIN tblCTCondition C ON C.strConditionName = x.strConditionName

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
			AND strRowState = 'Added'
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
