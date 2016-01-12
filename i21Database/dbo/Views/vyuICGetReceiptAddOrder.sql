CREATE VIEW [dbo].[vyuICGetReceiptAddOrder]
	AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * FROM (
	SELECT 	
		intLocationId
		, intEntityVendorId
		, strVendorId
		, strVendorName = strName
		, strReceiptType = 'Purchase Order'
		, intLineNo = intPurchaseDetailId
		, intOrderId = intPurchaseId
		, strOrderNumber = strPurchaseOrderNumber
		, dblOrdered = dblQtyOrdered
		, dblReceived = dblQtyReceived
		, intSourceType = 0
		, intSourceId = NULL
		, strSourceNumber = NULL
		, intItemId
		, strItemNo
		, strItemDescription = strDescription
		, dblQtyToReceive = dblQtyOrdered - dblQtyReceived
		, intLoadToReceive = NULL
		, dblUnitCost = dblCost
		, dblTax
		, dblLineTotal = dblTotal + dblTax
		, strLotTracking
		, intCommodityId
		, intContainerId = NULL
		, strContainer = NULL
		, intSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName = strStorageName
		, intOrderUOMId = intUnitOfMeasureId
		, strOrderUOM = strUOM
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId = intUnitOfMeasureId
		, strUnitMeasure = strUOM
		, strUnitType = strType
		, intWeightUOMId = NULL
		, strWeightUOM = NULL
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = 0
		, intCostUOMId = intUnitOfMeasureId
		, strCostUOM = strUOM
		, dblCostUOMConvFactor = dblItemUOMCF
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
	FROM vyuPODetails POView
	WHERE ysnCompleted = 0

	UNION ALL 

	SELECT 	
		intCompanyLocationId
		, intEntityId
		, strVendorId
		, strVendorName = strEntityName
		, strReceiptType = 'Purchase Contract'
		, intLineNo = intContractDetailId
		, intOrderId = intContractHeaderId
		, strOrderNumber = strContractNumber
		, dblOrdered = CASE WHEN ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END
		, dblReceived = CASE WHEN ysnLoad = 1 THEN intLoadReceived ELSE dblDetailQuantity - dblBalance END
		, intSourceType = 0
		, intSourceId = NULL
		, strSourceNumber = NULL
		, intItemId
		, strItemNo
		, strItemDescription
		, dblQtyToReceive = dblDetailQuantity - (dblDetailQuantity - dblBalance)
		, intLoadToReceive = intNoOfLoad - intLoadReceived
		, dblCashPrice
		, 0
		, dblLineTotal = 0
		, strLotTracking
		, intCommodityId
		, intContainerId = NULL
		, strContainer = NULL
		, intSubLocationId = intCompanyLocationSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName
		, intOrderUOMId = intItemUOMId
		, strOrderUOM = strItemUOM
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId = intItemUOMId
		, strUnitMeasure = strItemUOM
		, strUnitType = NULL
		, intWeightUOMId = NULL
		, strWeightUOM = NULL
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = 0
		, intCostUOMId = intItemUOMId
		, strCostUOM = strItemUOM
		, dblCostUOMConvFactor = dblItemUOMCF
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
	FROM vyuCTContractDetailView ContractView
	WHERE ysnAllowedToShow = 1
		AND strContractType = 'Purchase'

	UNION ALL

	SELECT
		intLocationId
		, intEntityVendorId
		, strVendor
		, strVendor
		, strReceiptType = 'Purchase Contract'
		, intLineNo = intContractDetailId
		, intOrderId = intContractHeaderId
		, strOrderNumber = strContractNumber
		, dblOrdered = dblQuantity
		, dblReceived = dblReceivedQty
		, intSourceType = 2
		, intSourceId = intShipmentContractQtyId
		, strSourceNumber = CAST(intTrackingNumber AS NVARCHAR(50))
		, intItemId
		, strItemNo
		, strItemDescription
		, dblQtyToReceive = dblQuantity - dblReceivedQty
		, intLoadToReceive = 0
		, dblCost
		, 0
		, dblLineTotal = 0
		, strLotTracking
		, intCommodityId
		, intContainerId = intShipmentBLContainerId
		, strContainer = strContainerNumber
		, intSubLocationId = intSubLocationId
		, strSubLocationName
		, intStorageLocationId = NULL
		, strStorageLocationName = NULL
		, intOrderUOMId = intItemUOMId
		, strOrderUOM = strUnitMeasure
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId = intItemUOMId
		, strUnitMeasure = strUnitMeasure
		, strUnitType = NULL
		, intWeightUOMId = intWeightUOMId
		, strWeightUOM = strWeightUOM
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = dblItemUOMCF
		, intCostUOMId = NULL --intCostUOMId
		, strCostUOM = NULL --strCostUOM
		, dblCostUOMConvFactor = NULL --dblCostUOMCF
		, intLifeTime
		, strLifeTimeType
		, ysnLoad = 0
		, dblAvailableQty = 0
	FROM vyuLGShipmentContainerReceiptContracts LogisticsView
	WHERE LogisticsView.dblBalanceToReceive > 0)
tblAddOrders