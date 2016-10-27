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
			

	
	SELECT	PF.intPriceFixationId,
			PD.dtmFixationDate,
			MA.strFutMarketName,
			MO.strFutureMonth,
			PD.[dblNoOfLots],
			LTRIM(PD.dblFutures) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strPrice,
			PD.strNotes
	
	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId	LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId		LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId			
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO