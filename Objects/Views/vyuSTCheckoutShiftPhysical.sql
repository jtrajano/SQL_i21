CREATE VIEW [dbo].[vyuSTCheckoutShiftPhysical]
AS 
SELECT 
intCheckoutShiftPhysicalId
, SP.intCheckoutId
, SP.intItemId
, SP.intItemLocationId
, SP.intCompanyLocationSubLocationId
, SP.intStorageLocationId
, SP.intCountGroupId
, intLotId
, strLotNo
, strLotAlias
, intParentLotId
, strParentLotNo
, strParentLotAlias
, intStockUOMId
, dblSystemCount
, dblLastCost
, strAutoCreatedLotNumber
, strCountLine
, dblPallets
, dblQtyPerPallet
, dblPhysicalCount
, SP.intItemUOMId
, SP.intWeightUOMId
, dblWeightQty
, dblNetQty
, SP.ysnRecount
, dblQtyReceived
, dblQtySold
, intEntityUserSecurityId
, SP.intSort
, ysnFetched
, dblConversionFactor = dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, 1)


, Item.strItemNo
, Item.strDescription
, strCategory = Category.strCategoryCode
, UOM.strUnitMeasure
, CountGroup.strCountGroup
, SubLocation.strSubLocationName
, UserSecurity.strUserName
, strStorageLocationName = StorageLocation.strName
, dblPhysicalCountStockUnit = dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, SP.dblPhysicalCount)
, dblVariance = (CASE WHEN CH.ysnCountByLots = 1 THEN ISNULL(SP.dblSystemCount, 0) - ISNULL(SP.dblPhysicalCount, 0)
					ELSE ISNULL(SP.dblSystemCount, 0) - dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, SP.dblPhysicalCount)
					END)
FROM tblSTCheckoutShiftPhysical SP
LEFT JOIN tblSTCheckoutHeader CH ON CH.intCheckoutId = SP.intCheckoutId
LEFT JOIN tblICItem Item ON Item.intItemId = SP.intItemId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = SP.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICCountGroup CountGroup ON CountGroup.intCountGroupId = SP.intCountGroupId
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = SP.intItemLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = SP.intCompanyLocationSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = SP.intStorageLocationId
LEFT JOIN tblSMUserSecurity UserSecurity ON UserSecurity.[intEntityId] = SP.intEntityUserSecurityId