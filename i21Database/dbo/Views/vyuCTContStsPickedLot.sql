
Create VIEW [dbo].[vyuCTContStsPickedLot]

AS

	SELECT	PL.intPickLotDetailId,
			AD.intPContractDetailId intContractDetailId,
			LH.[strPickLotNumber],
			LT.strLotNumber,
			LT.strMarkings,
			dbo.fnCTConvertQuantityToTargetItemUOM(LT.intItemId,PL.intLotUnitMeasureId,LP.intWeightUOMId,PL.dblLotPickedQty) dblPickedQty
			,strWarrantStatus = CASE LT.intWarrantStatus  
									  WHEN 1 THEN 'Pledged'  
									  WHEN 2 THEN 'Partially Released'  
									  WHEN 3 THEN 'Released'  
								END COLLATE Latin1_General_CI_AS  
	FROM	tblLGPickLotDetail		PL
	JOIN	tblLGPickLotHeader		LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
	JOIN	tblICLot				LT	ON	LT.intLotId					=	PL.intLotId
	JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId	CROSS	
	APPLY	tblLGCompanyPreference	LP 	

	UNION ALL

	SELECT	PL.intPickLotDetailId,
			AD.intSContractDetailId intContractDetailId,
			LH.[strPickLotNumber],
			LT.strLotNumber,
			LT.strMarkings,
			dbo.fnCTConvertQuantityToTargetItemUOM(LT.intItemId,PL.intSaleUnitMeasureId,LP.intWeightUOMId,PL.dblSalePickedQty)  dblPickedQty
			,strWarrantStatus = CASE LT.intWarrantStatus  
									  WHEN 1 THEN 'Pledged'  
									  WHEN 2 THEN 'Partially Released'  
									  WHEN 3 THEN 'Released'  
								END COLLATE Latin1_General_CI_AS  
	FROM	tblLGPickLotDetail		PL
	JOIN	tblLGPickLotHeader		LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
	JOIN	tblICLot				LT	ON	LT.intLotId					=	PL.intLotId
	JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId	CROSS	
	APPLY	tblLGCompanyPreference		LP
GO



