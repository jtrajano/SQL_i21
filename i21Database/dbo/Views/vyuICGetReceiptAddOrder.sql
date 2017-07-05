CREATE VIEW [dbo].[vyuICGetReceiptAddOrder]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, [intEntityId], intLineNo) AS INT)
, * FROM (
	SELECT 	
		intLocationId
		, [intEntityId]
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
        , intWeightUOMId = GrossNetUOM.intItemUOMId
        , strWeightUOM = GrossNetName.strUnitMeasure
		-- Conversion factor
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
		, ysnSubCurrency = CAST(0  AS BIT)
		, intCurrencyId = POView.intCurrencyId
		, strSubCurrency = CAST(NULL AS NVARCHAR(50)) 
		, dblGross = CAST(0 AS NUMERIC(38, 20)) -- There is no gross from PO
		, dblNet = CAST(0 AS NUMERIC(38, 20)) -- There is no net from PO
		, ysnBundleItem	= CAST(0 AS BIT)
		, intBundledItemId = CAST(NULL AS INT)
		, strBundledItemNo = CAST(NULL AS NVARCHAR(50))
	FROM	vyuPODetails POView LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON POView.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON POView.intUnitOfMeasureId = CostUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
            OUTER APPLY dbo.fnGetDefaultGrossNetUOMForLotItem(POView.intItemId) DefaultGrossNetUOM
            LEFT JOIN dbo.tblICItemUOM GrossNetUOM
                ON GrossNetUOM.intItemUOMId = DefaultGrossNetUOM.intGrossNetUOMId
            LEFT JOIN dbo.tblICUnitMeasure GrossNetName 
                ON GrossNetName.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
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
		, dblSeqPrice
		, dblTax = 0
		, dblLineTotal = CAST((dblDetailQuantity - (dblDetailQuantity - dblBalance)) * dblSeqPrice AS NUMERIC(18, 6))
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
		, intCostUOMId = ContractView.intSeqPriceUOMId
		, strCostUOM = ContractView.strSeqPriceUOM
		, dblCostUOMConvFactor = ContractView.dblQtyToPriceUOMConvFactor
		, intLifeTime
		, strLifeTimeType
		, 0 AS ysnLoad
		, 0 AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = CAST(ContractView.ysnSubCurrency AS BIT)
		, intCurrencyId = ISNULL( ISNULL(ContractView.intSeqCurrencyId, ContractView.intCurrencyId), DefaultCurrency.intCurrencyID)
		, strSubCurrency = CASE WHEN ContractView.ysnSubCurrency = 1 THEN ContractView.strCurrency ELSE ISNULL(ContractView.strMainCurrency, ISNULL(ContractView.strCurrency, DefaultCurrency.strCurrency)) END 
		, dblGross = CAST(0 AS NUMERIC(38, 20))-- There is no gross from contracts. 
		, dblNet = CAST(ContractView.dblAvailableNetWeight AS NUMERIC(38, 20))
		, ysnBundleItem	= ContractView.ysnBundleItem
		, intBundledItemId = CAST(NULL AS INT)
		, strBundledItemNo = CAST(NULL AS NVARCHAR(50))		
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

			LEFT JOIN dbo.tblSMCurrency DefaultCurrency
				ON DefaultCurrency.intCurrencyID = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 				

	WHERE	ysnAllowedToShow = 1
			AND strContractType = 'Purchase'
			AND ISNULL(ysnBundleItem, 0) = 0

    UNION ALL
	
	SELECT
		intLocationId				= ContractView.intCompanyLocationId
		, intEntityId			= ContractView.intEntityId
		, strVendorId				= ContractView.strVendorId
		, strVendorName				= ContractView.strEntityName
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= ContractView.intContractDetailId
		, intOrderId				= ContractView.intContractHeaderId
		, strOrderNumber			= ContractView.strContractNumber
		, dblOrdered				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intNoOfLoad ELSE dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity END
		, dblReceived				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intLoadReceived ELSE (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity) - (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblBalance) * BundleDetail.dblQuantity) END
		, intSourceType				= 0
		, intSourceId				= ContractItem.intItemId
		, strSourceNumber			= ContractItem.strItemNo
		, intItemId					= BundledItem.intItemId
		, strItemNo					= BundledItem.strItemNo
		, strItemDescription		= BundledItem.strDescription
		, dblQtyToReceive			= (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity) - ((dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity) - (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblBalance) * BundleDetail.dblQuantity))
		, intLoadToReceive			= ContractView.intNoOfLoad - ContractView.intLoadReceived
		, dblUnitCost				= ContractView.dblSeqPrice
		, dblTax					= CAST(0 AS NUMERIC(18, 6))
		, dblLineTotal				= CAST(((dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity) - ((dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity) - (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblBalance) * BundleDetail.dblQuantity))) * ContractView.dblSeqPrice AS NUMERIC(18, 6))
		, strLotTracking			= ContractView.strLotTracking
		, intCommodityId			= ContractView.intCommodityId
		, intContainerId			= CAST(NULL AS INT) 
		, strContainer				= CAST(NULL AS NVARCHAR(50)) 
		, intSubLocationId			= ContractView.intCompanyLocationSubLocationId
		, strSubLocationName		= ContractView.strSubLocationName
		, intStorageLocationId		= ContractView.intStorageLocationId
		, strStorageLocationName	= ContractView.strStorageLocationName
		, intOrderUOMId				= BundleDetail.intItemUnitMeasureId
		, strOrderUOM				= BundleDetailUOM.strUnitMeasure
		, dblOrderUOMConvFactor		= BundleDetail.dblQuantity
		, intItemUOMId				= BundleDetailUOM.intItemUOMId
		, strUnitMeasure			= BundleDetailUOM.strUnitMeasure
		, strUnitType				= BundleDetailUOM.strType
		, intWeightUOMId			= BundleDetailUOM.intItemUOMId
		, strWeightUOM				= BundleDetailUOM.strUnitMeasure
		, dblItemUOMConvFactor		= BundleDetailUOM.dblUnitQty
		, dblWeightUOMConvFactor	= BundleDetailUOM.dblUnitQty
		, intCostUOMId				= ContractView.intSeqPriceUOMId
		, strCostUOM				= ContractView.strSeqPriceUOM
		, dblCostUOMConvFactor		= (SELECT dblUnitQty from tblICItemUOM WHERE intItemUOMId = ContractView.intSeqPriceUOMId)
		, intLifeTime				= ContractView.intLifeTime
		, strLifeTimeType			= ContractView.strLifeTimeType
		, ysnLoad					= CAST(0 AS BIT)
		, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
		, strBOL					= CAST(NULL AS NVARCHAR(50))
		, dblFranchise				= CAST(NULL AS NUMERIC(18, 6))
		, dblContainerWeightPerQty	= CAST(NULL AS NUMERIC(18, 6))
		, ysnSubCurrency			= CAST(ContractView.ysnSubCurrency AS BIT)
		, intCurrencyId				= dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
		, strSubCurrency			= (SELECT strCurrency from tblSMCurrency where intCurrencyID = dbo.fnICGetCurrency(ContractView.intContractDetailId, 1)) -- 1 indicates that value is for Sub Currency
		, dblGross					= CAST(0 AS NUMERIC(38, 20))-- There is no gross from contracts.
		, dblNet					= CAST(dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblAvailableNetWeight) * BundleDetail.dblQuantity  AS NUMERIC(38, 20))
		, ysnBundleItem				= ContractView.ysnBundleItem
		, intBundledItemId			= CAST(ContractItem.intItemId AS INT)
		, strBundledItemNo			= CAST(ContractItem.strItemNo AS NVARCHAR(50))
	FROM tblICItemBundle BundleDetail
		INNER JOIN tblICItem BundledItem ON BundledItem.intItemId = BundleDetail.intBundleItemId
		INNER JOIN tblICItem ContractItem ON ContractItem.intItemId = BundleDetail.intItemId
		INNER JOIN vyuCTContractDetailView ContractView ON ContractView.intItemId = ContractItem.intItemId
		INNER JOIN vyuICItemUOM ItemUOM ON ItemUOM.intItemId = BundledItem.intItemId
			AND ItemUOM.ysnStockUnit = 1
		LEFT JOIN vyuICItemUOM BundleDetailUOM ON BundleDetailUOM.intItemId = BundleDetail.intBundleItemId
			AND BundleDetailUOM.intItemUOMId = BundleDetail.intItemUnitMeasureId
	WHERE ContractView.strContractType = 'Purchase'
		AND ContractView.ysnAllowedToShow = 1
		AND ContractView.ysnBundleItem = 1

	UNION ALL

	SELECT  intCompanyLocationId
		, intEntityVendorId
		, strVendor
		, strVendor
		, strReceiptType = 'Purchase Contract'
		, intLineNo = intPContractDetailId
		, intOrderId = intPContractHeaderId
		, strOrderNumber = strPContractNumber
		, dblOrdered = dblQuantity
		, dblReceived = dblDeliveredQuantity
		, intSourceType = 2
		, intSourceId = intLoadDetailId
		, strSourceNumber = strLoadNumber
		, LogisticsView.intItemId
		, strItemNo
		, strItemDescription
		, dblQtyToReceive = dblQuantity - dblDeliveredQuantity
		, intLoadToReceive = 0
		, dblCost
		, dblTax = 0
		, dblLineTotal = 0
		, strLotTracking
		, intPCommodityId
		, intContainerId = intLoadContainerId
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
		, intPLifeTime
		, strPLifeTimeType
		, ysnLoad = 0
		, dblAvailableQty = 0
		, strBOL = LogisticsView.strBLNumber
		, dblFranchise = LogisticsView.dblFranchise
		, dblContainerWeightPerQty = LogisticsView.dblContainerWeightPerQty
		, ysnSubCurrency = CAST(LogisticsView.ysnSubCurrency AS BIT)
		, intCurrencyId = Currency.intCurrencyID
		, strSubCurrency = CASE WHEN LogisticsView.ysnSubCurrency = 1 THEN LogisticsView.strCurrency ELSE LogisticsView.strMainCurrency END 
		, dblGross = CAST(LogisticsView.dblGross AS NUMERIC(38, 20))
		, dblNet = CAST(LogisticsView.dblNet AS NUMERIC(38, 20))
		, ysnBundleItem	= 0
		, intBundledItemId = CAST(NULL AS INT)
		, strBundledItemNo = CAST(NULL AS NVARCHAR(50))
	FROM	vyuLGLoadContainerReceiptContracts LogisticsView 
	LEFT JOIN dbo.tblSMCurrency Currency ON Currency.strCurrency = ISNULL(LogisticsView.strMainCurrency, LogisticsView.strCurrency) 
	LEFT JOIN dbo.tblICItemUOM ItemUOM ON LogisticsView.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN dbo.tblICItemUOM GrossNetUOM ON LogisticsView.intWeightItemUOMId = GrossNetUOM.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
	LEFT JOIN dbo.tblICItemUOM CostUOM ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(LogisticsView.intItemId, LogisticsView.intPCostUOMId)
	LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
	WHERE LogisticsView.dblBalanceToReceive > 0 
	  AND LogisticsView.intSourceType = 2 
	  AND LogisticsView.intTransUsedBy = 1 
	  AND LogisticsView.intPurchaseSale = 1
	  AND LogisticsView.ysnPosted = 1

	UNION ALL

	SELECT
		intLocationId = TransferView.intFromLocationId
		, intEntityVendorId = TransferView.intToLocationId
		, strVendorId = Loc.strLocationName
		, strVendorName = Loc.strLocationName
		, strReceiptType = 'Transfer Order'
		, intLineNo = TransferView.intInventoryTransferDetailId
		, intOrderId = TransferView.intInventoryTransferId
		, strOrderNumber = TransferView.strTransferNo
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
		, dblGross = CAST(0 AS NUMERIC(38, 20)) -- There is no gross from transfer
		, dblNet = CAST(0 AS NUMERIC(38, 20)) -- There is no net from transfer
		, ysnBundleItem	= 0
		, intBundledItemId = CAST(NULL AS INT)
		, strBundledItemNo = CAST(NULL AS NVARCHAR(50))		
	FROM	vyuICGetInventoryTransferDetail TransferView
			LEFT JOIN dbo.tblICInventoryTransfer TransferViewHeader
				ON TransferViewHeader.intInventoryTransferId = TransferView.intInventoryTransferId
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
			LEFT JOIN dbo.tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = TransferView.intToLocationId
			,tblSMCompanyPreference

	WHERE TransferView.ysnPosted = 1
		AND TransferViewHeader.ysnShipmentRequired = 1
		AND (TransferViewHeader.intStatusId = 1 OR TransferViewHeader.intStatusId = 2))
tblAddOrders
