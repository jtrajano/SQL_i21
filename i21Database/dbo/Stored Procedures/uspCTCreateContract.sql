﻿CREATE PROCEDURE [dbo].[uspCTCreateContract]
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50),
	@intUserId				INT,
	@XML					NVARCHAR(MAX),
	@intContractHeaderId	INT	OUTPUT,
	@intEntityId			INT	= NULL
AS
BEGIN TRY

	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@strStartingNumber			NVARCHAR(100),
			@strTblXML					NVARCHAR(MAX),

			@intContractTypeId			INT,
			@intCommodityId				INT,
			@dblHeaderQuantity			NUMERIC(18,6),
			@intCommodityUOMId			INT,
			@strContractNumber			NVARCHAR(100),
			@dtmContractDate			DATETIME,
			@intSalespersonId			INT,
			
			@intContractDetailId		INT,
			@intContractSeq				INT,
			@intCompanyLocationId		INT,
			@dtmStartDate				DATETIME,
			@dtmEndDate					DATETIME,
			@intContractStatusId		INT,
			@intItemId					INT,
			@dblQuantity				NUMERIC(18,6),
			@intItemUOMId				INT,
			@dblBalance					NUMERIC(18,6),
			@intPricingTypeId			INT,
			@intStorageScheduleRuleId	INT,
			@intCreatedById				INT,
			@dtmCreated					DATETIME,
			@SQL						NVARCHAR(MAX)
				
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
	(
		intContractTypeId			INT,			intEntityId			INT,			dtmContractDate		DATETIME,		strContractNumber	NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		intCommodityId				INT,			intCommodityUOMId	INT,			dblHeaderQuantity	NUMERIC(18,6),	intSalespersonId	INT,
		ysnSigned					BIT,			ysnPrinted			BIT,			intCropYearId		INT,			intPositionId		INT,


		intContractStatusId			INT,			intContractSeq		INT,			dtmStartDate		DATETIME,		dtmEndDate			DATETIME,
		intCompanyLocationId		INT,			intItemId			INT,			intItemUOMId		INT,			dblQuantity			NUMERIC(18,6),
		dblBalance					NUMERIC(18,6),	intPricingTypeId	INT,			intFutureMarketId	INT,			intFutureMonthId	INT,
		dblFutures					NUMERIC(18,6),	dblBasis			NUMERIC(18,6),	dblCashPrice		NUMERIC(18,6),	intPriceItemUOMId	INT,
		intStorageScheduleRuleId	INT,			intCurrencyId		INT,			dtmCreated			DATETIME,		intCreatedById		INT,
		intConcurrencyId			INT,			dblTotalCost		NUMERIC(18,6),	intUnitMeasureId	INT,			strRemark			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	); 

	IF OBJECT_ID('tempdb..#tmpXMLHeader') IS NOT NULL  					
		DROP TABLE #tmpXMLHeader	

	--IF ISNULL(@XML,'') <> ''
	--BEGIN
	--	SELECT	*
	--	INTO	#tmpXMLHeader
	--	FROM	OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader',2)
	--	WITH
	--	(
	--			intContractDetailId		INT,
	--			intConcurrencyId		INT,
	--			dblAdjAmount			NUMERIC(12,4)
	--	)
	--END

	IF	@strScreenName = 'Scale'
	BEGIN
		INSERT	INTO	#tmpExtracted
		(	intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblHeaderQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,
			intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPricingTypeId,dtmCreated,intConcurrencyId,intCreatedById,intUnitMeasureId
		)
		SELECT	intContractTypeId	=	CASE WHEN SC.strInOutFlag = 'I' THEN 1 ELSE 2 END,
				intEntityId			=	ISNULL(@intEntityId,SC.intEntityId),		dtmContractDate				=	SC.dtmTicketDateTime,
				intCommodityId		=	CM.intCommodityId,	intCommodityUOMId			=	CU.intCommodityUnitMeasureId,
				dblHeaderQuantity	=	0,					intSalespersonId			=	CP.intDefSalespersonId,	
				ysnSigned			=	0,					strContractNumber			=	CAST('' AS NVARCHAR(100)),
				ysnPrinted			=	0,

				intItemId			=	SC.intItemId,		intItemUOMId				=	SC.intItemUOMIdTo,
				intContractSeq		=	1,					intStorageScheduleRuleId	=	ISNULL(SP.intStorageScheduleId,SC.intStorageScheduleId),
				dtmEndDate			=	CP.dtmDefEndDate,	intCompanyLocationId		=	SC.intProcessingLocationId, 
				dblQuantity			=	0,					intContractStatusId			=	1,
				dblBalance			=	0,					dtmStartDate				=	SC.dtmTicketDateTime,
				intPricingTypeId	=	5,					dtmCreated					=	GETDATE(),
				intConcurrencyId	=	1,					intCreatedById				=	@intUserId,
				intUnitMeasureId	=	QU.intUnitMeasureId
												
		FROM	tblSCTicket					SC	CROSS 
		JOIN	tblCTCompanyPreference		CP
		JOIN	tblICItem					IM	ON	IM.intItemId		=	SC.intItemId
		JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId		=	SC.intItemUOMIdTo
		JOIN	tblICCommodity				CM	ON	CM.intCommodityId	=	IM.intCommodityId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CM.intCommodityId
												AND	CU.intUnitMeasureId =	QU.intUnitMeasureId	LEFT 
		JOIN	tblSCTicketSplit			SP	ON	SP.intTicketId		=	SC.intTicketId
												AND	SP.intCustomerId	=	ISNULL(@intEntityId,SC.intEntityId)
		WHERE	SC.intTicketId	= @intExternalId	

		SELECT	@strStartingNumber = CASE WHEN intContractTypeId = 1 THEN 'PurchaseContract' ELSE 'SaleContract' END FROM #tmpExtracted
		EXEC	@strContractNumber = uspCTGetStartingNumber @strStartingNumber
		UPDATE	#tmpExtracted SET strContractNumber = @strContractNumber
	END

	IF	@strScreenName = 'Contract Import'
	BEGIN
		INSERT	INTO	#tmpExtracted
		(
			intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblHeaderQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,
			intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
			intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId
		)
		SELECT	DISTINCT			intContractTypeId	=	CASE WHEN CI.strContractType IN ('B','Purchase') THEN 1 ELSE 2 END,
				intEntityId			=	EY.intEntityId,			dtmContractDate				=	CI.dtmStartDate,
				intCommodityId		=	CM.intCommodityId,		intCommodityUOMId			=	CU.intCommodityUnitMeasureId,
				dblHeaderQuantity	=	CI.dblQuantity,			intSalespersonId			=	SY.intEntityId,	
				ysnSigned			=	0,						strContractNumber			=	CI.strContractNumber,
				ysnPrinted			=	0,						intCropYearId				=	CP.intCropYearId,
				intPositionId		=	PN.intPositionId,

				intItemId			=	IM.intItemId,			intItemUOMId				=	QU.intItemUOMId,
				intContractSeq		=	1,						intStorageScheduleRuleId	=	NULL,
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
				intUnitMeasureId	=	QU.intUnitMeasureId

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
		JOIN	tblRKFutureMarket			MA	ON	MA.strFutMarketName	=	CI.strFutMarketName		LEFT
		JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMarketId=	MA.intFutureMarketId
												AND	MONTH(MO.dtmFutureMonthsDate)	=	CI.intMonth
												AND	YEAR(MO.dtmFutureMonthsDate)	=	CI.intYear		LEFT
		JOIN	vyuCTEntity					EY	ON	EY.strEntityName				=	CI.strEntityName	
												AND ISNULL(EY.strEntityNumber,'')	= ISNULL(CI.strEntityNo,'')	
												AND	EY.strEntityType	=	CASE WHEN CI.strContractType IN ('B','Purchase') THEN 'Vendor' ELSE 'Customer' END LEFT
		JOIN	vyuCTEntity					SY	ON	SY.strEntityName	=	CI.strSalesperson
												AND	SY.strEntityType	=	'Salesperson'
		
		WHERE	intContractImportId	= @intExternalId
	END

	IF EXISTS(SELECT * FROM #tmpExtracted)
	BEGIN
		INSERT	INTO #tmpContractHeader(intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId,intCreatedById,dtmCreated,intConcurrencyId)
		SELECT	intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblHeaderQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId,intCreatedById,dtmCreated,intConcurrencyId
		FROM	#tmpExtracted
		
		EXEC	uspCTGetTableDataInXML '#tmpContractHeader',null,@strTblXML OUTPUT,'tblCTContractHeader'
		EXEC	uspCTValidateContractHeader @strTblXML,'Added'
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractHeader',@strTblXML,@intContractHeaderId OUTPUT
		
		INSERT	INTO #tmpContractDetail
				(
					intContractHeaderId,intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
					intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId
				)
		SELECT	@intContractHeaderId,intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
				intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId
		FROM	#tmpExtracted

		EXEC	uspCTGetTableDataInXML '#tmpContractDetail',null,@strTblXML OUTPUT,'tblCTContractDetail'
		EXEC	uspCTValidateContractDetail @strTblXML,'Added'
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractDetail',@strTblXML,@intContractDetailId OUTPUT
	END


END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
