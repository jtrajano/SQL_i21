﻿CREATE VIEW [dbo].[vyuICGetReceiptAddPurchaseOrder]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, [intEntityId], intLineNo) AS INT)
, * 
FROM (
	SELECT 	
		POView.intLocationId
		, intEntityId = POView.intEntityVendorId
		, strVendorId
		, strVendorName = strName
		, strReceiptType = 'Purchase Order' COLLATE Latin1_General_CI_AS
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
		, strItemDescription = POView.strDescription
		, dblQtyToReceive = dblQtyOrdered - dblQtyReceived
		, intLoadToReceive = NULL
		, dblUnitCost = dblCost
		, dblTax
		, dblLineTotal = (dblQtyOrdered - dblQtyReceived) * dblCost * (ItemUOM.dblUnitQty / CostUOM.dblUnitQty)
		, strLotTracking
		, intCommodityId
		, intContainerId = NULL
		, strContainer = NULL
		, POView.intSubLocationId
		, strSubLocationName
		, POView.intStorageLocationId
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
		, CAST(0 AS BIT) AS ysnLoad
		, CAST(0 AS NUMERIC(38, 20)) AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = CAST(0  AS BIT)
		, intCurrencyId = POView.intCurrencyId
		, strSubCurrency = CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		, dblGross = CAST(0 AS NUMERIC(38, 20)) -- There is no gross from PO
		, dblNet = CAST(0 AS NUMERIC(38, 20)) -- There is no net from PO
		, intForexRateTypeId = POView.intForexRateTypeId
		, strForexRateType = currencyRateType.strCurrencyExchangeRateType
		, dblForexRate = POView.dblForexRate
		, ysnBundleItem = CAST(0 AS BIT)
		, intBundledItemId = CAST(NULL AS INT)
		, strBundledItemNo = CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		, strBundledItemDescription = CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		, ysnIsBasket = CAST(0 AS BIT)
		, POView.intFreightTermId
		, POView.strFreightTerm
		, POView.strBundleType
		, strLotCondition = ICPreference.strLotCondition
		, intAllowZeroCostTypeId = ItemLocation.intAllowZeroCostTypeId 
		, ysnWeighed					= CAST(0 AS BIT) 
	FROM	vyuPODetails POView			
			INNER JOIN tblICItemLocation ItemLocation 
				ON ItemLocation.intItemId = POView.intItemId 
				AND ItemLocation.intLocationId = POView.intLocationId 
			LEFT JOIN dbo.tblICItemUOM ItemUOM
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
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = POView.intForexRateTypeId
		OUTER APPLY (
			SELECT	TOP 1 *
			FROM	 tblICCompanyPreference			
		) ICPreference
	WHERE ysnCompleted = 0
		AND POView.strType NOT IN ('Software', 'Other Charge', 'Comment', 'Service')
		
) tblAddOrders