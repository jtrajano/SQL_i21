CREATE PROCEDURE [dbo].[uspCTReportPriceFixationDetail]
		
	@intPriceFixationId INT = NULL
	
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
			@strContractDocuments	NVARCHAR(MAX)
			
	SELECT	DISTINCT 
			PF.intPriceFixationId,
			PD.dtmFixationDate,
			CONVERT(NVARCHAR(50),PD.dtmFixationDate,106) AS dtmFixationDateDesc,
			isnull(rtrt.strTranslation,MA.strFutMarketName),
			MO.strFutureMonth,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) AS [dblNoOfLots],
			LTRIM(PD.dblFutures) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt2.strTranslation,CM.strUnitMeasure) strPrice,
			PD.strNotes,
			LTRIM(CAST(ROUND(PD.dblFutures,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt2.strTranslation,CM.strUnitMeasure) strPriceDesc,
			FLOOR(PD.[dblNoOfLots]) AS intNoOfLots,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) + ' Lot(s) fixed ' + 
			isnull(rtrt.strTranslation,MA.strFutMarketName) +  ' '  + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) + ' at ' + 
			dbo.fnRemoveTrailingZeroes(PD.dblFutures) + CY.strCurrency + '-' + isnull(rtrt2.strTranslation,CM.strUnitMeasure)	AS strGABPrice
				
	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractHeaderId			=	PF.intContractHeaderId	
											AND	CD.intContractDetailId			=	CASE	WHEN	PF.intContractDetailId IS NOT NULL 
																							THEN	PF.intContractDetailId 
																							ELSE	CD.intContractDetailId 
																					END						LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId		LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId
	
	left join tblCTContractHeader ch on ch.intContractHeaderId = CD.intContractHeaderId
	left join tblEMEntity				rte on rte.intEntityId = ch.intEntityId

	inner join tblSMScreen				rts on rts.strNamespace = 'RiskManagement.view.FuturesMarket'
	left join tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = MA.intFutureMarketId
	left join tblSMReportTranslation	rtrt on rtrt.intLanguageId = rte.intLanguageId and rtrt.intTransactionId = rtt.intTransactionId
	
	inner join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.InventoryUOM'
	left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = CM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = rte.intLanguageId and rtrt2.intTransactionId = rtt2.intTransactionId
			
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId

	/*
	SELECT	DISTINCT 
			PF.intPriceFixationId,
			PD.dtmFixationDate,
			CONVERT(NVARCHAR(50),PD.dtmFixationDate,106) AS dtmFixationDateDesc,
			MA.strFutMarketName,
			MO.strFutureMonth,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) AS [dblNoOfLots],
			LTRIM(PD.dblFutures) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strPrice,
			PD.strNotes,
			LTRIM(CAST(ROUND(PD.dblFutures,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strPriceDesc,
			FLOOR(PD.[dblNoOfLots]) AS intNoOfLots,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) + ' Lot(s) fixed ' + 
			MA.strFutMarketName +  ' '  + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) + ' at ' + 
			dbo.fnRemoveTrailingZeroes(PD.dblFutures) + CY.strCurrency + '-' + CM.strUnitMeasure	AS strGABPrice
				
	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractHeaderId			=	PF.intContractHeaderId	
											AND	CD.intContractDetailId			=	CASE	WHEN	PF.intContractDetailId IS NOT NULL 
																							THEN	PF.intContractDetailId 
																							ELSE	CD.intContractDetailId 
																					END						LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId		LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId			
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	*/
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO