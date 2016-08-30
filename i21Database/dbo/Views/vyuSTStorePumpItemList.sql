CREATE VIEW vyuSTStorePumpItemList
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
,STPumpItem.intStorePumpItemId
,STPumpItem.intStoreId
from tblICItem ICItem
inner join tblICItemUOM ICUom on ICItem.intItemId = ICUom.intItemId
inner join tblICItemLocation ICLoc on ICUom.intItemId =  ICLoc.intItemId
inner join tblICItemPricing ICItemPricing on ICItemPricing.intItemLocationId = ICLoc.intItemLocationId
inner join tblSMCompanyLocation SMLoc on ICLoc.intLocationId = SMLoc.intCompanyLocationId
inner join tblSTStore STStore on SMLoc.intCompanyLocationId = STStore.intCompanyLocationId
inner join tblSTPumpItem STPumpItem on STStore.intStoreId = STPumpItem.intStoreId
left join tblICCategory ICCat on STPumpItem.intCategoryId = ICCat.intCategoryId
where ICItem.ysnFuelItem = 1
and ICItem.strType = 'Inventory'
and ICItem.strStatus = 'Active'
and STPumpItem.intItemUOMId =  ICUom.intItemUOMId



