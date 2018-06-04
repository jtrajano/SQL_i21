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
		, strOrderUOM = CASE WHEN ContractView.ysnLoad = 1 THEN 'Load' ELSE ContractView.strItemUOM END
		, dblOrderUOMConvFactor = dblItemUOMCF
		, ContractView.intItemUOMId
		, strItemUOM = ContractView.strItemUOM
		, dblItemUOMConv = dblItemUOMCF
		, intWeightUOMId = ContractView.intNetWeightUOMId
		, strWeightUOM = weightUOM.strUnitMeasure
		, dblWeightItemUOMConv = dblItemUOMCF
		, dblQtyOrdered = CASE WHEN ContractView.ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END
		, dblQtyAllocated = CAST(ISNULL(dblAllocatedQty, 0) AS NUMERIC(18, 6))
		, dblQtyShipped = CASE WHEN ContractView.ysnLoad = 1 THEN  dbo.fnMultiply(ContractView.intLoadReceived, ContractView.dblQuantityPerLoad)
					ELSE ContractView.dblDetailQuantity - ContractView.dblBalance END--CAST(0 AS NUMERIC(18, 6))
		, dblUnitPrice = ISNULL(dblPricePerUnit, 0)
		, dblDiscount = CAST(0 AS NUMERIC(18, 6))
		, dblTotal = CAST(0 AS NUMERIC(18, 6))
		, dblQtyToShip = 
				CASE 
					WHEN ContractView.ysnLoad = 1 THEN 
						dbo.fnMultiply(ContractView.dblAvailableQty, ContractView.dblQuantityPerLoad)
					ELSE 
						ISNULL(dblAvailableQty, 0) 
				END
		, dblPrice = ISNULL(dblSeqPrice, 0)
		, dblLineTotal = 
				CASE 
					WHEN ContractView.ysnLoad = 1 THEN 
						dbo.fnMultiply(ContractView.dblAvailableQty, ContractView.dblQuantityPerLoad) 
					ELSE 
						ISNULL(ContractView.dblAvailableQty, 0) 
				END 
				* dbo.fnCalculateCostBetweenUOM (
					ISNULL(ItemPriceUOM.intItemUOMId, ContractView.intItemUOMId) 
					,ContractView.intItemUOMId
					,ISNULL(dblPricePerUnit, 0)	
				)							
		, intGradeId = NULL
		, strGrade = NULL
		, strDestinationGrades = ContractView.strGrade
		, intDestinationGradeId = ContractView.intGradeId
		, strDestinationWeights = ContractView.strWeight
		, intDestinationWeightId = ContractView.intWeightId
		, ysnLoad = ContractView.ysnLoad
		, dblAvailableQty = ContractView.dblAvailableQty
		, intNoOfLoad = ContractView.intNoOfLoad
		, intLoadShipped = ISNULL(ContractView.intNoOfLoad - ContractView.intLoadReceived, 0)
		, dblQuantityPerLoad = ISNULL(ContractView.dblQuantityPerLoad, 0)
		, intCurrencyId = ContractView.intCurrencyId
		, intForexRateTypeId = ContractView.intRateTypeId
		, strForexRateType = ContractView.strCurrencyExchangeRateType
		, dblForexRate = ContractView.dblRate
		, ContractView.intFreightTermId
		, ContractView.strFreightTerm
		, ContractView.intContractSeq
		, intPriceUOMId = ISNULL(ItemPriceUOM.intItemUOMId, ContractView.intItemUOMId) 
		, strPriceUOM = ISNULL(PriceUOM.strUnitMeasure, ContractView.strItemUOM) 
		, dblPriceUOMConv = ISNULL(ItemPriceUOM.dblUnitQty, ContractView.dblItemUOMCF)
FROM	vyuCTContractAddOrdersLookup ContractView
		INNER JOIN tblICItem Item ON Item.intItemId = ContractView.intItemId
		LEFT JOIN (
			tblICItemUOM ItemPriceUOM INNER JOIN tblICUnitMeasure PriceUOM
				ON ItemPriceUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
		)
			ON ItemPriceUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, ContractView.intSeqPriceUOMId)
		--INNER JOIN tblICItemUOM Iuom ON Iuom.intItemId = Item.intItemId AND Iuom.ysnStockUOM = 1
		--LEFT JOIN (
		--	tblICItemUOM ItemPriceUOM INNER JOIN tblICUnitMeasure PriceUOM
		--		ON ItemPriceUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
		--)
		--	ON ItemPriceUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, Iuom.intItemUOMId)
		LEFT JOIN (
			tblICItemUOM ItemWeightUOM INNER JOIN tblICUnitMeasure weightUOM
				ON ItemWeightUOM.intUnitMeasureId = weightUOM.intUnitMeasureId
		)
			ON ItemWeightUOM.intItemUOMId = ContractView.intNetWeightUOMId 
WHERE	ysnAllowedToShow = 1
		AND strContractType = 'Sale'
		AND ContractView.dblAvailableQty > 0