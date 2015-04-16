CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
Item.intItemId, 
Item.strItemNo,
Item.strType,
dbo.fnGetItemBaseGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Service Charges') AS intAccountId, 
dbo.fnGetItemBaseGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Cost of Goods') AS intCOGSAccountId, 
dbo.fnGetItemBaseGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Sales Account') AS intSalesAccountId, 
dbo.fnGetItemBaseGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Inventory') AS intInventoryAccountId
FROM         
dbo.tblICItem AS Item LEFT OUTER JOIN
dbo.tblICItemLocation AS ItemLocation ON ItemLocation.intItemId = Item.intItemId
