﻿CREATE VIEW [dbo].[vyuICGetReceiptAddPurchaseOrder]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * 
FROM (
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
		, dblGross = CAST(0 AS NUMERIC(38, 20)) -- There is no gross from PO
		, dblNet = CAST(0 AS NUMERIC(38, 20)) -- There is no net from PO
	FROM	vyuPODetails POView LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON POView.intUnitOfMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON POView.intUnitOfMeasureId = CostUOM.intItemUOMId
			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
	WHERE ysnCompleted = 0
		
) tblAddOrders