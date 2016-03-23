﻿CREATE VIEW [dbo].[vyuICGetReceiptAddOrder]
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
		-- Gross/Net 
		, intWeightUOMId = NULL
		, strWeightUOM = NULL
		-- Conversion factor
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = 00
		-- Cost UOM
		, intCostUOMId = intUnitOfMeasureId
		, strCostUOM = strUOM
		, dblCostUOMConvFactor = dblItemUOMCF
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = 0 
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
		, ContractView.intItemId
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
		, intOrderUOMId = ContractView.intItemUOMId
		, strOrderUOM = strItemUOM
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId = ContractView.intItemUOMId
		, strUnitMeasure = strItemUOM
		, strUnitType = NULL		
		-- Gross/Net UOM
		, intWeightUOMId = NetWeightUOM.intItemUOMId
		, strWeightUOM = UOM.strUnitMeasure
		-- Conversion factors
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = NetWeightUOM.dblUnitQty
		-- Cost UOM
		, intCostUOMId = dbo.fnGetMatchingItemUOMId(intCommodityId, intPriceItemUOMId) -- intPriceItemUOMId
		, strCostUOM = strPriceUOM
		, dblCostUOMConvFactor = dblItemUOMCF
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency
	FROM vyuCTContractDetailView ContractView LEFT JOIN dbo.tblICItemUOM NetWeightUOM
			ON ContractView.intNetWeightUOMId = NetWeightUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure UOM
			ON UOM.intUnitMeasureId = NetWeightUOM.intUnitMeasureId
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
		-- Gross/Net UOM
		, intWeightUOMId = intWeightItemUOMId  
		, strWeightUOM = strWeightUOM
		-- Conversion factor
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = dblItemUOMCF
		-- Cost UOM
		, intCostUOMId = dbo.fnGetMatchingItemUOMId(intItemId, intCostUOMId) -- intCostUOMId
		, strCostUOM = strCostUOM
		, dblCostUOMConvFactor = dblCostUOMCF
		, intLifeTime
		, strLifeTimeType
		, ysnLoad = 0
		, dblAvailableQty = 0
		, strBOL = LogisticsView.strBLNumber
		, dblFranchise = LogisticsView.dblFranchise
		, dblContainerWeightPerQty = LogisticsView.dblContainerWeightPerQty
		, ysnSubCurrency
	FROM vyuLGShipmentContainerReceiptContracts LogisticsView
	WHERE LogisticsView.dblBalanceToReceive > 0
		AND LogisticsView.ysnDirectShipment = 0
	
	UNION ALL

	SELECT
		intLocationId = TransferView.intToLocationId
		, intEntityVendorId = TransferView.intFromLocationId
		, NULL
		, NULL
		, strReceiptType = 'Transfer Order'
		, intLineNo = intInventoryTransferDetailId
		, intOrderId = intInventoryTransferId
		, strOrderNumber = strTransferNo
		, dblOrdered = dblQuantity
		, dblReceived = NULL
		, intSourceType = 0
		, intSourceId = NULL
		, strSourceNumber = NULL
		, intItemId
		, strItemNo
		, strItemDescription
		, dblQtyToReceive = dblQuantity
		, intLoadToReceive = 0
		, dblCost = dblLastCost
		, 0
		, dblLineTotal = 0
		, strLotTracking
		, intCommodityId
		, intContainerId = NULL
		, strContainer = NULL
		, intSubLocationId = intToSubLocationId
		, strSubLocationName = strToSubLocationName
		, intStorageLocationId = intToStorageLocationId
		, strStorageLocationName = strToStorageLocationName
		, intOrderUOMId = intItemUOMId
		, strOrderUOM = strUnitMeasure
		, dblOrderUOMConvFactor = dblItemUOMCF
		, intItemUOMId = intItemUOMId
		, strUnitMeasure = strUnitMeasure
		, strUnitType = NULL
		-- Gross/Net UOM
		, intWeightUOMId = intWeightUOMId
		, strWeightUOM = strWeightUOM
		-- Conversion factor
		, dblItemUOMConvFactor = dblItemUOMCF
		, dblWeightUOMConvFactor = dblWeightUOMCF
		-- Cost UOM 
		, intCostUOMId = dbo.fnGetMatchingItemUOMId(intItemId, intItemUOMId) -- intItemUOMId
		, strCostUOM = strUnitMeasure
		, dblCostUOMConvFactor = dblItemUOMCF
		, intLifeTime
		, strLifeTimeType
		, ysnLoad = 0
		, dblAvailableQty = 0
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = 0 
	FROM vyuICGetInventoryTransferDetail TransferView
	WHERE TransferView.ysnPosted = 1)
tblAddOrders