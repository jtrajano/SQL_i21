CREATE VIEW [dbo].[vyuICGetReceiptAddPurchaseOrder]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, [intEntityId], intLineNo) AS INT)
, * 
FROM (
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
		, CAST(0 AS BIT) AS ysnLoad
		, CAST(0 AS NUMERIC(38, 20)) AS dblAvailableQty
		, strBOL = NULL
		, dblFranchise = 0.00
		, dblContainerWeightPerQty = 0.00
		, ysnSubCurrency = CAST(0  AS BIT)
		, intCurrencyId = POView.intCurrencyId
		, strSubCurrency = CAST(NULL AS NVARCHAR(50)) 
		, dblGross = POView.dblNetWeight -- There is no gross from PO
		, dblNet = POView.dblNetWeight -- There is no net from PO
		, intForexRateTypeId = POView.intForexRateTypeId
		, strForexRateType = currencyRateType.strCurrencyExchangeRateType
		, dblForexRate = POView.dblForexRate
	FROM	vyuPODetails POView LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON POView.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON POView.intCostUOMId = CostUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
            --OUTER APPLY dbo.fnGetDefaultGrossNetUOMForLotItem(POView.intItemId) DefaultGrossNetUOM
            LEFT JOIN dbo.tblICItemUOM GrossNetUOM
                ON GrossNetUOM.intItemUOMId = POView.intWeightUOMId
            LEFT JOIN dbo.tblICUnitMeasure GrossNetName 
                ON GrossNetName.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = POView.intForexRateTypeId
	WHERE ysnCompleted = 0
		
) tblAddOrders