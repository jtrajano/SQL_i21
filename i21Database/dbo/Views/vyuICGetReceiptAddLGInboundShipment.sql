﻿CREATE VIEW [dbo].[vyuICGetReceiptAddLGInboundShipment]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * 
FROM (	
	SELECT  
		intLocationId				= LogisticsView.intCompanyLocationId
		, intEntityVendorId			= LogisticsView.intEntityVendorId
		, strVendorId				= LogisticsView.strVendor
		, strVendorName				= LogisticsView.strVendor
		, strReceiptType			= 'Purchase Contract'
		, intLineNo					= LogisticsView.intPContractDetailId
		, intOrderId				= LogisticsView.intPContractHeaderId
		, strOrderNumber			= LogisticsView.strPContractNumber
		, dblOrdered				= LogisticsView.dblQuantity
		, dblReceived				= LogisticsView.dblDeliveredQuantity
		, intSourceType				= 2
		, intSourceId				= LogisticsView.intLoadDetailId
		, strSourceNumber			= LogisticsView.strLoadNumber
		, intItemId					= LogisticsView.intItemId
		, strItemNo					= LogisticsView.strItemNo
		, strItemDescription		= LogisticsView.strItemDescription
		, dblQtyToReceive			= LogisticsView.dblQuantity - LogisticsView.dblDeliveredQuantity
		, intLoadToReceive			= CAST(0 AS INT) 
		, dblUnitCost				= LogisticsView.dblCost
		, dblTax					= CAST(0 AS NUMERIC(18, 6)) 
		, dblLineTotal				= CAST(0 AS NUMERIC(18, 6)) 
		, strLotTracking			= LogisticsView.strLotTracking
		, intCommodityId			= LogisticsView.intPCommodityId
		, intContainerId			= LogisticsView.intLoadContainerId
		, strContainer				= LogisticsView.strContainerNumber
		, intSubLocationId			= ISNULL(LogisticsView.intSubLocationId, LogisticsView.intPSubLocationId) 
		, strSubLocationName		= CASE WHEN LogisticsView.intSubLocationId IS NOT NULL THEN LogisticsView.strSubLocationName ELSE OrdersSubLocation.strSubLocationName END 
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
		, intLifeTime				= LogisticsView.intPLifeTime
		, strLifeTimeType			= LogisticsView.strPLifeTimeType
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
		, intForexRateTypeId		= ISNULL(LogisticsView.intForexRateTypeId, CompanyPreferenceForex.intForexRateTypeId) 
		, strForexRateType			= ISNULL(currencyType.strCurrencyExchangeRateType, CompanyPreferenceForex.strCurrencyExchangeRateType)
		, dblForexRate				= ISNULL(LogisticsView.dblForexRate, CompanyPreferenceForex.dblForexRate) 
		, ysnBundleItem				= CAST(0 AS BIT)
		, intBundledItemId			= CAST(NULL AS INT)
		, strBundledItemNo			= CAST(NULL AS NVARCHAR(50))
		, strBundledItemDescription = CAST(NULL AS NVARCHAR(50))
		, ysnIsBasket = CAST(0 AS BIT)
		, LogisticsView.intFreightTermId
		, LogisticsView.strFreightTerm 
		, strMarkings               = LogisticsView.strMarks
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
			LEFT JOIN tblSMCompanyLocationSubLocation OrdersSubLocation ON OrdersSubLocation.intCompanyLocationSubLocationId = LogisticsView.intPSubLocationId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyType ON currencyType.intCurrencyExchangeRateTypeId = LogisticsView.intForexRateTypeId

			OUTER APPLY (
				SELECT	dblForexRate = DefaultForexRateDetail.dblRate		
						,intForexRateTypeId = MultiCurrencyDefault.intContractRateTypeId
						,ForexRateType.strCurrencyExchangeRateType
				FROM	tblSMCompanyPreference Company
						INNER JOIN tblSMMultiCurrency MultiCurrencyDefault ON MultiCurrencyDefault.intMultiCurrencyId = Company.intMultiCurrencyId 												
						INNER JOIN [dbo].[tblSMCurrency] AS FromCurrency ON FromCurrency.[intCurrencyID] = dbo.fnICGetCurrency(LogisticsView.intPContractDetailId, 0)
						INNER JOIN [dbo].[tblSMCurrency] AS ToCurrency ON ToCurrency.[intCurrencyID] = Company.intDefaultCurrencyId 

						INNER JOIN [dbo].[tblSMCurrencyExchangeRate] AS ForexPair
							ON ForexPair.intFromCurrencyId = FromCurrency.intCurrencyID
							AND ForexPair.intToCurrencyId = ToCurrency.intCurrencyID
						INNER JOIN [dbo].[tblSMCurrencyExchangeRateDetail] AS DefaultForexRateDetail 
							ON DefaultForexRateDetail.intCurrencyExchangeRateId = ForexPair.intCurrencyExchangeRateId
							AND DefaultForexRateDetail.intRateTypeId = MultiCurrencyDefault.intContractRateTypeId
						INNER JOIN tblSMCurrencyExchangeRateType ForexRateType
							ON ForexRateType.intCurrencyExchangeRateTypeId = MultiCurrencyDefault.intContractRateTypeId
						
				WHERE	dbo.fnDateLessThanEquals(DefaultForexRateDetail.[dtmValidFromDate], LogisticsView.dtmScheduledDate) = 1						
						AND ToCurrency.intCurrencyID <> FromCurrency.intCurrencyID -- Transaction Currency is not the functiona currency. 
						AND LogisticsView.intForexRateTypeId IS NULL

			) CompanyPreferenceForex 

	WHERE LogisticsView.dblBalanceToReceive > 0 
		  AND LogisticsView.intSourceType = 2 
		  AND LogisticsView.intTransUsedBy = 1 
		  AND LogisticsView.intPurchaseSale = 1
		  AND LogisticsView.ysnPosted = 1
		  AND ISNULL(LC.ysnRejected,0) <> 1
) tblAddOrders
