CREATE PROCEDURE [dbo].[uspCTCreateContract]
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50),
	@intUserId				INT,
	@XML					NVARCHAR(MAX),
	@intContractHeaderId	INT	OUTPUT
AS
BEGIN TRY

	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@strStartingNumber			NVARCHAR(100),
			@strTblXML					NVARCHAR(MAX),

			@intContractTypeId			INT,
			@intEntityId				INT,
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
			@dtmCreated					DATETIME

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML

	IF OBJECT_ID('tempdb..#tmpContractHeader') IS NOT NULL  					
		DROP TABLE #tmpContractHeader					

	SELECT * INTO #tmpContractHeader FROM tblCTContractHeader WHERE 1 = 2

	IF OBJECT_ID('tempdb..#tmpContractDetail') IS NOT NULL  					
		DROP TABLE #tmpContractDetail					

	SELECT * INTO #tmpContractDetail FROM tblCTContractDetail WHERE 1 = 2

	IF OBJECT_ID('tempdb..#tmpExtracted') IS NOT NULL  					
		DROP TABLE #tmpExtracted	
	
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
		
		SELECT	intContractTypeId	=	CASE WHEN SC.strInOutFlag = 'I' THEN 1 ELSE 2 END,
				strStartingNumber	=	CASE WHEN SC.strInOutFlag = 'I' THEN 'PurchaseContract' ELSE 'SaleContract' END,
				intEntityId			=	SC.intEntityId,		dtmContractDate				=	SC.dtmTicketDateTime,
				intCommodityId		=	CM.intCommodityId,	intCommodityUOMId			=	CU.intCommodityUnitMeasureId,
				dblHeaderQuantity	=	0,					intSalespersonId			=	CP.intDefSalespersonId,	
				ysnSigned			=	0,					strContractNumber			=	CAST('' AS NVARCHAR(100)),
				ysnPrinted			=	0,

				intItemId			=	SC.intItemId,		intItemUOMId				=	SC.intItemUOMIdFrom,
				intContractSeq		=	1,					intStorageScheduleRuleId	=	SC.intStorageScheduleId,
				dtmEndDate			=	CP.dtmDefEndDate,	intCompanyLocationId		=	SC.intProcessingLocationId, 
				dblQuantity			=	0,					intContractStatusId			=	1,
				dblBalance			=	0,					dtmStartDate				=	SC.dtmTicketDateTime,
				intPricingTypeId	=	5,					dtmCreated					=	GETDATE(),
				intConcurrencyId	=	1,					intCreatedById				=	@intUserId
		INTO	#tmpExtracted								
		FROM	tblSCTicket					SC	CROSS 
		JOIN	tblCTCompanyPreference		CP
		JOIN	tblICItem					IM	ON	IM.intItemId		=	SC.intItemId
		JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId		=	SC.intItemUOMIdFrom
		JOIN	tblICCommodity				CM	ON	CM.intCommodityId	=	IM.intCommodityId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CM.intCommodityId	AND 
													CU.intUnitMeasureId =	QU.intUnitMeasureId
		WHERE	intTicketId	= @intExternalId	

		SELECT	@strStartingNumber = strStartingNumber FROM #tmpExtracted
		EXEC	@strContractNumber = uspCTGetStartingNumber @strStartingNumber
		UPDATE	#tmpExtracted SET strContractNumber = @strContractNumber
	END

	IF EXISTS(SELECT * FROM #tmpExtracted)
	BEGIN
		INSERT	INTO #tmpContractHeader(intContractTypeId,intEntityId,intCommodityId,dblQuantity,intCommodityUOMId,strContractNumber,dtmContractDate,intSalespersonId,intPricingTypeId,intCreatedById,dtmCreated,intConcurrencyId,ysnSigned,ysnPrinted)
		SELECT	intContractTypeId,intEntityId,intCommodityId,dblHeaderQuantity,intCommodityUOMId,strContractNumber,dtmContractDate,intSalespersonId,intPricingTypeId,intCreatedById,dtmCreated,intConcurrencyId,ysnSigned,ysnPrinted
		FROM	#tmpExtracted
		
		EXEC	uspCTGetTableDataInXML '#tmpContractHeader',null,@strTblXML OUTPUT,'tblCTContractHeader'
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractHeader',@strTblXML,@intContractHeaderId OUTPUT
		
		INSERT	INTO #tmpContractDetail(intContractHeaderId,intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPricingTypeId,dtmCreated,intCreatedById,intConcurrencyId)
		SELECT	@intContractHeaderId,intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPricingTypeId,dtmCreated,intCreatedById,intConcurrencyId
		FROM	#tmpExtracted

		EXEC	uspCTGetTableDataInXML '#tmpContractDetail',null,@strTblXML OUTPUT,'tblCTContractDetail'
		EXEC	uspCTInsertINTOTableFromXML 'tblCTContractDetail',@strTblXML,@intContractDetailId OUTPUT
	END


END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
