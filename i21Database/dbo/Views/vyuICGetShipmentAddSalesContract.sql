﻿CREATE VIEW [dbo].[vyuICGetShipmentAddSalesContract]
AS
-- intKey = CAST(ROW_NUMBER() OVER(ORDER BY intCompanyLocationId, intEntityId, intContractDetailId) AS INT)
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
		, intItemId
		, strItemNo
		, strItemDescription
		, strLotTracking
		, intCommodityId
		, intSubLocationId = intCompanyLocationSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName = strStorageLocationName
		, intOrderUOMId = intItemUOMId
		, strOrderUOM = strItemUOM
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId
		, strItemUOM = strItemUOM
		, dblItemUOMConv = dblItemUOMCF
		, intWeightUOMId = intItemUOMId
		, strWeightUOM = strItemUOM
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
FROM	vyuCTContractAddOrdersLookup ContractView
WHERE	ysnAllowedToShow = 1
		AND strContractType = 'Sale'
		AND ContractView.dblAvailableQty > 0