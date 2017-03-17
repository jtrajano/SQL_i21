CREATE VIEW [dbo].[vyuICGetReceiptAddLGInboundShipment]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * 
FROM (	
	SELECT  
		intLocationId				= LogisticsView.intCompanyLocationId
		, intEntityVendorId			= intEntityVendorId
		, strVendorId				= strVendor
		, strVendorName				= strVendor
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= intPContractDetailId
		, intOrderId				= intPContractHeaderId
		, strOrderNumber			= strPContractNumber
		, dblOrdered				= LogisticsView.dblQuantity
		, dblReceived				= dblDeliveredQuantity
		, intSourceType				= 2
		, intSourceId				= intLoadDetailId
		, strSourceNumber			= strLoadNumber
		, intItemId					= LogisticsView.intItemId
		, strItemNo					= strItemNo
		, strItemDescription		= strItemDescription
		, dblQtyToReceive			= LogisticsView.dblQuantity - dblDeliveredQuantity
		, intLoadToReceive			= CAST(0 AS INT) 
		, dblUnitCost				= dblCost
		, dblTax					= CAST(0 AS NUMERIC(18, 6)) 
		, dblLineTotal				= CAST(0 AS NUMERIC(18, 6)) 
		, strLotTracking			= strLotTracking
		, intCommodityId			= intPCommodityId
		, intContainerId			= LogisticsView.intLoadContainerId
		, strContainer				= LogisticsView.strContainerNumber
		, intSubLocationId			= LogisticsView.intPSubLocationId
		, strSubLocationName		= subLocation.strSubLocationName
		, intStorageLocationId		= LogisticsView.intStorageLocationId
		, strStorageLocationName	= LogisticsView.strStorageLocationName 
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
		, intCostUOMId				= CostUOM.intItemUOMId
		, strCostUOM				= CostUnitMeasure.strUnitMeasure
		, dblCostUOMConvFactor		= CostUOM.dblUnitQty
		, intLifeTime				= intPLifeTime
		, strLifeTimeType			= strPLifeTimeType
		, ysnLoad					= CAST(0 AS BIT) 
		, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
		, strBOL					= LogisticsView.strBLNumber
		, dblFranchise				= LogisticsView.dblFranchise
		, dblContainerWeightPerQty	= LogisticsView.dblContainerWeightPerQty
		, ysnSubCurrency			= CAST(LogisticsView.ysnSubCurrency AS BIT)
		, intCurrencyId				= dbo.fnICGetCurrency(LogisticsView.intPContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
		, strSubCurrency			= (SELECT strCurrency from tblSMCurrency where intCurrencyID = dbo.fnICGetCurrency(LogisticsView.intPContractDetailId, 1)) -- 1 indicates that value is for Sub Currency
		, dblGross					= CAST(LogisticsView.dblGross AS NUMERIC(38, 20))
		, dblNet					= CAST(LogisticsView.dblNet AS NUMERIC(38, 20))
		, LC.ysnRejected
		, intForexRateTypeId		= CAST(NULL AS INT) -- Add dummy fields for the meantime. 
		, strForexRateType			= currencyType.strCurrencyExchangeRateType -- Add dummy fields for the meantime. 
		, dblForexRate				= CAST(NULL AS NUMERIC(18, 6)) -- Add dummy fields for the meantime. 
	FROM	vyuLGLoadContainerReceiptContracts LogisticsView LEFT JOIN dbo.tblSMCurrency Currency 
				ON Currency.strCurrency = ISNULL(LogisticsView.strCurrency, LogisticsView.strMainCurrency) 
			LEFT JOIN dbo.tblICItemUOM ItemUOM 
				ON LogisticsView.intItemUOMId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure 
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
				ON LogisticsView.intWeightItemUOMId = GrossNetUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure 
				ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM CostUOM 
				ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(LogisticsView.intItemId, LogisticsView.intPCostUOMId)
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure 
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = LogisticsView.intItemId AND ItemLocation.intLocationId = LogisticsView.intCompanyLocationId
			LEFT JOIN tblLGLoadContainer LC 
				ON LC.intLoadContainerId = LogisticsView.intLoadContainerId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyType 
				ON currencyType.intCurrencyExchangeRateTypeId = NULL 
			LEFT JOIN tblSMCompanyLocationSubLocation subLocation ON subLocation.intCompanyLocationSubLocationId = LogisticsView.intPSubLocationId
	WHERE LogisticsView.dblBalanceToReceive > 0 
		  AND LogisticsView.intSourceType = 2 
		  AND LogisticsView.intTransUsedBy = 1 
		  AND LogisticsView.intPurchaseSale = 1
		  AND LogisticsView.ysnPosted = 1
		  AND ISNULL(LC.ysnRejected,0) <> 1
) tblAddOrders
