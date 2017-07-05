CREATE VIEW [dbo].[vyuICGetReceiptAddPurchaseContract]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * 
FROM (
	SELECT 	
		intLocationId				= intCompanyLocationId			
		, intEntityVendorId			= intEntityId
		, strVendorId				= strVendorId
		, strVendorName				= strEntityName
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= intContractDetailId
		, intOrderId				= intContractHeaderId
		, strOrderNumber			= strContractNumber
		, dblOrdered				= CASE WHEN ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END
		, dblReceived				= CASE WHEN ysnLoad = 1 THEN intLoadReceived ELSE dblDetailQuantity - dblBalance END
		, intSourceType				= CAST(0 AS INT)
		, intSourceId				= CAST(NULL AS INT) 
		, strSourceNumber			= CAST(NULL AS NVARCHAR(50)) 
		, intItemId					= ContractView.intItemId
		, strItemNo					= strItemNo
		, strItemDescription		= strItemDescription
		, dblQtyToReceive			= dblDetailQuantity - (dblDetailQuantity - dblBalance)
		, intLoadToReceive			= intNoOfLoad - intLoadReceived
		, dblUnitCost				= dblSeqPrice
		, dblTax					= CAST(0 AS NUMERIC(18, 6))
		, dblLineTotal				= CAST((dblDetailQuantity - (dblDetailQuantity - dblBalance)) * dblSeqPrice AS NUMERIC(18, 6))
		, strLotTracking			= strLotTracking
		, intCommodityId			= intCommodityId
		, intContainerId			= CAST(NULL AS INT) 
		, strContainer				= CAST(NULL AS NVARCHAR(50)) 
		, intSubLocationId			= intCompanyLocationSubLocationId
		, strSubLocationName		= strSubLocationName
		, intStorageLocationId		= intStorageLocationId
		, strStorageLocationName	= strStorageLocationName
		, intOrderUOMId				= ItemUOM.intItemUOMId
		, strOrderUOM				= ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor		= ItemUOM.dblUnitQty
		, intItemUOMId				= ItemUOM.intItemUOMId
		, strUnitMeasure			= ItemUnitMeasure.strUnitMeasure
		, strUnitType				= ItemUnitMeasure.strUnitType
		-- Gross/Net UOM -----------
		, intWeightUOMId			= GrossNetUOM.intItemUOMId
		, strWeightUOM				= GrossNetUnitMeasure.strUnitMeasure
		-- Conversion factor -------
		, dblItemUOMConvFactor		= ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor	= GrossNetUOM.dblUnitQty
		-- Cost UOM ----------------
		, intCostUOMId				= ContractView.intSeqPriceUOMId
		, strCostUOM				= ContractView.strSeqPriceUOM
		--, dblCostUOMConvFactor		= ContractView.dblQtyToPriceUOMConvFactor
		, dblCostUOMConvFactor		= (SELECT dblUnitQty from tblICItemUOM WHERE intItemUOMId = ContractView.intSeqPriceUOMId)
		, intLifeTime				= intLifeTime
		, strLifeTimeType			= strLifeTimeType
		, ysnLoad					= CAST(0 AS BIT)
		, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
		, strBOL					= CAST(NULL AS NVARCHAR(50))
		, dblFranchise				= CAST(NULL AS NUMERIC(18, 6))
		, dblContainerWeightPerQty	= CAST(NULL AS NUMERIC(18, 6))
		, ysnSubCurrency			= CAST(ContractView.ysnSubCurrency AS BIT)
		, intCurrencyId				= dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
		, strSubCurrency			= (SELECT strCurrency from tblSMCurrency where intCurrencyID = dbo.fnICGetCurrency(ContractView.intContractDetailId, 1)) -- 1 indicates that value is for Sub Currency
		, dblGross					= CAST(0 AS NUMERIC(38, 20))-- There is no gross from contracts.
		, dblNet					= CAST(ContractView.dblAvailableNetWeight AS NUMERIC(38, 20))
		, intForexRateTypeId		= ContractView.intRateTypeId
		, strForexRateType			= ContractView.strCurrencyExchangeRateType
		, dblForexRate				= ContractView.dblRate
		, ysnBundleItem				= ContractView.ysnBundleItem
		, intBundledItemId			= CAST(NULL AS INT)
		, strBundledItemNo			= CAST(NULL AS NVARCHAR(50))
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
			AND ISNULL(ysnBundleItem, 0) = 0
	
	UNION ALL
	
	SELECT
		intLocationId				= ContractView.intCompanyLocationId
		, intEntityVendorId			= ContractView.intEntityId
		, strVendorId				= ContractView.strVendorId
		, strVendorName				= ContractView.strEntityName
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= ContractView.intContractDetailId
		, intOrderId				= ContractView.intContractHeaderId
		, strOrderNumber			= ContractView.strContractNumber
		, dblOrdered				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intNoOfLoad ELSE dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity END
		, dblReceived				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intLoadReceived ELSE (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblDetailQuantity) * BundleDetail.dblQuantity) - (dbo.fnCalculateQtyBetweenUOM(ContractView.intItemUOMId, ItemUOM.intItemUOMId, ContractView.dblBalance) * BundleDetail.dblQuantity) END
		, intSourceType				= CAST(0 AS INT)
		, intSourceId				= CAST(NULL AS INT) 
		, strSourceNumber			= CAST(NULL AS NVARCHAR(50)) 
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
		-- Gross/Net UOM -----------
		, intWeightUOMId			= BundleDetailUOM.intItemUOMId
		, strWeightUOM				= BundleDetailUOM.strUnitMeasure
		-- Conversion factor -------
		, dblItemUOMConvFactor		= BundleDetailUOM.dblUnitQty
		, dblWeightUOMConvFactor	= BundleDetailUOM.dblUnitQty
		-- Cost UOM ----------------
		, intCostUOMId				= ContractView.intSeqPriceUOMId
		, strCostUOM				= ContractView.strSeqPriceUOM
		--, dblCostUOMConvFactor	
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
		, intForexRateTypeId		= ContractView.intRateTypeId
		, strForexRateType			= ContractView.strCurrencyExchangeRateType
		, dblForexRate				= ContractView.dblRate
		, ysnBundleItem				= ContractView.ysnBundleItem
		, intBundledItemId			= ContractItem.intItemId
		, strBundledItemNo			= ContractItem.strItemNo
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
) tblAddOrders
