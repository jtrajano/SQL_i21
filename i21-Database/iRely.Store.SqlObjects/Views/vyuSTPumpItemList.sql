CREATE VIEW vyuSTPumpItemList
AS
SELECT 
ICItem.intItemId
,ICItem.strItemNo
,ICItem.strDescription as strPumpItemDescription
,ICItem.intCategoryId
,ICCat.strCategoryCode
,ICCat.strDescription as strCategoryDescription
,ICUom.strUpcCode
,ICUom.strLongUPCCode
,ICUom.intItemUOMId
,SMLoc.intCompanyLocationId
,SMLoc.strLocationName 
,ICItem.ysnFuelItem
,ICItemPricing.dblSalePrice as dblPrice
,ICLoc.intFamilyId
,ICLoc.intClassId

from tblICItem ICItem
inner join tblICItemUOM ICUom on ICItem.intItemId = ICUom.intItemId
inner join tblICItemLocation ICLoc on ICUom.intItemId =  ICLoc.intItemId
inner join tblICItemPricing ICItemPricing on ICItemPricing.intItemLocationId = ICLoc.intItemLocationId
inner join tblSMCompanyLocation SMLoc on ICLoc.intLocationId = SMLoc.intCompanyLocationId
inner join tblSTStore STStore on SMLoc.intCompanyLocationId = STStore.intCompanyLocationId
left join tblICCategory ICCat on ICItem.intCategoryId = ICCat.intCategoryId


where ICItem.ysnFuelItem = 1
and ICItem.strType = 'Inventory'
and ICItem.strStatus = 'Active'
