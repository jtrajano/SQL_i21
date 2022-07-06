CREATE PROCEDURE dbo.uspCTImportContractFromCsv
	@intUserId INT,
	@guiUniqueId UNIQUEIDENTIFIER
AS

DECLARE @XML NVARCHAR(MAX)
DECLARE @intContractHeaderId INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @idoc INT
DECLARE @strTblXML NVARCHAR(MAX)
DECLARE @intEntityId INT
DECLARE @intContractDetailId INT
DECLARE @SQL NVARCHAR(MAX)

			
EXEC sp_xml_preparedocument @idoc OUTPUT, @XML

IF OBJECT_ID('tempdb..#tmpContractHeader') IS NOT NULL  					
	DROP TABLE #tmpContractHeader					

SELECT * INTO #tmpContractHeader FROM tblCTContractHeader WHERE 1 = 2

SELECT @SQL =  STUFF((SELECT ' ALTER TABLE #tmpContractHeader ALTER COLUMN '+COLUMN_NAME+' ' + DATA_TYPE + 
CASE	WHEN DATA_TYPE LIKE '%varchar' THEN '('+LTRIM(CHARACTER_MAXIMUM_LENGTH)+')' 
		WHEN DATA_TYPE = 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
		ELSE ''
END + ' NULL' 
FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpContractHeader%' AND IS_NULLABLE = 'NO' AND COLUMN_NAME <> 'intContractHeaderId' FOR xml path('')) ,1,1,'')
	
EXEC sp_executesql @SQL 

IF OBJECT_ID('tempdb..#tmpContractDetail') IS NOT NULL  					
	DROP TABLE #tmpContractDetail					

SELECT * INTO #tmpContractDetail FROM tblCTContractDetail WHERE 1 = 2

SELECT @SQL =  STUFF((SELECT ' ALTER TABLE #tmpContractDetail ALTER COLUMN '+COLUMN_NAME+' ' + DATA_TYPE + 
CASE	WHEN DATA_TYPE LIKE '%varchar' THEN '('+LTRIM(CHARACTER_MAXIMUM_LENGTH)+')' 
		WHEN DATA_TYPE = 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
		ELSE ''
END + ' NULL' 
FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpContractDetail%' AND IS_NULLABLE = 'NO' AND COLUMN_NAME <> 'intContractDetailId' FOR xml path('')) ,1,1,'')
	
EXEC sp_executesql @SQL 

IF OBJECT_ID('tempdb..#tmpExtracted') IS NOT NULL  					
	DROP TABLE #tmpExtracted	
	
CREATE TABLE #tmpExtracted
( intContractImportId INT,
	intContractTypeId			INT,			intEntityId			INT,			dtmContractDate		DATETIME,		strContractNumber	NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intCommodityId				INT,			intCommodityUOMId	INT,			dblHeaderQuantity	NUMERIC(18,6),	intSalespersonId	INT,
	ysnSigned					BIT,			ysnPrinted			BIT,			intCropYearId		INT,			intPositionId		INT,


	intContractStatusId			INT,			intContractSeq		INT,			dtmStartDate		DATETIME,		dtmEndDate			DATETIME,
	intCompanyLocationId		INT,			intItemId			INT,			intItemUOMId		INT,			dblQuantity			NUMERIC(18,6),
	dblBalance					NUMERIC(18,6),	intPricingTypeId	INT,			intFutureMarketId	INT,			intFutureMonthId	INT,
	dblFutures					NUMERIC(18,6),	dblBasis			NUMERIC(18,6),	dblCashPrice		NUMERIC(18,6),	intPriceItemUOMId	INT,
	intStorageScheduleRuleId	INT,			intCurrencyId		INT,			dtmCreated			DATETIME,		intCreatedById		INT,
	intConcurrencyId			INT,			dblTotalCost		NUMERIC(18,6),	intUnitMeasureId	INT,			strRemark			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmM2MDate					DATETIME
); 

IF OBJECT_ID('tempdb..#tmpXMLHeader') IS NOT NULL  					
	DROP TABLE #tmpXMLHeader	

IF ISNULL(@XML,'') <> ''
BEGIN
	SELECT	@intEntityId	=	intEntityId
	FROM	OPENXML(@idoc, 'overrides',2)
	WITH
	(
			intEntityId		INT
	)
END


INSERT	INTO #tmpExtracted
(
	intContractImportId, intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblHeaderQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,
	intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
	intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId, dtmM2MDate
)
SELECT	DISTINCT CI.intContractImportId,			intContractTypeId	=	CASE WHEN CI.strContractType IN ('B','Purchase') THEN 1 ELSE 2 END,
		intEntityId			=	EY.intEntityId,			dtmContractDate				=	CI.dtmContractDate,
		intCommodityId		=	CM.intCommodityId,		intCommodityUOMId			=	CU.intCommodityUnitMeasureId,
		dblHeaderQuantity	=	CI.dblQuantity,			intSalespersonId			=	SY.intEntityId,	
		ysnSigned			=	0,						strContractNumber			=	CI.strContractNumber,
		ysnPrinted			=	0,						intCropYearId				=	CP.intCropYearId,
		intPositionId		=	PN.intPositionId,

		intItemId			=	IM.intItemId,			intItemUOMId				=	QU.intItemUOMId,
		intContractSeq		=	CI.intContractSeq,						intStorageScheduleRuleId	=	NULL,
		dtmEndDate			=	CI.dtmEndDate,			intCompanyLocationId		=	CL.intCompanyLocationId, 
		dblQuantity			=	CI.dblQuantity,			intContractStatusId			=	1,
		dblBalance			=	CI.dblQuantity,			dtmStartDate				=	CI.dtmStartDate,
		intPriceItemUOMId	=	QU.intItemUOMId,		dtmCreated					=	GETDATE(),
		intConcurrencyId	=	1,						intCreatedById				=	@intUserId,
		intFutureMarketId	=	MA.intFutureMarketId,	intFutureMonthId			=	MO.intFutureMonthId,
		dblFutures			=	CI.dblFutures,			dblBasis					=	CI.dblBasis,
		dblCashPrice		=	CI.dblCashPrice,		strRemark					=	CI.strRemark,
		intPricingTypeId	=	CASE	WHEN	MA.intFutureMarketId IS NOT NULL AND CI.dblCashPrice IS NOT NULL
										THEN	1
										WHEN	MA.intFutureMarketId IS NOT NULL AND CI.dblCashPrice IS NULL AND CI.dblFutures IS NOT NULL
										THEN	3
										WHEN	MA.intFutureMarketId IS NOT NULL AND CI.dblCashPrice IS NULL AND CI.dblBasis IS NOT NULL
										THEN	2
										WHEN	MA.intFutureMarketId IS NULL AND CI.dblCashPrice IS NOT NULL
										THEN	6
										ELSE	4
								END,
		dblTotalCost		=	CI.dblCashPrice * CI.dblQuantity,
		intCurrencyId		=	CY.intCurrencyID,
		intUnitMeasureId	=	QU.intUnitMeasureId,
		dtmM2MDate 			= 	ISNULL(CI.dtmM2MDate,getdate())

FROM	tblCTContractImport			CI	LEFT
JOIN	tblICItem					IM	ON	IM.strItemNo		=	CI.strItem				LEFT
JOIN	tblICUnitMeasure			IU	ON	IU.strUnitMeasure	=	CI.strQuantityUOM		LEFT
JOIN	tblICItemUOM				QU	ON	QU.intItemId		=	IM.intItemId		
										AND	QU.intUnitMeasureId	=	IU.intUnitMeasureId		LEFT
JOIN	tblICCommodity				CM	ON	CM.strCommodityCode	=	CI.strCommodity			LEFT
JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CM.intCommodityId	 		
										AND	CU.intUnitMeasureId =	IU.intUnitMeasureId		LEFT
JOIN	tblSMCurrency				CY	ON	CY.strCurrency		=	CI.strCurrency			LEFT
JOIN	tblSMCompanyLocation		CL	ON	CL.strLocationName	=	CI.strLocationName		LEFT
JOIN	tblCTCropYear				CP	ON	CP.strCropYear		=	CI.strCropYear			
										AND	CP.intCommodityId	=	CM.intCommodityId		LEFT
JOIN	tblCTPosition				PN	ON	PN.strPosition		=	CI.strPosition			LEFT
JOIN	tblRKFutureMarket			MA	ON	LTRIM(RTRIM(LOWER(MA.strFutMarketName))) =	LTRIM(RTRIM(LOWER(CI.strFutMarketName)))		LEFT
JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMarketId=	MA.intFutureMarketId
										AND	MONTH(MO.dtmFutureMonthsDate) = CI.intMonth
										AND	(YEAR(MO.dtmFutureMonthsDate) % 100) = CI.intYear		LEFT
JOIN	vyuCTEntity					EY	ON	EY.strEntityName				=	CI.strEntityName	
										AND ISNULL(EY.strEntityNumber,'')	= ISNULL(CI.strEntityNo,'')	
										AND	EY.strEntityType	=	CASE WHEN CI.strContractType IN ('B','Purchase') THEN 'Vendor' ELSE 'Customer' END LEFT
JOIN	vyuCTEntity					SY	ON	SY.strEntityName	=	CI.strSalesperson
										AND	SY.strEntityType	=	'Salesperson'	
WHERE CI.guiUniqueId = @guiUniqueId

IF EXISTS(SELECT * FROM #tmpExtracted)
BEGIN
	DECLARE @intContractImportId INT
	DECLARE @intContractTypeId INT
	DECLARE @intContractEntityId INT
	DECLARE @dtmContractDate DATETIME
	DECLARE @intCommodityId INT
	DECLARE @intCommodityUOMId INT
	DECLARE @dblQuantity INT
	DECLARE @intSalespersonId INT
	DECLARE @ysnSigned BIT
	DECLARE @strContractNumber NVARCHAR(200)
	DECLARE @ysnPrinted BIT
	DECLARE @intCropYearId INT
	DECLARE @intPositionId INT
	DECLARE @intPricingTypeId INT
	DECLARE @intCreatedById INT
	DECLARE @dtmCreated DATETIME
	DECLARE @intConcurrencyId INT
	DECLARE @ysnReceivedSignedFixationLetter BIT
	DECLARE @ysnReadOnlyInterCoContract BIT
	DECLARE @Date DATETIME = GETUTCDATE()

	DECLARE cur CURSOR LOCAL FAST_FORWARD
	FOR
	SELECT DISTINCT	MAX(intContractImportId), intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,MAX(dblHeaderQuantity),intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId,MAX(intCreatedById),MAX(dtmCreated),1, 0, 0
	FROM	#tmpExtracted
	GROUP BY intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,
		intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId

	OPEN cur

	FETCH NEXT FROM cur INTO
	      @intContractImportId
		, @intContractTypeId
		, @intContractEntityId
		, @dtmContractDate
		, @intCommodityId
		, @intCommodityUOMId
		, @dblQuantity
		, @intSalespersonId
		, @ysnSigned
		, @strContractNumber
		, @ysnPrinted
		, @intCropYearId
		, @intPositionId
		, @intPricingTypeId
		, @intCreatedById
		, @dtmCreated
		, @intConcurrencyId
		, @ysnReceivedSignedFixationLetter
		, @ysnReadOnlyInterCoContract

	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN TRY
		DELETE FROM #tmpContractHeader

		INSERT INTO #tmpContractHeader(intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId,intCreatedById,dtmCreated,intConcurrencyId, ysnReceivedSignedFixationLetter, ysnReadOnlyInterCoContract)
		SELECT @intContractTypeId
			, @intContractEntityId
			, @dtmContractDate
			, @intCommodityId
			, @intCommodityUOMId
			, @dblQuantity
			, @intSalespersonId
			, @ysnSigned
			, @strContractNumber
			, @ysnPrinted
			, @intCropYearId
			, @intPositionId
			, @intPricingTypeId
			, @intCreatedById
			, @dtmCreated
			, @intConcurrencyId
			, @ysnReceivedSignedFixationLetter
			, @ysnReadOnlyInterCoContract

		EXEC uspCTGetTableDataInXML '#tmpContractHeader', null, @strTblXML OUTPUT,'tblCTContractHeader'
		EXEC uspCTValidateContractHeader @strTblXML,'Added'

		INSERT INTO tblCTContractHeader (
			  intContractTypeId
			, intEntityId
			, dtmContractDate
			, intCommodityId
			, intCommodityUOMId
			, dblQuantity
			, intSalespersonId
			, ysnSigned
			, strContractNumber
			, ysnPrinted
			, intCropYearId
			, intPositionId
			, intPricingTypeId
			, intCreatedById
			, dtmCreated
			, intConcurrencyId
			, ysnReceivedSignedFixationLetter
			, ysnReadOnlyInterCoContract
		)
		VALUES (
			  @intContractTypeId
			, @intContractEntityId
			, @dtmContractDate
			, @intCommodityId
			, @intCommodityUOMId
			, @dblQuantity
			, @intSalespersonId
			, @ysnSigned
			, @strContractNumber
			, @ysnPrinted
			, @intCropYearId
			, @intPositionId
			, @intPricingTypeId
			, @intCreatedById
			, @dtmCreated
			, @intConcurrencyId
			, @ysnReceivedSignedFixationLetter
			, @ysnReadOnlyInterCoContract
		)

		SET @intContractHeaderId = SCOPE_IDENTITY()

		DELETE FROM #tmpContractDetail

		INSERT	INTO #tmpContractDetail(intContractHeaderId,intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
			intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId,dblNetWeight,intNetWeightUOMId,dtmM2MDate, ysnProvisionalPNL, ysnFinalPNL
		)
		SELECT
			  @intContractHeaderId
			, intItemId
			, intItemUOMId
			, intContractSeq
			, intStorageScheduleRuleId
			, dtmEndDate
			, intCompanyLocationId
			, dblQuantity
			, intContractStatusId
			, dblBalance
			, dtmStartDate
			, intPriceItemUOMId
			, dtmCreated
			, intConcurrencyId
			, intCreatedById
			, intFutureMarketId
			, intFutureMonthId
			, dblFutures
			, dblBasis
			, dblCashPrice
			, strRemark
			, intPricingTypeId
			, dblTotalCost
			, intCurrencyId
			, intUnitMeasureId
			, dblQuantity
			, intItemUOMId
			, dtmM2MDate
			, 0
			, 0
		FROM #tmpExtracted
		WHERE
				ISNULL(intContractTypeId, 0) = ISNULL(@intContractTypeId, 0)
			AND ISNULL(intEntityId, 0) = ISNULL(@intContractEntityId, 0)
			AND ISNULL(dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
			AND ISNULL(intCommodityId, 0) = ISNULL(@intCommodityId, 0)
			AND ISNULL(intCommodityUOMId, 0) = ISNULL(@intCommodityUOMId, 0)
			AND ISNULL(dblQuantity, 0) = ISNULL(@dblQuantity, 0)
			AND ISNULL(intSalespersonId, 0) = ISNULL(@intSalespersonId, 0)
			AND ISNULL(ysnSigned, 0) = ISNULL(@ysnSigned, 0)
			AND ISNULL(strContractNumber, '') = ISNULL(@strContractNumber, '')
			AND ISNULL(ysnPrinted, 0) = ISNULL(@ysnPrinted, 0)
			AND ISNULL(intCropYearId, 0) = ISNULL(@intCropYearId, 0)
			AND ISNULL(intPositionId, 0) = ISNULL(@intPositionId, 0)
			AND ISNULL(intPricingTypeId, 0) = ISNULL(@intPricingTypeId, 0)

		EXEC uspCTGetTableDataInXML '#tmpContractDetail', null, @strTblXML OUTPUT,'tblCTContractDetail'
		EXEC uspCTValidateContractDetail @strTblXML, 'Added'

		INSERT INTO tblCTContractDetail (
			  intContractHeaderId
			, intItemId
			, intItemUOMId
			, intContractSeq
			, intStorageScheduleRuleId
			, dtmEndDate
			, intCompanyLocationId
			, dblQuantity
			, intContractStatusId
			, dblBalance
			, dtmStartDate
			, intPriceItemUOMId
			, dtmCreated
			, intConcurrencyId
			, intCreatedById
			, intFutureMarketId
			, intFutureMonthId
			, dblFutures
			, dblBasis
			, dblCashPrice
			, strRemark
			, intPricingTypeId
			, dblTotalCost
			, intCurrencyId
			, intUnitMeasureId
			, dblNetWeight
			, intNetWeightUOMId
			, dtmM2MDate
			, ysnProvisionalPNL
			, ysnFinalPNL)
		SELECT
			  @intContractHeaderId
			, intItemId
			, intItemUOMId
			, intContractSeq
			, intStorageScheduleRuleId
			, dtmEndDate
			, intCompanyLocationId
			, dblQuantity
			, intContractStatusId
			, dblBalance
			, dtmStartDate
			, intPriceItemUOMId
			, dtmCreated
			, intConcurrencyId
			, intCreatedById
			, intFutureMarketId
			, intFutureMonthId
			, dblFutures
			, dblBasis
			, dblCashPrice
			, strRemark
			, intPricingTypeId
			, dblTotalCost
			, intCurrencyId
			, intUnitMeasureId
			, dblQuantity
			, intItemUOMId
			, dtmM2MDate
			, 0
			, 0
		FROM #tmpExtracted
		WHERE
				ISNULL(intContractTypeId, 0) = ISNULL(@intContractTypeId, 0)
			AND ISNULL(intEntityId, 0) = ISNULL(@intContractEntityId, 0)
			AND ISNULL(dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
			AND ISNULL(intCommodityId, 0) = ISNULL(@intCommodityId, 0)
			AND ISNULL(intCommodityUOMId, 0) = ISNULL(@intCommodityUOMId, 0)
			AND ISNULL(intSalespersonId, 0) = ISNULL(@intSalespersonId, 0)
			AND ISNULL(ysnSigned, 0) = ISNULL(@ysnSigned, 0)
			AND ISNULL(strContractNumber, '') = ISNULL(@strContractNumber, '')
			AND ISNULL(ysnPrinted, 0) = ISNULL(@ysnPrinted, 0)
			AND ISNULL(intCropYearId, 0) = ISNULL(@intCropYearId, 0)
			AND ISNULL(intPositionId, 0) = ISNULL(@intPositionId, 0)
			AND ISNULL(intPricingTypeId, 0) = ISNULL(@intPricingTypeId, 0)

		UPDATE tblCTContractHeader
		SET dblQuantity = (SELECT SUM(dblQuantity) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId)
		WHERE intContractHeaderId = @intContractHeaderId

		EXEC uspCTCreateDetailHistory	@intContractHeaderId = @intContractHeaderId, 
										@intContractDetailId = NULL,
										@strSource			 = 'Contract',
										@strProcess		     = 'Create Contract',
										@intUserId			 = @intUserId
	
		UPDATE	tblCTContractImport
		SET		ysnImported				=	1,
				intImportedById			=	@intUserId,
				dtmImported				=	GETDATE(),
				intContractHeaderId		=	@intContractHeaderId,
				ysnIsProcessed			=   1
		WHERE	guiUniqueId = @guiUniqueId AND intContractImportId = @intContractImportId

		END TRY
		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE() 
			UPDATE	tblCTContractImport
			SET		ysnImported			=	0,
					intImportedById		=	@intUserId,
					dtmImported			=	GETDATE(),
					strErrorMsg			=	@ErrMsg,
					ysnIsProcessed		=   1
			WHERE	guiUniqueId = @guiUniqueId AND intContractImportId = @intContractImportId
		END CATCH

		FETCH NEXT FROM cur INTO
			  @intContractImportId
			, @intContractTypeId
			, @intContractEntityId
			, @dtmContractDate
			, @intCommodityId
			, @intCommodityUOMId
			, @dblQuantity
			, @intSalespersonId
			, @ysnSigned
			, @strContractNumber
			, @ysnPrinted
			, @intCropYearId
			, @intPositionId
			, @intPricingTypeId
			, @intCreatedById
			, @dtmCreated
			, @intConcurrencyId
			, @ysnReceivedSignedFixationLetter
			, @ysnReadOnlyInterCoContract

	END

	CLOSE cur;
	DEALLOCATE cur;
END