CREATE VIEW vyuRKM2MContractCost
AS
SELECT CC.intContractDetailId, 		
			CC.dblRate,
			IU.intUnitMeasureId,
			CD.intItemId
FROM		tblCTContractCost	CC
JOIN		tblCTContractDetail CD ON CD.intContractDetailId	=	CC.intContractDetailId
JOIN  tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId

