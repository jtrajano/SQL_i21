CREATE VIEW [dbo].[vyuSTCheckoutShiftPhysical]
AS 
SELECT 
intCheckoutShiftPhysicalId
, SP.intCheckoutId
, SP.intItemId
, SP.intItemLocationId
, SP.intCountGroupId
, dblSystemCount
, dblPhysicalCount
, SP.intItemUOMId
, dblQtyReceived
, dblQtySold
, intEntityUserSecurityId
, dblConversionFactor = dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, 1)


, Item.strItemNo
, Item.strDescription
, strCategory = Category.strCategoryCode
, UOM.strUnitMeasure
, CountGroup.strCountGroup
, UserSecurity.strUserName
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
LEFT JOIN tblSMUserSecurity UserSecurity ON UserSecurity.[intEntityId] = SP.intEntityUserSecurityId