CREATE VIEW [dbo].[vyuICGetInventoryCountDetail]
	AS 

SELECT InvCountDetail.intInventoryCountDetailId,
	InvCountDetail.intInventoryCountId,
	InvCountDetail.intItemId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	Item.strLotTracking,
	ysnLotWeightsRequired = ISNULL(Item.ysnLotWeightsRequired, CAST(0 AS BIT)),
	Item.intCategoryId,
	strCategory = Category.strCategoryCode,
	InvCountDetail.intItemLocationId,
	Location.strLocationName,
	InvCountDetail.intSubLocationId,
	SubLocation.strSubLocationName,
	InvCountDetail.intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
	InvCountDetail.intLotId,
	strLotNo = InvCountDetail.strLotNo,
	strLotAlias = InvCountDetail.strLotAlias,
	InvCountDetail.intParentLotId,
	strParentLotNo = InvCountDetail.strParentLotNo,
	strParentLotAlias = InvCountDetail.strParentLotAlias,
	InvCountDetail.dblSystemCount,
	InvCountDetail.dblLastCost,
	InvCountDetail.strCountLine,
	InvCountDetail.dblPallets,
	InvCountDetail.dblQtyPerPallet,
	InvCountDetail.dblPhysicalCount,
	InvCountDetail.intStockUOMId,
	strStockUOM = StockUOM.strUnitMeasure,
	InvCountDetail.intItemUOMId,
	InvCountDetail.intWeightUOMId,
	dblWeightQty = Lot.dblWeight,--InvCountDetail.dblWeightQty,
	InvCountDetail.dblNetQty,
	UOM.strUnitMeasure,
	strWeightUOM = WeightUOM.strUnitMeasure,
	dblItemUOMConversionFactor = ISNULL(ItemUOM.dblUnitQty, 0.00),
	dblWeightUOMConversionFactor = ISNULL(ItemWeightUOM.dblUnitQty, 0.00),
	dblWeightPerQty = ISNULL(Lot.dblWeightPerQty, 0.00),
	dblConversionFactor = dbo.fnICConvertUOMtoStockUnit(InvCountDetail.intItemId, InvCountDetail.intItemUOMId, 1),
	dblPhysicalCountStockUnit = dbo.fnICConvertUOMtoStockUnit(InvCountDetail.intItemId, InvCountDetail.intItemUOMId, InvCountDetail.dblPhysicalCount),
	dblVariance = (CASE WHEN InvCount.ysnCountByLots = 1 THEN ISNULL(InvCountDetail.dblSystemCount, 0) - ISNULL(InvCountDetail.dblPhysicalCount, 0)
					ELSE ISNULL(InvCountDetail.dblSystemCount, 0) - dbo.fnICConvertUOMtoStockUnit(InvCountDetail.intItemId, InvCountDetail.intItemUOMId, InvCountDetail.dblPhysicalCount)
					END),
	InvCountDetail.ysnRecount,
	InvCountDetail.intEntityUserSecurityId,
	UserSecurity.strUserName,
	InvCountDetail.intCountGroupId,
	CountGroup.strCountGroup,
	InvCountDetail.dblQtyReceived,
	InvCountDetail.dblQtySold,
	InvCountDetail.intSort, InvCountDetail.intConcurrencyId,
	ItemLocation.strStorageUnitNo
FROM tblICInventoryCountDetail InvCountDetail
	LEFT JOIN tblICInventoryCount InvCount ON InvCount.intInventoryCountId = InvCountDetail.intInventoryCountId
	LEFT JOIN tblICCountGroup CountGroup ON CountGroup.intCountGroupId = InvCountDetail.intCountGroupId
	LEFT JOIN tblICItem Item ON Item.intItemId = InvCountDetail.intItemId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = InvCountDetail.intItemLocationId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = InvCountDetail.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = InvCountDetail.intStorageLocationId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = InvCountDetail.intLotId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InvCountDetail.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = InvCountDetail.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemStockUOM ON ItemStockUOM.intItemUOMId = InvCountDetail.intStockUOMId
	LEFT JOIN tblICUnitMeasure StockUOM ON StockUOM.intUnitMeasureId = ItemStockUOM.intUnitMeasureId
	LEFT JOIN tblSMUserSecurity UserSecurity ON UserSecurity.[intEntityId] = InvCountDetail.intEntityUserSecurityId
