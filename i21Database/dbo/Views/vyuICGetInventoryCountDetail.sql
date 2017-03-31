CREATE VIEW [dbo].[vyuICGetInventoryCountDetail]
	AS 

SELECT InvCountDetail.intInventoryCountDetailId,
	InvCountDetail.intInventoryCountId,
	InvCountDetail.intItemId,
	Item.strItemNo,
	strItemDescription = Item.strDescription,
	Item.strLotTracking,
	Item.intCategoryId,
	strCategory = Category.strCategoryCode,
	InvCountDetail.intItemLocationId,
	Location.strLocationName,
	InvCountDetail.intSubLocationId,
	SubLocation.strSubLocationName,
	InvCountDetail.intStorageLocationId,
	strStorageLocationName = StorageLocation.strName,
	InvCountDetail.intLotId,
	Lot.strLotNumber,
	Lot.strLotAlias,
	InvCountDetail.dblSystemCount,
	InvCountDetail.dblLastCost,
	InvCountDetail.strCountLine,
	InvCountDetail.dblPallets,
	InvCountDetail.dblQtyPerPallet,
	InvCountDetail.dblPhysicalCount,
	InvCountDetail.intItemUOMId,
	UOM.strUnitMeasure,
	dblConversionFactor = dbo.fnICConvertUOMtoStockUnit(InvCountDetail.intItemId, InvCountDetail.intItemUOMId, 1),
	dblPhysicalCountStockUnit = dbo.fnICConvertUOMtoStockUnit(InvCountDetail.intItemId, InvCountDetail.intItemUOMId, InvCountDetail.dblPhysicalCount),
	dblVariance = (CASE WHEN InvCount.ysnCountByLots = 1 THEN ISNULL(InvCountDetail.dblSystemCount, 0) - ISNULL(InvCountDetail.dblPhysicalCount, 0)
					ELSE ISNULL(InvCountDetail.dblSystemCount, 0) - dbo.fnICConvertUOMtoStockUnit(InvCountDetail.intItemId, InvCountDetail.intItemUOMId, InvCountDetail.dblPhysicalCount)
					END),
	InvCountDetail.ysnRecount,
	InvCountDetail.intEntityUserSecurityId,
	UserSecurity.strUserName,
	InvCountDetail.intSort
FROM tblICInventoryCountDetail InvCountDetail
	LEFT JOIN tblICInventoryCount InvCount ON InvCount.intInventoryCountId = InvCountDetail.intInventoryCountId
	LEFT JOIN tblICItem Item ON Item.intItemId = InvCountDetail.intItemId
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
	LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = InvCountDetail.intItemLocationId
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = InvCountDetail.intSubLocationId
	LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = InvCountDetail.intStorageLocationId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = InvCountDetail.intLotId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InvCountDetail.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMUserSecurity UserSecurity ON UserSecurity.[intEntityId] = InvCountDetail.intEntityUserSecurityId
