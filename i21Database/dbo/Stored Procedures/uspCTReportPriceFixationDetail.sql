CREATE PROCEDURE [dbo].[uspCTReportPriceFixationDetail]		
	@xmlParam NVARCHAR(MAX) = NULL	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX),
			@intLaguageId			INT = null,
			@strExpressionLabelName	NVARCHAR(50) = 'Expression',
			@strMonthLabelName		NVARCHAR(50) = 'Month',
			@intPriceFixationId		INT,
			@ysnEnableFXFieldInContractPricing BIT = 0;

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
    
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	/*Declared variables for translating expression*/
	declare @per nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'per'),'per');
	declare @at nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'at'),'at');
	declare @Lotsfixed nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Lot(s) fixed'),'Lot(s) fixed');

	select top 1 @ysnEnableFXFieldInContractPricing = ysnEnableFXFieldInContractPricing from tblCTCompanyPreference;
			
	SELECT	DISTINCT 
			PD.intPriceFixationDetailId,
			PF.intPriceFixationId,
			PD.dtmFixationDate,
			strFixationDate = datename(dd,PD.dtmFixationDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,datename(mm,PD.dtmFixationDate)),datename(mm,PD.dtmFixationDate)) + ' ' + datename(yyyy,PD.dtmFixationDate),
			CONVERT(NVARCHAR(50),PD.dtmFixationDate,106) AS dtmFixationDateDesc,
			isnull(rtrt.strTranslation,MA.strFutMarketName) AS strFutMarketName,
			MO.strFutureMonth,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) AS [dblNoOfLots],
			CASE WHEN CP.strDefaultContractReport IN ('ContractBeGreen') THEN CONVERT(NVARCHAR,CAST(PD.dblFutures  AS Money),1) 
				 WHEN CP.strDefaultPricingConfirmation IN ('PriceFixationWalter') THEN CONVERT(NVARCHAR,CAST(PD.dblFixationPrice  AS Money),1) 
				 ELSE dbo.fnCTChangeNumericScale(PD.dblFutures,2) END + ' ' 
				 + (CASE WHEN @ysnEnableFXFieldInContractPricing = 1 THEN SC.strCurrency ELSE CY.strCurrency END) + ' '+@per+' ' + (CASE WHEN CP.strDefaultPricingConfirmation IN ('PriceFixationWalter') THEN isnull(rtrt2.strTranslation,PM2.strUnitMeasure) ELSE  isnull(rtrt2.strTranslation,CM.strUnitMeasure) END) strPrice,
			PD.strNotes,
			LTRIM(CAST(ROUND(PD.dblFutures,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' '+@per+' ' + isnull(rtrt2.strTranslation,CM.strUnitMeasure) strPriceDesc,
			FLOOR(PD.[dblNoOfLots]) AS intNoOfLots,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) + ' '+@Lotsfixed+' ' + 
			isnull(rtrt.strTranslation,MA.strFutMarketName) +  ' '  + case when MO.dtmFutureMonthsDate is null then '' else isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,MO.dtmFutureMonthsDate)),DATENAME(mm,MO.dtmFutureMonthsDate)) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) end + ' '+@at+' ' + 
			dbo.fnRemoveTrailingZeroes(PD.dblFutures) + CY.strCurrency + '-' + isnull(rtrt2.strTranslation,CM.strUnitMeasure)	AS strGABPrice,
			CD.dblRatio,
			dbo.fnRemoveTrailingZeroes(PD.dblQuantity) + ' ' + CD.strItemUOM AS strQtyWithUOM,
			lblFX = CASE WHEN 
							  PD.dblFX != 1  AND PD.dblFX IS NOT NULL THEN 'FX' ELSE NULL  END,
			 CD.intInvoiceCurrencyId,
			 ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) as intMainCurrencyId,
			strFX = CASE WHEN CD.intInvoiceCurrencyId != ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) THEN LTRIM(CAST( PD.dblFX AS NUMERIC(18, 6))) 
						 WHEN CD.intInvoiceCurrencyId = ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) AND PD.dblFX = 1 THEN NULL
						 ELSE NULL END,
			dblFX = PD.dblFX,
		    ysnEnableFXFieldInContractPricing = @ysnEnableFXFieldInContractPricing

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	LEFT	JOIN tblCTPriceContract		PC	ON  PC.intPriceContractId			=   PF.intPriceContractId
	LEFT	JOIN tblSMCurrency			SC	ON  SC.intCurrencyID				=	PC.intFinalCurrencyId

	CROSS APPLY dbo.fnCTGetTopOneSequence(PF.intContractHeaderId,PF.intContractDetailId) CD					
	
	LEFT	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId	
	LEFT	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId		
	LEFT	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		
	LEFT	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId		
	LEFT	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId				

	LEFT	JOIN	tblSMScreen				rts on rts.strNamespace = 'RiskManagement.view.FuturesMarket'
	LEFT	JOIN	tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = MA.intFutureMarketId
	LEFT	JOIN	tblSMReportTranslation	rtrt on rtrt.intLanguageId = @intLaguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Market Name'

	LEFT	JOIN	tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.ReportTranslation'
	LEFT	JOIN	tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = CM.intUnitMeasureId
	LEFT	JOIN	tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'	
	LEFT	JOIN tblICUnitMeasure			PM2	ON	PM2.intUnitMeasureId			=	PD.intQtyItemUOMId

	CROSS JOIN tblCTCompanyPreference   CP		
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO