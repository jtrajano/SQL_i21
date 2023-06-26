CREATE VIEW vyuLGAllocationOpenContracts
AS
SELECT 	
	CD.intContractDetailId
	,CD.intContractHeaderId
	,CD.intContractSeq
	,Item.intOriginId
	,strItemOrigin = Country.strCountry
	,Country.intCountryID
	,CD.intItemId				
	,Item.strItemNo
	,strItemDescription = Item.strDescription
	,strBundleItemNo = BundleItem.strItemNo
	,ysnBundle = CAST(CASE WHEN (BundleItem.strType = 'Bundle') THEN 1 ELSE 0 END AS BIT)
	,intContractBasisId = CH.intFreightTermId
	,strINCOTerm = CB.strContractBasis
	,dblDetailQuantity = CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance ELSE CD.dblQuantity END
	,CD.intUnitMeasureId
	,UOM.strUnitMeasure
	,UOM.strUnitType
	,intPricingType = CD.intPricingTypeId
	,CD.dblBasis
	,strBasisCurrency = Curr.strCurrency
	,CD.dtmStartDate
	,CD.dtmEndDate
	,dblAllocatedQuantity = IsNull(CD.dblAllocatedQty, 0)
	,dblReservedQuantity = IsNull(CD.dblReservedQty, 0)
	,dblOpenQuantity = CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance 
							ELSE CD.dblQuantity END - IsNull(CD.dblAllocatedQty, 0) - IsNull(CD.dblReservedQty, 0) - IsNull(CD.dblAllocationAdjQty, 0)
	,dblUnAllocatedQuantity = CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance 
								ELSE CD.dblQuantity END - IsNull(CD.dblAllocatedQty, 0) - IsNull(CD.dblAllocationAdjQty, 0)
	,dblUnReservedQuantity = CASE WHEN CD.intContractStatusId = 6 THEN CD.dblQuantity - CD.dblBalance 
								ELSE CD.dblQuantity END - IsNull(CD.dblReservedQty, 0)
	,intPurchaseSale = CH.intContractTypeId
	,CH.intEntityId
	,strName = EN.strEntityName
	,intEntityLocationId = EN.intDefaultLocationId
	,CH.strContractNumber
	,CH.dtmContractDate
	,CH.intCommodityId
	,CD.intItemUOMId
	,CD.intCompanyLocationId
	,strPurchaseSale = CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END COLLATE Latin1_General_CI_AS
	,strCommodity = Comm.strDescription
	,CL.strLocationName
	,ysnAllowedToShow = CAST(CASE WHEN (CH.intContractTypeId = 1 AND CD.intContractStatusId IN (1,4,5,6)) 
									OR (CH.intContractTypeId = 2 AND CD.intContractStatusId IN (1, 4)) THEN 1 ELSE 0 END AS BIT)
	,PT.strPricingType
	,CD.dblCashPrice
	,CD.dblAdjustment
	,CD.dblScheduleQty
	,CD.dblBalance
	,CD.strItemSpecification
	,CD.intBookId
	,BO.strBook
	,CD.intSubBookId
	,SB.strSubBook
	,CD.intFutureMarketId
	,strFutureMarket = FMKT.strFutMarketName
	,CD.intFutureMonthId
	,FMTH.strFutureMonth
FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblSMCompanyLocation CL ON	CL.intCompanyLocationId	= CD.intCompanyLocationId
	JOIN vyuCTEntity EN ON EN.intEntityId = CH.intEntityId AND EN.strEntityType	= (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblSMCurrency Curr ON Curr.intCurrencyID = CD.intCurrencyId
	JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICItem BundleItem ON BundleItem.intItemId = CD.intItemBundleId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCountry Country ON Country.intCountryID = CA.intCountryID
	LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = CH.intCommodityId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	LEFT JOIN tblRKFutureMarket FMKT ON FMKT.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth FMTH ON FMTH.intFutureMonthId = CD.intFutureMonthId
WHERE CD.dblQuantity - IsNull(CD.dblAllocatedQty, 0) - IsNull(CD.dblAllocationAdjQty, 0) > 0.0
