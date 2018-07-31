CREATE VIEW [dbo].[vyuICGetShipmentAddSalesContract]
AS
--intKey = CAST(ROW_NUMBER() OVER(ORDER BY intCompanyLocationId, intEntityId, intContractDetailId) AS INT)
SELECT	strOrderType = 'Sales Contract'
		, strSourceType = 'None'
		, intLocationId = intCompanyLocationId
		, strShipFromLocation = strLocationName
		, intEntityCustomerId = intEntityId
		, strCustomerNumber = strEntityNumber
		, strCustomerName = strEntityName
		, intLineNo = intContractDetailId
		, intOrderId = intContractHeaderId
		, strOrderNumber = strContractNumber
		, intSourceId = NULL
		, strSourceNumber = NULL
		, Item.intItemId
		, Item.strItemNo
		, strItemDescription = Item.strDescription
		, Item.strBundleType
		, Item.strLotTracking
		, Item.intCommodityId
		, intSubLocationId = intCompanyLocationSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName = strStorageLocationName
		, intOrderUOMId = ContractView.intItemUOMId
		, strOrderUOM = strItemUOM
		, dblOrderUOMConvFactor = dblItemUOMCF
		, ContractView.intItemUOMId
		, strItemUOM = ContractView.strItemUOM
		, dblItemUOMConv = dblItemUOMCF
		, intWeightUOMId = ContractView.intNetWeightUOMId
		, strWeightUOM = weightUOM.strUnitMeasure
		, dblWeightItemUOMConv = dblItemUOMCF
		, dblQtyOrdered = CASE WHEN ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END
		, dblQtyAllocated = CAST(ISNULL(dblAllocatedQty, 0) AS NUMERIC(18, 6))
		, dblQtyShipped = CAST(0 AS NUMERIC(18, 6))
		, dblUnitPrice = ISNULL(dblPricePerUnit, 0)
		, dblDiscount = CAST(0 AS NUMERIC(18, 6))
		, dblTotal = CAST(0 AS NUMERIC(18, 6))
		, dblQtyToShip = ISNULL(dblAvailableQty, 0)
		, dblPrice = ISNULL(dblSeqPrice, 0)
		, dblLineTotal = ISNULL(dblDetailQuantity, 0) * ISNULL(dblPricePerUnit, 0)
		, intGradeId = NULL
		, strGrade = NULL
		, strDestinationGrades = ContractView.strGrade
		, intDestinationGradeId = ContractView.intGradeId
		, strDestinationWeights = ContractView.strWeight
		, intDestinationWeightId = ContractView.intWeightId
		, intCurrencyId = ContractView.intCurrencyId
		, intForexRateTypeId = ContractView.intRateTypeId
		, strForexRateType = ContractView.strCurrencyExchangeRateType
		, dblForexRate = ContractView.dblRate
		, ContractView.intFreightTermId
		, ContractView.strFreightTerm
		, ContractView.intContractSeq
		, intPriceUOMId = ISNULL(ItemPriceUOM.intItemUOMId, ContractView.intItemUOMId) 
		, strPriceUOM = ISNULL(PriceUOM.strUnitMeasure, ContractView.strItemUOM) 
FROM	vyuCTContractAddOrdersLookup ContractView
		INNER JOIN tblICItem Item ON Item.intItemId = ContractView.intItemId
		INNER JOIN tblICItemUOM Iuom ON Iuom.intItemId = Item.intItemId AND Iuom.ysnStockUnit = 1
		LEFT JOIN (
			tblICItemUOM ItemPriceUOM INNER JOIN tblICUnitMeasure PriceUOM
				ON ItemPriceUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
		)
			ON ItemPriceUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, Iuom.intItemUOMId)
		LEFT JOIN (
			tblICItemUOM ItemWeightUOM INNER JOIN tblICUnitMeasure weightUOM
				ON ItemWeightUOM.intUnitMeasureId = weightUOM.intUnitMeasureId
		)
			ON ItemWeightUOM.intItemUOMId = ContractView.intNetWeightUOMId 
WHERE	ysnAllowedToShow = 1
		AND strContractType = 'Sale'
		AND ContractView.dblAvailableQty > 0
