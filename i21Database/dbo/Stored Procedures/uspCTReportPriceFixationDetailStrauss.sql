CREATE PROCEDURE [dbo].[uspCTReportPriceFixationDetailStrauss]
	@xmlParam NVARCHAR(MAX) = NULL	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE
		@intPriceFixationId		INT,
		@xmlDocumentId			INT,
		@intContractHeaderId	int,
		@intContractDetailId	int;

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)   
    
	SELECT	@intPriceFixationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPriceFixationId'

	select @intContractHeaderId = intContractHeaderId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
			
	SELECT	DISTINCT 
			PF.intPriceFixationId,
			PD.dtmFixationDate,
			strFutMarketName = MA.strFutMarketName,
			MO.strFutureMonth,
			dblNoOfLots = CASE WHEN CP.strLotCalculationType = 'Round' THEN  dbo.fnRemoveTrailingZeroes(ROUND(PD.[dblNoOfLots],2))
							   WHEN CP.strLotCalculationType = 'Actual' THEN  dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots])
						  ELSE dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) END,
			strPrice = dbo.fnCTChangeNumericScale(PD.dblFutures,ISNULL(CP.intPricingDecimals,2)) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure,
			PD.strNotes
	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	cross apply	(	select top 1 cd1.*
					from tblCTContractDetail cd1
					where cd1.intContractHeaderId = 
													case
													when isnull(@intContractDetailId,0) = 0
													then @intContractHeaderId
													else cd1.intContractHeaderId
													end
						  and cd1.intContractDetailId =
						  							case
						  							when isnull(@intContractDetailId,0) = 0
						  							then cd1.intContractDetailId
						  							else @intContractDetailId 
						  							end
				) CD
	--CROSS APPLY dbo.fnCTGetTopOneSequence(PF.intContractHeaderId,PF.intContractDetailId) CD
	LEFT	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId	
	LEFT	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId		
	LEFT	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		
	LEFT	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId		
	LEFT	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId
	CROSS 	APPLY	tblCTCompanyPreference 		CP
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO