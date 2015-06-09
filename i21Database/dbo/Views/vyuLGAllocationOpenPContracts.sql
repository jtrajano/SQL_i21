CREATE VIEW vyuLGAllocationOpenPContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq, 
			IM.intOriginId, 
			CD.intItemId, 					IM.strDescription 			AS strItemDescription,
			CH.intContractBasisId,
			CB.strContractBasis											AS strINCOTerm,
			CD.dblQuantity												AS dblDetailQuantity,
			CD.intUnitMeasureId, 			
			UM.strUnitMeasure,
			UM.strUnitType,
			CD.intPricingTypeId intPricingType,
			CD.dblBasis,
			CU.strCurrency												AS strBasisCurrency,
			CD.dtmStartDate,
			CD.dtmEndDate,
			IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) AS dblAllocatedQuantity,
			IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId, R.intPurchaseSale Having CD.intContractDetailId = R.intContractDetailId AND R.intPurchaseSale = 1), 0) AS dblReservedQuantity,
			CD.dblQuantity - IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId, R.intPurchaseSale Having CD.intContractDetailId = R.intContractDetailId AND R.intPurchaseSale = 1 ), 0) AS dblOpenQuantity,
			CD.dblQuantity - IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) AS dblUnAllocatedQuantity,
			CD.dblQuantity - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId, R.intPurchaseSale Having CD.intContractDetailId = R.intContractDetailId AND R.intPurchaseSale = 1), 0) AS dblUnReservedQuantity,

			CH.intContractTypeId intPurchaseSale,
			CH.intEntityId,
			EN.strName,
			EN.intDefaultLocationId as intEntityLocationId,
			CH.intContractNumber,
			CH.dtmContractDate,
			CH.intCommodityId,
			CD.intItemUOMId,
			CD.intCompanyLocationId
	FROM 	tblCTContractDetail 		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	CD.intUnitMeasureId
	LEFT JOIN	tblCTContractBasis		CB	ON	CB.intContractBasisId		=	CH.intContractBasisId
	LEFT JOIN	tblSMCurrency			CU	ON	CU.intCurrencyID		=	CD.intCurrencyId
	LEFT JOIN	tblEntity				EN	ON	EN.intEntityId				=	CH.intEntityId
	WHERE CD.dblQuantity - IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) > 0
	AND
	CD.dblQuantity - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId, R.intPurchaseSale Having CD.intContractDetailId = R.intContractDetailId AND R.intPurchaseSale = 1), 0) > 0
	AND
	CH.intContractTypeId=1

	