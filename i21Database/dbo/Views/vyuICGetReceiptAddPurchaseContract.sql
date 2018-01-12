CREATE  VIEW [dbo].[vyuICGetReceiptAddPurchaseContract]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intItemId, intLineNo) AS INT)
, * 
FROM (
	SELECT 	
		intLocationId				= ContractView.intCompanyLocationId			
		, intEntityVendorId			= ContractView.intEntityId
		, strVendorId				= ContractView.strVendorId
		, strVendorName				= ContractView.strEntityName
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= ContractView.intContractDetailId
		, intOrderId				= ContractView.intContractHeaderId
		, strOrderNumber			= ContractView.strContractNumber
		, dblOrdered				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intNoOfLoad ELSE ContractView.dblDetailQuantity END
		, dblReceived				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intLoadReceived ELSE ContractView.dblDetailQuantity - ContractView.dblBalance END
		, intSourceType				= CAST(0 AS INT)
		, intSourceId				= CAST(NULL AS INT) 
		, strSourceNumber			= CAST(NULL AS NVARCHAR(50)) 
		, intItemId					= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.intItemId ELSE ContractView.intItemId END 
		, strItemNo					= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.strItemNo ELSE ContractView.strItemNo END 
		, strItemDescription		= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.strDescription ELSE ContractView.strItemDescription END 
		, dblQtyToReceive			= ContractView.dblDetailQuantity - (ContractView.dblDetailQuantity - ContractView.dblBalance)
		, intLoadToReceive			= ContractView.intNoOfLoad - ContractView.intLoadReceived
		, dblUnitCost				= ContractView.dblSeqPrice
		, dblTax					= CAST(0 AS NUMERIC(18, 6))
		, dblLineTotal				= CAST((ContractView.dblDetailQuantity - (ContractView.dblDetailQuantity - ContractView.dblBalance)) * ContractView.dblSeqPrice AS NUMERIC(18, 6))
		, strLotTracking			= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.strLotTracking ELSE ContractView.strLotTracking END 
		, intCommodityId			= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.intCommodityId ELSE ContractView.intCommodityId END
		, intContainerId			= CAST(NULL AS INT) 
		, strContainer				= CAST(NULL AS NVARCHAR(50)) 
		, intSubLocationId			= ContractView.intCompanyLocationSubLocationId
		, strSubLocationName		= ContractView.strSubLocationName
		, intStorageLocationId		= ContractView.intStorageLocationId
		, strStorageLocationName	= ContractView.strStorageLocationName
		, intOrderUOMId				= BasketItemUOM.intItemUOMId
		, strOrderUOM				= ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor		= ItemUOM.dblUnitQty
		, intItemUOMId				= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItemUOM.intItemUOMId ELSE ItemUOM.intItemUOMId END 
		, strUnitMeasure			= ItemUnitMeasure.strUnitMeasure
		, strUnitType				= ItemUnitMeasure.strUnitType
		-- Gross/Net UOM -----------
		, intWeightUOMId			= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketWeightUOM.intItemUOMId ELSE GrossNetUOM.intItemUOMId END  
		, strWeightUOM				= GrossNetUnitMeasure.strUnitMeasure 
		-- Conversion factor -------
		, dblItemUOMConvFactor		= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN ItemUOM.dblUnitQty ELSE ItemUOM.dblUnitQty  END  
		, dblWeightUOMConvFactor	= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN GrossNetUOM.dblUnitQty ELSE GrossNetUOM.dblUnitQty END  
		-- Cost UOM ----------------
		, intCostUOMId				= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketCostUOM.intItemUOMId ELSE ItemCostUOM.intItemUOMId END  -- ContractView.intSeqPriceUOMId
		, strCostUOM				= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketCostUnitMeasure.strUnitMeasure ELSE ItemCostUnitMeasure.strUnitMeasure END  
		, dblCostUOMConvFactor		= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN ItemCostUOM.dblUnitQty ELSE ItemCostUOM.dblUnitQty END  
		----------------------------
		, intLifeTime				= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.intLifeTime ELSE ContractView.intLifeTime END
		, strLifeTimeType			= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN BasketItem.strLifeTimeType ELSE ContractView.strLifeTimeType END
		, ysnLoad					= CAST(0 AS BIT)
		, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
		, strBOL					= CAST(NULL AS NVARCHAR(50))
		, dblFranchise				= CAST(NULL AS NUMERIC(18, 6))
		, dblContainerWeightPerQty	= CAST(NULL AS NUMERIC(18, 6))
		, ysnSubCurrency			= CAST(ContractView.ysnSubCurrency AS BIT)
		, intCurrencyId				= dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
		, strSubCurrency			= SubCurrency.strCurrency
		, dblGross					= 
									CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN 
										CAST((dblDetailQuantity - (dblDetailQuantity - dblBalance)) AS NUMERIC(38, 20)) 
									ELSE 
										CAST(0 AS NUMERIC(38, 20))									
									END
									
		, dblNet					= 
									CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN 
										CAST((dblDetailQuantity - (dblDetailQuantity - dblBalance)) AS NUMERIC(38, 20))
									ELSE 
										CAST(0 AS NUMERIC(38, 20))									
									END

		, intForexRateTypeId		= ContractView.intRateTypeId
		, strForexRateType			= ContractView.strCurrencyExchangeRateType
		, dblForexRate				= ContractView.dblRate
		, ysnBundleItem				= ContractView.ysnBundleItem
		, intBundledItemId			= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN ContractView.intItemId ELSE CAST(NULL AS INT) END 
		, strBundledItemNo			= CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN ContractView.strItemNo ELSE CAST(NULL AS NVARCHAR(50)) END 
		, strBundledItemDescription = CASE WHEN ISNULL(ContractView.ysnIsBasket, 0) = 1 THEN ContractView.strItemDescription ELSE CAST(NULL AS NVARCHAR(50)) END 
		, ysnIsBasket 				= ContractView.ysnIsBasket
		, ContractView.intFreightTermId
		, ContractView.strFreightTerm
	FROM vyuCTContractAddOrdersLookup ContractView
		LEFT JOIN dbo.tblICItemUOM ItemUOM ON ContractView.intItemUOMId = ItemUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM GrossNetUOM ON ContractView.intNetWeightUOMId = GrossNetUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, ContractView.intSeqPriceUOMId)
		LEFT JOIN dbo.tblICUnitMeasure ItemCostUnitMeasure ON ItemCostUnitMeasure.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = dbo.fnICGetCurrency(ContractView.intContractDetailId, 1) -- 1 indicates that value is for Sub Currency

		-- The following are bundle/basket related queries:
		LEFT JOIN tblICItemBundle BundleItem ON BundleItem.intItemId = ContractView.intItemId
		LEFT JOIN tblICItem BasketItem ON BasketItem.intItemId = BundleItem.intBundleItemId
		LEFT JOIN tblICItemUOM BasketItemUOM ON BasketItemUOM.intItemId = BasketItem.intItemId AND BasketItemUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM BasketWeightUOM ON BasketWeightUOM.intItemId = BasketItem.intItemId AND BasketWeightUOM.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM BasketCostUOM ON BasketCostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(BasketItem.intItemId, ContractView.intSeqPriceUOMId)
		LEFT JOIN dbo.tblICUnitMeasure BasketCostUnitMeasure ON BasketCostUnitMeasure.intUnitMeasureId = BasketCostUOM.intUnitMeasureId

	WHERE ContractView.ysnAllowedToShow = 1
		AND ContractView.strContractType = 'Purchase'
	
	--UNION ALL	
	--SELECT 	
	--	intLocationId				= intCompanyLocationId			
	--	, intEntityId				= intEntityId
	--	, strVendorId				= strVendorId
	--	, strVendorName				= strEntityName
	--	, strReceiptType			= 'Purchase Contract'
	--	, intLineNo					= intContractDetailId
	--	, intOrderId				= intContractHeaderId
	--	, strOrderNumber			= strContractNumber
	--	, dblOrdered				= CASE WHEN ysnLoad = 1 THEN intNoOfLoad ELSE dblDetailQuantity END
	--	, dblReceived				= CASE WHEN ysnLoad = 1 THEN intLoadReceived ELSE dblDetailQuantity - dblBalance END
	--	, intSourceType				= CAST(0 AS INT)
	--	, intSourceId				= CAST(NULL AS INT) 
	--	, strSourceNumber			= CAST(NULL AS NVARCHAR(50)) 
	--	, intItemId					= BasketItem.intItemId
	--	, strItemNo					= BasketItem.strItemNo
	--	, strItemDescription		= BasketItem.strDescription
	--	, dblQtyToReceive			= dblDetailQuantity - (dblDetailQuantity - dblBalance)
	--	, intLoadToReceive			= intNoOfLoad - intLoadReceived
	--	, dblUnitCost				= dblSeqPrice
	--	, dblTax					= CAST(0 AS NUMERIC(18, 6))
	--	, dblLineTotal				= CAST((dblDetailQuantity - (dblDetailQuantity - dblBalance)) * dblSeqPrice AS NUMERIC(18, 6))
	--	, strLotTracking			= BasketItem.strLotTracking
	--	, intCommodityId			= BasketItem.intCommodityId
	--	, intContainerId			= CAST(NULL AS INT) 
	--	, strContainer				= CAST(NULL AS NVARCHAR(50)) 
	--	, intSubLocationId			= intCompanyLocationSubLocationId
	--	, strSubLocationName		= strSubLocationName
	--	, intStorageLocationId		= intStorageLocationId
	--	, strStorageLocationName	= strStorageLocationName
	--	, intOrderUOMId				= BundleItemUOM.intItemUOMId
	--	, strOrderUOM				= BundleItemUnitMeasure.strUnitMeasure
	--	, dblOrderUOMConvFactor		= BundleItemUOM.dblUnitQty
	--	, intItemUOMId				= dbo.fnGetMatchingItemUOMId(BasketItem.intItemId, BundleItemUOM.intItemUOMId)
	--	, strUnitMeasure			= BundleItemUnitMeasure.strUnitMeasure
	--	, strUnitType				= BundleItemUnitMeasure.strUnitType
	--	-- Gross/Net UOM -----------
	--	, intWeightUOMId			= BasketUOM.intItemUOMId
	--	, strWeightUOM				= GrossNetUnitMeasure.strUnitMeasure
	--	-- Conversion factor -------
	--	, dblItemUOMConvFactor		= BundleItemUOM.dblUnitQty
	--	, dblWeightUOMConvFactor	= BasketUOM.dblUnitQty
	--	-- Cost UOM ----------------
	--	, intCostUOMId				= ContractView.intSeqPriceUOMId
	--	, strCostUOM				= ContractView.strSeqPriceUOM
	--	--, dblCostUOMConvFactor		= ContractView.dblQtyToPriceUOMConvFactor
	--	, dblCostUOMConvFactor		= (SELECT dblUnitQty from tblICItemUOM WHERE intItemUOMId = ContractView.intSeqPriceUOMId)
	--	, intLifeTime				= BasketItem.intLifeTime
	--	, strLifeTimeType			= BasketItem.strLifeTimeType
	--	, ysnLoad					= CAST(0 AS BIT)
	--	, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
	--	, strBOL					= CAST(NULL AS NVARCHAR(50))
	--	, dblFranchise				= CAST(NULL AS NUMERIC(18, 6))
	--	, dblContainerWeightPerQty	= CAST(NULL AS NUMERIC(18, 6))
	--	, ysnSubCurrency			= CAST(ContractView.ysnSubCurrency AS BIT)
	--	, intCurrencyId				= dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
	--	, strSubCurrency			= (SELECT strCurrency from tblSMCurrency where intCurrencyID = dbo.fnICGetCurrency(ContractView.intContractDetailId, 1)) -- 1 indicates that value is for Sub Currency
	--	, dblGross					= CAST(dbo.fnCalculateQtyBetweenUOM(BundleItemUOM.intItemUOMId, BasketUOM.intItemUOMId, dblDetailQuantity - (dblDetailQuantity - dblBalance)) AS NUMERIC(38, 20))-- There is no gross from contracts.
	--	, dblNet					= CAST(dbo.fnCalculateQtyBetweenUOM(BundleItemUOM.intItemUOMId, BasketUOM.intItemUOMId, dblDetailQuantity - (dblDetailQuantity - dblBalance)) AS NUMERIC(38, 20))
	--	, intForexRateTypeId		= ContractView.intRateTypeId
	--	, strForexRateType			= ContractView.strCurrencyExchangeRateType
	--	, dblForexRate				= ContractView.dblRate
	--	, ysnBundleItem				= ContractView.ysnBundleItem
	--	, intBundledItemId			= ContractView.intItemId
	--	, strBundledItemNo			= ContractView.strItemNo
	--	, strBundledItemDescription = ContractView.strItemDescription
	--	, ysnIsBasket 				= ContractView.ysnIsBasket
	--FROM vyuCTContractAddOrdersLookup ContractView
	--	--LEFT JOIN dbo.tblICItemUOM ItemUOM ON ContractView.intItemUOMId = ItemUOM.intItemUOMId
	--	INNER JOIN tblICItemBundle BundleItem ON BundleItem.intItemId = ContractView.intItemId
	--	LEFT JOIN tblICItem BasketItem ON BasketItem.intItemId = BundleItem.intBundleItemId
	--	--LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
	--	LEFT JOIN dbo.tblICItemUOM GrossNetUOM ON ContractView.intNetWeightUOMId = GrossNetUOM.intItemUOMId
	--	LEFT JOIN dbo.tblICItemUOM BundleItemUOM ON ContractView.intItemUOMId = BundleItemUOM.intItemUOMId
	--	LEFT JOIN dbo.tblICUnitMeasure BundleItemUnitMeasure ON BundleItemUnitMeasure.intUnitMeasureId = BundleItemUOM.intUnitMeasureId
	--	LEFT JOIN tblICItemUOM BasketUOM ON BasketUOM.intItemId = BasketItem.intItemId
	--		AND BasketUOM.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
	--	LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
	--	LEFT JOIN dbo.tblICItemUOM CostUOM ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, intPriceItemUOMId)
	--	LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
	--WHERE ContractView.ysnAllowedToShow = 1
	--	AND ContractView.strContractType = 'Purchase'
	--	AND ISNULL(ContractView.ysnIsBasket, 0) = 1
) tblAddOrders