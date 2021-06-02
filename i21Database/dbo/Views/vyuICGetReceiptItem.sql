CREATE VIEW [dbo].[vyuICGetReceiptItem]
AS 

SELECT
	intKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intItemId, ItemLocation.intLocationId) AS INT),
	Item.intItemId,
	Item.strItemNo,
	Item.strDescription,
	Item.strType,
	Item.intCommodityId,
	Item.intLifeTime,
	Item.strLifeTimeType,
	Item.ysnLotWeightsRequired,
	dblLastCost = COALESCE(ItemPricing.dblLastCost, 0),
	dblStandardCost = COALESCE(ItemPricing.dblStandardCost, 0),
	dblSalePrice = ISNULL(ItemPricing.dblSalePrice, 0),
	dblReceiveUOMConvFactor = COALESCE(ReceiveUOM.dblUnitQty, ItemUOM.dblUnitQty, 0),
	strReceiveUOM = COALESCE(rUOM.strUnitMeasure, iUOM.strUnitMeasure),
	strReceiveUOMType = COALESCE(rUOM.strUnitType, iUOM.strUnitType),
	intReceiveUOMId = COALESCE(ReceiveUOM.intItemUOMId, ItemUOM.intItemUOMId),
	strReceiveUPC = COALESCE(ReceiveUOM.strLongUPCCode, ItemUOM.strLongUPCCode, COALESCE(ReceiveUOM.strUpcCode, ItemUOM.strUpcCode, '')),
	intReceiveUnitMeasureId = COALESCE(ReceiveUOM.intUnitMeasureId, ItemUOM.intUnitMeasureId),
	intGrossUOMId = GrossUOM.intItemUOMId,
	strGrossUOM = gUOM.strUnitMeasure,
	intGrossUnitMeasureId = GrossUOM.intUnitMeasureId,
	dblGrossUOMConvFactor = GrossUOM.dblUnitQty,
	ItemLocation.intLocationId,
	ItemLocation.intSubLocationId,
	ItemLocation.intStorageLocationId,
	ItemLocation.ysnStorageUnitRequired,
	StorageLocation.strName AS strStorageLocationName,
	SubLocation.strSubLocationName AS strSubLocationName,
	intCostingMethod = 
			CASE 
				WHEN ISNULL(Item.strLotTracking, 'No') <> 'No' THEN 
					4 -- 4 is for Lot Costing
				ELSE
					ItemLocation.intCostingMethod
			END,
	ysnHasAddOn = CAST(ISNULL(ItemAddOn.ysnHasAddOn, 0) AS BIT),
	ysnHasAddOnOtherCharge = CAST(ISNULL(AddOnOtherCharge.ysnHasAddOnOtherCharge, 0) AS BIT)
FROM tblICItem Item
LEFT JOIN (
	tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
		ON l.intCompanyLocationId = ItemLocation.intLocationId
)
	ON ItemLocation.intItemId = Item.intItemId
	AND ItemLocation.intLocationId IS NOT NULL 
LEFT JOIN (
	tblICItemUOM ReceiveUOM INNER JOIN tblICUnitMeasure rUOM 
		ON rUOM.intUnitMeasureId = ReceiveUOM.intUnitMeasureId
)	
	ON ReceiveUOM.intItemUOMId = ItemLocation.intReceiveUOMId

LEFT JOIN (
	tblICItemUOM GrossUOM INNER JOIN tblICUnitMeasure gUOM 
		ON gUOM.intUnitMeasureId = GrossUOM.intUnitMeasureId
		AND gUOM.strUnitType IN ('Volume', 'Weight')
)
	ON GrossUOM.intItemUOMId = ItemLocation.intGrossUOMId

LEFT JOIN (
	tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
		ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
)
	ON ItemUOM.intItemId = Item.intItemId AND COALESCE(ItemUOM.strLongUPCCode, ItemUOM.strUpcCode) IS NOT NULL

LEFT JOIN tblICItemPricing ItemPricing 
	ON ItemLocation.intItemId = ItemPricing.intItemId 
	AND ItemLocation.intItemLocationId = ItemPricing.intItemLocationId

LEFT JOIN tblICStorageLocation StorageLocation 
	ON ItemLocation.intStorageLocationId = StorageLocation.intStorageLocationId

LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
	ON ItemLocation.intSubLocationId = SubLocation.intCompanyLocationSubLocationId

OUTER APPLY (
	SELECT TOP 1 1 as ysnHasAddOn FROM tblICItemAddOn ItemAddOn 
	WHERE ItemAddOn.intItemId = Item.intItemId
) ItemAddOn

OUTER APPLY(
	SELECT TOP 1 1 as ysnHasAddOnOtherCharge FROM tblICItemAddOn ItemAddOn
	INNER JOIN tblICItem ChargeItem ON ChargeItem.intItemId = ItemAddOn.intItemId
	WHERE ItemAddOn.intItemId = Item.intItemId
	AND ChargeItem.strType = 'Other Charge'
) AddOnOtherCharge