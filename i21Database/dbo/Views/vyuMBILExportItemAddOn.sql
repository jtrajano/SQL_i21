CREATE VIEW [dbo].[vyuMBILExportItemAddOn]
AS    
SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY addon.intItemAddOnId) AS INT)    
      ,addon.intItemAddOnId    
      ,addon.intItemId    
      ,item.strDescription strItemDescription    
      ,addon.intAddOnItemId    
      ,itemAddOn.strDescription stritemAddOnDescription    
      , addon.dblQuantity    
      ,addon.ysnAutoAdd     
      ,itemstock.intLocationId    
      ,itemstock.dblSalePrice    
      ,addon.dtmEffectivityDateFrom    
      ,addon.dtmEffectivityDateTo    
FROM tblICItemAddOn addon      
LEFT JOIN tblICItem item ON addon.intItemId = item.intItemId      
LEFT JOIN tblICItem itemAddOn ON addon.intAddOnItemId = itemAddOn.intItemId    
--LEFT JOIN tblICItemLocation itemlocation ON itemAddOn.intItemId = itemlocation.intItemId AND itemlocation.intLocationId IS NOT NULL       
LEFT JOIN vyuICGetItemStock itemstock ON itemAddOn.intItemId = itemstock.intItemId