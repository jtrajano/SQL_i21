CREATE VIEW [dbo].[vyuARGetInventoryItem]
AS
SELECT     
Item.intItemId, 
Item.strItemNo, 
Item.strType, 
Item.strDescription, 
ItemLocation.intLocationId, 
Location.strLocationName, 
Location.strLocationType,  
ItemLocation.intIssueUOMId, 
strIssueUOM =(SELECT TOP 1 strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = ItemLocation.intIssueUOMId),
dblSalePrice = ISNULL((SELECT TOP 1 dblSalePrice FROM tblICItemPricing WHERE intItemId = Item.intItemId AND intLocationId = ItemLocation.intLocationId),0) 
FROM         tblICItem Item INNER JOIN
tblICItemLocation ItemLocation ON ItemLocation.intItemId = Item.intItemId LEFT JOIN
tblSMCompanyLocation Location ON Location.intCompanyLocationId = ItemLocation.intLocationId

