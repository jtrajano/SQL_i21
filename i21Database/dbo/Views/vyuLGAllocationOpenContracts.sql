CREATE VIEW vyuLGAllocationOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq,
			Item.intOriginId, 
			Country.strCountry as strItemOrigin,
			CD.intItemId, 					
			CD.strItemDescription,
			CD.intContractBasisId,
			CD.strContractBasis											AS strINCOTerm,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.strItemUOM as strUnitMeasure,
			UOM.strUnitType,
			CD.intPricingTypeId intPricingType,
			CD.dblBasis,
			CD.strCurrency												AS strBasisCurrency,
			CD.dtmStartDate,
			CD.dtmEndDate,
			IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) AS dblAllocatedQuantity,
			IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId Having CD.intContractDetailId = R.intContractDetailId), 0) AS dblReservedQuantity,
			CD.dblDetailQuantity - IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId Having CD.intContractDetailId = R.intContractDetailId), 0) AS dblOpenQuantity,
			CD.dblDetailQuantity - IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) AS dblUnAllocatedQuantity,
			CD.dblDetailQuantity - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId Having CD.intContractDetailId = R.intContractDetailId), 0) AS dblUnReservedQuantity,

			CD.intContractTypeId intPurchaseSale,
			CD.intEntityId,
			CD.strEntityName as strName,
			CD.intDefaultLocationId as intEntityLocationId,
			CD.strContractNumber,
			CD.dtmContractDate,
			CD.intCommodityId,
			CD.intItemUOMId,
			CD.intCompanyLocationId,
			CASE WHEN CD.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END AS strPurchaseSale,
			CD.strCommodityDescription as strCommodity,
			CD.strLocationName
	FROM 	vyuCTContractDetailView 		CD
	LEFT JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	LEFT JOIN tblSMCountry Country ON Country.intCountryID = Item.intOriginId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CD.intUnitMeasureId
	WHERE CD.dblDetailQuantity - IsNull((SELECT SUM (AD.dblPAllocatedQty) from tblLGAllocationDetail AD Group By AD.intPContractDetailId Having CD.intContractDetailId = AD.intPContractDetailId), 0) > 0
	AND CD.intContractTypeId = 1

	UNION ALL

	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq,
			Item.intOriginId, 
			Country.strCountry as strItemOrigin,
			CD.intItemId, 					
			CD.strItemDescription,
			CD.intContractBasisId,
			CD.strContractBasis											AS strINCOTerm,
			CD.dblDetailQuantity,
			CD.intUnitMeasureId,
			CD.strItemUOM as strUnitMeasure,
			UOM.strUnitType,
			CD.intPricingTypeId intPricingType,
			CD.dblBasis,
			CD.strCurrency												AS strBasisCurrency,
			CD.dtmStartDate,
			CD.dtmEndDate,
			IsNull((SELECT SUM (AD.dblSAllocatedQty) from tblLGAllocationDetail AD Group By AD.intSContractDetailId Having CD.intContractDetailId = AD.intSContractDetailId), 0) AS dblAllocatedQuantity,
			IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId Having CD.intContractDetailId = R.intContractDetailId), 0) AS dblReservedQuantity,
			CD.dblDetailQuantity - IsNull((SELECT SUM (AD.dblSAllocatedQty) from tblLGAllocationDetail AD Group By AD.intSContractDetailId Having CD.intContractDetailId = AD.intSContractDetailId), 0) - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId Having CD.intContractDetailId = R.intContractDetailId), 0) AS dblOpenQuantity,
			CD.dblDetailQuantity - IsNull((SELECT SUM (AD.dblSAllocatedQty) from tblLGAllocationDetail AD Group By AD.intSContractDetailId Having CD.intContractDetailId = AD.intSContractDetailId), 0) AS dblUnAllocatedQuantity,
			CD.dblDetailQuantity - IsNull((SELECT SUM (R.dblReservedQuantity) from tblLGReservation R Group By R.intContractDetailId Having CD.intContractDetailId = R.intContractDetailId), 0) AS dblUnReservedQuantity,

			CD.intContractTypeId intPurchaseSale,
			CD.intEntityId,
			CD.strEntityName as strName,
			CD.intDefaultLocationId as intEntityLocationId,
			CD.strContractNumber,
			CD.dtmContractDate,
			CD.intCommodityId,
			CD.intItemUOMId,
			CD.intCompanyLocationId,
			CASE WHEN CD.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END AS strPurchaseSale,
			CD.strCommodityDescription as strCommodity,
			CD.strLocationName
	FROM 	vyuCTContractDetailView 		CD
	LEFT JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	LEFT JOIN tblSMCountry Country ON Country.intCountryID = Item.intOriginId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CD.intUnitMeasureId
	WHERE CD.dblDetailQuantity - IsNull((SELECT SUM (AD.dblSAllocatedQty) from tblLGAllocationDetail AD Group By AD.intSContractDetailId Having CD.intContractDetailId = AD.intSContractDetailId), 0) > 0
	AND CD.intContractTypeId = 2
	