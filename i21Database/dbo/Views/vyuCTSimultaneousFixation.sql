CREATE VIEW [dbo].[vyuCTSimultaneousFixation]

AS 

SELECT	*,ISNULL(dblFutures,0)+ISNULL(dblBasis,0)+ISNULL(dblAdditionalCost,0) AS dblFinalPrice,dblBasis - ISNULL(dblRollArb,0) AS dblOriginalBasis
FROM	
(
	SELECT	PF.intPriceFixationId,
			CD.intContractDetailId,
			CD.intContractSeq,
			PF.[dblLotsFixed]/CH.dblQuantity * dbo.fnCTConvertQuantityToTargetCommodityUOM(QM.intCommodityUnitMeasureId,CH.intCommodityUOMId ,CD.dblQuantity) dblFixedLots,
			dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,CU.intCommodityUnitMeasureId,CD.dblFutures) dblFutures,
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
				JOIN	tblCTContractDetail		DL	ON	DL.intContractDetailId	=	CC.intContractDetailId	
				JOIN	tblCTContractHeader		HR	ON	HR.intContractHeaderId	=	DL.intContractHeaderId	
				JOIN	tblCTPriceFixation			PX	ON	PX.intContractHeaderId	=	DL.intContractHeaderId		
				JOIN	tblICItemUOM				TU	ON	TU.intItemUOMId			=	DL.intItemUOMId
				JOIN	tblICCommodityUnitMeasure	YM	ON	YM.intCommodityId		=	HR.intCommodityId		AND 
															YM.intUnitMeasureId		=	TU.intUnitMeasureId		LEFT	
				JOIN	tblICItemUOM				IU	ON	IU.intItemUOMId			=	CC.intItemUOMId			LEFT
				JOIN	tblICCommodityUnitMeasure	CM	ON	CM.intCommodityId		=	CD.intCommodityId		AND 
															CM.intUnitMeasureId		=	IU.intUnitMeasureId
				WHERE	CC.intContractDetailId = CD.intContractDetailId 
				AND		ISNULL(CC.ysnBasis,0) <> 1
			) dblAdditionalCost,
			PF.intFinalPriceUOMId
			
	FROM	tblCTPriceFixation			PF
	JOIN	vyuCTContractSequence		CD	ON	CD.intContractHeaderId	=	PF.intContractHeaderId
	JOIN	tblCTContractHeader			CH  ON  CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICItemUOM				IM	ON	IM.intItemUOMId			=	CD.intPriceItemUOMId
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CD.intCommodityId		AND 
												CU.intUnitMeasureId		=	IM.intUnitMeasureId
	JOIN  tblICItemUOM                  TU  ON  TU.intItemUOMId			=   CD.intItemUOMId
    JOIN  tblICCommodityUnitMeasure     QM  ON  QM.intCommodityId       =   CD.intCommodityId       AND 
												QM.intUnitMeasureId     =   TU.intUnitMeasureId     
	WHERE	PF.intContractDetailId IS NULL
)t


