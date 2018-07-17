CREATE VIEW [dbo].[vyuICGetReceiptAddPurchaseContractOrder]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intItemId, intLineNo) AS INT)
, * 
FROM (
	SELECT 	
		intLocationId				= POView.intLocationId --ContractView.intCompanyLocationId			
		, intEntityVendorId			= ContractView.intEntityId
		, strVendorId				= POView.strVendorId
		, strVendorName				= ContractView.strEntityName
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= POView.intContractDetailId
		, intOrderId				= ContractView.intContractHeaderId
		, strOrderNumber			= ContractView.strContractNumber
		, dblOrdered				= POView.dblQtyOrdered --CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intNoOfLoad ELSE ContractView.dblDetailQuantity END
		, dblReceived				= POView.dblQtyReceived --CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intLoadReceived ELSE ContractView.dblDetailQuantity - ContractView.dblBalance END
		, intSourceType				= 6 --CAST(0 AS INT)
		, intSourceId				= POView.intPurchaseId --CAST(NULL AS INT) 
		, strSourceNumber			= POView.strPurchaseOrderNumber -- CAST(NULL AS NVARCHAR(50)) 
		--, intItemId					= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.intItemId ELSE ContractView.intItemId END 
		--, strItemNo					= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.strItemNo ELSE ContractView.strItemNo END 
		--, strItemDescription		= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.strDescription ELSE ContractView.strItemDescription END 
		, intItemId					= POView.intItemId --ContractView.intItemId
		, strItemNo					= POView.strItemNo
		, strItemDescription		= ContractView.strItemDescription
		-- , dblQtyToReceive			= 
		-- 			CASE	
		-- 				WHEN ContractView.ysnLoad = 1 THEN 
		-- 					dbo.fnMultiply((ContractView.intNoOfLoad - ContractView.intLoadReceived), ContractView.dblQuantityPerLoad)
		-- 				ELSE 
		-- 					ContractView.dblDetailQuantity - (ContractView.dblDetailQuantity - ContractView.dblBalance) 
		-- 			END
        , dblQtyToReceive           = POView.dblQtyOrdered - POView.dblQtyReceived
		, ysnLoad					= CAST(ContractView.ysnLoad AS BIT)
		, dblAvailableQty			= ContractView.dblAvailableQty
		, intNoOfLoad				= ContractView.intNoOfLoad
		, intLoadReceive			= 
					CASE 
						WHEN ContractView.ysnLoad = 1 THEN 
							ISNULL(ContractView.intNoOfLoad, 0) - ISNULL(ContractView.intLoadReceived, 0)
						ELSE 
							CAST(0 AS INT) 
					END
		, dblQuantityPerLoad		= ISNULL(ContractView.dblQuantityPerLoad, 0)
		, dblUnitCost				= ContractView.dblSeqPrice
		, dblTax					= POView.dblTax
		, dblLineTotal				= CAST(CASE WHEN ContractView.ysnLoad = 1 THEN ((ContractView.intNoOfLoad - ContractView.intLoadReceived) * dbo.fnDivide(ContractView.dblDetailQuantity, ContractView.intNoOfLoad))* ContractView.dblSeqPrice
											ELSE (ContractView.dblDetailQuantity - (ContractView.dblDetailQuantity - ContractView.dblBalance)) * ContractView.dblSeqPrice END AS NUMERIC(18, 6))
		--, strLotTracking			= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.strLotTracking ELSE ContractView.strLotTracking END 
		--, intCommodityId			= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.intCommodityId ELSE ContractView.intCommodityId END
		, strLotTracking			= ContractView.strLotTracking
		, intCommodityId			= ContractView.intCommodityId
		, intContainerId			= CAST(NULL AS INT) 
		, strContainer				= CAST(NULL AS NVARCHAR(50)) 
		, intSubLocationId			= ContractView.intCompanyLocationSubLocationId
		, strSubLocationName		= ContractView.strSubLocationName
		, intStorageLocationId		= ContractView.intStorageLocationId
		, strStorageLocationName	= ContractView.strStorageLocationName
		, intOrderUOMId				= CASE WHEN ContractView.ysnLoad = 1 THEN NULL ELSE ItemUOM.intItemUOMId END
		, strOrderUOM				= CASE WHEN ContractView.ysnLoad = 1 THEN 'Load' ELSE ItemUnitMeasure.strUnitMeasure END
		, dblOrderUOMConvFactor		= CASE WHEN ContractView.ysnLoad = 1 THEN 1 ELSE ItemUOM.dblUnitQty END
		--, intItemUOMId				= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItemUOM.intItemUOMId ELSE ItemUOM.intItemUOMId END 
		, intItemUOMId				= ItemUOM.intItemUOMId
		, strUnitMeasure			= ItemUnitMeasure.strUnitMeasure
		, strUnitType				= ItemUnitMeasure.strUnitType
		-- Gross/Net UOM -----------
		--, intWeightUOMId			= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketWeightUOM.intItemUOMId ELSE GrossNetUOM.intItemUOMId END  
		, intWeightUOMId			= GrossNetUOM.intItemUOMId
		, strWeightUOM				= GrossNetUnitMeasure.strUnitMeasure 
		-- Conversion factor -------
		--, dblItemUOMConvFactor		= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItemUOM.dblUnitQty ELSE ItemUOM.dblUnitQty  END  
		--, dblWeightUOMConvFactor	= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketWeightUOM.dblUnitQty ELSE GrossNetUOM.dblUnitQty END  
		, dblItemUOMConvFactor		= ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor	= GrossNetUOM.dblUnitQty
		-- Cost UOM ----------------
		--, intCostUOMId				= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketCostUOM.intItemUOMId ELSE ItemCostUOM.intItemUOMId END  -- ContractView.intSeqPriceUOMId
		--, strCostUOM				= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketCostUnitMeasure.strUnitMeasure ELSE ItemCostUnitMeasure.strUnitMeasure END  
		--, dblCostUOMConvFactor		= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketCostUOM.dblUnitQty ELSE ItemCostUOM.dblUnitQty END  
		, intCostUOMId				= ItemCostUOM.intItemUOMId
		, strCostUOM				= ItemCostUnitMeasure.strUnitMeasure
		, dblCostUOMConvFactor		= ItemCostUOM.dblUnitQty 
		----------------------------
		--, intLifeTime				= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.intLifeTime ELSE ContractView.intLifeTime END
		--, strLifeTimeType			= CASE WHEN ContractView.strBundleType = 'Basket' THEN BasketItem.strLifeTimeType ELSE ContractView.strLifeTimeType END
		, intLifeTime				= ContractView.intLifeTime
		, strLifeTimeType			= ContractView.strLifeTimeType
		, strBOL					= CAST(NULL AS NVARCHAR(50))
		, dblFranchise				= CAST(NULL AS NUMERIC(18, 6))
		, dblContainerWeightPerQty	= CAST(NULL AS NUMERIC(18, 6))
		, ysnSubCurrency			= CAST(ContractView.ysnSubCurrency AS BIT)
		, intCurrencyId				= dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
		, strSubCurrency			= SubCurrency.strCurrency
		, dblGross					= 
									--CASE WHEN ContractView.strBundleType = 'Basket' THEN 
									--	CAST(dbo.fnCalculateQtyBetweenUOM(ItemUOM.intItemUOMId, BasketWeightUOM.intItemUOMId, dblDetailQuantity - (dblDetailQuantity - dblBalance)) AS NUMERIC(38, 20)) 
									--ELSE 
										CAST(POView.dblQtyOrdered AS NUMERIC(38, 20))									
									--END
									
		, dblNet					= 
									--CASE WHEN ContractView.strBundleType = 'Basket' THEN 
									--	CAST(dbo.fnCalculateQtyBetweenUOM(ItemUOM.intItemUOMId, BasketWeightUOM.intItemUOMId, dblDetailQuantity - (dblDetailQuantity - dblBalance)) AS NUMERIC(38, 20))
									--ELSE 
										CAST(POView.dblQtyOrdered AS NUMERIC(38, 20))									
									--END

		, intForexRateTypeId		= ISNULL(ContractView.intRateTypeId, CompanyPreferenceForexRateType.intForexRateTypeId)
		, strForexRateType			= ISNULL(ContractView.strCurrencyExchangeRateType, CompanyPreferenceForexRateType.strCurrencyExchangeRateType)
		, dblForexRate				= ISNULL(ContractView.dblRate, defaultForexRate.dblRate) 
		, strBundleType				= ContractView.strBundleType
		--, ysnBundleItem				= ContractView.ysnBundleItem
		--, intBundledItemId			= CASE WHEN ContractView.strBundleType = 'Basket' THEN ContractView.intItemId ELSE CAST(NULL AS INT) END 
		--, strBundledItemNo			= CASE WHEN ContractView.strBundleType = 'Basket' THEN ContractView.strItemNo ELSE CAST(NULL AS NVARCHAR(50)) END 
		--, strBundledItemDescription = CASE WHEN ContractView.strBundleType = 'Basket' THEN ContractView.strItemDescription ELSE CAST(NULL AS NVARCHAR(50)) END 
		--, ysnIsBasket 				= CAST(CASE ContractView.strBundleType WHEN 'Baset' THEN 1 ELSE 0 END AS BIT)
		, ContractView.intFreightTermId
		, ContractView.strFreightTerm
		, ContractView.intContractSeq
	FROM vyuCTContractAddOrdersLookup ContractView
        INNER JOIN vyuPODetails POView ON POView.intContractDetailId = ContractView.intContractDetailId
		LEFT JOIN dbo.tblICItemUOM ItemUOM ON ContractView.intItemUOMId = ItemUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM GrossNetUOM ON ContractView.intNetWeightUOMId = GrossNetUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, ContractView.intSeqPriceUOMId)
		LEFT JOIN dbo.tblICUnitMeasure ItemCostUnitMeasure ON ItemCostUnitMeasure.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = dbo.fnICGetCurrency(ContractView.intContractDetailId, 1) -- 1 indicates that value is for Sub Currency
		OUTER APPLY (
			SELECT	intForexRateTypeId = MultiCurrencyDefault.intContractRateTypeId
					,ForexRateType.strCurrencyExchangeRateType
			FROM	tblSMCompanyPreference Company
					INNER JOIN tblSMMultiCurrency MultiCurrencyDefault 
						ON MultiCurrencyDefault.intMultiCurrencyId = Company.intMultiCurrencyId
					INNER JOIN tblSMCurrencyExchangeRateType ForexRateType
						ON ForexRateType.intCurrencyExchangeRateTypeId = MultiCurrencyDefault.intContractRateTypeId -- Get the contract default forex rate type
			WHERE	ContractView.intRateTypeId IS NULL 
					AND Company.intDefaultCurrencyId <> dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- Contract currency is not the functional currnecy. 
		) CompanyPreferenceForexRateType

		OUTER APPLY dbo.fnSMGetForexRate(
			dbo.fnICGetCurrency(ContractView.intContractDetailId, 0)
			,ISNULL(ContractView.intRateTypeId, CompanyPreferenceForexRateType.intForexRateTypeId)
			,ContractView.dtmContractDate
		) defaultForexRate 

		-- The following are bundle/basket related queries:
		--LEFT JOIN tblICItemBundle BundleItem ON BundleItem.intItemId = ContractView.intItemId
		--LEFT JOIN tblICItem BasketItem ON BasketItem.intItemId = BundleItem.intBundleItemId
		--LEFT JOIN tblICItemUOM BasketItemUOM ON BasketItemUOM.intItemId = BasketItem.intItemId AND BasketItemUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		--LEFT JOIN tblICItemUOM BasketWeightUOM ON BasketWeightUOM.intItemId = BasketItem.intItemId AND BasketWeightUOM.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
		--LEFT JOIN dbo.tblICItemUOM BasketCostUOM ON BasketCostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(BasketItem.intItemId, ContractView.intSeqPriceUOMId)
		--LEFT JOIN dbo.tblICUnitMeasure BasketCostUnitMeasure ON BasketCostUnitMeasure.intUnitMeasureId = BasketCostUOM.intUnitMeasureId

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