CREATE VIEW [dbo].[vyuSTCheckoutShiftPhysicalItem]
AS 
SELECT 
intCheckoutShiftPhysicalItemId
, SP.intCheckoutId
, CH.dtmCheckoutDate
, SP.intItemId
, SP.intItemLocationId
, preload.dblSystemCount AS dblSystemCount
, SP.dblPhysicalCount
, SP.intItemUOMId
, preload.dblQtyReceived
, preload.dblQtySold
, preload.dblQtyTransferred
, SP.intEntityUserSecurityId
, dblConversionFactor = dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, 1)


, Item.strItemNo
, Item.strDescription
, strCategory = Category.strCategoryCode
, UOM.strUnitMeasure
, UserSecurity.strUserName
, dblPhysicalCountStockUnit = dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, SP.dblPhysicalCount)
, dblVariance = (CASE WHEN CH.ysnCountByLots = 1 THEN ISNULL(SP.dblSystemCount, 0) - ISNULL(SP.dblPhysicalCount, 0)
					ELSE ISNULL(SP.dblSystemCount, 0) - dbo.fnICConvertUOMtoStockUnit(SP.intItemId, SP.intItemUOMId, SP.dblPhysicalCount)
					END)
, SP.intConcurrencyId
FROM tblSTCheckoutShiftPhysicalItem SP
LEFT JOIN tblSTCheckoutShiftPhysicalPreview preload 
	ON SP.intCheckoutId = preload.intCheckoutId
	AND ISNULL(SP.intItemId, 0) = ISNULL(preload.intItemId, 0)
	AND ISNULL(SP.intItemLocationId, 0) = ISNULL(preload.intItemLocationId, 0)
	AND ISNULL(SP.intItemUOMId, 0) = ISNULL(preload.intItemUOMId, 0)
LEFT JOIN tblSTCheckoutHeader CH ON CH.intCheckoutId = SP.intCheckoutId
LEFT JOIN tblICItem Item ON Item.intItemId = SP.intItemId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = SP.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = SP.intItemLocationId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMUserSecurity UserSecurity ON UserSecurity.[intEntityId] = SP.intEntityUserSecurityId