CREATE VIEW [dbo].[vyuCTContStsPricingAndHedging]

AS 

	SELECT	SY.intAssignFuturesToContractSummaryId,
			CD.intContractDetailId,
			PD.dtmFixationDate,
			PD.[dblNoOfLots],
			PD.dblFinalPrice,
			CM.strUnitMeasure strPricingUOM,
			SY.dtmMatchDate,
			SY.intHedgedLots,
			FO.dblPrice,
			MM.strUnitMeasure strHedgeUOM
	FROM	tblRKAssignFuturesToContractSummary SY 
	JOIN	tblRKFutOptTransaction				FO	ON	FO.intFutOptTransactionId		=	SY.intFutOptTransactionId	
	JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId			=	FO.intFutureMarketId		
	JOIn	tblICUnitMeasure					MM	ON	MM.intUnitMeasureId				=	MA.intUnitMeasureId			LEFT
	JOIN	tblCTPriceFixationDetail			PD	ON	PD.intFutOptTransactionId		=	SY.intFutOptTransactionId	LEFT
	JOIN	tblCTPriceFixation					PF	ON	PF.intPriceFixationId			=	PD.intPriceFixationId		LEFT
	JOIN	tblCTContractHeader					CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId		LEFT
	JOIN	tblCTContractDetail					CD	ON	CD.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN  CD.intContractDetailId	ELSE PF.intContractDetailId	END
													AND	CD.intContractHeaderId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN  PF.intContractHeaderId	ELSE CD.intContractHeaderId	END	LEFT
	
	JOIN	tblICCommodityUnitMeasure			CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId		LEFT
	JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CD.intItemId				
													AND	IU.intUnitMeasureId				=	CU.intUnitMeasureId			LEFT
	JOIN	tblICUnitMeasure					CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId	
	WHERE	PF.intPriceFixationId IS NOT NULL