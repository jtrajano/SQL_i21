CREATE VIEW [dbo].[vyuCTContStsPickedLot]

AS

	SELECT	PL.intPickLotDetailId,
			AD.intPContractDetailId intContractDetailId,
			LH.[strPickLotNumber],
			LT.strLotNumber,
			LT.strMarkings,
			PL.dblLotPickedQty dblPickedQty
	FROM	tblLGPickLotDetail		PL
	JOIN	tblLGPickLotHeader		LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
	JOIN	tblICLot				LT	ON	LT.intLotId					=	PL.intLotId
	JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId

	UNION ALL

	SELECT	PL.intPickLotDetailId,
			AD.intSContractDetailId intContractDetailId,
			LH.[strPickLotNumber],
			LT.strLotNumber,
			LT.strMarkings,
			PL.dblSalePickedQty dblPickedQty
	FROM	tblLGPickLotDetail		PL
	JOIN	tblLGPickLotHeader		LH	ON	LH.intPickLotHeaderId		=	PL.intPickLotHeaderId
	JOIN	tblICLot				LT	ON	LT.intLotId					=	PL.intLotId
	JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	=	PL.intAllocationDetailId
