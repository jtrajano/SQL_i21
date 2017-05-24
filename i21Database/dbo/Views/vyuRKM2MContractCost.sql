CREATE VIEW vyuRKM2MContractCost
AS
SELECT CC.intContractDetailId, 		
			CC.dblRate,
			IU.intUnitMeasureId,
			CC.intItemId,
			CH.intContractBasisId

FROM		tblCTContractCost	CC
JOIN		tblCTContractDetail CD ON CD.intContractDetailId	=	CC.intContractDetailId
join		tblCTContractHeader CH ON CH.intContractHeaderId	=	CD.intContractHeaderId
JOIN  tblICItemUOM		IU 
ON IU.intItemUOMId		=	CC.intItemUOMId

