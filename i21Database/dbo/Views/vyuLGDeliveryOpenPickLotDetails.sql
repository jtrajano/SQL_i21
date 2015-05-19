CREATE VIEW vyuLGDeliveryOpenPickLotDetails
AS
SELECT	PL.intPickLotDetailId,
		PL.intPickLotHeaderId,
		PL.intAllocationDetailId,
		PL.intLotId,
		PL.dblSalePickedQty,
		PL.dblLotPickedQty,
		PL.intSaleUnitMeasureId,
		PL.intLotUnitMeasureId,
		PL.dblGrossWt,
		PL.dblTareWt,
		PL.dblNetWt,
		PL.intWeightUnitMeasureId,
		PL.dtmPickedDate,
		Lot.strLotNumber,
		Lot.strReceiptNumber,
		Lot.strMarkings,
		IM.strDescription as strItemDescription,
		CH.intContractNumber as intSContractNumber,
		CD.intContractSeq as intSContractSeq,
		UM.strUnitMeasure as strLotUnitMeasure
FROM	tblLGPickLotDetail		PL
JOIN	tblICLot				Lot	ON	Lot.intLotId				= PL.intLotId
JOIN	tblICItem				IM	ON	IM.intItemId				= Lot.intItemId
JOIN	tblLGAllocationDetail	AD	ON	AD.intAllocationDetailId	= PL.intAllocationDetailId
JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		= AD.intSContractDetailId
JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		= CD.intContractHeaderId
JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			= PL.intLotUnitMeasureId

