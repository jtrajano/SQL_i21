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
		, POView.intItemId
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
		, strOrderUOM = ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor = ItemUOM.dblUnitQty
		, intItemUOMId = ItemUOM.intItemUOMId
		, strUnitMeasure = ItemUnitMeasure.strUnitMeasure
		, strUnitType = strType
		-- Gross/Net 
		, intWeightUOMId = NULL
		, strWeightUOM = NULL
		-- Conversion factor
		, dblItemUOMConvFactor = ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor = NULL 
		-- Cost UOM
		, intCostUOMId = CostUOM.intItemUOMId
		, strCostUOM = CostUnitMeasure.strUnitMeasure
		, dblCostUOMConvFactor = CostUOM.dblUnitQty
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = CAST(0  AS BIT)
		, intCurrencyId = POView.intCurrencyId
		, strSubCurrency = CAST(NULL AS NVARCHAR(50)) 
	FROM	vyuPODetails POView LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON POView.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON POView.intUnitOfMeasureId = CostUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId


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
		, dblTax = 0
		, dblLineTotal = 0
		, strLotTracking
		, intCommodityId
		, intContainerId = NULL
		, strContainer = NULL
		, intSubLocationId = intCompanyLocationSubLocationId
		, strSubLocationName
		, intStorageLocationId
		, strStorageLocationName
		, intOrderUOMId = ItemUOM.intItemUOMId
		, strOrderUOM = ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor = ItemUOM.dblUnitQty
		, intItemUOMId = ItemUOM.intItemUOMId
		, strUnitMeasure = ItemUnitMeasure.strUnitMeasure
		, strUnitType = NULL		
		-- Gross/Net UOM
		, intWeightUOMId = GrossNetUOM.intItemUOMId
		, strWeightUOM = GrossNetUnitMeasure.strUnitMeasure
		-- Conversion factors
		, dblItemUOMConvFactor = ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor = GrossNetUOM.dblUnitQty
		-- Cost UOM
		, intCostUOMId = CostUOM.intItemUOMId 
		, strCostUOM = CostUnitMeasure.strUnitMeasure
		, dblCostUOMConvFactor = CostUOM.dblUnitQty
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = CAST(ysnSubCurrency AS BIT)
		, intCurrencyId = ISNULL(ContractView.intMainCurrencyId, ContractView.intCurrencyId) 
		, strSubCurrency = CASE WHEN ysnSubCurrency = 1 THEN ContractView.strCurrency ELSE ContractView.strMainCurrency END 
	FROM	vyuCTContractDetailView ContractView LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ContractView.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM GrossNetUOM
				ON ContractView.intNetWeightUOMId = GrossNetUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure
				ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, intPriceItemUOMId)
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId

	WHERE	ysnAllowedToShow = 1
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
		, LogisticsView.intItemId
		, strItemNo
		, strItemDescription
		, dblQtyToReceive = dblQuantity - dblReceivedQty
		, intLoadToReceive = 0
		, dblCost
		, dblTax = 0
		, dblLineTotal = 0
		, strLotTracking
		, intCommodityId
		, intContainerId = intShipmentBLContainerId
		, strContainer = strContainerNumber
		, intSubLocationId = intSubLocationId
		, strSubLocationName
		, intStorageLocationId = NULL
		, strStorageLocationName = NULL
		, intOrderUOMId = ItemUOM.intItemUOMId
		, strOrderUOM = ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor = ItemUOM.dblUnitQty
		, intItemUOMId = ItemUOM.intItemUOMId
		, strUnitMeasure = ItemUnitMeasure.strUnitMeasure
		, strUnitType = NULL
		-- Gross/Net UOM
		, intWeightUOMId = GrossNetUOM.intItemUOMId
		, strWeightUOM = GrossNetUnitMeasure.strUnitMeasure
		-- Conversion factor
		, dblItemUOMConvFactor = ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor = GrossNetUOM.dblUnitQty
		-- Cost UOM
		, intCostUOMId = CostUOM.intItemUOMId
		, strCostUOM = CostUnitMeasure.strUnitMeasure
		, dblCostUOMConvFactor = CostUOM.dblUnitQty
		, intLifeTime
		, strLifeTimeType
		, ysnLoad = 0
		, dblAvailableQty = 0
		, strBOL = LogisticsView.strBLNumber
		, dblFranchise = LogisticsView.dblFranchise
		, dblContainerWeightPerQty = LogisticsView.dblContainerWeightPerQty
		, ysnSubCurrency = CAST(LogisticsView.ysnSubCurrency AS BIT)
		, intCurrencyId = Currency.intCurrencyID
		, strSubCurrency = CASE WHEN LogisticsView.ysnSubCurrency = 1 THEN LogisticsView.strCurrency ELSE LogisticsView.strMainCurrency END 
	FROM	vyuLGShipmentContainerReceiptContracts LogisticsView LEFT JOIN dbo.tblSMCurrency Currency
				ON Currency.strCurrency = ISNULL(LogisticsView.strMainCurrency, LogisticsView.strCurrency) 

			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON LogisticsView.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM GrossNetUOM
				ON LogisticsView.intWeightItemUOMId = GrossNetUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure
				ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(LogisticsView.intItemId, LogisticsView.intCostUOMId)
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId

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
		, TransferView.intItemId
		, strItemNo
		, strItemDescription
		, dblQtyToReceive = dblQuantity
		, intLoadToReceive = 0
		, dblCost = dblLastCost
		, dblTax = 0
		, dblLineTotal = 0
		, strLotTracking
		, intCommodityId
		, intContainerId = NULL
		, strContainer = NULL
		, intSubLocationId = intToSubLocationId
		, strSubLocationName = strToSubLocationName
		, intStorageLocationId = intToStorageLocationId
		, strStorageLocationName = strToStorageLocationName
		, intOrderUOMId = ItemUOM.intItemUOMId
		, strOrderUOM = ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor = ItemUOM.dblUnitQty
		, intItemUOMId = ItemUOM.intItemUOMId
		, strUnitMeasure = ItemUnitMeasure.strUnitMeasure
		, strUnitType = NULL
		-- Gross/Net UOM
		, intWeightUOMId = GrossNetUOM.intItemUOMId
		, strWeightUOM = GrossNetUnitMeasure.strUnitMeasure
		-- Conversion factor
		, dblItemUOMConvFactor = ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor = GrossNetUOM.dblUnitQty
		-- Cost UOM 
		, intCostUOMId = CostUOM.intItemUOMId -- intItemUOMId
		, strCostUOM = CostUnitMeasure.strUnitMeasure
		, dblCostUOMConvFactor = CostUOM.dblUnitQty
		, intLifeTime
		, strLifeTimeType
		, ysnLoad = 0
		, dblAvailableQty = 0
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = CAST(0 AS BIT) 
		, tblSMCompanyPreference.intDefaultCurrencyId
		, strSubCurrency = NULL 
	FROM	vyuICGetInventoryTransferDetail TransferView
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON TransferView.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM GrossNetUOM
				ON TransferView.intWeightUOMId = GrossNetUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure
				ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(TransferView.intItemId, TransferView.intItemUOMId)
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId

			,tblSMCompanyPreference

	WHERE TransferView.ysnPosted = 1)
tblAddOrders
