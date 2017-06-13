CREATE VIEW vyuLGAllocationOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq,
			Item.intOriginId, 
			Country.strCountry as strItemOrigin,
			CD.intItemId, 					
			Item.strDescription as strItemDescription,
			CH.intContractBasisId,
			CB.strContractBasis	AS strINCOTerm,
			CD.dblQuantity as dblDetailQuantity,
			CD.intUnitMeasureId,
			UOM.strUnitMeasure,
			UOM.strUnitType,
			CD.intPricingTypeId intPricingType,
			CD.dblBasis,
			Curr.strCurrency AS strBasisCurrency,
			CD.dtmStartDate,
			CD.dtmEndDate,
			IsNull(ALD.dblPAllocatedQty, 0) AS dblAllocatedQuantity,
			IsNull(R.dblPReservedQuantity, 0) AS dblReservedQuantity,
			CD.dblQuantity - IsNull(ALD.dblPAllocatedQty, 0) - IsNull(R.dblPReservedQuantity, 0) AS dblOpenQuantity,
			CD.dblQuantity - IsNull(ALD.dblPAllocatedQty, 0) AS dblUnAllocatedQuantity,
			CD.dblQuantity - IsNull(R.dblPReservedQuantity, 0) AS dblUnReservedQuantity,

			CH.intContractTypeId intPurchaseSale,
			CH.intEntityId,
			EN.strEntityName as strName,
			EN.intDefaultLocationId as intEntityLocationId,
			CH.strContractNumber,
			CH.dtmContractDate,
			CH.intCommodityId,
			CD.intItemUOMId,
			CD.intCompanyLocationId,
			CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END AS strPurchaseSale,
			Comm.strDescription as strCommodity,
			CL.strLocationName,
			CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT) AS ysnAllowedToShow,
			PT.strPricingType,
			CD.dblCashPrice,
			CD.dblAdjustment,
			CD.dblScheduleQty,
			CD.dblBalance

	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblSMCompanyLocation CL ON	CL.intCompanyLocationId	= CD.intCompanyLocationId
	JOIN vyuCTEntity EN ON EN.intEntityId = CH.intEntityId AND EN.strEntityType	= (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblSMCurrency Curr ON Curr.intCurrencyID = CD.intCurrencyId
	JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblSMCountry Country ON Country.intCountryID = Item.intOriginId
	LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = CH.intCommodityId
	LEFT JOIN (SELECT AD.intPContractDetailId, SUM(dblPAllocatedQty) dblPAllocatedQty FROM tblLGAllocationDetail AD GROUP BY AD.intPContractDetailId) ALD ON ALD.intPContractDetailId = CD.intContractDetailId
	LEFT JOIN (SELECT R.intContractDetailId, SUM(dblReservedQuantity) dblPReservedQuantity FROM tblLGReservation R GROUP BY R.intContractDetailId) R ON R.intContractDetailId = CD.intContractDetailId
	WHERE CD.dblQuantity - IsNull(ALD.dblPAllocatedQty, 0) > 0.0 AND CH.intContractTypeId = 1

	UNION ALL

	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq,
			Item.intOriginId, 
			Country.strCountry as strItemOrigin,
			CD.intItemId, 					
			Item.strDescription as strItemDescription,
			CH.intContractBasisId,
			CB.strContractBasis	AS strINCOTerm,
			CD.dblQuantity as dblDetailQuantity,
			CD.intUnitMeasureId,
			UOM.strUnitMeasure,
			UOM.strUnitType,
			CD.intPricingTypeId intPricingType,
			CD.dblBasis,
			Curr.strCurrency AS strBasisCurrency,
			CD.dtmStartDate,
			CD.dtmEndDate,
			IsNull(ALD.dblSAllocatedQty, 0) AS dblAllocatedQuantity,
			IsNull(R.dblSReservedQuantity, 0) AS dblReservedQuantity,
			CD.dblQuantity - IsNull(ALD.dblSAllocatedQty, 0) - IsNull(R.dblSReservedQuantity, 0) AS dblOpenQuantity,
			CD.dblQuantity - IsNull(ALD.dblSAllocatedQty, 0) AS dblUnAllocatedQuantity,
			CD.dblQuantity - IsNull(R.dblSReservedQuantity, 0) AS dblUnReservedQuantity,

			CH.intContractTypeId intPurchaseSale,
			CH.intEntityId,
			EN.strEntityName as strName,
			EN.intDefaultLocationId as intEntityLocationId,
			CH.strContractNumber,
			CH.dtmContractDate,
			CH.intCommodityId,
			CD.intItemUOMId,
			CD.intCompanyLocationId,
			CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END AS strPurchaseSale,
			Comm.strDescription as strCommodity,
			CL.strLocationName,
			CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT) AS ysnAllowedToShow,
			PT.strPricingType,
			CD.dblCashPrice,
			CD.dblAdjustment,
			CD.dblScheduleQty,
			CD.dblBalance

	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblSMCompanyLocation CL ON	CL.intCompanyLocationId	= CD.intCompanyLocationId
	JOIN vyuCTEntity EN ON EN.intEntityId = CH.intEntityId AND EN.strEntityType	= (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblSMCurrency Curr ON Curr.intCurrencyID = CD.intCurrencyId
	JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblSMCountry Country ON Country.intCountryID = Item.intOriginId
	LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = CH.intCommodityId
	LEFT JOIN (SELECT AD.intSContractDetailId, SUM(dblSAllocatedQty) dblSAllocatedQty FROM tblLGAllocationDetail AD GROUP BY AD.intSContractDetailId) ALD ON ALD.intSContractDetailId = CD.intContractDetailId
	LEFT JOIN (SELECT R.intContractDetailId, SUM(dblReservedQuantity) dblSReservedQuantity FROM tblLGReservation R GROUP BY R.intContractDetailId) R ON R.intContractDetailId = CD.intContractDetailId
	WHERE CD.dblQuantity - IsNull(ALD.dblSAllocatedQty, 0) > 0.0 AND CH.intContractTypeId = 2
