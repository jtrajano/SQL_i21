CREATE VIEW [dbo].[vyuCTContractCostView]
	
AS 

	SELECT	CC.intContractCostId,
			CC.intContractDetailId,
			CC.intItemId,
			CC.intVendorId,
			CC.strCostMethod,
			CC.dblRate,
			CC.intItemUOMId,
			CC.ysnAccrue,
			CC.ysnMTM,
			CC.ysnPrice ,
			IM.strItemNo,
			UM.strUnitMeasure AS strUOM,
			EY.strEntityName AS strVendorName,
			CD.intContractHeaderId,
			IU.intUnitMeasureId

	FROM	tblCTContractCost	CC
	JOIN	tblCTContractDetail CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
	JOIN	tblICItem			IM	ON	IM.intItemId			=	CC.intItemId
	JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CC.intItemUOMId
	JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	IU.intUnitMeasureId
	JOIN	vyuCTEntity			EY	ON	EY.intEntityId			=	CC.intVendorId AND 
										EY.strEntityType		=	'Vendor'
