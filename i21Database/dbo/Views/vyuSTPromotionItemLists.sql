CREATE VIEW vyuSTPromotionItemLists
AS
SELECT 
intKey = CAST(ROW_NUMBER() OVER(ORDER BY adj1.intItemUOMId, adj2.intLocationId) AS INT),
adj3.strLocationName, 
adj1.strUpcCode,
adj1.strLongUPCCode,
adj1.intItemUOMId,
adj5.strItemNo,
adj5.strDescription as strPumpItemDescription,
adj6.intCategoryId,
adj6.strCategoryCode,
adj6.strDescription as categoryDesc,
adj5.ysnFuelItem,
adj4.dblSalePrice as dblPrice,
adj2.intFamilyId,
adj2.intClassId
from tblICItemUOM adj1 JOIN tblICItemLocation adj2 ON adj1.intItemId = adj2.intItemId
JOIN tblSMCompanyLocation adj3 ON adj3.intCompanyLocationId = adj2.intLocationId
JOIN tblICItemPricing adj4 on adj4.intItemLocationId = adj2.intItemLocationId
JOIN tblICItem adj5 ON adj5.intItemId = adj1.intItemId  
JOIN tblICCategory adj6 ON adj5.intCategoryId = adj6.intCategoryId
and adj5.strType = 'Inventory' and adj5.strStatus = 'Active'

