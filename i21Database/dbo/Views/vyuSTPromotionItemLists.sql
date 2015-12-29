CREATE VIEW vyuSTPromotionItemLists
AS
SELECT 
adj3.strLocationName, 
adj1.strUpcCode,
adj1.strLongUPCCode,
adj1.intItemUOMId,
adj5.strDescription,
adj5.ysnFuelItem,
adj4.dblSalePrice,
adj2.intFamilyId,
adj2.intClassId
from tblICItemUOM adj1 JOIN tblICItemLocation adj2 ON adj1.intItemId = adj2.intItemId
JOIN tblSMCompanyLocation adj3 ON adj3.intCompanyLocationId = adj2.intLocationId
JOIN tblICItemPricing adj4 on adj4.intItemLocationId = adj2.intItemLocationId
JOIN tblICItem adj5 ON adj5.intItemId = adj1.intItemId 
and adj1.strUpcCode IS NOT NULL 
and adj5.strType = 'Inventory' and adj5.strStatus = 'Active'
