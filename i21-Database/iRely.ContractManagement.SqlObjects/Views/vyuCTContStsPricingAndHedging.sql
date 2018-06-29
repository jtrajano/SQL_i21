CREATE VIEW [dbo].[vyuCTContStsPricingAndHedging]

AS 

	SELECT	SY.intAssignFuturesToContractSummaryId,
			PD.intPriceFixationDetailId,
			CD.intContractDetailId,
			PD.dtmFixationDate,
			PD.[dblNoOfLots],
			PD.dblFinalPrice,
			CM.strUnitMeasure strPricingUOM,
			SY.dtmMatchDate,
			SY.intHedgedLots,
			FO.dblPrice,
			MM.strUnitMeasure strHedgeUOM,
			PF.intPriceContractId,
			PC.strPriceContractNo

	FROM	tblCTPriceFixationDetail			PD
	JOIN	tblCTPriceFixation					PF	ON	PF.intPriceFixationId			=	PD.intPriceFixationId		
	JOIN	tblCTPriceContract					PC	ON	PC.intPriceContractId			=	PF.intPriceContractId		LEFT
	JOIN	tblRKAssignFuturesToContractSummary SY 	ON	SY.intFutOptTransactionId		=	PD.intFutOptTransactionId	LEFT
	JOIN	tblRKFutOptTransaction				FO	ON	FO.intFutOptTransactionId		=	SY.intFutOptTransactionId	LEFT
	JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId			=	FO.intFutureMarketId		LEFT
	JOIN	tblICUnitMeasure					MM	ON	MM.intUnitMeasureId				=	MA.intUnitMeasureId			LEFT
	JOIN	tblCTContractHeader					CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId		LEFT
	JOIN	tblCTContractDetail					CD	ON	CD.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN  CD.intContractDetailId	ELSE PF.intContractDetailId	END
													AND	CD.intContractHeaderId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN  PF.intContractHeaderId	ELSE CD.intContractHeaderId	END	LEFT
	JOIN	tblICCommodityUnitMeasure			CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId		LEFT
	JOIN	tblICItemUOM						IU	ON	IU.intItemId					=	CD.intItemId				
													AND	IU.intUnitMeasureId				=	CU.intUnitMeasureId			LEFT
	JOIN	tblICUnitMeasure					CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId	
	WHERE	PF.intPriceFixationId IS NOT NULL