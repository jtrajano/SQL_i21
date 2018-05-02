CREATE VIEW vyuLGAllocationOpenContracts
AS
	SELECT 	CD.intContractDetailId, 
			CD.intContractHeaderId, 
			CD.intContractSeq,
			Item.intOriginId, 
			Country.strCountry as strItemOrigin,
			Country.intCountryID,
			CD.intItemId, 					
			Item.strItemNo,
			Item.strDescription as strItemDescription,
			CH.intContractBasisId,
			CB.strContractBasis	AS strINCOTerm,
			CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance ELSE CD.dblQuantity END as dblDetailQuantity,
			CD.intUnitMeasureId,
			UOM.strUnitMeasure,
			UOM.strUnitType,
			CD.intPricingTypeId intPricingType,
			CD.dblBasis,
			Curr.strCurrency AS strBasisCurrency,
			CD.dtmStartDate,
			CD.dtmEndDate,
			IsNull(CD.dblAllocatedQty, 0) AS dblAllocatedQuantity,
			IsNull(CD.dblReservedQty, 0) AS dblReservedQuantity,
			CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance ELSE CD.dblQuantity END - IsNull(CD.dblAllocatedQty, 0) - IsNull(CD.dblReservedQty, 0) - IsNull(CD.dblAllocationAdjQty, 0) AS dblOpenQuantity,
			CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance ELSE CD.dblQuantity END - IsNull(CD.dblAllocatedQty, 0) - IsNull(CD.dblAllocationAdjQty, 0) AS dblUnAllocatedQuantity,
			CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance ELSE CD.dblQuantity END - IsNull(CD.dblReservedQty, 0) AS dblUnReservedQuantity,

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
			CAST(CASE WHEN CD.intContractStatusId IN (1,4,5,6) THEN 1 ELSE 0 END AS BIT) AS ysnAllowedToShow,
			PT.strPricingType,
			CD.dblCashPrice,
			CD.dblAdjustment,
			CD.dblScheduleQty,
			CD.dblBalance,
			CD.strItemSpecification,
			CD.intBookId,
			BO.strBook,
			CD.intSubBookId, 
			SB.strSubBook

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
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCountry Country ON Country.intCountryID = CA.intCountryID
	LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = CH.intCommodityId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	WHERE CD.dblQuantity - IsNull(CD.dblAllocatedQty, 0) - IsNull(CD.dblAllocationAdjQty, 0) > 0.0