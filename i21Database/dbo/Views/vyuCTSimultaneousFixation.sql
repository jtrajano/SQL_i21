﻿CREATE VIEW [dbo].[vyuCTSimultaneousFixation]

AS 

SELECT	*,dblFutures+dblBasis+dblAdditionalCost AS dblFinalPrice
FROM	
(
	SELECT	CD.intContractSeq,
			PF.intLotsFixed/dblHeaderQuantity * dbo.fnCTConvertQuantityToTargetCommodityUOM(CU.intCommodityUnitMeasureId,CD.intCommodityUnitMeasureId,CD.dblDetailQuantity) dblFixedLots,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,CU.intCommodityUnitMeasureId,CD.dblFutures) dblFutures,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,CU.intCommodityUnitMeasureId,CD.dblOriginalBasis) dblOriginalBasis,
			PF.dblRollArb,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,CU.intCommodityUnitMeasureId,CD.dblBasis) dblBasis,
			(
				SELECT	SUM(
								CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
											dbo.fnCTConvertQuantityToTargetCommodityUOM(PX.intFinalPriceUOMId,CM.intCommodityUnitMeasureId,CC.dblRate)
										WHEN	CC.strCostMethod = 'Amount'		THEN
											CC.dblRate
										WHEN	CC.strCostMethod = 'Percentage' THEN 
											dbo.fnCTConvertQuantityToTargetCommodityUOM(PX.intFinalPriceUOMId,YM.intCommodityUnitMeasureId,DL.dblCashPrice) * CC.dblRate / 100
								END
							) 
				FROM	tblCTContractCost			CC 
				JOIN	vyuCTContractDetailView		DL	ON	DL.intContractDetailId	=	CC.intContractDetailId	
				JOIN	tblCTPriceFixation			PX	ON	PX.intContractHeaderId	=	DL.intContractHeaderId		
				JOIN	tblICItemUOM				TU	ON	TU.intItemUOMId			=	DL.intItemUOMId
				JOIN	tblICCommodityUnitMeasure	YM	ON	YM.intCommodityId		=	DL.intCommodityId		AND 
															YM.intUnitMeasureId		=	TU.intUnitMeasureId		LEFT	
				JOIN	tblICItemUOM				IU	ON	IU.intItemUOMId			=	CC.intItemUOMId			LEFT
				JOIN	tblICCommodityUnitMeasure	CM	ON	CM.intCommodityId		=	CD.intCommodityId		AND 
															CM.intUnitMeasureId		=	IU.intUnitMeasureId
				WHERE CC.intContractDetailId = CD.intContractDetailId
			) dblAdditionalCost
	FROM	tblCTPriceFixationDetail	FD
	JOIN	tblCTPriceFixation			PF	ON	PF.intPriceFixationId	=	FD.intPriceFixationId
	JOIN	vyuCTContractDetailView		CD	ON	CD.intContractHeaderId	=	PF.intContractHeaderId
	JOIN	tblICItemUOM				IM	ON	IM.intItemUOMId			=	CD.intItemUOMId
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CD.intCommodityId AND 
												CU.intUnitMeasureId		=	IM.intUnitMeasureId
	WHERE	PF.intContractDetailId IS NULL
)t


