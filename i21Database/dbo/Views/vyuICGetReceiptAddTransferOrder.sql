CREATE VIEW [dbo].[vyuICGetReceiptAddTransferOrder]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * 
FROM (
	SELECT
			intLocationId				= h.intFromLocationId
			, intEntityVendorId			= CAST(h.intToLocationId AS INT) 
			, strVendorId				= CAST(Loc.strLocationName AS NVARCHAR(50))
			, strVendorName				= CAST(Loc.strLocationName AS NVARCHAR(50))
			, strReceiptType			= 'Transfer Order'
			, intLineNo					= d.intInventoryTransferDetailId
			, intOrderId				= h.intInventoryTransferId
			, strOrderNumber			= h.strTransferNo
			, dblOrdered				= -t.dblQty 
			, dblReceived				= CAST(NULL AS NUMERIC(38, 20))
			, intSourceType				= CAST(0 AS INT)
			, intSourceId				= CAST(NULL AS INT)
			, strSourceNumber			= CAST(NULL AS NVARCHAR(50))
			, intItemId					= d.intItemId
			, strItemNo					= item.strItemNo
			, strItemDescription		= item.strDescription
			, dblQtyToReceive			= -t.dblQty 
			, intLoadToReceive			= CAST(0 AS INT)
			, dblUnitCost				= t.dblCost 
			, dblTax					= CAST(0 AS NUMERIC(18, 6))
			, dblLineTotal				= CAST(0 AS NUMERIC(38, 20))
			, strLotTracking			= item.strLotTracking
			, intCommodityId			= item.intCommodityId
			, intContainerId			= CAST(NULL AS INT)
			, strContainer				= CAST(NULL AS NVARCHAR(50))
			, intSubLocationId			= toSubLocation.intCompanyLocationSubLocationId
			, strSubLocationName		= toSubLocation.strSubLocationName 
			, intStorageLocationId		= toStorageLocation.intStorageLocationId
			, strStorageLocationName	= toStorageLocation.strName
			, intOrderUOMId				= ItemUOM.intItemUOMId
			, strOrderUOM				= ItemUnitMeasure.strUnitMeasure
			, dblOrderUOMConvFactor		= ItemUOM.dblUnitQty
			, intItemUOMId				= ItemUOM.intItemUOMId
			, strUnitMeasure			= ItemUnitMeasure.strUnitMeasure
			, strUnitType				= CAST(NULL AS NVARCHAR(50))
			-- Gross/Net UOM --------------------------------------------------------
			, intWeightUOMId			= GrossNetUOM.intItemUOMId
			, strWeightUOM				= GrossNetUnitMeasure.strUnitMeasure
			-- Conversion factor --------------------------------------------------------
			, dblItemUOMConvFactor		= ItemUOM.dblUnitQty
			, dblWeightUOMConvFactor	= GrossNetUOM.dblUnitQty
			-- Cost UOM --------------------------------------------------------
			, intCostUOMId				= CostUOM.intItemUOMId -- intItemUOMId
			, strCostUOM				= CostUnitMeasure.strUnitMeasure
			, dblCostUOMConvFactor		= CostUOM.dblUnitQty
			, intLifeTime				= item.intLifeTime
			, strLifeTimeType			= item.strLifeTimeType
			, ysnLoad					= CAST(0 AS BIT) 
			, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
			, strBOL					= CAST(NULL AS NVARCHAR(50))
			, dblFranchise				= CAST(0 AS NUMERIC(18, 6))
			, dblContainerWeightPerQty	= CAST(0 AS NUMERIC(18, 6))
			, ysnSubCurrency			= CAST(0 AS BIT) 
			, intCurrencyId				= dbo.fnSMGetDefaultCurrency('FUNCTIONAL')  
			, strSubCurrency			= CAST(NULL AS NVARCHAR(50)) 
			, dblGross					= CAST(0 AS NUMERIC(38, 20)) -- There is no gross from transfer
			, dblNet					= CAST(0 AS NUMERIC(38, 20)) -- There is no net from transfer
			, ysnBundleItem = CAST(0 AS BIT)
			, intBundledItemId = CAST(NULL AS INT)
			, strBundledItemNo = CAST(NULL AS NVARCHAR(50))
			, strBundledItemDescription = CAST(NULL AS NVARCHAR(50))
			, ysnIsBasket = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransfer h INNER JOIN tblICInventoryTransferDetail d 
				ON h.intInventoryTransferId = d.intInventoryTransferId
	
			INNER JOIN tblICInventoryTransaction t
				ON t.intTransactionId = h.intInventoryTransferId
				AND t.strTransactionId = h.strTransferNo
				AND ISNULL(t.dblQty, 0) <> 0 
				AND ISNULL(t.dblQty, 0) < 0 
				AND t.ysnIsUnposted = 0 

			INNER JOIN dbo.tblICItem item
				ON item.intItemId = d.intItemId

			LEFT JOIN tblICItemLocation fromLocation
				ON fromLocation.intItemId = d.intItemId
				AND fromLocation.intLocationId = h.intFromLocationId

			LEFT JOIN tblICItemLocation toLocation
				ON toLocation.intItemId = d.intItemId
				AND toLocation.intLocationId = h.intToLocationId
			
			LEFT JOIN dbo.tblICItemPricing ip
				ON ip.intItemId = d.intItemId
				AND ip.intItemLocationId = fromLocation.intItemLocationId

			LEFT JOIN dbo.tblSMCompanyLocationSubLocation fromSubLocation
				ON fromSubLocation.intCompanyLocationSubLocationId = d.intFromSubLocationId

			LEFT JOIN dbo.tblSMCompanyLocationSubLocation toSubLocation
				ON toSubLocation.intCompanyLocationSubLocationId = d.intToSubLocationId

			LEFT JOIN dbo.tblICStorageLocation fromStorageLocation
				ON fromStorageLocation.intStorageLocationId = d.intFromStorageLocationId

			LEFT JOIN dbo.tblICStorageLocation toStorageLocation
				ON toStorageLocation.intStorageLocationId = d.intToStorageLocationId

			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON ItemUOM.intItemUOMId = t.intItemUOMId 
				AND ItemUOM.intItemId = item.intItemId

			LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure
				ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM GrossNetUOM
				ON GrossNetUOM.intItemUOMId = d.intItemWeightUOMId
				AND GrossNetUOM.intItemId = item.intItemId

			LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure
				ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId

			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(t.intItemId, t.intItemUOMId)
				AND CostUOM.intItemId = item.intItemId

			LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure
				ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
			LEFT JOIN dbo.tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = toLocation.intLocationId
	WHERE h.ysnPosted = 1
		AND h.ysnShipmentRequired = 1
		AND (h.intStatusId = 1 OR h.intStatusId = 2)
	
) tblAddOrders
